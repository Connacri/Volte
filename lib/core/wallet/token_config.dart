import 'genesis.dart';

class TokenConfig {
  TokenConfig._();

  static const String name = "NovaCoin";
  static const String symbol = "NOVA";

  /// Sourced from Genesis (single source of truth).
  static BigInt get maxSupply => Genesis.maxSupply;

  static BigInt circulating = BigInt.zero;

  static const int decimals = 18;
}
