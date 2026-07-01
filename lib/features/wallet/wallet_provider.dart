import 'package:flutter/foundation.dart';

import '../../core/crypto/signature.dart';
import '../../core/dag/transaction_model.dart';
import '../../core/p2p/p2p_node.dart';
import '../../core/utils/id_generator.dart';
import '../../core/wallet/address_generator.dart';
import '../../core/wallet/wallet_core.dart';
import '../../core/wallet/wallet_model.dart';
import '../../core/storage/repositories/wallet_repository.dart';

class WalletProvider extends ChangeNotifier {
  final WalletCore core;
  final WalletRepository repo;
  final P2PNode? node;
  final CryptoService _crypto = CryptoService();

  WalletProvider(this.core, this.repo, {this.node}) {
    _restoreFromRepo();
  }

  /// Recharge les wallets déjà connus du repository (survit aux rebuilds /
  /// changements d'écran dans la même session). NB: `WalletRepository` est
  /// aujourd'hui un cache en mémoire, donc ceci ne survit PAS à un vrai
  /// redémarrage de l'app — pour ça il faudra brancher un stockage
  /// persistant (ObjectBox déjà présent dans les dépendances de l'app mais
  /// pas encore câblé : pas d'annotations @Entity ni de code généré via
  /// build_runner, ou plus simple : shared_preferences en JSON).
  void _restoreFromRepo() {
    for (final w in repo.all()) {
      core.restore(w);
    }
  }

  List<Wallet> get wallets => core.all();

  Future<Wallet> createWallet() async {
    final keyPair = await _crypto.generateKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final pubKeyHex = _bytesToHex(publicKey.bytes);
    final address = AddressGenerator.generate(pubKeyHex);

    final wallet = core.create(address, pubKeyHex);
    repo.save(wallet);
    notifyListeners();

    // NOTE: la clé privée du KeyPair n'est volontairement pas conservée ici.
    // Un vrai wallet doit stocker sa clé privée dans un coffre sécurisé
    // (flutter_secure_storage / keystore Android) avant qu'on puisse signer
    // les transactions. Tant que ce n'est pas fait, `signature` reste vide
    // dans les tx émises par send() ci-dessous.
    return wallet;
  }

  void send({
    required String from,
    required String to,
    required BigInt amount,
  }) {
    final ok = core.transfer(from, to, amount);
    if (!ok) return;

    repo.syncFromCore(core);

    final tx = Transaction(
      id: IdGenerator.generateId("tx"),
      from: from,
      to: to,
      amount: amount,
      approvals: const [],
      timestamp: DateTime.now().millisecondsSinceEpoch,
      signature: "", // TODO: signer avec la clé privée du wallet une fois le stockage sécurisé en place
    );

    // Commit local + diffusion aux pairs WebRTC connectés.
    node?.broadcastTx(tx.toJson());

    notifyListeners();
  }

  void load() {
    notifyListeners();
  }

  String _bytesToHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}