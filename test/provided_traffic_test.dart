// Provided: the live traffic chart (ready-made, not a TODO).
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_vpn/models/device_status.dart';
import 'package:personal_vpn/models/traffic_history.dart';
import 'package:personal_vpn/widgets/live_stats.dart';

DeviceStatus at(int rx, int tx) => DeviceStatus(
  name: 'MacBook Air',
  online: true,
  lastHandshakeSecsAgo: 3,
  receivedBytes: rx,
  sentBytes: tx,
);

void main() {
  test('speed is the difference between two totals, per second', () {
    final h = TrafficHistory();
    final t0 = DateTime(2026, 11, 14, 15);
    h.add(at(1000, 500), t0);
    h.add(at(4000, 1500), t0.add(const Duration(seconds: 2)));
    expect(h.points.single.bytesPerSecond, 2000);
  });

  test('a server restart (counters going down) counts as zero, and the history is capped', () {
    final h = TrafficHistory(capacity: 3);
    final t0 = DateTime(2026, 11, 14, 15);
    h.add(at(9000, 0), t0);
    h.add(at(100, 0), t0.add(const Duration(seconds: 1)));
    expect(h.points.single.bytesPerSecond, 0);
    for (var i = 2; i < 8; i++) {
      h.add(at(100 + i * 10, 0), t0.add(Duration(seconds: i)));
    }
    expect(h.points.length, 3);
  });

  testWidgets('the chart appears once there are two speeds (three answers)', (tester) async {
    Widget app(DeviceStatus s) => MaterialApp(
      home: Scaffold(body: LiveStats(status: s)),
    );
    await tester.pumpWidget(app(at(0, 0)));
    expect(find.text('Collecting live data…'), findsOneWidget);
    // Real time must pass between two answers (the app polls every 3 seconds).
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpWidget(app(at(2048, 1024)));
    expect(find.text('Collecting live data…'), findsOneWidget);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpWidget(app(at(4096, 2048)));
    expect(find.byKey(const Key('traffic-chart')), findsOneWidget);
  });
}
