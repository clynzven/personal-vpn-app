// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
import 'enroll_result.dart';

/// Everything this device keeps after enrolling: which server, its own private key,
/// and the settings the server gave it. Stored in the system's secure storage.
class EnrolledDevice {
  const EnrolledDevice({
    required this.serverHost,
    required this.serverPort,
    required this.fingerprint,
    required this.privateKey,
    required this.result,
  });

  final String serverHost;
  final int serverPort;
  final String fingerprint;

  /// Made on this device and never sent anywhere.
  final String privateKey;
  final EnrollResult result;

  // TODO 5: turn the settings into a WireGuard config file
  // Follow along in the video, then run: flutter test
  String toWgQuickConfig() => throw UnimplementedError('TODO 5: build the WireGuard config');

  factory EnrolledDevice.fromJson(Map<String, dynamic> json) => EnrolledDevice(
    serverHost: json['server_host'] as String,
    serverPort: json['server_port'] as int,
    fingerprint: json['fingerprint'] as String,
    privateKey: json['private_key'] as String,
    result: EnrollResult.fromJson(json['result'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'server_host': serverHost,
    'server_port': serverPort,
    'fingerprint': fingerprint,
    'private_key': privateKey,
    'result': result.toJson(),
  };
}
