import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/enrolled_device.dart';

/// Where the enrolled device (including its private key) is kept.
abstract class DeviceStore {
  Future<EnrolledDevice?> load();
  Future<void> save(EnrolledDevice device);
  Future<void> clear();
}

/// Uses the operating system's secure storage: Keychain on Apple devices,
/// Keystore on Android, Credential Manager on Windows, libsecret on Linux.
class SecureDeviceStore implements DeviceStore {
  SecureDeviceStore()
    : _storage = const FlutterSecureStorage(
        // The classic macOS keychain works without extra signing setup.
        mOptions: MacOsOptions(usesDataProtectionKeychain: false),
      );

  final FlutterSecureStorage _storage;
  static const _key = 'enrolled_device';

  @override
  Future<EnrolledDevice?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return EnrolledDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Unreadable data from an older version: start fresh rather than crash.
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(EnrolledDevice device) =>
      _storage.write(key: _key, value: jsonEncode(device.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Keeps everything in memory. Used by tests.
class MemoryDeviceStore implements DeviceStore {
  EnrolledDevice? device;

  @override
  Future<EnrolledDevice?> load() async => device;

  @override
  Future<void> save(EnrolledDevice value) async => device = value;

  @override
  Future<void> clear() async => device = null;
}
