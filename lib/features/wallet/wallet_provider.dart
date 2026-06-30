import 'package:flutter/foundation.dart';

import '../../core/wallet/wallet_core.dart';
import '../../core/wallet/wallet_model.dart';
import '../../core/storage/repositories/wallet_repository.dart';

class WalletProvider extends ChangeNotifier {
  final WalletCore core;
  final WalletRepository repo;

  WalletProvider(this.core, this.repo);

  List<Wallet> get wallets => core.all();

  void createWallet(String address, String pubKey) {
    core.create(address, pubKey);
    notifyListeners();
  }

  void send({
    required String from,
    required String to,
    required BigInt amount,
  }) {
    final ok = core.transfer(from, to, amount);
    if (ok) {
      repo.syncFromCore(core);
      notifyListeners();
    }
  }

  void load() {
    notifyListeners();
  }
}
