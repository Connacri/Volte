import 'package:cryptography/cryptography.dart';
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
    _init();
  }

  Future<void> _init() async {
    await repo.load();
    _restoreFromRepo();
    notifyListeners();
  }

  void _restoreFromRepo() {
    for (final w in repo.all()) {
      core.restore(w);
    }
  }

  List<Wallet> get wallets => core.all();

  Future<Wallet> createWallet() async {
    final keyPair = await _crypto.generateKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final pubKeyHex = _bytesToHex((publicKey as SimplePublicKey).bytes);
    final address = AddressGenerator.generate(pubKeyHex);

    final wallet = core.create(address, pubKeyHex);
    await repo.save(wallet);
    notifyListeners();

    return wallet;
  }

  Future<void> send({
    required String from,
    required String to,
    required BigInt amount,
  }) async {
    final ok = core.transfer(from, to, amount);
    if (!ok) return;

    await repo.syncFromCore(core);

    final tx = Transaction(
      id: IdGenerator.generateId("tx"),
      from: from,
      to: to,
      amount: amount,
      approvals: const [],
      timestamp: DateTime.now().millisecondsSinceEpoch,
      signature: "",
    );

    node?.broadcastTx(tx.toJson());

    notifyListeners();
  }

  void load() {
    notifyListeners();
  }

  String _bytesToHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
