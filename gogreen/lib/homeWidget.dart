import 'package:flutter/material.dart';
import "overview/overviewWidget.dart";
import "timeline/timelineWidget.dart";
import "tips/tipsWidget.dart";

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeWidget> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    OverviewWidget(),
    TimelineWidget(),
    TipsWidget()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
              icon: Icon(Icons.visibility), title: Text('Overview')),
          new BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), title: Text('Timeline')),
          new BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), title: Text('Tips'))
        ],
      ),
    );
  }
}
