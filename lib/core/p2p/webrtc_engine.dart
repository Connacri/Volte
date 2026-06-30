import 'dart:convert';
import 'peer_connection.dart';
import 'peer_model.dart';

class WebRTCNetworkEngine {
  final Map<String, PeerConnection> _connections = {};
  final Map<String, Peer> peers = {};
  final Map<String, dynamic> _pendingOffers = {};

  Function(String from, String msg)? onMessage;

  Future<void> connectPeer(Peer peer) async {
    final conn = PeerConnection();
    await conn.init();

    conn.onMessage = (msg) {
      onMessage?.call(peer.id, msg);
    };

    await conn.createChannel();
    _connections[peer.id] = conn;
    peers[peer.id] = peer;
  }

  Future<Map<String, dynamic>?> createOffer(String peerId) async {
    final conn = PeerConnection();
    await conn.init();

    conn.onMessage = (msg) {
      onMessage?.call(peerId, msg);
    };

    final offer = await conn.createOffer();
    _connections[peerId] = conn;
    _pendingOffers[peerId] = conn;
    return offer;
  }

  Future<void> handleAnswer(String peerId, dynamic sdp) async {
    final conn = _connections[peerId];
    if (conn == null) return;
    await conn.setRemoteDescription(sdp);
  }

  Future<PeerConnection> acceptConnection(String peerId, dynamic sdp) async {
    final conn = PeerConnection();
    await conn.init();

    conn.onMessage = (msg) {
      onMessage?.call(peerId, msg);
    };

    await conn.setRemoteDescription(sdp);
    await conn.createAnswer();
    _connections[peerId] = conn;
    peers[peerId] = Peer(id: peerId, address: "", lastSeen: DateTime.now());
    return conn;
  }

  Future<void> handleIce(String peerId, dynamic candidate) async {
    final conn = _connections[peerId];
    if (conn == null) return;
    await conn.addIceCandidate(candidate);
  }

  void sendToPeer(String peerId, Map<String, dynamic> data) {
    final conn = _connections[peerId];
    if (conn == null) return;
    conn.send(jsonEncode(data));
  }

  void broadcast(Map<String, dynamic> data) {
    final encoded = jsonEncode(data);
    for (final conn in _connections.values) {
      conn.send(encoded);
    }
  }

  void removePeer(String peerId) {
    _connections[peerId]?.close();
    _connections.remove(peerId);
    peers.remove(peerId);
  }

  Future<void> dispose() async {
    for (final conn in _connections.values) {
      await conn.close();
    }
    _connections.clear();
    peers.clear();
  }
}
