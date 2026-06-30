import '../crypto/signature.dart';

class SignatureService {
  final CryptoService _crypto = CryptoService();

  CryptoService get crypto => _crypto;
}
