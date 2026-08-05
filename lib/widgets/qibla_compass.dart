import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A brass qibla-numa style compass face — a ring with engraved tick
/// marks, cardinal letters, a faint eight-point-star medallion, and a
/// two-tone needle — matching the design mockup instead of a bare
/// Material arrow icon.
class QiblaCompass extends StatelessWidget {
  final double angle;

  const QiblaCompass({super.key, required this.angle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(color: _CompassPainter._brassLo, fontWeight: FontWeight.bold);
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _CompassPainter(
          angle: angle,
          primary: theme.colorScheme.primary,
          onSurface: theme.colorScheme.onSurface,
          surface: theme.colorScheme.surface,
          labelStyle: labelStyle,
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  static const _brassLo = Color(0xFF8A6317);
  static const _brassHi = Color(0xFFF2DFA6);

  final double angle;
  final Color primary;
  final Color onSurface;
  final Color surface;
  final TextStyle labelStyle;

  const _CompassPainter({
    required this.angle,
    required this.primary,
    required this.onSurface,
    required this.surface,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide / 2;

    final ringRect = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..shader = const SweepGradient(
          colors: [_brassLo, _brassHi, _brassLo, _brassHi, _brassLo],
          stops: [0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(ringRect),
    );

    final tickPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i < 72; i++) {
      final a = (i / 72) * 2 * math.pi;
      final direction = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + direction * (outerRadius * 0.86),
        center + direction * outerRadius,
        tickPaint,
      );
    }

    final faceRadius = outerRadius * 0.78;
    canvas.drawCircle(center, faceRadius, Paint()..color = surface);
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..color = _brassLo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawLabel(canvas, 'ش', center + Offset(0, -faceRadius * 0.78));
    _drawLabel(canvas, 'ج', center + Offset(0, faceRadius * 0.78));
    _drawLabel(canvas, 'ق', center + Offset(faceRadius * 0.78, 0));
    _drawLabel(canvas, 'غ', center + Offset(-faceRadius * 0.78, 0));

    _drawStar8(canvas, center, faceRadius * 0.36, onSurface.withValues(alpha: 0.25));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final needleLength = faceRadius * 1.35;
    final needleWidth = faceRadius * 0.12;
    final needleRect = Rect.fromCenter(
      center: Offset(0, -needleLength * 0.15),
      width: needleWidth,
      height: needleLength,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(needleRect, Radius.circular(needleWidth / 3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary, primary, onSurface, onSurface],
          stops: const [0, 0.46, 0.54, 1],
        ).createShader(needleRect),
    );

    final tipY = needleRect.top;
    final tipPath = Path()
      ..moveTo(-needleWidth * 0.9, tipY)
      ..lineTo(needleWidth * 0.9, tipY)
      ..lineTo(0, tipY - needleWidth * 1.6)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = primary);
    canvas.restore();

    canvas.drawCircle(center, faceRadius * 0.06, Paint()..color = primary);
    canvas.drawCircle(
      center,
      faceRadius * 0.06,
      Paint()
        ..color = surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    painter.paint(canvas, pos - Offset(painter.width / 2, painter.height / 2));
  }

  void _drawStar8(Canvas canvas, Offset center, double half, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = Rect.fromCenter(center: center, width: half * 2, height: half * 2);
    canvas.drawRect(rect, paint);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.primary != primary ||
      oldDelegate.onSurface != onSurface ||
      oldDelegate.surface != surface ||
      oldDelegate.labelStyle != labelStyle;
}
