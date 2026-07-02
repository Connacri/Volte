import 'dart:async';
import 'dart:convert';

import '../crypto/signature.dart';
import '../gossip/gossip_engine.dart';
import '../dag/dag_engine.dart';
import '../sync/sync_engine.dart';
import '../consensus/consensus_engine.dart';
import '../consensus/reputation_score.dart';
import '../wallet/wallet_core.dart';
import '../network/network_health.dart';
import '../utils/logger.dart';
import 'peer_model.dart';
import 'webrtc_engine.dart';
import 'signaling_client.dart';
import 'peer_manager.dart';

class P2PNode {
  final String nodeId;
  late final CryptoService crypto;
  late final WebRTCNetworkEngine p2p;
  late final GossipEngine gossip;
  late final DagEngine dag;
  late final SyncEngine sync;
  late final ConsensusEngine consensus;
  late final WalletCore wallet;
  late final NetworkHealth health;
  late final PeerManager peerManager;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  final StreamController<void> _networkChangeController =
      StreamController<void>.broadcast();

  Stream<void> get networkChanges => _networkChangeController.stream;

  final StreamController<void> _walletChangeController =
      StreamController<void>.broadcast();

  /// Émet un événement chaque fois que MON wallet local est crédité par
  /// une transaction reçue du réseau (donc jamais pour un solde qui ne
  /// m'appartient pas).
  Stream<void> get walletChanges => _walletChangeController.stream;

  SignalingClient? _signaling;
  Timer? _healthTimer;

  bool isSignalingConnected = false;

  P2PNode(this.nodeId) {
    crypto = CryptoService();
    p2p = WebRTCNetworkEngine();
    gossip = GossipEngine();
    dag = DagEngine();
    sync = SyncEngine();
    consensus = ConsensusEngine(ReputationScore());
    wallet = WalletCore();
    health = NetworkHealth();
    peerManager = PeerManager(engine: p2p);

    _wire();
  }

  void _wire() {
    p2p.onMessage = (from, msg) {
      try {
        final data = jsonDecode(msg);
        _messageController.add({"from": from, "data": data});

        if (data is Map && data["type"] == "tx") {
          final txMap = Map<String, dynamic>.from(data);
          dag.addFromNetwork(txMap);

          // Crédit réel côté récepteur : seulement si l'adresse "to" est
          // un wallet que JE possède localement (creditIfLocal renvoie
          // false sinon). C'est ce qui rend le solde reçu réel, plutôt
          // que juste une entrée de journal sans effet.
          final to = txMap["to"] as String?;
          final amountStr = txMap["amount"] as String?;
          if (to != null && amountStr != null) {
            final amount = BigInt.tryParse(amountStr);
            if (amount != null) {
              final credited = wallet.creditIfLocal(to, amount);
              if (credited && !_walletChangeController.isClosed) {
                _walletChangeController.add(null);
              }
            }
          }
        }
      } catch (e) {
        Logger.error("Failed to process message from $from: $e");
      }
    };

    dag.onCommit = (tx) {
      sync.push(tx);
    };

    p2p.onPeerConnected = (peerId) {
      health.ping(peerId);
      if (!_networkChangeController.isClosed) _networkChangeController.add(null);
    };

    p2p.onPeerDisconnected = (peerId) {
      if (!_networkChangeController.isClosed) _networkChangeController.add(null);
    };

    p2p.onIceCandidate = (peerId, candidate) {
      _signaling?.send({
        "type": "ice",
        "to": peerId,
        "from": nodeId,
        "candidate": candidate,
      });
    };
  }

  Future<void> start({String? signalingUrl}) async {
    Logger.info("Starting P2P node: $nodeId");

    await crypto.generateKeyPair();
    Logger.info("Node identity generated");

    if (signalingUrl != null) {
      _signaling = SignalingClient(signalingUrl);
      _signaling!.onConnect = () {
        isSignalingConnected = true;
        _signaling!.send({"type": "register", "id": nodeId});
        Logger.info("Registered on signaling server");
        if (!_networkChangeController.isClosed) _networkChangeController.add(null);
      };
      _signaling!.onDisconnect = () {
        isSignalingConnected = false;
        if (!_networkChangeController.isClosed) _networkChangeController.add(null);
      };
      _signaling!.onMessage = (msg) {
        health.ping(nodeId);
        _handleSignal(msg);
      };
    }

    health.ping(nodeId);
    if (!_networkChangeController.isClosed) _networkChangeController.add(null);

    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      health.ping(nodeId);
      if (!_networkChangeController.isClosed) _networkChangeController.add(null);
    });
  }

  void _handleSignal(Map<String, dynamic> msg) {
    final type = msg["type"] as String?;
    if (type == null) return;

    switch (type) {
      case "peer_offer":
        final peerId = msg["from"] as String;
        final sdp = msg["sdp"];
        _handleOffer(peerId, sdp);
        break;
      case "peer_answer":
        final peerId = msg["from"] as String;
        final sdp = msg["sdp"];
        _handleAnswer(peerId, sdp);
        break;
      case "peer_ice":
        final peerId = msg["from"] as String;
        final candidate = msg["candidate"];
        _handleIce(peerId, candidate);
        break;
      case "peer_list":
        final peers = List<String>.from(msg["peers"] ?? []);
        for (final pid in peers) {
          if (pid != nodeId && !p2p.peers.containsKey(pid)) {
            connectToPeer(pid);
          }
        }
        break;
    }
  }

  Future<void> _handleOffer(String peerId, dynamic sdp) async {
    final answer = await p2p.acceptConnection(peerId, sdp);
    if (answer != null && _signaling != null) {
      _signaling!.send({
        "type": "answer",
        "to": peerId,
        "from": nodeId,
        "sdp": answer,
      });
    }
    peerManager.registerPeer(Peer(id: peerId, address: "", lastSeen: DateTime.now()));
    health.ping(peerId);
  }

  Future<void> _handleAnswer(String peerId, dynamic sdp) async {
    await p2p.handleAnswer(peerId, sdp);
    health.ping(peerId);
  }

  Future<void> _handleIce(String peerId, dynamic candidate) async {
    await p2p.handleIce(peerId, candidate);
  }

  Future<void> connectToPeer(String peerId) async {
    final offer = await p2p.createOffer(peerId);
    if (offer != null && _signaling != null) {
      _signaling!.send({
        "type": "offer",
        "to": peerId,
        "from": nodeId,
        "sdp": offer,
      });
      peerManager.registerPeer(Peer(id: peerId, address: "", lastSeen: DateTime.now()));
    }
  }

  /// Connexion à un pair à partir de son ID (collé manuellement ou lu via
  /// QR code). C'est le point d'entrée utilisé par l'UI "Ajouter un pair".
  Future<void> connectPeer(String addr) async {
    final peerId = addr.trim();
    if (peerId.isEmpty || peerId == nodeId) return;
    if (p2p.peers.containsKey(peerId)) return; // déjà connecté
    if (_signaling == null || !isSignalingConnected) {
      throw StateError(
        "Non connecté au serveur de signaling — impossible d'ajouter un pair pour l'instant.",
      );
    }
    await connectToPeer(peerId);
  }

  void broadcastTx(Map<String, dynamic> txData) {
    dag.addFromNetwork(txData);
    p2p.broadcast({"type": "tx", ...txData});
  }

  void sendChat(String text) {
    p2p.broadcast({
      "type": "chat",
      "from": nodeId,
      "text": text,
      "time": DateTime.now().toIso8601String(),
    });
  }

  Future<void> stop() async {
    _healthTimer?.cancel();
    await p2p.dispose();
    _signaling?.close();
    await _messageController.close();
    await _networkChangeController.close();
    await _walletChangeController.close();
    Logger.info("P2P node $nodeId stopped");
  }
}