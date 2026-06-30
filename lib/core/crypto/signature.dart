import 'package:cryptography/cryptography.dart';

class CryptoService {
  final Ed25519 _ed25519 = Ed25519();

  Future<KeyPair> generateKeyPair() {
    return _ed25519.newKeyPair();
  }

  Future<Signature> sign(List<int> message, {required KeyPair keyPair}) {
    return _ed25519.sign(message, keyPair: keyPair);
  }

  Future<Signature> signString(String message, {required KeyPair keyPair}) {
    return _ed25519.signString(message, keyPair: keyPair);
  }

  Future<bool> verify(List<int> message, {required Signature signature}) {
    return _ed25519.verify(message, signature: signature);
  }

  Future<bool> verifyString(String message, {required Signature signature}) {
    return _ed25519.verifyString(message, signature: signature);
  }
}
