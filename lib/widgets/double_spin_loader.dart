import 'dart:math' as math;

import 'package:flutter/material.dart';

class DoubleSpinLoader extends StatefulWidget {
  final double size;
  final Color color1;
  final Color color2;
  final Color? trackColor;
  final double strokeWidth;
  final Duration duration;
  final double innerSpeedFactor;

  const DoubleSpinLoader({
    super.key,
    this.size = 50,
    this.color1 = const Color(0xFFFF6B6B),
    this.color2 = const Color(0xFF4ECDC4),
    this.trackColor,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 1200),
    this.innerSpeedFactor = 1.5,
  });

  @override
  State<DoubleSpinLoader> createState() => _DoubleSpinLoaderState();
}

class _DoubleSpinLoaderState extends State<DoubleSpinLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DoubleSpinPainter(
              outerProgress: _controller.value,
              innerProgress: (_controller.value * widget.innerSpeedFactor) % 1,
              color1: widget.color1,
              color2: widget.color2,
              trackColor: widget.trackColor ?? widget.color1.withValues(alpha: 0.12),
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _DoubleSpinPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;
  final Color color1;
  final Color color2;
  final Color trackColor;
  final double strokeWidth;

  const _DoubleSpinPainter({
    required this.outerProgress,
    required this.innerProgress,
    required this.color1,
    required this.color2,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - strokeWidth / 2;
    final innerRadius = outerRadius * 0.62;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final outerPaint = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = color2
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      (-math.pi / 2) + (outerProgress * 2 * math.pi),
      math.pi * 0.92,
      false,
      outerPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      (math.pi / 2) - (innerProgress * 2 * math.pi),
      math.pi * 0.92,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DoubleSpinPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
