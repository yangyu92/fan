import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fan_manager.dart';

class FanWidget extends StatefulWidget {
  final double size;
  const FanWidget({required this.size, Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FanManage pm = FanManage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        if (pm.speed < 0) {
          _controller.stop();
        } else {
          pm.tick();
        }
      });
    // ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: FanPainter(widget.size, manage: pm), // 背景
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ShellPainter(), // 背景
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  pm.updateMax(6);
                  _controller.repeat();
                },
                icon: const Icon(Icons.filter_1_outlined),
              ),
              IconButton(
                onPressed: () {
                  pm.updateMax(8);
                  _controller.repeat();
                },
                icon: const Icon(Icons.filter_2_outlined),
              ),
              IconButton(
                onPressed: () {
                  pm.updateMax(10);
                  _controller.repeat();
                },
                icon: const Icon(Icons.filter_3_outlined),
              ),
              IconButton(
                onPressed: () {
                  pm.updateMax(0);
                },
                icon: const Icon(CupertinoIcons.power),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FanPainter extends CustomPainter {
  final FanManage manage;

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

  FanPainter(this.size, {required this.manage}) : super(repaint: manage) {
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
    canvas.rotate(pi / 180 * manage.rotation);
    canvas.drawPath(pathBlades, paintBlades);
  }

  @override
  bool shouldRepaint(FanPainter oldDelegate) => oldDelegate.manage != manage;
}

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

  // 绘制风扇壳
  void _drawShell(Canvas canvas, Size size) {
    double radius = size.width / 2 - 5;

    canvas.drawCircle(Offset.zero, radius, paintShell);
    canvas.drawCircle(
      Offset.zero,
      radius / 1.6,
      paintShell..strokeWidth = 3.0,
    );
    canvas.save();
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
}
