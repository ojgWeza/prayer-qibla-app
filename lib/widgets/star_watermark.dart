import 'package:flutter/material.dart';

/// The app's signature eight-point Islamic star (khatam construction,
/// {8/3} skip-3 polygon), anchored as a single large low-opacity emblem in
/// the top corner behind the app bar/content -- matching the design
/// handoff's "decorative corner accent" rather than a tiled background
/// pattern. RTL mirrors it to the top-left corner automatically via
/// `Alignment.topEnd`.
class StarWatermark extends StatelessWidget {
  const StarWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(
          alpha: 0.07,
        );
    return IgnorePointer(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: FractionalTranslation(
          translation: const Offset(0.42, -0.42),
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(painter: _Star8Painter(color: color)),
          ),
        ),
      ),
    );
  }
}

class _Star8Painter extends CustomPainter {
  final Color color;

  const _Star8Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(r / 100);

    final path = Path()
      ..moveTo(90, 0)
      ..lineTo(-63.6, 63.6)
      ..lineTo(0, -90)
      ..lineTo(63.6, 63.6)
      ..lineTo(-90, 0)
      ..lineTo(63.6, -63.6)
      ..lineTo(0, 90)
      ..lineTo(-63.6, -63.6)
      ..close();
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(Offset.zero, 94, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Star8Painter oldDelegate) =>
      oldDelegate.color != color;
}
