import 'package:flutter/material.dart';

class TipsWidget extends StatefulWidget {
  const TipsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TipsWidgetState();
}

class _TipsWidgetState extends State<TipsWidget> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Tips"),
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
