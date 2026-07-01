import 'wallet_model.dart';

class WalletCore {
  final Map<String, Wallet> _wallets = {};

  Wallet create(String address, String pubKey) {
    // Pour la démo, on donne 1000 NOVA à chaque nouveau wallet
    final wallet = Wallet(
      address: address,
      publicKey: pubKey,
      balance: BigInt.from(1000) * BigInt.from(10).pow(18),
    );

    _wallets[address] = wallet;
    return wallet;
  }

  void restore(Wallet wallet) {
    _wallets[wallet.address] = wallet;
  }

  Wallet? get(String address) => _wallets[address];

  List<Wallet> all() => _wallets.values.toList();

  bool transfer(String from, String to, BigInt amount) {
    final sender = _wallets[from];
    if (sender == null) return false;
    if (sender.balance < amount) return false;

    sender.debit(amount);

    final receiver = _wallets[to];
    if (receiver != null) {
      receiver.credit(amount);
    }

    return true;
  }

  BigInt balanceOf(String address) {
    return _wallets[address]?.balance ?? BigInt.zero;
  }
}
