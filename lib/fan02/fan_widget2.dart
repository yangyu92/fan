import 'dart:math';

import 'package:flutter/material.dart';

class FanWidget extends StatefulWidget {
  final double size;
  const FanWidget({required this.size, Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      lowerBound: 0,
      upperBound: 360,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  onTap() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: FanPainter(widget.size, angle: _controller), // 背景
          ),
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ShellPainter(), // 背景
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FanPainter extends CustomPainter {
  final Animation<double> angle; // 角度(与x轴交角 角度制)

  final double size;

  int bladesCount = 8;

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

  late Path pathBlades;
  Paint paintBlades = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0
    ..color = const Color(0xFFE8E8E8);

  FanPainter(this.size, {required this.angle}) : super(repaint: angle) {
    points = points
        .map((offset) => Offset(
              offset.dx * size / 400,
              offset.dy * size / 400,
            ))
        .toList();
    pathBlades = pathBladesPaint();
  }

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
    // canvas.drawColor(Colors.red, BlendMode.src);
    _drawBlades(canvas, size);
  }

  void _drawBlades(Canvas canvas, Size size) {
    // double rotation = angle.value;
    // Matrix4 rotateM4 = Matrix4.rotationZ(pi / 180 * rotation);
    // canvas.drawPath(pathBlades.transform(rotateM4.storage), paintBlades);
    double rotation = angle.value;
    canvas.rotate(pi / 180 * rotation);
    canvas.drawPath(pathBlades, paintBlades);
  }

  @override
  bool shouldRepaint(FanPainter oldDelegate) => oldDelegate.angle == angle;
}

class ShellPainter extends CustomPainter {
  // 风扇壳上线条数
  int count = 24;

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

  // 绘制风扇壳
  void _drawShell(Canvas canvas, Size size) {
    double radius = size.width / 2 - 5;
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = const Color(0xFF888888);

    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(
      Offset.zero,
      radius / 1.6,
      paint..strokeWidth = 3.0,
    );
    canvas.save();
    for (var i = 0; i < count; i++) {
      var step = 2 * pi / count;
      canvas.drawLine(
        Offset.zero,
        Offset(radius, 0),
        paint..strokeWidth = 1.2,
      );
      canvas.rotate(step);
    }
    canvas.restore();
    canvas.drawCircle(
      Offset.zero,
      radius / 7,
      paint..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      Offset.zero,
      radius / 7,
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFD8D8D8),
    );
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

  @override
  bool shouldRepaint(ShellPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ShellPainter oldDelegate) => false;
}
