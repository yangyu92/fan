import 'dart:math';

import 'package:flutter/material.dart';

import 'fan_manager.dart';

/// 风扇页
class FanPainter extends CustomPainter {
  FanPainter(this.size, {required this.manage}) : super(repaint: manage) {
    points = points
        .map((offset) => Offset(
              offset.dx * size / 400,
              offset.dy * size / 400,
            ))
        .toList();
    pathBlades = pathBladesPaint();
  }

  // 风扇页数目
  int bladesCount = 8;
  // 风扇页控制器
  final FanManage manage;
  Paint paintBlades = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0
    ..color = const Color(0xFFE8E8E8);

  late Path pathBlades;
  List<Offset> points = [
    const Offset(0, -10),
    const Offset(20, -25),
    const Offset(70, -55),
    const Offset(0, 0),
    const Offset(80, -70),
    const Offset(100, 0),
    const Offset(0, 0),
    const Offset(20, 60),
    const Offset(-30, 45),
    const Offset(0, 0),
    const Offset(-60, -10),
    const Offset(-120, 20),
    const Offset(0, 0),
    const Offset(-20, 10),
    const Offset(-20, -10),
  ];

  final double size;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.clipPath(Path()
      ..addOval(
        Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
      ));
    // canvas.drawColor(Colors.white, BlendMode.src);
    _drawBlades(canvas, size);
  }

  @override
  bool shouldRepaint(FanPainter oldDelegate) => oldDelegate.manage != manage;

  pathBladesPaint() {
    Path path = Path();
    path.moveTo(0, 0);
    for (var i = 0; i < bladesCount; i++) {
      var step = 2 * pi / bladesCount;
      Matrix4 m4 = Matrix4.translationValues(size / 2, size / 2, 0);
      Matrix4 rotateM4 = Matrix4.rotationZ(step);
      m4.multiply(rotateM4);
      path = path.transform(m4.storage);
      for (int i = 0; i < points.length / 3; i++) {
        path.relativeCubicTo(
            points[3 * i + 0].dx,
            points[3 * i + 0].dy,
            points[3 * i + 1].dx,
            points[3 * i + 1].dy,
            points[3 * i + 2].dx,
            points[3 * i + 2].dy);
      }
    }
    path.close();
    return path;
  }

  void _drawBlades(Canvas canvas, Size size) {
    canvas.rotate(pi / 180 * manage.rotation);
    canvas.drawPath(pathBlades, paintBlades);
  }
}
