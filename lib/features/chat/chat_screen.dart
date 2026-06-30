import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scrollCtrl = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void send() {
    final text = controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().send(text);
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final peers = provider.onlinePeers;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          if (peers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Offline", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text("${peers.length} en ligne",
                      style: const TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (peers.isEmpty)
            Container(
              width: double.infinity,
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "Aucun pair connecté. Ouvre l'onglet Network pour démarrer.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            Container(
              width: double.infinity,
              color: Colors.green.shade900.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                "🟢 Connecté à ${peers.length} pair${peers.length > 1 ? 's' : ''}",
                style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
              ),
            ),
          Expanded(
            child: provider.messages.isEmpty
                ? const Center(child: Text("Aucun message. Envoie le premier !"))
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];
                      final isMine = msg["from"] == provider.myId;
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMine
                                ? Colors.purple.shade800
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMine ? "Moi" : msg["from"].toString().substring(0, 12),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Text(msg["text"] ?? ""),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Écris un message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
