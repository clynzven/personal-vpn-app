import 'package:material_ui/material_ui.dart';

import '../models/device_status.dart';
import '../models/traffic_history.dart';
import '../theme.dart';
import 'traffic_chart.dart';

/// Data sent and received through the tunnel, as the server counts it, plus a live chart.
class LiveStats extends StatefulWidget {
  const LiveStats({super.key, required this.status});

  final DeviceStatus? status;

  @override
  State<LiveStats> createState() => _LiveStatsState();
}

class _LiveStatsState extends State<LiveStats> {
  final _history = TrafficHistory();

  @override
  void initState() {
    super.initState();
    _record();
  }

  @override
  void didUpdateWidget(LiveStats old) {
    super.didUpdateWidget(old);
    // A new answer from the server: remember it for the chart.
    if (!identical(old.status, widget.status)) _record();
  }

  void _record() {
    final s = widget.status;
    if (s != null) _history.add(s, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final handshake = s?.lastHandshakeSecsAgo;
    return Column(
      children: [
        Row(
          children: [
            _Stat(
              icon: Icons.south_rounded,
              label: 'Received',
              value: s == null ? '—' : formatBytes(s.receivedBytes),
            ),
            _Stat(
              icon: Icons.north_rounded,
              label: 'Sent',
              value: s == null ? '—' : formatBytes(s.sentBytes),
            ),
            _Stat(
              icon: Icons.handshake_outlined,
              label: 'Handshake',
              value: handshake == null ? '—' : '$handshake s ago',
            ),
          ],
        ),
        const SizedBox(height: 10),
        TrafficChart(points: List.of(_history.points)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Brand.card.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF252B36)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Brand.green),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
