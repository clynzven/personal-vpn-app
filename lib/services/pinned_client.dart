import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// An HTTPS client that trusts exactly one certificate: the one whose SHA-256
/// fingerprint came inside the enrollment code ("certificate pinning").
///
/// The server's certificate is self-signed, so no certificate authority vouches
/// for it. Instead we compare its fingerprint with the one from the code: a fake
/// server in the middle (for example on café Wi-Fi) cannot match it.
http.Client pinnedClient(String sha256Hex) {
  // No trusted roots: every certificate goes through our check below.
  final context = SecurityContext(withTrustedRoots: false);
  final client = HttpClient(context: context)
    ..connectionTimeout = const Duration(seconds: 10)
    ..badCertificateCallback = (cert, host, port) =>
        fingerprintOf(cert.der) == sha256Hex.toLowerCase();
  return IOClient(client);
}

String fingerprintOf(List<int> der) => sha256.convert(der).toString();
