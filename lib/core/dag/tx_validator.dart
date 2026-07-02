import 'transaction_model.dart';
import '../wallet/address_generator.dart';

/// Validation STRUCTURELLE d'une transaction (synchrone, pas de crypto
/// asynchrone ici). La vérification de signature elle-même (qui nécessite
/// Ed25519, asynchrone) se fait séparément — voir P2PNode._verifySignature.
class TxValidator {
  bool validate(Transaction tx) {
    if (tx.amount <= BigInt.zero) return false;
    if (tx.from.isEmpty || tx.to.isEmpty) return false;
    if (tx.from == tx.to) return false;
    if (tx.signature.isEmpty) return false;
    if (tx.senderPublicKey.isEmpty) return false;
    if (tx.nonce < 0) return false;

    // L'adresse déclarée doit être dérivable de la clé publique fournie —
    // sinon n'importe qui pourrait prétendre envoyer depuis l'adresse d'un
    // autre sans en détenir la clé privée.
    if (AddressGenerator.generate(tx.senderPublicKey) != tx.from) return false;

    return true;
  }
}