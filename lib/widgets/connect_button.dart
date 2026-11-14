import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import '../tunnel/tunnel_engine.dart';

/// The big round button in the middle of the Home screen.
///
/// It uses *implicit animations* (AnimatedContainer, AnimatedSwitcher): you only
/// set the new colour or icon, and Flutter animates from the old one by itself.
class ConnectButton extends StatelessWidget {
  const ConnectButton({super.key, required this.status, required this.onPressed});

  final TunnelStatus status;

  /// Null disables the button (for example while connecting).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      TunnelStatus.connected => (Brand.green, Icons.verified_user_rounded, 'Protected'),
      TunnelStatus.connecting => (Brand.amber, Icons.sync_rounded, 'Connecting…'),
      TunnelStatus.disconnecting => (Brand.amber, Icons.sync_rounded, 'Disconnecting…'),
      TunnelStatus.failed => (Brand.red, Icons.refresh_rounded, 'Tap to try again'),
      TunnelStatus.disconnected => (
        Brand.orange,
        Icons.power_settings_new_rounded,
        'Tap to connect',
      ),
    };
    final on = status == TunnelStatus.connected;
    final busy = status == TunnelStatus.connecting || status == TunnelStatus.disconnecting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: 210,
              height: 210,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.55), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: on ? 0.45 : 0.18),
                    blurRadius: on ? 70 : 36,
                    spreadRadius: on ? 6 : 0,
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: on
                        ? [Brand.green, const Color(0xFF168A4A)]
                        : [Brand.card, const Color(0xFF0F131A)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (busy)
                      SizedBox.expand(
                        child: CircularProgressIndicator(strokeWidth: 3, color: color),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        size: 76,
                        color: on ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: on ? Brand.green : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
