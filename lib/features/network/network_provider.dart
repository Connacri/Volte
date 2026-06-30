import 'package:flutter/material.dart';
import '../../core/p2p/p2p_node.dart';

class NetworkProvider extends ChangeNotifier {
  final P2PNode node;

  NetworkProvider(this.node);

  bool get isConnected => node.health.isAlive(node.nodeId);

  Future<void> init() async {
    await node.start();
    notifyListeners();
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
