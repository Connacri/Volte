import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/bootstrap/bootstrap_service.dart';
import 'network_provider.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final net = Provider.of<NetworkProvider>(context);
    final seeds = BootstrapService.getSeeds();

    return Scaffold(
      appBar: AppBar(title: const Text("Réseau")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 16,
                      color: net.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      net.isConnected ? "Connecté" : "Déconnecté",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: net.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    const Spacer(),
                    Text("${net.peers.length} pair(s)"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Serveur signaling : ${seeds.isNotEmpty ? seeds.first : 'aucun'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text("Pairs connectés :"),
            const SizedBox(height: 8),
            Expanded(
              child: net.peers.isEmpty
                  ? const Center(
                      child: Text("Aucun pair pour le moment"),
                    )
                  : ListView.builder(
                      itemCount: net.peers.length,
                      itemBuilder: (context, index) {
                        final peerId = net.peers[index];
                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.green),
                          title: Text(peerId),
                          subtitle: const Text("Connecté"),
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
