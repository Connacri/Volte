import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wallet_provider.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final toCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  @override
  void dispose() {
    toCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final to = toCtrl.text.trim();
    final amountStr = amountCtrl.text.trim();
    if (to.isEmpty || amountStr.isEmpty) return;

    final amount = BigInt.tryParse(amountStr);
    if (amount == null || amount <= BigInt.zero) return;

    final provider = context.read<WalletProvider>();
    final wallets = provider.wallets;
    if (wallets.isEmpty) return;

    provider.send(
      from: wallets.first.address,
      to: to,
      amount: amount,
    );

    toCtrl.clear();
    amountCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction sent")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: toCtrl,
            decoration: const InputDecoration(
              labelText: "Recipient address",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(
              labelText: "Amount (wei)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _send,
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
