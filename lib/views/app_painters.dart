import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// HEART + ECG PULSE PAINTER  (used inside AppIcon)
// ═══════════════════════════════════════════════════════════════════════════════

class HeartPulsePainter extends CustomPainter {
  const HeartPulsePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h * 0.52;
    final s  = w * 0.38;

    // ── Filled heart ──────────────────────────────────────────────────
    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final heart = Path()
      ..moveTo(cx, cy + s * 0.9)
      ..cubicTo(cx - s * 2.0, cy, cx - s * 2.0, cy - s * 1.2, cx, cy - s * 0.3)
      ..cubicTo(cx + s * 2.0, cy - s * 1.2, cx + s * 2.0, cy, cx, cy + s * 0.9)
      ..close();
    canvas.drawPath(heart, heartPaint);

    // ── ECG pulse line ────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0xFF26A69A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final y0 = cy + s * 0.18;
    final pulse = Path()
      ..moveTo(cx - s * 1.4, y0)
      ..lineTo(cx - s * 0.6,  y0)
      ..lineTo(cx - s * 0.25, y0 - s * 0.9)   // up spike
      ..lineTo(cx,             y0 + s * 0.5)   // down dip
      ..lineTo(cx + s * 0.25, y0 - s * 0.4)   // small bump
      ..lineTo(cx + s * 0.6,  y0)
      ..lineTo(cx + s * 1.4,  y0);
    canvas.drawPath(pulse, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCENERY PAINTER  (background landscape on OnboardingScreen)
// ═══════════════════════════════════════════════════════════════════════════════

class SceneryPainter extends CustomPainter {
  const SceneryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Mountains ─────────────────────────────────────────────────────
    final mountainPaint = Paint()..color = const Color(0xFF5B9E7A);
    final mountains = Path()
      ..moveTo(0,          h * 0.62)
      ..lineTo(w * 0.18,  h * 0.28)
      ..lineTo(w * 0.38,  h * 0.55)
      ..lineTo(w * 0.55,  h * 0.20)
      ..lineTo(w * 0.75,  h * 0.50)
      ..lineTo(w * 0.88,  h * 0.32)
      ..lineTo(w,          h * 0.48)
      ..lineTo(w,          h * 0.72)
      ..lineTo(0,          h * 0.72)
      ..close();
    canvas.drawPath(mountains, mountainPaint);

    // ── Ground ────────────────────────────────────────────────────────
    final groundPaint = Paint()..color = const Color(0xFF8BC8A0);
    final ground = Path()
      ..moveTo(0,          h * 0.72)
      ..quadraticBezierTo(w * 0.3, h * 0.65, w * 0.6, h * 0.70)
      ..quadraticBezierTo(w * 0.8, h * 0.74, w,       h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ground, groundPaint);

    // ── Trees ─────────────────────────────────────────────────────────
    _drawTree(canvas, w * 0.08, h * 0.68, h * 0.22);
    _drawTree(canvas, w * 0.14, h * 0.70, h * 0.18);
    _drawTree(canvas, w * 0.82, h * 0.67, h * 0.20);
    _drawTree(canvas, w * 0.90, h * 0.69, h * 0.16);

    // ── Dirt path / road ──────────────────────────────────────────────
    final roadPaint = Paint()
      ..color = const Color(0xFFD4B896)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, h), Offset(w * 0.55, h * 0.68), roadPaint);
  }

  void _drawTree(Canvas canvas, double x, double y, double treeH) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF8B6B3D);
    canvas.drawRect(Rect.fromLTWH(x - 4, y - treeH * 0.15, 8, treeH * 0.2), trunkPaint);

    // Upper canopy (darker)
    final leavesUpper = Paint()..color = const Color(0xFF2D7A50);
    final top = Path()
      ..moveTo(x,               y - treeH)
      ..lineTo(x - treeH * 0.28, y - treeH * 0.35)
      ..lineTo(x + treeH * 0.28, y - treeH * 0.35)
      ..close();
    canvas.drawPath(top, leavesUpper);

    // Lower canopy (lighter)
    final leavesLower = Paint()..color = const Color(0xFF3A9160);
    final bottom = Path()
      ..moveTo(x,                y - treeH * 0.75)
      ..lineTo(x - treeH * 0.35, y - treeH * 0.12)
      ..lineTo(x + treeH * 0.35, y - treeH * 0.12)
      ..close();
    canvas.drawPath(bottom, leavesLower);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// RUNNER PAINTER  (character on OnboardingScreen)
// ═══════════════════════════════════════════════════════════════════════════════

class RunnerPainter extends CustomPainter {
  const RunnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skin  = Paint()..color = const Color(0xFFFFCBA4)..style = PaintingStyle.fill;
    final shirt = Paint()..color = const Color(0xFF3ABFB0)..style = PaintingStyle.fill;
    final shoes = Paint()..color = const Color(0xFF1A2340)..style = PaintingStyle.fill;
    final hair  = Paint()..color = const Color(0xFF2C1810)..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.12), w * 0.13, skin);

    // Hair
    canvas.drawPath(
      Path()..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.08),
        width: w * 0.28, height: w * 0.18,
      )),
      hair,
    );

    // Torso
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.32, h * 0.27)
        ..lineTo(w * 0.68, h * 0.27)
        ..lineTo(w * 0.65, h * 0.52)
        ..lineTo(w * 0.35, h * 0.52)
        ..close(),
      shirt,
    );

    // ── Arms ──────────────────────────────────────────────────────────
    final armPaint = Paint()
      ..color = const Color(0xFF3ABFB0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round;

    // Left arm – forward swing
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.32, h * 0.30)
        ..quadraticBezierTo(w * 0.10, h * 0.38, w * 0.16, h * 0.54),
      armPaint,
    );
    canvas.drawCircle(Offset(w * 0.16, h * 0.54), w * 0.07, skin);

    // Right arm – back swing
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.68, h * 0.30)
        ..quadraticBezierTo(w * 0.88, h * 0.36, w * 0.80, h * 0.50),
      armPaint,
    );
    canvas.drawCircle(Offset(w * 0.80, h * 0.50), w * 0.07, skin);

    // ── Legs ──────────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color = const Color(0xFF2D6E88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.14
      ..strokeCap = StrokeCap.round;

    // Left leg – forward
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.42, h * 0.52)
        ..quadraticBezierTo(w * 0.38, h * 0.70, w * 0.25, h * 0.82),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.84, w * 0.24, h * 0.09),
        const Radius.circular(5),
      ),
      shoes,
    );

    // Right leg – back
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.58, h * 0.52)
        ..quadraticBezierTo(w * 0.65, h * 0.68, w * 0.72, h * 0.80),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.82, w * 0.22, h * 0.09),
        const Radius.circular(5),
      ),
      shoes,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
