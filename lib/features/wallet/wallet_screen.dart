import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wallet_provider.dart';
import 'send_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<void> _createWallet(BuildContext context) async {
    final provider = context.read<WalletProvider>();
    final wallet = await provider.createWallet();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet créé : ${wallet.address}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createWallet(context),
        icon: const Icon(Icons.add),
        label: const Text("Créer un wallet"),
      ),
      body: ListView(
        children: [
          if (provider.wallets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "Aucun wallet pour l'instant.\nAppuie sur \"Créer un wallet\" pour commencer.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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