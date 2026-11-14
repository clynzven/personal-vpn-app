// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'models/device_status.dart';
import 'models/enrolled_device.dart';
import 'models/server_profile.dart';
import 'services/device_store.dart';
import 'services/enrollment_service.dart';
import 'services/status_service.dart';
import 'tunnel/tunnel_engine.dart';

/// The app's state in one place. Screens listen to it and rebuild when it changes.
class VpnController extends ChangeNotifier {
  VpnController({
    required this.engine,
    required this.store,
    EnrollmentService? enrollment,
    StatusService? statusService,
    this.pollEvery = const Duration(seconds: 3),
  }) : _enrollment = enrollment ?? EnrollmentService(),
       _statusService = statusService ?? StatusService();

  final TunnelEngine engine;
  final DeviceStore store;
  final EnrollmentService _enrollment;
  final StatusService _statusService;
  final Duration pollEvery;

  EnrolledDevice? device;
  DeviceStatus? live;
  bool busy = false;
  bool loaded = false;
  String? error;

  StreamSubscription<TunnelStatus>? _sub;
  Timer? _poller;

  TunnelStatus get status => engine.current;
  bool get isConnected => status == TunnelStatus.connected;
  bool get isFullTunnel => device?.result.isFullTunnel ?? false;

  /// Loads the saved device and checks whether the tunnel is already running.
  Future<void> start() async {
    _sub = engine.status.listen(_onStatus);
    device = await store.load();
    loaded = true;
    final saved = device;
    if (saved != null) {
      final status = await _statusService.fetch(saved.result.statusUrl);
      if (status != null) {
        live = status;
        engine.markConnected();
      }
    }
    notifyListeners();
  }

  /// Reads the code, enrolls this device and saves the result.
  /// Returns true on success; on failure [error] says what went wrong.
  Future<bool> addServer(String code) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final profile = ServerProfile.fromEnrollmentCode(code);
      final enrolled = await _enrollment.enroll(profile);
      await store.save(enrolled);
      device = enrolled;
      return true;
    } on FormatException catch (e) {
      error = e.message;
      return false;
    } on EnrollmentException catch (e) {
      error = e.message;
      return false;
    } on Exception catch (e) {
      // Anything else (for example the system keychain) still gets a message, never a silent failure.
      error = 'Could not add this server: $e';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // TODO 6a: connect and disconnect
  // Follow along in the video, then run: flutter test
  Future<void> connect() => throw UnimplementedError('TODO 6a: connect the tunnel');

  Future<void> disconnect() => throw UnimplementedError('TODO 6a: disconnect the tunnel');

  /// Disconnects and deletes this device's keys and settings from the app.
  /// (The admin removes it from the server on the dashboard.)
  Future<void> forget() async {
    if (isConnected) await engine.disconnect();
    await store.clear();
    device = null;
    live = null;
    notifyListeners();
  }

  void _onStatus(TunnelStatus status) {
    if (status == TunnelStatus.failed) error = engine.lastError;
    if (status == TunnelStatus.connected) {
      _startPolling();
    } else if (status != TunnelStatus.connecting) {
      _stopPolling();
      if (status == TunnelStatus.disconnected) live = null;
    }
    notifyListeners();
  }

  void _startPolling() {
    _poller?.cancel();
    _poll();
    _poller = Timer.periodic(pollEvery, (_) => _poll());
  }

  void _stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> _poll() async {
    final current = device;
    if (current == null) return;
    final status = await _statusService.fetch(current.result.statusUrl);
    if (status != null) {
      live = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _sub?.cancel();
    super.dispose();
  }
}
