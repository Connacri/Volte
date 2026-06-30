import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wallet_provider.dart';
import 'send_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      body: ListView(
        children: [
          ...provider.wallets.map(
            (w) => ListTile(
              title: Text(w.address),
              subtitle: Text("Balance: ${w.balance}"),
              trailing: const Icon(Icons.account_balance_wallet),
            ),
          ),
          const Divider(),
          const SendScreen(),
        ],
      ),
    );
  }
}
