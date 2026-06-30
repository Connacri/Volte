import '../entities/tx_entity.dart';

class TxRepository {
  final List<TxEntity> _cache = [];

  void save(TxEntity tx) {
    _cache.add(tx);
  }

  List<TxEntity> getAll() {
    return List.unmodifiable(_cache);
  }
}
