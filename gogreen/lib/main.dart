import 'package:flutter/material.dart';
import 'homeWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Green',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.purple,
      ),
      home: HomeWidget(),
    );
  }
}