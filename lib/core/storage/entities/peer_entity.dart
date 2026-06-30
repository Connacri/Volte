class PeerEntity {
  final String peerId;
  final String address;
  final bool trusted;
  final int lastSeen;

  PeerEntity({
    required this.peerId,
    required this.address,
    this.trusted = false,
    required this.lastSeen,
  });
}
