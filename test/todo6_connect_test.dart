// TODO 6: these tests pass once connect/disconnect and the live status chip work.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_vpn/screens/home_screen.dart';
import 'package:personal_vpn/services/device_store.dart';
import 'package:personal_vpn/tunnel/tunnel_engine.dart';
import 'package:personal_vpn/vpn_controller.dart';
import 'package:personal_vpn/widgets/status_chip.dart';

import 'helpers.dart';

void main() {
  test('6a: connect hands the config to the engine, disconnect stops it', () async {
    final engine = FakeEngine();
    final store = MemoryDeviceStore()..device = sampleDevice();
    final controller = VpnController(engine: engine, store: store);
    await controller.start();

    final seen = <TunnelStatus>[];
    final sub = engine.status.listen(seen.add);
    await controller.connect();
    expect(controller.isConnected, isTrue);
    expect(engine.configs.single, contains('Endpoint = 203.0.113.10:51820'));

    await controller.disconnect();
    expect(controller.isConnected, isFalse);
    await pumpEventQueue();
    expect(seen, [
      TunnelStatus.connecting,
      TunnelStatus.connected,
      TunnelStatus.disconnecting,
      TunnelStatus.disconnected,
    ]);
    await sub.cancel();
    controller.dispose();
  });

  test('6a: a cancelled password prompt shows a clear message', () async {
    final engine = FakeEngine()..failNext = true;
    final controller = VpnController(
      engine: engine,
      store: MemoryDeviceStore()..device = sampleDevice(),
    );
    await controller.start();
    await controller.connect();
    await pumpEventQueue();
    expect(controller.isConnected, isFalse);
    expect(controller.error, contains('cancelled'));
    controller.dispose();
  });

  testWidgets('6b: the status chip follows the stream live', (tester) async {
    final engine = FakeEngine();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatusChip(status: engine.status, initial: engine.current),
        ),
      ),
    );
    expect(find.text('Not connected'), findsOneWidget);

    engine.setStatus(TunnelStatus.connecting);
    await tester.pump();
    expect(find.text('Connecting…'), findsOneWidget);

    engine.setStatus(TunnelStatus.connected);
    await tester.pump();
    expect(find.text('Connected'), findsOneWidget);
  });

  // 6c needs TODOs 1 to 5 too: the whole Home screen working together.
  Future<void> pumpHome(WidgetTester tester, List<String> allowed) async {
    final controller = VpnController(
      engine: FakeEngine(),
      store: MemoryDeviceStore()..device = sampleDevice(allowed: allowed),
    );
    await tester.runAsync(controller.start);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(controller: controller)));
    await tester.pump();
  }

  testWidgets('6c: the button connects, and the protection label updates', (tester) async {
    await pumpHome(tester, ['0.0.0.0/0', '::/0']);
    expect(find.text('Not connected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('connect-button')));
    await tester.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Full protection'), findsOneWidget);
  });

  testWidgets('6c: a split tunnel is labelled honestly', (tester) async {
    await pumpHome(tester, ['10.8.0.0/24']);
    await tester.tap(find.byKey(const Key('connect-button')));
    await tester.pumpAndSettle();
    expect(find.text('Private network only'), findsOneWidget);
    expect(find.text('Full protection'), findsNothing);
  });
}
