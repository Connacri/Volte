import '../../wallet/wallet_core.dart';
import '../../wallet/wallet_model.dart';

class WalletRepository {
  final List<Wallet> _cache = [];

  void save(Wallet w) {
    _cache.add(w);
  }

  List<Wallet> all() => List.unmodifiable(_cache);

  void syncFromCore(WalletCore core) {
    _cache.clear();
    _cache.addAll(core.all());
  }
}
