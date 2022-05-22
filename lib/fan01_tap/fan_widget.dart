import 'package:flutter/material.dart';

class FanWidget extends StatefulWidget {
  const FanWidget({Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget> {
  final FanBtnManager stamps = FanBtnManager();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    stamps.onTapDown();
  }

  void _onTapUp(TapUpDetails details) {
    stamps.onTapUp();
  }

  void _onTapCancel() {
    stamps.onTapCancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: CustomPaint(
        size: const Size(60, 60),
        painter: FanBtnPainter(stamps),
      ),
    );
  }
}

class FanBtnPainter extends CustomPainter {
  FanBtnPainter(this.manage) : super(repaint: manage);

  final FanBtnManager manage;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        ),
        const Radius.circular(5),
      ));

    switch (manage.state) {
      case PaintState.down:
      case PaintState.select:
        canvas.drawShadow(
            path.shift(const Offset(0, -1)), Colors.white, 2, false);
        break;
      case PaintState.none:
      default:
        canvas.drawShadow(
            path.shift(const Offset(0, -2)), Colors.white, 8, false);
    }
    canvas.drawPath(path, paint);

    Path circlePath = Path()
      ..addOval(
        Rect.fromCircle(center: Offset.zero, radius: size.width / 2 * 0.4),
      );
    Paint circlePaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = manage.color;
    canvas.drawPath(circlePath, circlePaint);
  }

  @override
  bool shouldRepaint(FanBtnPainter oldDelegate) => manage != oldDelegate.manage;
}

enum PaintState { none, select, down }

class FanPaintModel {
  FanPaintModel(this.path);

  final Path path;
  late PaintState state = PaintState.none;

  Color get color => state == PaintState.select
      ? const Color.fromARGB(255, 0, 222, 137)
      : Colors.black54;

  late Offset center;
  late Size size;

  void paint(Canvas canvas, Size size, Paint paint) {}
}

class FanBtnManager extends ChangeNotifier {
  FanPaintModel model = FanPaintModel(Path()
    ..addOval(
      Rect.fromCircle(center: Offset.zero, radius: 0),
    ));

  late PaintState state = PaintState.none;

  Color get color => state == PaintState.select
      ? const Color.fromARGB(255, 0, 222, 137)
      : Colors.black54;

  void onTapDown() {
    if (state == PaintState.select) return;
    state = PaintState.down;
    notifyListeners();
  }

  void onTapUp() {
    state = state == PaintState.select ? PaintState.none : PaintState.select;
    notifyListeners();
  }

  void onTapCancel() {
    if (state == PaintState.select) return;
    state = PaintState.none;
    notifyListeners();
  }
}
