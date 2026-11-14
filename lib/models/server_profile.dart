// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
/// The server details inside an enrollment code like:
/// pvpn://enroll?host=203.0.113.10&port=443&token=abc...&fp=0ac5...
class ServerProfile {
  const ServerProfile({
    required this.host,
    required this.port,
    required this.token,
    required this.fingerprint,
  });

  /// Public IP address or domain name of the server.
  final String host;

  /// Port of the HTTPS enrollment API.
  final int port;

  /// The one-time code. It works once and expires after 10 minutes.
  final String token;

  /// SHA-256 of the server's certificate. We only trust a server with this exact certificate.
  final String fingerprint;

  // TODO 3: read an enrollment code into a ServerProfile
  // Follow along in the video, then run: flutter test
  factory ServerProfile.fromEnrollmentCode(String code) =>
      throw UnimplementedError('TODO 3: read the enrollment code');

  /// Where the enrollment API lives.
  Uri get enrollUrl => Uri(scheme: 'https', host: host, port: port, path: '/api/enroll');
}
