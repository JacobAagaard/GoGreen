// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gogreen/addReceipt/addReceiptWidget.dart';
import 'package:gogreen/overview/emissionOverviewGauge.dart';
import 'package:gogreen/settings/settingsWidget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverviewWidget extends StatefulWidget {
  @override
  OverviewWidgetState createState() => OverviewWidgetState();
}

class OverviewWidgetState extends State<OverviewWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<double> _personalGoal;
  Future<double> _monthlyEmission;

  @override
  void initState() {
    super.initState();
    _personalGoal = _prefs.then((SharedPreferences prefs) {
      prefs.setDouble("personalGoal", 580.0).then((bool success) {
        print(success);
      });
      double storedPersonalGoal = (prefs.getDouble('personalGoal') ?? 580.0);
      return storedPersonalGoal;
    });
    _monthlyEmission = _prefs.then((SharedPreferences prefs) {
      prefs.setDouble("monthlyEmission", 123.0).then((bool success) {
        print(success);
      });

      double storedMonthlyEmission =
          (prefs.getDouble('monthlyEmission') ?? 0.0);
      print("emission $storedMonthlyEmission");
      return storedMonthlyEmission;
    });
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Carbon Emission'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Go to Settings screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsWidget(),
                  )).then((value) {
                print("overview page got value: $value");
                setState(() {
                  _personalGoal = _prefs.then((SharedPreferences prefs) {
                    double storedPersonalGoal =
                        (prefs.getDouble('personalGoal') ?? 0.0);
                    return storedPersonalGoal;
                  });
                });
              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("So far in "),
                Text(
                  "$nowMonth $nowYear",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: maxWidth,
                  height: maxHeight,
                  child: new FutureBuilder(
                    future: Future.wait([_personalGoal, _monthlyEmission]).then(
                      (response) =>
                          new Merged(goal: response[0], emission: response[1]),
                    ),
                    builder:
                        (BuildContext context, AsyncSnapshot<Merged> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Center(
                              child: EmissionOverviewGauge.withSampleData(
                                personalGoal: snapshot.data.goal,
                                monthlyEmission: snapshot.data.emission,
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  splashColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white),
                  ),
                  child: Text(
                    "ADD NEW RECEIPT",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    // Go to Add receipt screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReceiptWidget(),
                      ),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper to extract both values in FutureBuilder
class Merged {
  final double goal;
  final double emission;

  Merged({this.goal, this.emission});
}
