# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project nature

教学示例项目:用 Flutter `CustomPainter` 从零绘制一个可交互的电风扇 UI。**不是产品**,而是一组分阶段迭代的 demo,目的是配合 README.md 中的图文教程逐步演示绘制技巧(外壳 → 扇叶 → 动画 → 档位 → 灯柱 → 控制按钮)。

依赖刻意保持最小:只用 `flutter` SDK、`cupertino_icons`、`flutter_lints`。SDK 约束已对齐到 Flutter 3.38 / Dart 3.9+,但 `lib/` 下的源码仍是项目最初(Dart 2.x / Flutter 3.0)的风格 — 教程截图与 README 引用都基于此。新 lints 在老代码上会报一批 info/warning(`use_super_parameters`、`unreachable_switch_default`、`window` deprecated、`strict_top_level_inference`),**这些不是 bug,是历史风格残留**。除非用户明确要"代码现代化",否则不要顺手改这些 — 改了会让 README 截图/代码块与实际源码脱节。

## Common commands

```bash
flutter pub get                         # 装依赖
flutter run                             # 跑 lib/main.dart(当前指向 fan06 完整版)
flutter analyze                         # 静态检查(用 flutter_lints 默认规则)
flutter build apk / ios                 # 构建
```

**仅支持 Android 与 iOS** — Linux/macOS/web/Windows 已显式移除(目录与 `.metadata` 平台条目都删了)。如果用户想加回某个平台,跑 `flutter create --platforms=<name> .` 而不是手动建目录。

无单元测试目录(`test/` 不存在),`flutter test` 当前没东西可跑 — 这是 demo 项目,不要假装"先跑测试"。

## Architecture: 迭代演进而非模块化

`lib/` 下每个 `fanXX/` 是**一个独立可运行的 demo**,代表教程的一个阶段。它们**不互相 import**,每个目录都有自己的 `main.dart`(除了 `fan02` 是中间变体只有 widget)。顶层 `lib/main.dart` 只是默认指向最完整的 `fan06`。

```
fan01           只画风扇壳(外圆 + 支架线 + 内圆)
fan01_tap,
fan01_tap2      在 fan01 基础上加手势 / 状态变体
fan02           加扇叶绘制(贝塞尔曲线)
fan03           引入 FanManage(ChangeNotifier)+ Ticker 实现转动
fan04           完善加/减速度逻辑
fan05           加档位与灯柱绘制
fan06           最终完整版:壳 + 叶 + 灯柱 + 控制按钮
```

要切换默认运行哪一版,改 `lib/main.dart` 顶部的 `import 'fanXX/fan_widget.dart';` 即可。也可以 `flutter run -t lib/fan03/main.dart` 单独跑某个阶段。

## Architecture: fan06 完整版的运行模型

最终版的关键分层(对应 `lib/fan06/`):

- **`FanManage` (`fan_manager.dart`)** — `ChangeNotifier`,保存 `rotation` / `speed` / `max` / `velocity`。每个 tick 增量更新 `speed`(向 `max` 收敛,自带加减速),累加 `rotation`,然后 `notifyListeners()`。**这是动画的唯一状态源**。
- **`FanWidget` (`fan_widget.dart`)** — `StatefulWidget` + `SingleTickerProviderStateMixin`,持有 `FanManage pm` 和 `ValueNotifier<int> upholderNum`(当前档位)。用 `createTicker(_tick)` 驱动 `pm.tick()`,**当 `pm.speed < 0` 时主动 `_ticker.stop()` 省电**,切档时再 `_ticker.start()`。
- **Painter 三件套** — 各自只 listen 自己关心的状态:
  - `FanPainter`(扇叶):`repaint: manage`,读 `manage.rotation` 旋转画布
  - `ShellPainter`(外壳):静态,套 `RepaintBoundary` 避免被扇叶重绘连带
  - `UpholderPainter`(灯柱 + 档位灯):`repaint: upholderNum`
- **`FanGradeWidget` (`fan_grade_widget.dart`)** — 底部 4 个档位按钮(off/1/2/3)。`FanBtnManager` + `FanPaintModel` 自管手势态(none/select/down)与按钮路径,通过 `onGradeSelect` 回调把 `FanGradeType` 抛给 `FanWidget.chageGrade`。

数据流:**按钮 tap → `chageGrade(type)` → `pm.updateGrade(max)` + `upholderNum.value = type.index` → Ticker 驱动 `pm.tick()` → `FanPainter` / `UpholderPainter` 各自重绘**。`ShellPainter` 永远不重绘。

## 涉及绘制时要注意的几点

- 扇叶路径在循环里**一次性构建并 transform**(README §二)而不是"画一片然后 rotate 多次" — 后者会让动画掉帧。改扇叶时保留这个模式。
- `canvas.drawCircle` 画 stroke 时线条会向外扩展线宽的一半,半径要减去线宽(见 `shell_painter.dart`)。
- 动画速度是"每帧弧度增量",**帧率不同的设备转速会不一样**(README 已注明,iPhone 13 Pro 120Hz 会更快)。这是已知设计,不要"修复"成基于真实时间的插值,除非用户明确要求。
- 各 Painter 的 `shouldRepaint` 通常返回 `false`,靠 `CustomPaint(painter: ..., repaint: notifier)` 触发重绘 — 改 Painter 时不要随手返回 `true`。

## Lint / 风格

`analysis_options.yaml` 仅 include `package:flutter_lints/flutter.yaml`,没有自定义规则。提交前跑 `flutter analyze` 检查;不要新增自定义 lint 除非有具体理由。
