// ignore_for_file: unused_import, unused_element, unused_field, prefer_final_fields
import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import '../tunnel/tunnel_engine.dart';

/// A small coloured label that follows the tunnel's status live.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.initial});

  /// Every status change of the tunnel.
  final Stream<TunnelStatus> status;

  /// What to show before the first change arrives.
  final TunnelStatus initial;

  // TODO 6b: show the live status with a StreamBuilder
  // Follow along in the video, then run: flutter test
  @override
  Widget build(BuildContext context) => const Text('TODO 6b: show the live status');
}
