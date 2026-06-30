import 'package:flutter/material.dart';
import '../../core/dag/dag_engine.dart';
import '../../core/dag/transaction_model.dart';

class LedgerProvider extends ChangeNotifier {
  final DagEngine dag = DagEngine();

  void addTx(Transaction tx) {
    dag.add(tx);
    notifyListeners();
  }

  List<Transaction> get transactions => dag.all();
}
