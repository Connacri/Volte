import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/bootstrap/bootstrap_service.dart';
import 'network_provider.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final net = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("P2P Network")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => net.init(),
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Node"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final seeds = BootstrapService.getSeeds();
                for (final seed in seeds) {
                  net.connectPeer(seed);
                }
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text("Connect to Seed Nodes"),
            ),
            const SizedBox(height: 16),
            const Text("Connected Peers:"),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: net.peers.length,
                itemBuilder: (context, index) {
                  final peerId = net.peers[index];
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: net.isConnected ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    title: Text(peerId),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
