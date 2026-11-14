// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/enroll_result.dart';
import '../models/enrolled_device.dart';
import '../models/server_profile.dart';
import 'key_pair.dart';
import 'pinned_client.dart';

/// A problem the person can understand and act on.
class EnrollmentException implements Exception {
  const EnrollmentException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Adds this device to a server with a one-time code.
class EnrollmentService {
  EnrollmentService({
    http.Client Function(String fingerprint)? clientFor,
    Future<WgKeyPair> Function()? newKeyPair,
  }) : _clientFor = clientFor ?? pinnedClient,
       _newKeyPair = newKeyPair ?? generateKeyPair;

  final http.Client Function(String fingerprint) _clientFor;
  final Future<WgKeyPair> Function() _newKeyPair;

  // TODO 4: make keys on this device and enroll with the server
  // Follow along in the video, then run: flutter test
  Future<EnrolledDevice> enroll(ServerProfile server) =>
      throw UnimplementedError('TODO 4: enroll with the server');

  static String _messageFor(int status) => switch (status) {
    400 => 'The server did not accept this device\'s key.',
    401 => 'This code is invalid, expired or already used. Ask for a new one.',
    409 => 'This device is already enrolled.',
    429 => 'Too many tries. Wait a minute and try again.',
    503 => 'The VPN is full. Remove a device on the dashboard first.',
    _ => 'The server answered with an error ($status).',
  };
}
