import 'package:material_ui/material_ui.dart';

import '../vpn_controller.dart';

/// Server details and the option to forget this server.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final VpnController controller;

  Future<void> _forget(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forget this server?'),
        content: const Text(
          'This disconnects and deletes this device\'s key from the app. To remove it from the server too, use the dashboard.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Forget')),
        ],
      ),
    );
    if (yes == true) {
      await controller.forget();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = controller.device;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: device == null
          ? const SizedBox.shrink()
          : ListView(
              children: [
                ListTile(
                  title: const Text('Device name'),
                  subtitle: Text(device.result.deviceName),
                ),
                ListTile(
                  title: const Text('Server'),
                  subtitle: Text('${device.serverHost}:${device.serverPort}'),
                ),
                ListTile(title: const Text('VPN address'), subtitle: Text(device.result.address)),
                ListTile(
                  title: const Text('What uses the tunnel'),
                  subtitle: Text(
                    device.result.isFullTunnel
                        ? 'Everything (full protection)'
                        : 'Only ${device.result.allowedIps.join(', ')}',
                  ),
                ),
                ListTile(title: const Text('DNS'), subtitle: Text(device.result.dns.join(', '))),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  title: const Text('Forget this server'),
                  onTap: () => _forget(context),
                ),
              ],
            ),
    );
  }
}
