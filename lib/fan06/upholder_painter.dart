import 'package:flutter/material.dart';

/// 风扇柱子
class UpholderPainter extends CustomPainter {
  UpholderPainter({required this.upholderNum}) : super(repaint: upholderNum);

  final ValueNotifier<int> upholderNum;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.clipRect(Rect.fromCenter(
      center: Offset.zero,
      width: size.width + 100,
      height: size.height,
    ));
    _drawUpholder(canvas, size);
    _drawLampMake(canvas, size);
  }

  @override
  bool shouldRepaint(UpholderPainter oldDelegate) =>
      upholderNum != oldDelegate.upholderNum;

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
}
