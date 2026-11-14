// TODO 1: these tests pass once the Home screen is built.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_vpn/screens/home_screen.dart';
import 'package:personal_vpn/services/device_store.dart';
import 'package:personal_vpn/vpn_controller.dart';

import 'helpers.dart';

Future<VpnController> pumpHome(
  WidgetTester tester, {
  List<String> allowed = const ['0.0.0.0/0', '::/0'],
}) async {
  final controller = VpnController(
    engine: FakeEngine(),
    store: MemoryDeviceStore()..device = sampleDevice(allowed: allowed),
  );
  await tester.runAsync(controller.start);
  await tester.pumpWidget(MaterialApp(home: HomeScreen(controller: controller)));
  await tester.pump();
  return controller;
}

void main() {
  testWidgets('shows the server, the button and what is protected', (tester) async {
    await pumpHome(tester);
    expect(find.text('MacBook Air'), findsOneWidget);
    expect(find.textContaining('203.0.113.10'), findsOneWidget);
    expect(find.byKey(const Key('connect-button')), findsOneWidget);
    expect(find.text('Not protected'), findsOneWidget);
  });

  testWidgets('on a laptop the button sits left of the details', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpHome(tester);
    final button = tester.getCenter(find.byKey(const Key('connect-button')));
    final server = tester.getCenter(find.text('MacBook Air'));
    expect(button.dx, lessThan(server.dx));
  });

  testWidgets('on a phone the button sits above the details', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpHome(tester);
    final button = tester.getCenter(find.byKey(const Key('connect-button')));
    final server = tester.getCenter(find.text('MacBook Air'));
    expect(button.dy, lessThan(server.dy));
  });
}
