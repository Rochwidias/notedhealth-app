import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cincin skor harian 0–100 ala mockup (latar redup + busur progres).
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 96,
    this.trackColor = const Color(0x33FFFFFF),
    this.progressColor = Colors.white,
  });

  final double score;
  final double size;
  final Color trackColor;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (score.clamp(0, 100)) / 100,
          trackColor: trackColor,
          progressColor: progressColor,
        ),
        child: Center(
          child: Text(
            score.round().toString(),
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w600,
              fontSize: size * 0.3,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 11.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    const sweep = math.pi * 2;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    if (progress > 0) {
      canvas.drawArc(
        rect,
        start,
        sweep * progress,
        false,
        Paint()
          ..color = progressColor
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
