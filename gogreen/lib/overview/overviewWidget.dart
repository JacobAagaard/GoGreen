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
  Future<List<String>> _receipts;

  @override
  void initState() {
    super.initState();
    _personalGoal = _prefs.then((SharedPreferences prefs) {
      double storedPersonalGoal = 0.0;
      try {
        storedPersonalGoal = prefs.getDouble('personalGoal');
      } catch (e) {
        // Handle launching the app, if getting monthlyEmission above throws exception
        double initialGoal = 580.0;
        prefs.setDouble("personalGoal", initialGoal).then((bool success) {
          success
              ? print("Personal Goal initialized to $initialGoal")
              : print("Personal Goal is unset");
        });
      }

      return storedPersonalGoal;
    });

    _monthlyEmission = _prefs.then((SharedPreferences prefs) {
      double storedMonthlyEmission = 0.0;
      try {
        storedMonthlyEmission = prefs.getDouble('monthlyEmission');
      } catch (e) {
        // Handle launching the app, if getting monthlyEmission above throws exception
        double initialEmission = 0.0;
        prefs
            .setDouble("monthlyEmission", initialEmission)
            .then((bool success) {
          success
              ? print("Monthly Emission initialized to $initialEmission")
              : print("Monthly Emission is unset");
        });
      }

      return storedMonthlyEmission;
    });

    _receipts = _prefs.then((SharedPreferences prefs) {
      List<String> storedReceipts;
      try {
        storedReceipts = prefs.getStringList('receipts');
      } catch (e) {
        // Handle launching the app, if getting receipts above throws exception
        List<String> initialReceipts = [];
        prefs.setStringList("receipts", initialReceipts).then((bool success) {
          success
              ? print("Receipts initialized to $initialReceipts")
              : print("Receipts is unset");
        });
      }

      return storedReceipts;
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
                    return prefs.getDouble('personalGoal');
                  });
                });
              });
            },
          )
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        // padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "So far in ",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      "$nowMonth $nowYear",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: maxWidth,
                    height: maxHeight,
                    child: new FutureBuilder(
                      future:
                          Future.wait([_personalGoal, _monthlyEmission]).then(
                        (response) => new Merged(
                            goal: response[0], emission: response[1]),
                      ),
                      builder: (BuildContext context,
                          AsyncSnapshot<Merged> snapshot) {
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green.shade500, Colors.green.shade300],
                      stops: [0.0, 0.7]),
                ),
                padding: EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: RaisedButton(
                        splashColor: Colors.green,
                        color: Colors.white,
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
                          ).then((amountMap) {
                            Map<String, double> _amountMap = amountMap;
                            if (amountMap != null) {
                              _amountMap.remove("test");
                              double addedEmissions = _amountMap.values
                                  .reduce((value, element) => value + element);
                              String addedReceiptItems = _amountMap.keys.reduce(
                                  (value, element) => value + "|" + element);
                              print("addedReceiptItems: $addedReceiptItems");
                              setState(() {
                                _monthlyEmission =
                                    _prefs.then((SharedPreferences prefs) {
                                  double storedMonthlyEmission =
                                      (prefs.getDouble('monthlyEmission') ??
                                          0.0);

                                  prefs
                                      .setDouble(
                                          'monthlyEmission',
                                          addedEmissions +
                                              storedMonthlyEmission)
                                      .then((success) {});
                                  return addedEmissions + storedMonthlyEmission;
                                });

                                _receipts =
                                    _prefs.then((SharedPreferences prefs) {
                                  List<String> storedReceipts =
                                      prefs.getStringList("receipts");
                                  if (storedReceipts != null) {
                                    var reduced = storedReceipts.join("|");
                                    print(
                                        "Shared prefs returned receipts: $reduced");
                                  }

                                  DateTime receiptTime = new DateTime.now();

                                  List<String> value = [
                                    receiptTime.toIso8601String(),
                                    "|",
                                    addedEmissions.toString(),
                                    "|",
                                    addedReceiptItems
                                  ];

                                  // Append new receipts after a '^' if some exist already
                                  if (storedReceipts != null) {
                                    storedReceipts.add("^");
                                    storedReceipts.addAll(value);
                                    print(
                                        "saving more receipts ${storedReceipts.join('')}");
                                    prefs.setStringList(
                                        "receipts", storedReceipts);
                                    return storedReceipts;
                                  } else {
                                    print(
                                        "saving new receipts ${value.join('')}");
                                    prefs.setStringList("receipts", value);
                                    return value;
                                  }
                                });
                              });
                            } else {
                              print('No values returned from addReceipt');
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green.shade300, Colors.green.shade50],
                          stops: [0.0, 0.7]),
                    ),
                    padding:
                        EdgeInsets.only(top: 10.0, left: 10.0, bottom: 20.0),
                    width: maxWidth + 2 * padding,
                    child: new FutureBuilder(
                      future: _receipts,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          default:
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<Widget> children = [];

                              if (snapshot.hasData) {
                                // Fetch the receipts from the snapshot and do a lot of ugly String / List formatting
                                String receiptListsStr = snapshot.data.join();
                                List<String> receiptLists =
                                    receiptListsStr.split("^");
                                List<Widget> receiptWidgets =
                                    receiptLists.map((receiptListStr) {
                                  List<String> receiptList =
                                      receiptListStr.split("|");

                                  // Extract date the receipt was added
                                  DateTime date =
                                      DateTime.parse(receiptList[0]);
                                  String formattedDate =
                                      DateFormat('d/M/yy - H:m').format(date);
                                  String emission = receiptList[1];
                                  String receiptItemsStr =
                                      receiptList.sublist(2).join("|");

                                  // Extract items to show images
                                  List<String> receiptItems =
                                      receiptItemsStr.split("|");

                                  List<Image> receiptImgs = receiptItems
                                      .map(
                                        (item) =>
                                            new Image.asset("images/$item.png"),
                                      )
                                      .toList();

                                  List<Widget> imgWidgets = receiptImgs
                                      .map((img) => Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6.0, right: 8.0),
                                            child: new Image(
                                                image: img.image, width: 25),
                                          ))
                                      .toList();

                                  Widget child = Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black45,
                                                blurRadius:
                                                    1.0, // has the effect of softening the shadow
                                                spreadRadius:
                                                    1.0, // has the effect of extending the shadow
                                                offset: Offset(
                                                  1.0, // horizontal, move right 1px
                                                  1.0, // vertical, move down 1px
                                                ),
                                              )
                                            ],
                                            color: Colors.green,
                                          ),
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(
                                            Icons.shopping_cart,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              bottom: 10.0,
                                              top: 10.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    "$formattedDate",
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                  Text(" | "),
                                                  Text(
                                                    "${emission.split('.')[0]}kg CO₂",
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: imgWidgets,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Don't add the edit icon since editing is not supported right now
                                        // Column(
                                        //   // mainAxisAlignment: MainAxisAlignment.end,
                                        //   crossAxisAlignment: CrossAxisAlignment.end,
                                        //   children: <Widget>[
                                        //     Icon(Icons.edit,
                                        //         color: Colors.grey, size: 20)
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  );

                                  return child;
                                }).toList();

                                children.addAll(receiptWidgets);
                              } else {
                                children = <Widget>[
                                  Icon(
                                    Icons.shopping_cart,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  Text(
                                    "No receipts to show yet...",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ];
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children,
                              );
                            }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
