import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/device_status.dart';
import '../models/traffic_history.dart';
import '../theme.dart';

/// A live chart of the traffic going through the tunnel, drawn with a CustomPainter.
class TrafficChart extends StatelessWidget {
  const TrafficChart({super.key, required this.points});

  final List<TrafficPoint> points;

  @override
  Widget build(BuildContext context) {
    final peak = points.fold<double>(0, (m, p) => math.max(m, p.bytesPerSecond));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: Brand.card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF252B36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_vert_rounded, size: 18, color: Brand.green),
              const SizedBox(width: 6),
              const Text('Traffic', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (points.length >= 2)
                Text(
                  'peak ${formatBytes(peak.round())}/s',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: points.length < 2
                ? Center(
                    child: Text(
                      'Collecting live data…',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  )
                : CustomPaint(
                    key: const Key('traffic-chart'),
                    size: Size.infinite,
                    painter: _ChartPainter(points, peak),
                  ),
          ),
          if (points.length >= 2) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(_time(points.first.at), style: _axis),
                const Spacer(),
                Text(_time(points.last.at), style: _axis),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static final _axis = TextStyle(color: Colors.grey.shade600, fontSize: 11);

  static String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.points, this.peak);

  final List<TrafficPoint> points;
  final double peak;

  @override
  void paint(Canvas canvas, Size size) {
    final top = peak <= 0 ? 1.0 : peak * 1.15;
    Offset at(int i) => Offset(
      size.width * i / (points.length - 1),
      size.height - size.height * (points[i].bytesPerSecond / top),
    );

    // A smooth line through the points.
    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      final a = at(i - 1), b = at(i);
      final midX = (a.dx + b.dx) / 2;
      line.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final grid = Paint()
      ..color = const Color(0xFF252B36)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Brand.green.withValues(alpha: 0.35), Brand.green.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = Brand.green
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.points != points || old.peak != peak;
}
