import 'package:material_ui/material_ui.dart';

import '../models/enrolled_device.dart';
import '../theme.dart';
import '../tunnel/tunnel_engine.dart';

/// The app name in the top bar: a small shield badge and "Personal VPN".
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(colors: [Brand.orange, Color(0xFFF2994A)]),
          ),
          child: const Icon(Icons.shield_rounded, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Text(
          'Personal VPN',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
      ],
    );
  }
}

/// A soft coloured glow behind the screen that follows the tunnel's status:
/// orange when off, amber while busy, green when you are protected.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.status, required this.child});

  final TunnelStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TunnelStatus.connected => Brand.green,
      TunnelStatus.connecting || TunnelStatus.disconnecting => Brand.amber,
      TunnelStatus.failed => Brand.red,
      TunnelStatus.disconnected => Brand.orange,
    };
    // A soft glow made from a blurred shadow: it renders the same on every platform.
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: const Alignment(0, -0.4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.16),
                      blurRadius: 320,
                      spreadRadius: 220,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Your server: device name, server address and this device's VPN address.
class ServerCard extends StatelessWidget {
  const ServerCard({super.key, required this.device});

  final EnrolledDevice device;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Brand.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dns_rounded, color: Brand.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.result.deviceName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.serverHost} · ${device.result.address}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            'YOUR SERVER',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
