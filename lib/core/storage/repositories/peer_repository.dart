import '../entities/peer_entity.dart';

class PeerRepository {
  final List<PeerEntity> _cache = [];

  void upsert(PeerEntity peer) {
    _cache.removeWhere((p) => p.peerId == peer.peerId);
    _cache.add(peer);
  }

  List<PeerEntity> getAll() {
    return List.unmodifiable(_cache);
  }

  PeerEntity? findById(String peerId) {
    try {
      return _cache.firstWhere((p) => p.peerId == peerId);
    } catch (_) {
      return null;
    }
  }

  void delete(String peerId) {
    _cache.removeWhere((p) => p.peerId == peerId);
  }
}
