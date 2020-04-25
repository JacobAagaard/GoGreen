import 'package:flutter/material.dart';
import 'package:gogreen/overview/emissionOverviewGauge.dart';
import 'package:intl/intl.dart';

class CompareEmissionWidget extends StatefulWidget {
  CompareEmissionWidget(this.personalGoal, this.monthlyEmission);
  final personalGoal;
  final monthlyEmission;

  @override
  CompareEmissionWidgetState createState() =>
      CompareEmissionWidgetState(personalGoal, monthlyEmission);
}

class CompareEmissionWidgetState extends State<CompareEmissionWidget> {
  double personalGoal;
  double monthlyEmission;
  CompareEmissionWidgetState(this.personalGoal, this.monthlyEmission);

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final screenWidth = queryData.size.width;
    final padding = 20.0;
    final maxWidth = screenWidth - 2 * padding;
    final maxHeight = maxWidth * .75;
    var now = DateTime.now();
    var nowMonth = DateFormat('MMMM').format(now);
    var nowYear = now.year;

    var emissionsDiff = (personalGoal - monthlyEmission).abs();

    return Scaffold(
      appBar: AppBar(
        title: Text('More stats for you'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$nowMonth $nowYear",
                  style: TextStyle(color: Colors.green.shade700, fontSize: 20),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: maxWidth,
                  height: maxHeight,
                  child: Center(
                    child: EmissionOverviewGauge.withSampleData(
                      personalGoal: personalGoal,
                      monthlyEmission: monthlyEmission,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Your monthly emissions ${monthlyEmission > personalGoal ? 'surplus equals' : 'savings equal'} to:",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  getComparison(emissionsDiff, maxWidth, 3.2, "watching",
                      "hours of Netflix", "images/netflix.jpg"),
                  getComparison(emissionsDiff, maxWidth, 4.0, "driving", "km",
                      "images/driving.jpg"),
                  getComparison(emissionsDiff, maxWidth, 50, "planting",
                      "tree seedlings", "images/seedling.jpg"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getComparison(double emissionsDiff, double maxWidth, double factor,
    String text1, String text2, String imgPath) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Column(
      children: <Widget>[
        Container(
          width: maxWidth * 0.9,
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: Image.asset(imgPath).image),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${emissionsDiff ~/ factor}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                text2,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
