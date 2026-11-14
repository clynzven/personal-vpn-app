// TODO 2: these tests pass once the Connect button uses setState.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_vpn/screens/home_screen.dart';
import 'package:personal_vpn/services/device_store.dart';
import 'package:personal_vpn/vpn_controller.dart';
import 'package:personal_vpn/widgets/connect_button.dart';

import 'helpers.dart';

/// A controller whose connect() waits until the test says so, so we can see the busy state.
class SlowController extends VpnController {
  SlowController()
    : super(engine: FakeEngine(), store: MemoryDeviceStore()..device = sampleDevice());

  final gate = Completer<void>();
  int connects = 0;

  @override
  Future<void> connect() async {
    connects++;
    await gate.future;
  }
}

ConnectButton button(WidgetTester tester) =>
    tester.widget<ConnectButton>(find.byKey(const Key('connect-button')));

void main() {
  testWidgets('tapping the button asks the controller to connect', (tester) async {
    final c = SlowController();
    await tester.runAsync(c.start);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(controller: c)));
    await tester.tap(find.byKey(const Key('connect-button')));
    await tester.pump();
    expect(c.connects, 1);
  });

  testWidgets('while busy the button is disabled, then it works again', (tester) async {
    final c = SlowController();
    await tester.runAsync(c.start);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(controller: c)));
    expect(button(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('connect-button')));
    await tester.pump();
    expect(button(tester).onPressed, isNull, reason: 'setState(() => _busy = true) disables it');

    c.gate.complete();
    await tester.pump();
    await tester.pump();
    expect(
      button(tester).onPressed,
      isNotNull,
      reason: 'setState(() => _busy = false) enables it again',
    );
  });
}
