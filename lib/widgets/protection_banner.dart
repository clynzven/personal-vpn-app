import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Tells the person, in plain words, what the VPN protects right now.
class ProtectionBanner extends StatelessWidget {
  const ProtectionBanner({super.key, required this.connected, required this.fullTunnel});

  final bool connected;
  final bool fullTunnel;

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, body) = !connected
        ? (
            Icons.shield_outlined,
            Colors.grey,
            'Not protected',
            'Your traffic goes out normally. On public Wi-Fi, others nearby may see it.',
          )
        : fullTunnel
        ? (
            Icons.verified_user,
            Brand.green,
            'Full protection',
            'All your traffic is encrypted to your own server, even on public Wi-Fi.',
          )
        : (
            Icons.lan_outlined,
            Brand.amber,
            'Private network only',
            'Only VPN addresses (like the dashboard) use the tunnel. Other traffic goes out normally.',
          );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
