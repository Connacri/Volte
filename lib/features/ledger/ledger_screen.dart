import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/tx_tile.dart';
import 'ledger_provider.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LedgerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Ledger")),
      body: provider.transactions.isEmpty
          ? const Center(child: Text("No transactions yet"))
          : ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions[index];
                return TxTile(
                  from: tx.from,
                  to: tx.to,
                  amount: tx.amount.toString(),
                  isFinal: provider.isFinal(tx.id),
                  confirmations: provider.confirmationsOf(tx.id),
                );
              },
            ),
    );
  }
}