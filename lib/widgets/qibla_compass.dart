import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The qibla gauge from the design handoff: a sage-to-terracotta gradient
/// ring with tick marks and a fixed true-north marker, a cream dial face,
/// and a wide chevron/arrowhead needle (instead of a plain pointer) that
/// reads as directional even when static.
class QiblaCompass extends StatelessWidget {
  final double angle;
  final String language;

  const QiblaCompass({super.key, required this.angle, this.language = 'ar'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(color: AppTheme.accent900, fontWeight: FontWeight.bold);
    return SizedBox(
      width: 240,
      height: 240,
      child: CustomPaint(
        painter: _CompassPainter(
          angle: angle,
          surface: theme.colorScheme.surface,
          labelStyle: labelStyle,
          useArabicLabels: language == 'ar',
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double angle;
  final Color surface;
  final TextStyle labelStyle;
  final bool useArabicLabels;

  const _CompassPainter({
    required this.angle,
    required this.surface,
    required this.labelStyle,
    required this.useArabicLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide / 2;

    // Sage <-> terracotta gradient ring.
    final ringRect = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            AppTheme.accent2,
            AppTheme.accent2_100,
            AppTheme.accent100,
            AppTheme.accent,
            AppTheme.accent2,
          ],
          stops: [0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(ringRect),
    );
    canvas.drawCircle(
      center,
      outerRadius - 10,
      Paint()..color = surface,
    );

    // Fixed true-north marker on the outer ring.
    canvas.drawCircle(
      center + Offset(0, -outerRadius + 5),
      4,
      Paint()..color = const Color(0xFFC1442E),
    );

    final tickPaint = Paint()
      ..color = AppTheme.accent900.withValues(alpha: 0.35)
      ..strokeWidth = 1.4;
    for (var i = 0; i < 40; i++) {
      final a = (i / 40) * 2 * math.pi;
      final direction = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        center + direction * (outerRadius - 16),
        center + direction * (outerRadius - 22),
        tickPaint,
      );
    }

    final faceRadius = outerRadius - 30;
    canvas.drawCircle(center, faceRadius, Paint()..color = surface);
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..color = AppTheme.accent900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final north = useArabicLabels ? 'ش' : 'N';
    final south = useArabicLabels ? 'ج' : 'S';
    final east = useArabicLabels ? 'ق' : 'E';
    final west = useArabicLabels ? 'غ' : 'W';
    _drawLabel(canvas, north, center + Offset(0, -faceRadius * 0.82));
    _drawLabel(canvas, south, center + Offset(0, faceRadius * 0.82));
    _drawLabel(canvas, east, center + Offset(faceRadius * 0.82, 0));
    _drawLabel(canvas, west, center + Offset(-faceRadius * 0.82, 0));

    // Faint eight-point khatam-star medallion at the center -- the same
    // {8/3} star polygon as the app's corner watermark, not a plain rotated
    // square.
    _drawKhatamStar(
      canvas,
      center,
      faceRadius * 0.22,
      AppTheme.accent900.withValues(alpha: 0.18),
    );

    // Wide chevron/arrowhead needle -- reads as directional even static.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final needleLen = faceRadius * 0.92;
    final needleHalfWidth = faceRadius * 0.24;
    final needlePath = Path()
      ..moveTo(-needleLen, 0)
      ..lineTo(needleLen * 0.15, -needleHalfWidth)
      ..lineTo(needleLen, 0)
      ..lineTo(needleLen * 0.15, needleHalfWidth)
      ..close();
    canvas.drawPath(
      needlePath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppTheme.accent900,
            AppTheme.accent,
            AppTheme.accent100,
          ],
        ).createShader(
          Rect.fromLTWH(-needleLen, -needleHalfWidth, needleLen * 2, needleHalfWidth * 2),
        ),
    );
    canvas.restore();

    canvas.drawCircle(center, faceRadius * 0.14, Paint()..color = surface);
    canvas.drawCircle(
      center,
      faceRadius * 0.14,
      Paint()
        ..color = AppTheme.accent900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawCircle(center, faceRadius * 0.05, Paint()..color = AppTheme.accent);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    painter.paint(canvas, pos - Offset(painter.width / 2, painter.height / 2));
  }

  /// The exact {8/3} khatam-star polygon from the design handoff (reference
  /// coordinates "90,0 -63.6,63.6 0,-90 ..." scaled to [radius]), drawn with
  /// the even-odd fill rule so the points read as a proper interlocking
  /// star rather than a plain rotated square.
  void _drawKhatamStar(Canvas canvas, Offset center, double radius, Color color) {
    final s = radius / 90;
    final path = Path()
      ..moveTo(center.dx + 90 * s, center.dy)
      ..lineTo(center.dx - 63.6 * s, center.dy + 63.6 * s)
      ..lineTo(center.dx, center.dy - 90 * s)
      ..lineTo(center.dx + 63.6 * s, center.dy + 63.6 * s)
      ..lineTo(center.dx - 90 * s, center.dy)
      ..lineTo(center.dx + 63.6 * s, center.dy - 63.6 * s)
      ..lineTo(center.dx, center.dy + 90 * s)
      ..lineTo(center.dx - 63.6 * s, center.dy - 63.6 * s)
      ..close();
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.surface != surface ||
      oldDelegate.labelStyle != labelStyle ||
      oldDelegate.useArabicLabels != useArabicLabels;
}
