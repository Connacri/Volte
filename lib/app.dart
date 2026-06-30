import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/wallet/wallet_provider.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/chat_provider.dart';
import 'features/ledger/ledger_provider.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/network/network_provider.dart';

import 'core/wallet/wallet_core.dart';
import 'core/storage/repositories/wallet_repository.dart';
import 'core/p2p/p2p_node.dart';

class VolteApp extends StatelessWidget {
  const VolteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final walletCore = WalletCore();
    final node = P2PNode("node-${DateTime.now().millisecondsSinceEpoch}");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WalletProvider(walletCore, WalletRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(node),
        ),
        ChangeNotifierProvider(
          create: (_) => LedgerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NetworkProvider(node),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Volte",
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF6C5CE7),
          useMaterial3: true,
        ),
        home: const Root(),
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int index = 0;

  final screens = const [
    WalletScreen(),
    ChatScreen(),
    LedgerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wallet), label: "Wallet"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
          NavigationDestination(icon: Icon(Icons.book), label: "Ledger"),
        ],
      ),
    );
  }
}
