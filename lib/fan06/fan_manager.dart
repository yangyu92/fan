import 'dart:math';

import 'package:flutter/cupertino.dart';

/// 风扇转速控制器
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
