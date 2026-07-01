import 'package:flutter/material.dart';
import '../../core/dag/dag_engine.dart';
import '../../core/dag/transaction_model.dart';
import '../../core/p2p/p2p_node.dart';

class LedgerProvider extends ChangeNotifier {
  final P2PNode node;

  LedgerProvider(this.node) {
    // Le DagEngine du node notifie déjà `sync.push(tx)` à chaque commit ;
    // on se branche dessus en plus pour rafraîchir l'UI Ledger en temps réel,
    // que la tx vienne du réseau ou d'un envoi wallet local.
    final previousOnCommit = dag.onCommit;
    dag.onCommit = (tx) {
      previousOnCommit?.call(tx);
      notifyListeners();
    };
  }

  DagEngine get dag => node.dag;

  void addTx(Transaction tx) {
    dag.add(tx);
  }

  List<Transaction> get transactions => dag.all();
}