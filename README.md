# Flutter绘制一个风扇

## 本文涉及到的知识点

* CustomPainter自定义绘制
* Path路径绘制，包含直线，圆，贝塞尔曲线，阴影等
* Ticker实现惯性旋转动画

> 废话不多说，上效果：

![1653125977134108.gif](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bda549143b54485aa7f5469453341381~tplv-k3u1fbpfcp-watermark.image?)

## 一、风扇壳绘制

> 风扇壳包含三部分：外边框、支架线条、内圆。通过自定义CustomPainter布局，使用canvas.drawCircle绘制外圆；

![WX20220522-152522@2x.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3a0ba3ebeeb424697d31c3226ba36b0~tplv-k3u1fbpfcp-watermark.image?)

> 绘制外边框

```dart
Paint paintShell = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..color = const Color(0xFF888888);
    
// 圆形的半径需要减去线条宽度
double radius = size.width / 2 - 5;
canvas.drawCircle(
  Offset.zero,
  radius,
  paintShell..strokeWidth = 5,
);
```

`` 注意：由于绘制线条时，会超出画布大小，线条绘制会超出线条宽度的一半。 ``

> 绘制支架线条：线条从圆心开始绘制，绘制count数目的线条数。也可以绘制外圆直径，这时候只需要绘制count/2数目的线条。

`pi为半圆，所以此处旋转角为: pi * 2 / count`

```dart
// 风扇壳上线条数
int count = 24;
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
```

> 绘制内圆，改变画笔的为填充属性：

`paintShell..style = PaintingStyle.fill`

```dart
canvas.drawCircle(
    Offset.zero,
    radius / 7,
    paintShell
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF656565));
```

至此，风扇的外壳绘制完毕。

## 二、风扇页绘制

> 使用path.relativeCubicTo绘制贝塞尔曲线，具体需要大家自行了解贝塞尔曲线的绘制。

![WX20220522-152607@2x.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/45ff58233a03412bb5b5621b110a453c~tplv-k3u1fbpfcp-watermark.image?)

```dart
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

Paint paintBlades = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0
    ..color = const Color(0xFFE8E8E8);

// 风扇页数目
int bladesCount = 8;
Path path = Path();
path.moveTo(0, 0);
for (var i = 0; i < bladesCount; i++) {
  // 计算每次旋转角度数
  var step = 2 * pi / bladesCount;
  Matrix4 m4 = Matrix4.translationValues(size / 2, size / 2, 0);
  Matrix4 rotateM4 = Matrix4.rotationZ(step);
  m4.multiply(rotateM4);
  // 根据角度数旋转绘制的路径
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

canvas.drawPath(path, paintBlades);
```

`` 可以先绘制一个扇叶然后旋转，但是由于后期制作动画时，此处的计算会导致旋转动画掉帧，所以此处使用一次性将路径绘制，并缓存到变量中，防止反复创建路径。 ``

## 三、风扇页实现动画

> 通过旋转画布的方式实现风扇页的旋转

```dart
/// 定义风扇转速控制器
class FanManage with ChangeNotifier {
  // 角度
  double rotation = 0;
  // 当前速度
  double speed = 0;
  // 当前最大速度(每帧旋转角度数)
  double max = 6;
  // 加速度
  double velocity;
  // 减速度
  double mVelocity = 1;

  FanManage({this.velocity = 2});

  void tick() {
    doUpdate();
    notifyListeners();
  }

  void updateGrade(double max) {
    if (speed < 0) {
      speed = 0;
    }
    this.max = max;
  }

  void doUpdate() {
    if (speed <= max) {
      speed += velocity * pi / 180;
    } else {
      speed -= mVelocity * pi / 180;
    }
    rotation += speed;
    if (rotation > 360) {
      rotation = 0;
    }
  }
}
```

> 定义的widget中实现SingleTickerProviderStateMixin，创建动画帧记录器。

`_ticker = createTicker(_tick).start();`

```dart
// 风扇页控制器
late FanManage pm = FanManage();
_ticker = createTicker(_tick);
CustomPaint(
  painter: FanPainter(manage: pm),
)
// 风扇页旋转帧动画
// iPhone13 Pro支持120帧, 此处帧率不一样的设备转速会不一样
void _tick(Duration duration) {
    // 速度小于0时，停止帧记录器的执行
    if (pm.speed < 0) {
      if (_ticker.isActive) {
        _ticker.stop();
      }
    } else {
      pm.tick();
    }
}
```

上述代码让风扇页旋转起来，详细代码见文末源码fan04。

## 四、风扇柱绘制

> 风扇柱包含阴影绘制，当前档位亮灯绘制。

![WX20220522-152729@2x.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/20d4a01fc6fe47d7a62ad5e43a8eaed4~tplv-k3u1fbpfcp-watermark.image?)

> 使用canvas画布的drawShadow绘制边框阴影，使用paint画笔maskFilter进行模糊处理，使阴影看上去更立体。

`绘制指示灯使用同样的方法。`

```dart
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
```

> 指示灯绘制，upholderNum为当前显示的档位，此处根据当前显示档位的位置，控制绘制指示灯的起始位置，避免切换档位时，灯的绘制位置发生变化。

```dart
Paint paint = Paint()
  ..style = PaintingStyle.fill
  ..color = const Color(0xFF656565)
  ..isAntiAlias = true;
double width = 12;
double height = 60;
double lampHeight = (height - 20) / 3;
// 根据档位，移动画布，让指示灯起始点保持一致
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
canvas.drawPath(lampPath, paint..color = const Color(0xFF00FF00));
```

此时灯柱绘制完毕，最终我们需要使用Stack布局，使绘制的内容同时呈现到一个widget中，具体代码见详细源码。

## 五、绘制控制按钮

> 底部控制按钮的绘制，其中包含阴影，已经按钮中的图形，按钮中的图形使用贝塞尔曲线绘制。

![WX20220522-152711@2x.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95ba9265171347968d6c68b785afec95~tplv-k3u1fbpfcp-watermark.image?)

> 按钮的状态有按下效果，选中效果，需要定义一个按钮的实体模型，模型中包含不同状态时需要显示的颜色，阴影，以及图形路径。

`不同档位的按钮，我们需要绘制不同的图形，另外我们需要根据选中与按下状态控制按钮的阴影与颜色。`

```dart
// 按钮的选中
enum FanPaintState { none, select, down }

// 按钮的类型，包含开关与不同档位
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
```

> 由于我们在按钮模型中定义了曲线，此处直接使用CustomPainter绘制。

```dart
// 定义控制按钮数组
List<FanPaintModel> list = [
    FanPaintModel(FanGradeType.off),
    FanPaintModel(FanGradeType.grade1),
    FanPaintModel(FanGradeType.grade2),
    FanPaintModel(FanGradeType.grade3),
];
for (var i = 0; i < list.length; i++) {
  FanPaintModel model = list[i];
  canvas.save();
  double left = (-list.length / 2 + i + 0.5) * (model.size + 15);
  canvas.translate(left, 0);
  model.paint(
      canvas,
      Rect.fromCenter(
          center: Offset(left + size.width / 2, model.size / 2),
          width: model.size,
          height: model.size));
  canvas.restore();
}
```

至此，绘制工作已经完毕。我们还需要将按钮事件与风扇的旋转结合起来。

> 定义按钮按下时的控制器。

```dart
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
```

> 通过GestureDetector监听手势。

```dart
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
// 按钮点击后修改按钮组中的状态
void _onTapUp(TapUpDetails details) {
    stamps.onTapUp(details);
    FanPaintModel model = stamps.list.firstWhere(
        (value) => value.state == FanPaintState.select,
        orElse: (() => FanPaintModel(FanGradeType.off)));
    widget.onGradeSelect.call(model.type);
}
```

> 最后我们将代码组装起来，定义一个widget，布局绘制的内容。同时，使用按钮控制器控制档位，指示灯的显示，风扇的旋转。具体效果如文章顶部。

详细代码见github源代码。

路漫漫其修远兮，吾将上下而求索。学无止境，花了一周零散的时间总算完成啦，总结一下。
