import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'services/device_store.dart';
import 'theme.dart';
import 'tunnel/desktop_engine.dart';
import 'tunnel/mobile_engine.dart';
import 'tunnel/tunnel_engine.dart';
import 'vpn_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Phones use the system VPN APIs; computers use the WireGuard tools.
  final TunnelEngine engine = (Platform.isAndroid || Platform.isIOS)
      ? MobileEngine()
      : DesktopEngine();
  final controller = VpnController(engine: engine, store: SecureDeviceStore());
  runApp(PersonalVpnApp(controller: controller));
  controller.start();
}

class PersonalVpnApp extends StatelessWidget {
  const PersonalVpnApp({super.key, required this.controller});
  final VpnController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal VPN',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: HomeScreen(controller: controller),
    );
  }
}
