import 'dart:async';

enum TunnelStatus { disconnected, connecting, connected, disconnecting, failed }

/// Something that can bring a WireGuard tunnel up and down.
/// The desktop and mobile engines do it in very different ways; the rest of the
/// app only talks to this interface.
abstract class TunnelEngine {
  TunnelEngine() : _current = TunnelStatus.disconnected;

  final _controller = StreamController<TunnelStatus>.broadcast();
  TunnelStatus _current;
  String? _lastError;

  /// Every status change, as it happens.
  /// Created once: a StreamBuilder that gets a new Stream object on every rebuild
  /// drops its subscription each time and can show a stale value.
  late final Stream<TunnelStatus> status = _controller.stream;
  TunnelStatus get current => _current;

  /// A message for the person when the last action failed.
  String? get lastError => _lastError;

  Future<void> connect(String wgQuickConfig, {required String endpoint});
  Future<void> disconnect();

  /// Called on start-up when we find the tunnel already running.
  void markConnected() => setStatus(TunnelStatus.connected);

  void setStatus(TunnelStatus status, {String? error}) {
    _current = status;
    _lastError = error;
    _controller.add(status);
  }

  Future<void> dispose() => _controller.close();
}
