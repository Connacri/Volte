import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class CryptoHash {
  static String sha256(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }
}
