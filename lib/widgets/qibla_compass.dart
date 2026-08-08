import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The qibla gauge from the design handoff: a sage-to-terracotta gradient
/// ring with tick marks and a fixed true-north marker, a cream dial face,
/// and an asymmetric tapered-blade needle (sharp tip = Qibla, blunt rounded
/// tail, trailing chevrons) so which end points at Qibla is unambiguous
/// even when the needle isn't moving.
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
    final isDark = ThemeData.estimateBrightnessForColor(surface) == Brightness.dark;

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

    // Qibla needle -- an asymmetric tapered blade (sharp tip = Qibla, blunt
    // rounded tail) with trailing chevron motion marks, NOT a generic
    // symmetric double-pointed arrow: a symmetric shape has two identical
    // tips and gives the user no way to tell which end is Qibla. Path data
    // is the design handoff's exact needle
    // ("M0,-80 L11,-28 Q12,38 0,54 Q-12,38 -11,-28 Z" + 3 chevrons at a 240x240
    // compass, faceRadius ~92) scaled to this dial's faceRadius. Points up
    // (toward the tip) at angle == 0.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final s = faceRadius / 92;
    final chevronPaint = Paint()
      ..color = AppTheme.accent700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    for (final (yTop, yBottom, opacity) in [
      (8.0, 18.0, 0.55),
      (20.0, 30.0, 0.35),
      (32.0, 42.0, 0.18),
    ]) {
      final chevron = Path()
        ..moveTo(-9 * s, yBottom * s)
        ..lineTo(0, yTop * s)
        ..lineTo(9 * s, yBottom * s);
      canvas.drawPath(chevron, chevronPaint..color = AppTheme.accent700.withValues(alpha: opacity));
    }

    final bladePath = Path()
      ..moveTo(0, -80 * s)
      ..lineTo(11 * s, -28 * s)
      ..quadraticBezierTo(12 * s, 38 * s, 0, 54 * s)
      ..quadraticBezierTo(-12 * s, 38 * s, -11 * s, -28 * s)
      ..close();
    // Dark at the tail fading to a light highlight at the tip in light
    // theme; reversed in dark theme -- never a flat single fill, and never
    // just inherited so it stays legible on the sage widget/dark surfaces.
    final tailColor = isDark ? AppTheme.accent2_100 : AppTheme.accent900;
    final tipColor = isDark ? AppTheme.accent900 : AppTheme.accent2_100;
    canvas.drawPath(
      bladePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [tailColor, AppTheme.accent, tipColor],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTWH(-12 * s, -80 * s, 24 * s, 134 * s)),
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
