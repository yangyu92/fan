import 'dart:math';

import 'package:flutter/material.dart';

/// 风扇壳
class ShellPainter extends CustomPainter {
  // 风扇壳上线条数
  int count = 24;

  Paint paintShell = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..color = const Color(0xFF888888);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.clipRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width,
        height: size.height,
      ),
    );
    _drawShell(canvas, size);
  }

  @override
  bool shouldRepaint(ShellPainter oldDelegate) => false;

  // 绘制风扇壳
  void _drawShell(Canvas canvas, Size size) {
    // 圆形的半径需要减去线条宽度
    double radius = size.width / 2 - 5;
    canvas.drawCircle(
      Offset.zero,
      radius,
      paintShell..strokeWidth = 5,
    );
    canvas.drawCircle(
      Offset.zero,
      radius / 1.6,
      paintShell..strokeWidth = 3,
    );
    canvas.save();
    // 绘制线条
    for (var i = 0; i < count; i++) {
      var step = 2 * pi / count;
      canvas.drawLine(
        Offset.zero,
        Offset(radius, 0),
        paintShell..strokeWidth = 1.2,
      );
      canvas.rotate(step);
    }
    canvas.restore();
    canvas.drawCircle(
      Offset.zero,
      radius / 7,
      paintShell..strokeWidth = 1.0,
    );
    canvas.drawCircle(
        Offset.zero,
        radius / 7,
        paintShell
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF656565));
    // TextPainter textPainter = TextPainter(
    //   text: TextSpan(
    //     text: "Fan",
    //     style: TextStyle(
    //       fontSize: radius / 6 / 1.8,
    //       color: Colors.black,
    //     ),
    //   ),
    //   textAlign: TextAlign.center,
    //   textDirection: TextDirection.ltr,
    // );
    // textPainter.layout();
    // Size textSize = textPainter.size; // 尺寸必须在布局后获取
    // textPainter.paint(
    //     canvas, Offset(-textSize.width / 2, -textSize.height / 2));
  }
}
