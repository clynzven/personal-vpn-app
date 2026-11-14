import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// A WireGuard key pair, both halves in base64 like `wg genkey` / `wg pubkey`.
class WgKeyPair {
  const WgKeyPair({required this.privateKey, required this.publicKey});
  final String privateKey;
  final String publicKey;
}

/// Makes a new key pair on this device (Curve25519, the curve WireGuard uses).
Future<WgKeyPair> generateKeyPair() async {
  final pair = await X25519().newKeyPair();
  final privateBytes = await pair.extractPrivateKeyBytes();
  final publicKey = await pair.extractPublicKey();
  return WgKeyPair(
    privateKey: base64.encode(privateBytes),
    publicKey: base64.encode(publicKey.bytes),
  );
}

/// The public key that belongs to a base64 private key (same as `wg pubkey`).
Future<String> publicKeyFor(String privateKey) async {
  final pair = await X25519().newKeyPairFromSeed(base64.decode(privateKey));
  final publicKey = await pair.extractPublicKey();
  return base64.encode(publicKey.bytes);
}
