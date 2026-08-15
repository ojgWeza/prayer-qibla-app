import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The qibla gauge from the design handoff: a sage-to-terracotta gradient
/// ring with tick marks and a fixed true-north marker, a cream dial face,
/// and an asymmetric tapered-blade needle (sharp tip = Qibla, blunt rounded
/// tail, trailing chevrons) so which end points at Qibla is unambiguous
/// even when the needle isn't moving.
class QiblaCompass extends StatefulWidget {
  final double angle;
  final String language;

  /// True once the device heading is within the alignment threshold of the
  /// qibla bearing -- mirrors a competitor app's Kaaba-icon-turns-blue cue so
  /// the user gets a clear "you're pointing at Qibla now" signal instead of
  /// having to eyeball a moving needle against a static label.
  final bool isAligned;

  const QiblaCompass({
    super.key,
    required this.angle,
    this.language = 'ar',
    this.isAligned = false,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with TickerProviderStateMixin {
  // Raw sensor headings jump discontinuously (both from magnetometer noise
  // between events and from the 359->1 wraparound), which read as a jittery,
  // teleporting needle. This controller chases the latest target angle over
  // a short throw instead of snapping straight to it, so the needle reads as
  // a physical compass card settling rather than a raw sensor readout.
  late final AnimationController _headingController;
  late Animation<double> _headingAnimation;
  double _displayAngle = 0;

  // Crossfades the needle/hub color between the resting and "locked on
  // Qibla" palettes so the alignment cue reads as a transition, not a hard
  // color snap.
  late final AnimationController _alignController;
  // Color/state transitions read best on an eased curve rather than the
  // controller's raw linear value -- same easeOut used by _headingAnimation.
  late final CurvedAnimation _alignAnimation;

  // One-shot burst fired only on the false->true alignment edge -- the
  // authored "you found Qibla" moment, synced with the haptic tap already
  // fired by QiblaScreen on the same edge.
  late final AnimationController _lockController;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _displayAngle = widget.angle;
    _headingAnimation = AlwaysStoppedAnimation(_displayAngle);
    _headingController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 180))
          ..addListener(() => setState(() => _displayAngle = _headingAnimation.value));
    _alignController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isAligned ? 1 : 0,
    );
    _alignAnimation = CurvedAnimation(parent: _alignController, curve: Curves.easeOut);
    _lockController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  }

  @override
  void didUpdateWidget(covariant QiblaCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion = _reduceMotion;

    if (oldWidget.angle != widget.angle) {
      final target = _displayAngle + _shortestAngleDelta(_displayAngle, widget.angle);
      if (reduceMotion) {
        _headingController.stop();
        setState(() => _displayAngle = target);
      } else {
        _headingAnimation = Tween<double>(begin: _displayAngle, end: target)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(_headingController);
        _headingController.forward(from: 0);
      }
    }

    if (oldWidget.isAligned != widget.isAligned) {
      if (reduceMotion) {
        _alignController.value = widget.isAligned ? 1 : 0;
      } else {
        widget.isAligned ? _alignController.forward() : _alignController.reverse();
        if (widget.isAligned) _lockController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _alignAnimation.dispose();
    _alignController.dispose();
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(color: AppTheme.accent900, fontWeight: FontWeight.bold);
    return SizedBox(
      width: 240,
      height: 240,
      child: AnimatedBuilder(
        animation: Listenable.merge([_alignController, _lockController]),
        builder: (context, _) {
          return CustomPaint(
            painter: _CompassPainter(
              angle: _displayAngle,
              surface: theme.colorScheme.surface,
              labelStyle: labelStyle,
              useArabicLabels: widget.language == 'ar',
              alignFraction: _alignAnimation.value,
              lockProgress: _lockController.value,
            ),
          );
        },
      ),
    );
  }
}

/// Signed shortest angular distance from [from] to [to] in radians, in
/// (-pi, pi] -- so a heading crossing the 359/1 degree boundary turns the
/// needle by ~2 degrees instead of spinning it almost a full circle.
double _shortestAngleDelta(double from, double to) {
  const twoPi = 2 * math.pi;
  var diff = (to - from) % twoPi;
  if (diff > math.pi) diff -= twoPi;
  return diff;
}

class _CompassPainter extends CustomPainter {
  final double angle;
  final Color surface;
  final TextStyle labelStyle;
  final bool useArabicLabels;

  /// 0 at rest, 1 fully "locked on Qibla" -- crossfades needle/hub color.
  final double alignFraction;

  /// 0..1 progress of the one-shot lock-burst ring; inert at 0.
  final double lockProgress;

  const _CompassPainter({
    required this.angle,
    required this.surface,
    required this.labelStyle,
    required this.useArabicLabels,
    required this.alignFraction,
    required this.lockProgress,
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
    // As alignFraction rises toward 1, every stop lerps toward the same
    // locked terracotta -- a gradient that degenerates into a flat fill --
    // so the "locked on" cue crossfades in instead of hard-cutting, while
    // still reading as a clear, unambiguous color change once settled, same
    // idea as the competitor app's Kaaba icon turning solid blue when facing
    // Qibla.
    final tailColor = isDark ? AppTheme.accent2_100 : AppTheme.accent900;
    final tipColor = isDark ? AppTheme.accent900 : AppTheme.accent2_100;
    const lockedColor = AppTheme.accent700;
    canvas.drawPath(
      bladePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.lerp(tailColor, lockedColor, alignFraction)!,
            Color.lerp(AppTheme.accent, lockedColor, alignFraction)!,
            Color.lerp(tipColor, lockedColor, alignFraction)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTWH(-12 * s, -80 * s, 24 * s, 134 * s)),
    );
    canvas.restore();

    canvas.drawCircle(center, faceRadius * 0.14, Paint()..color = surface);
    canvas.drawCircle(
      center,
      faceRadius * 0.14,
      Paint()
        ..color = Color.lerp(AppTheme.accent900, AppTheme.accent700, alignFraction)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawCircle(
      center,
      faceRadius * 0.05,
      Paint()..color = Color.lerp(AppTheme.accent, AppTheme.accent700, alignFraction)!,
    );

    // The lock-burst: a ring expanding out from the hub and fading as it
    // grows, fired once on the moment the needle settles onto Qibla.
    if (lockProgress > 0 && lockProgress < 1) {
      final radiusT = Curves.easeOutCubic.transform(lockProgress);
      final fadeT = Curves.easeIn.transform(lockProgress);
      final ringRadius = faceRadius * 0.16 + (faceRadius * 0.82 - faceRadius * 0.16) * radiusT;
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..color = AppTheme.accent700.withValues(alpha: (1 - fadeT) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s,
      );
    }
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
      oldDelegate.useArabicLabels != useArabicLabels ||
      oldDelegate.alignFraction != alignFraction ||
      oldDelegate.lockProgress != lockProgress;
}
