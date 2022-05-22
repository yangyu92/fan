import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fan_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FanWidget(
            onGradeSelect: (value) {
              if (kDebugMode) {
                print(value.index);
              }
            },
          ),
        ),
      ),
    );
  }
}
