import '../wallet/genesis.dart';

class AppConstants {
  AppConstants._();

  // Network
  static const int maxPeers = 50;
  static const int gossipTtl = 32;
  static const Duration peerTimeout = Duration(seconds: 30);

  // DAG / Ledger
  static const int maxTxPerBlockEquivalent = 1000;
  static const int confirmationThreshold = 3;

  // Token — sourced from Genesis (single source of truth)
  static BigInt get maxSupply => Genesis.maxSupply;

  // Security
  static const int reputationTrustThreshold = 20;
  static const int sybilRiskThreshold = 70;

  // Crypto
  static const String curve = "ed25519";
}