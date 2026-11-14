import 'device_status.dart';

/// One point on the traffic chart: how many bytes per second went through the tunnel.
class TrafficPoint {
  const TrafficPoint(this.at, this.bytesPerSecond);
  final DateTime at;
  final double bytesPerSecond;
}

/// Turns the server's running byte counters into a speed over time.
///
/// The server only tells us totals ("8.3 MB so far"). The speed is the difference
/// between two totals, divided by the seconds between them.
class TrafficHistory {
  TrafficHistory({this.capacity = 40});

  final int capacity;
  final List<TrafficPoint> points = [];
  DateTime? _lastAt;
  int? _lastTotal;

  void add(DeviceStatus status, DateTime now) {
    final total = status.receivedBytes + status.sentBytes;
    final lastAt = _lastAt;
    final lastTotal = _lastTotal;
    _lastAt = now;
    _lastTotal = total;
    if (lastAt == null || lastTotal == null) return;
    final seconds = now.difference(lastAt).inMilliseconds / 1000;
    if (seconds <= 0) return;
    // A counter that goes down means the server restarted: count it as zero, not negative.
    final delta = total >= lastTotal ? total - lastTotal : 0;
    points.add(TrafficPoint(now, delta / seconds));
    if (points.length > capacity) points.removeAt(0);
  }
}
