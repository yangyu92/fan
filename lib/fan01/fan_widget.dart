import 'dart:math';

import 'package:flutter/material.dart';

class FanWidget extends StatefulWidget {
  const FanWidget({Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Colors.red,
    //   child: CustomPaint(
    //     size: const Size(350, 350),
    //     painter: FanDrawPainter(), // 背景
    //   ),
    // );

    // return CustomPaint(
    //   size: const Size(45, 350),
    //   painter: UpholderPainter(), // 背景
    // );

    return CustomPaint(
      size: const Size(45, 45),
      painter: FanBtnPainter(), // 背景
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class FanBtnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        ),
        const Radius.circular(5),
      ));

    canvas.drawShadow(path.shift(const Offset(-2, -4)), Colors.white, 8, false);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
        Offset.zero,
        size.width / 2 * 0.4,
        Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..color = Colors.black54);
  }

  @override
  bool shouldRepaint(FanBtnPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(FanBtnPainter oldDelegate) => false;
}

class UpholderPainter extends CustomPainter {
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
    canvas.translate(0, -size.height / 5);
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
    double num = 2;
    canvas.translate(0, -(height - lampHeight * num) / 2 + 10);
    Path lampPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, 5),
            width: 4,
            height: lampHeight * num,
          ),
          Radius.circular(width),
        ),
      );
    Path lampShadowPath = Path()
      ..addRect(
        Rect.fromCenter(
          center: const Offset(0, -10),
          width: 8,
          height: lampHeight * num,
        ),
      );
    canvas.drawShadow(lampShadowPath, const Color(0xFF00FF00), 20, false);
    // paint.maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);
    canvas.drawPath(lampPath, paint..color = const Color(0xFF00FF00));
  }

  @override
  bool shouldRepaint(UpholderPainter oldDelegate) => false;
}

class FanDrawPainter extends CustomPainter {
  // 风扇壳上线条数
  int count = 24;

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

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.clipPath(Path()
      ..addOval(
        Rect.fromCircle(center: Offset.zero, radius: size.width),
      ));
    canvas.drawColor(Colors.white, BlendMode.src);
    _drawBlades(canvas, size);
    _drawShell(canvas, size);
  }

  void _drawBlades(Canvas canvas, Size size) {
    double rotation = 10;

    points = points
        .map((offset) => Offset(
              offset.dx * size.width / 400,
              offset.dy * size.width / 400,
            ))
        .toList();

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = const Color(0xFFE8E8E8);

    Path path = Path();
    path.moveTo(0, 0);
    for (var i = 0; i < bladesCount; i++) {
      var step = 2 * pi / bladesCount;
      Matrix4 m4 =
          Matrix4.translationValues(size.width / 2, size.height / 2, 0);
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
    Matrix4 rotateM4 = Matrix4.rotationZ(pi / 180 * rotation);
    path = path.transform(rotateM4.storage);
    canvas.drawPath(path, paint);
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
  bool shouldRepaint(FanDrawPainter oldDelegate) => false;
}
