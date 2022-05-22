import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'fan_manager.dart';

class FanWidget extends StatefulWidget {
  final double size;
  const FanWidget({required this.size, Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late FanManage pm = FanManage();

  final ValueNotifier<int> upholderNum = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // print(WidgetsBinding.instance.window.);
    _ticker = createTicker(_tick);
  }

  void _tick(Duration duration) {
    // print(duration);
    if (pm.speed < 0) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    } else {
      pm.tick();
    }
  }

  void startUpdateMax(double max) {
    pm.updateMax(max);
    if (max == 0) upholderNum.value = 0;
    if (max == 6) upholderNum.value = 1;
    if (max == 8) upholderNum.value = 2;
    if (max == 10) upholderNum.value = 3;

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(top: widget.size / 2),
              child: CustomPaint(
                size: Size(
                  45,
                  WidgetsBinding.instance.window.physicalSize.height /
                          WidgetsBinding.instance.window.devicePixelRatio -
                      400,
                ),
                painter: UpholderPainter(upholderNum: upholderNum), // 背景
              ),
            ),
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
                  startUpdateMax(6);
                },
                icon: const Icon(Icons.filter_1_outlined),
              ),
              IconButton(
                onPressed: () {
                  startUpdateMax(8);
                },
                icon: const Icon(Icons.filter_2_outlined),
              ),
              IconButton(
                onPressed: () {
                  startUpdateMax(10);
                },
                icon: const Icon(Icons.filter_3_outlined),
              ),
              IconButton(
                onPressed: () {
                  startUpdateMax(0);
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
    _ticker.dispose();
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
    canvas.clipPath(Path()
      ..addOval(
        Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
      ));
    // canvas.drawColor(Colors.white, BlendMode.src);
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

class UpholderPainter extends CustomPainter {
  final ValueNotifier<int> upholderNum;

  UpholderPainter({required this.upholderNum}) : super(repaint: upholderNum);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.clipRect(Rect.fromCenter(
      center: Offset.zero,
      width: size.width + 100,
      height: size.height,
    ));
    // canvas.drawColor(Colors.red, BlendMode.src);
    _drawUpholder(canvas, size);
    _drawLampMake(canvas, size);
  }

  void _drawUpholder(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    Path shadowPath = Path()
      ..addRect(Rect.fromCenter(
        center: const Offset(0, -5),
        width: size.width - 8,
        height: size.height + 10,
      ));
    canvas.drawShadow(
        shadowPath, const Color.fromARGB(255, 100, 100, 100), 10, false);

    Path rectanglePath = Path()
      ..addRect(Rect.fromCenter(
        center: const Offset(0, 5),
        width: size.width,
        height: size.height + 5,
      ));
    canvas.drawPath(
        rectanglePath, paint..color = const Color.fromARGB(255, 200, 200, 200));
    paint.maskFilter = const MaskFilter.blur(BlurStyle.inner, 8);
    canvas.drawPath(rectanglePath, paint..color = Colors.white);
  }

  void _drawLampMake(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF656565)
      ..isAntiAlias = true;
    double width = 12;
    double height = 60;
    canvas.translate(0, 0);
    Path rectanglePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, 5),
            width: width,
            height: height,
          ),
          Radius.circular(width),
        ),
      );
    canvas.drawPath(rectanglePath, paint);

    _drawLamp(canvas, size);
  }

  void _drawLamp(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF656565)
      ..isAntiAlias = true;
    double width = 12;
    double height = 60;
    double lampHeight = (height - 20) / 3;

    canvas.translate(0, -(height - lampHeight * upholderNum.value) / 2 + 10);
    Path lampPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, 5),
            width: 4,
            height: lampHeight * upholderNum.value,
          ),
          Radius.circular(width),
        ),
      );
    Path lampShadowPath = Path()
      ..addRect(
        Rect.fromCenter(
          center: const Offset(0, -10),
          width: 8,
          height: lampHeight * upholderNum.value,
        ),
      );
    canvas.drawShadow(lampShadowPath, const Color(0xFF00FF00), 20, false);
    // paint.maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);
    canvas.drawPath(lampPath, paint..color = const Color(0xFF00FF00));
  }

  @override
  bool shouldRepaint(UpholderPainter oldDelegate) =>
      upholderNum != oldDelegate.upholderNum;
}
