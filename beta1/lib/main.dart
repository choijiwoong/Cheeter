import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사진 메타데이터 편집기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // 최초 실행 화면으로 MainScreen호출
    );
  }
}
