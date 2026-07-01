import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/p2p/p2p_node.dart';

class NetworkProvider extends ChangeNotifier {
  final P2PNode node;
  StreamSubscription<void>? _sub;

  NetworkProvider(this.node) {
    _sub = node.networkChanges.listen((_) => notifyListeners());
  }

  bool get isConnected => node.health.isAlive(node.nodeId);

  /// NB: ne PAS appeler node.start() ici sans signalingUrl — ça régénère
  /// une paire de clés Ed25519. Le démarrage réel se fait dans
  /// app.dart::_bootstrap() avec l'URL de signaling.
  void init() {
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> connectPeer(String address) async {
    await node.connectPeer(address);
    notifyListeners();
  }

  void broadcast(Map<String, dynamic> msg) {
    node.broadcastTx(msg);
  }

  List<String> get peers => node.p2p.peers.keys.toList();

  Future<void> stop() async {
    await node.stop();
    notifyListeners();
  }
}