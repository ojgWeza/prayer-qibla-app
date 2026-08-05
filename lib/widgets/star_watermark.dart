import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app's seal mark — a ring around an eight-point star (two
/// overlapping squares, the traditional khatam construction) — tiled
/// faintly across the background so the whole app carries the one
/// signature shape instead of a bare star pattern.
class StarWatermark extends StatelessWidget {
  const StarWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(
          alpha: 0.06,
        );
    return IgnorePointer(
      child: CustomPaint(painter: _Star8TilePainter(color: color)),
    );
  }
}

class _Star8TilePainter extends CustomPainter {
  static const double _tile = 44;
  static const double _starSize = 22;

  final Color color;

  const _Star8TilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final square = Rect.fromCenter(
      center: Offset.zero,
      width: _starSize,
      height: _starSize,
    );
    final ringRadius = _starSize * 0.8;

    for (double y = _tile / 2; y < size.height + _tile; y += _tile) {
      for (double x = _tile / 2; x < size.width + _tile; x += _tile) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawCircle(Offset.zero, ringRadius, paint);
        canvas.drawRect(square, paint);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(square, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Star8TilePainter oldDelegate) =>
      oldDelegate.color != color;
}
