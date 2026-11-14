import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/device_status.dart';

/// Asks the server how this device looks from its side: online, data in and out.
/// The request travels inside the tunnel, so it only works while connected.
class StatusService {
  StatusService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<DeviceStatus?> fetch(Uri statusUrl) async {
    try {
      final response = await _client.get(statusUrl).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return null;
      return DeviceStatus.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on Object {
      return null; // Not reachable (yet): the tunnel may still be starting.
    }
  }
}
