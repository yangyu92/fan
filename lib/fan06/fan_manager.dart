import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

/// 风扇转速控制器
///
/// - 启动/升档:SpringSimulation 平滑收敛到目标角速度
/// - 关机:线性恒减速度(库仑摩擦模型)。FrictionSimulation 的指数衰减有
///   长尾,实测"快停时仍在缓慢转动",不符合机械风扇关机感受,故弃用
/// - 单位:speed = rad/s,rotation = rad。基于时间步长 dt,跨设备帧率一致
class FanManage with ChangeNotifier {
  double rotation = 0;
  double speed = 0;

  // 启动/升档分支
  Simulation? _speedSim;
  Duration? _simStart;
  double _targetSpeed = 0;

  // 关机分支:库仑摩擦的恒减速滑停
  bool _coasting = false;

  Duration? _lastTick;

  // 临界阻尼弹簧:平滑收敛到 target,无 overshoot
  static final SpringDescription _spring = SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: 10.0,
    ratio: 1.0,
  );

  // 关机减速度 (rad/s²)。从 10 rad/s 关机约需 10/_decel 秒停下
  static const double _decel = 3.0;

  /// 切换目标角速度。target > 0 启动/升降档,== 0 关机滑停
  void updateGrade(double target) {
    _targetSpeed = target;
    _simStart = null;
    if (target > 0) {
      _coasting = false;
      _speedSim = SpringSimulation(_spring, speed, target, 0);
    } else {
      _speedSim = null;
      _coasting = speed > 0;
    }
  }

  /// Ticker 每帧回调。elapsed 是 Ticker 的累计运行时间
  void tick(Duration elapsed) {
    double dt = 0;
    if (_lastTick != null) {
      dt =
          (elapsed - _lastTick!).inMicroseconds /
          Duration.microsecondsPerSecond;
    }
    _lastTick = elapsed;

    if (_speedSim != null) {
      _simStart ??= elapsed;
      final t =
          (elapsed - _simStart!).inMicroseconds /
          Duration.microsecondsPerSecond;
      final sim = _speedSim!;
      speed = sim.x(t);
      if (sim.isDone(t)) {
        _speedSim = null;
        _simStart = null;
        speed = _targetSpeed;
      }
    } else if (_coasting) {
      speed = (speed - _decel * dt).clamp(0.0, double.infinity);
      if (speed == 0) {
        _coasting = false;
      }
    }

    rotation += speed * dt;
    if (rotation > 2 * pi) rotation -= 2 * pi;

    notifyListeners();
  }

  /// 是否需要继续 ticker
  bool get isAnimating => _speedSim != null || _coasting || speed > 0.001;
}
