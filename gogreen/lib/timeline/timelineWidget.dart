import 'package:flutter/material.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Timeline"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("TO BE DONE")
              ],
            )
          ],
        ),
      ),
    );
  }
}
