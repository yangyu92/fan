import 'package:flutter/material.dart';

typedef GradeSelectCallback = void Function(FanGradeType value);

/// 风扇控制按钮
class FanGradeWidget extends StatefulWidget {
  final GradeSelectCallback onGradeSelect;

  const FanGradeWidget({Key? key, required this.onGradeSelect})
      : super(key: key);

  @override
  State<FanGradeWidget> createState() => _FanGradeWidgetState();
}

class _FanGradeWidgetState extends State<FanGradeWidget> {
  final FanBtnManager stamps = FanBtnManager();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: stamps.onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: stamps.onTapCancel,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 60),
        painter: FanBtnPainter(stamps),
      ),
    );
  }

  void _onTapUp(TapUpDetails details) {
    stamps.onTapUp(details);
    FanPaintModel model = stamps.list.firstWhere(
        (value) => value.state == FanPaintState.select,
        orElse: (() => FanPaintModel(FanGradeType.off)));
    widget.onGradeSelect.call(model.type);
  }
}

class FanBtnPainter extends CustomPainter {
  FanBtnPainter(this.manage) : super(repaint: manage);

  final FanBtnManager manage;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    for (var i = 0; i < manage.list.length; i++) {
      FanPaintModel model = manage.list[i];
      canvas.save();
      double left = (-manage.list.length / 2 + i + 0.5) * (model.size + 15);
      canvas.translate(left, 0);
      model.paint(
          canvas,
          Rect.fromCenter(
              center: Offset(left + size.width / 2, model.size / 2),
              width: model.size,
              height: model.size));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FanBtnPainter oldDelegate) => manage != oldDelegate.manage;
}

enum FanPaintState { none, select, down }

enum FanGradeType { off, grade1, grade2, grade3 }

class FanPaintModel {
  FanPaintModel(this.type);

  final FanGradeType type;
  late FanPaintState state = FanPaintState.none;

  Color get color => state == FanPaintState.select
      ? const Color.fromARGB(255, 0, 222, 137)
      : Colors.black54;

  late Rect rect;
  double size = 50;

  Paint paintBorder = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

  Paint gradePaint = Paint()
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  Path? _path;

  Path get path {
    if (_path != null) {
      return _path!;
    } else {
      _path = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: size,
            height: size,
          ),
          const Radius.circular(5),
        ));
      return _path!;
    }
  }

  void paint(Canvas canvas, Rect rect) {
    this.rect = rect;
    switch (state) {
      case FanPaintState.down:
      case FanPaintState.select:
        canvas.drawShadow(
            path.shift(const Offset(0, -1)), Colors.white, 2, false);
        break;
      case FanPaintState.none:
      default:
        canvas.drawShadow(
            path.shift(const Offset(0, -2)), Colors.white, 8, false);
    }
    canvas.drawPath(path, paintBorder);
    canvas.drawPath(_gradePath(), gradePaint..color = color);
  }

  Path _gradePath() {
    Path gradePath = Path();
    switch (type) {
      case FanGradeType.off:
        gradePath = Path()
          ..addOval(
            Rect.fromCircle(center: Offset.zero, radius: size / 2 * 0.4),
          );
        break;
      case FanGradeType.grade1:
        gradePath = Path()
          ..moveTo(-size / 2 + 10, 5)
          ..lineTo(size / 2 - 20, 5)
          ..relativeQuadraticBezierTo(10, 0, 8, -8)
          ..relativeQuadraticBezierTo(-4, -8, -10, 0);
        break;
      case FanGradeType.grade2:
        gradePath = Path()
          ..moveTo(-size / 2 + 10, 0)
          ..lineTo(size / 2 - 20, 0)
          ..relativeQuadraticBezierTo(10, 0, 8, -8)
          ..relativeQuadraticBezierTo(-4, -8, -10, 0)
          ..moveTo(-size / 2 + 10, 5)
          ..relativeLineTo(15, 0)
          ..relativeQuadraticBezierTo(10, 0, 7, 8)
          ..relativeQuadraticBezierTo(-4, 5, -8, 0);
        break;
      case FanGradeType.grade3:
        gradePath = Path()
          ..moveTo(-size / 2 + 10, 0)
          ..lineTo(size / 2 - 15, 0)
          ..relativeQuadraticBezierTo(10, 0, 8, -8)
          ..relativeQuadraticBezierTo(-4, -8, -10, 0)
          ..moveTo(-size / 2 + 10, -5)
          ..lineTo(size / 2 - 30, -5)
          ..relativeQuadraticBezierTo(10, 0, 8, -8)
          ..relativeQuadraticBezierTo(-5, -8, -10, 0)
          ..moveTo(-size / 2 + 10, 5)
          ..relativeLineTo(15, 0)
          ..relativeQuadraticBezierTo(10, 0, 7, 8)
          ..relativeQuadraticBezierTo(-4, 5, -8, 0);
        break;
      default:
    }
    return gradePath;
  }
}

class FanBtnManager extends ChangeNotifier {
  List<FanPaintModel> list = [
    FanPaintModel(FanGradeType.off),
    FanPaintModel(FanGradeType.grade1),
    FanPaintModel(FanGradeType.grade2),
    FanPaintModel(FanGradeType.grade3),
  ];

  void onTapDown(TapDownDetails details) {
    for (var model in list) {
      if (!model.rect.contains(details.localPosition)) continue;
      if (model.state == FanPaintState.select) break;
      model.state = FanPaintState.down;
      break;
    }
    notifyListeners();
  }

  void onTapUp(TapUpDetails details) {
    for (var model in list) {
      if (model.rect.contains(details.localPosition)) {
        model.state = model.state == FanPaintState.select
            ? FanPaintState.none
            : FanPaintState.select;
        if (model.type == FanGradeType.off) model.state = FanPaintState.none;
      } else {
        model.state = FanPaintState.none;
      }
    }
    notifyListeners();
  }

  void onTapCancel() {
    for (var model in list) {
      if (model.state == FanPaintState.select) continue;
      model.state = FanPaintState.none;
    }
    notifyListeners();
  }
}
