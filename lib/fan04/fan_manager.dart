import 'dart:math';

import 'package:flutter/cupertino.dart';

/// create by 张风捷特烈 on 2020/11/7
/// contact me by email 1981462002@qq.com
/// 说明:

class FanManage with ChangeNotifier {
  // 角度
  double rotation = 0;
  // 当前速度
  double speed = 0;
  // 当前最大速度
  double max1 = 6;
  // 加速度
  double velocity;
  // 减速度
  double mVelocity = 1;

  FanManage({this.velocity = 2});

  void tick() {
    doUpdate();
    notifyListeners();
  }

  void updateMax(double max) {
    if (speed < 0) {
      speed = 0;
    }
    max1 = max;
  }

  void doUpdate() {
    if (speed <= max1) {
      speed += velocity * pi / 180;
    } else {
      speed -= mVelocity * pi / 180;
    }
    rotation += speed;
    if (rotation > 360) {
      rotation = 0;
    }
  }

  void reset() {
    notifyListeners();
  }
}
