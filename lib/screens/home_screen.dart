// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import '../vpn_controller.dart';
import '../widgets/brand.dart';
import '../widgets/connect_button.dart';
import '../widgets/live_stats.dart';
import '../widgets/protection_banner.dart';
import '../widgets/status_chip.dart';
import 'add_server_screen.dart';
import 'settings_screen.dart';

/// The main screen: a big Connect button, your server, and what is protected.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final VpnController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    // ListenableBuilder rebuilds the screen whenever the controller calls notifyListeners().
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const BrandTitle(),
          actions: [
            if (controller.device != null)
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _open(SettingsScreen(controller: controller)),
              ),
          ],
        ),
        body: GlowBackground(
          status: controller.status,
          child: SafeArea(
            child: !controller.loaded
                ? const Center(child: CircularProgressIndicator())
                : controller.device == null
                ? _NoServerYet(onAdd: () => _open(AddServerScreen(controller: controller)))
                // LayoutBuilder tells us how wide the window is.
                : LayoutBuilder(
                    builder: (context, size) => SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _dashboard(controller, wide: size.maxWidth >= 760),
                          if (controller.error != null)
                            Text(controller.error!, style: const TextStyle(color: Brand.red)),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // TODO 2: make the button work with setState
  // Follow along in the video, then run: flutter test
  bool _busy = false;

  Future<void> _toggle() async {}

  // TODO 1: lay out the Home screen
  // Follow along in the video, then run: flutter test
  Widget _dashboard(VpnController c, {required bool wide}) =>
      const Text('TODO 1: build the Home screen');
}

class _NoServerYet extends StatelessWidget {
  const _NoServerYet({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Brand.card,
                border: Border.all(color: Brand.orange.withValues(alpha: 0.5), width: 2),
                boxShadow: [BoxShadow(color: Brand.orange.withValues(alpha: 0.25), blurRadius: 50)],
              ),
              child: const Icon(Icons.vpn_lock_rounded, size: 56, color: Brand.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add your server',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a one-time code on your server\'s dashboard, then paste it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: FilledButton.icon(
                key: const Key('add-server'),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add server'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
