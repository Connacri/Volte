import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/p2p/p2p_node.dart';

class NetworkProvider extends ChangeNotifier {
  final P2PNode node;
  StreamSubscription<void>? _sub;

  NetworkProvider(this.node) {
    _sub = node.networkChanges.listen((_) => notifyListeners());
  }

  /// "Connecté" = joint au serveur de signaling (peut découvrir/accepter
  /// des pairs) OU déjà en relation avec au moins un pair (le mesh peut
  /// survivre temporairement à une coupure du signaling).
  /// health.isAlive(node.nodeId) ne doit plus être utilisé ici : il ne
  /// mesure que "mon propre Timer local tourne", donc toujours vrai.
  bool get isConnected => node.isSignalingConnected || peers.isNotEmpty;

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