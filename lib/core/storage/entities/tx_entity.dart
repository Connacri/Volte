class TxEntity {
  final String txId;
  final String from;
  final String to;
  final String amount;
  final int timestamp;

  TxEntity({
    required this.txId,
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
  });
}
