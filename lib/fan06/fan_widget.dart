import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'fan_grade_widget.dart';
import 'fan_manager.dart';
import 'fan_painter.dart';
import 'shell_painter.dart';
import 'upholder_painter.dart';

/// 风扇
class FanWidget extends StatefulWidget {
  const FanWidget({Key? key}) : super(key: key);

  @override
  State<FanWidget> createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget>
    with SingleTickerProviderStateMixin {
  // 风扇页控制器
  late FanManage pm = FanManage();
  // 控制灯柱上灯亮的长度
  final ValueNotifier<int> upholderNum = ValueNotifier<int>(0);

  late Ticker _ticker;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  // 切换档位 → 目标角速度(rad/s)
  void chageGrade(FanGradeType type) {
    const targets = {
      FanGradeType.off: 0.0,
      FanGradeType.grade1: 6.0,
      FanGradeType.grade2: 8.0,
      FanGradeType.grade3: 10.0,
    };
    pm.updateGrade(targets[type] ?? 0);
    upholderNum.value = type.index;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  // 风扇页旋转帧动画。基于物理仿真的 dt 累计角度,跨设备帧率一致
  void _tick(Duration duration) {
    pm.tick(duration);
    if (!pm.isAnimating && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fanSize = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: fanSize - height * 0.1,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(45, height - (fanSize - height * 0.1) - 130),
                painter: UpholderPainter(upholderNum: upholderNum),
              ),
            ),
          ),
          Positioned(
            top: height * 0.1,
            child: CustomPaint(
              size: Size(fanSize, fanSize),
              painter: FanPainter(fanSize, manage: pm),
            ),
          ),
          Positioned(
            top: height * 0.1,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(fanSize, fanSize),
                painter: ShellPainter(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: RepaintBoundary(
                child: FanGradeWidget(onGradeSelect: chageGrade),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
