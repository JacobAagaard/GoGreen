// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gogreen/addReceipt/addReceiptWidget.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'package:gogreen/overview/emissionOverviewGauge.dart';
import 'package:gogreen/settings/settingsWidget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OverviewWidget extends StatefulWidget {
  @override
  OverviewWidgetState createState() => OverviewWidgetState();
}

class OverviewWidgetState extends State<OverviewWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  ReceiptDao _receiptDao = ReceiptDao();

  Future<dynamic> _fetchData() async {
      List<Receipt> receipts = await _receiptDao.getCurrentMonthReceipts();
      double tempEmission = 0;
      receipts.forEach((Receipt receipt) {
        tempEmission += receipt.totalEmission;
      });

      SharedPreferences prefs = await _prefs;
      double storedPersonalGoal = 0.0;
      storedPersonalGoal = prefs.getDouble('personalGoal');
      if (storedPersonalGoal == null) {
        // Handle launching the app, if getting monthlyEmission above throws exception
        double initialGoal = 580.0;
        prefs.setDouble("personalGoal", initialGoal).then((bool success) {
          success ? print("Personal Goal initialized to $initialGoal") : print("Personal Goal is unset");
        });
      }
      return new Merged(goal: storedPersonalGoal, emission: tempEmission, receipts: receipts);
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
                  ));
            },
          )
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
                      future: _fetchData(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          default:
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              if (snapshot.hasData && snapshot.data.emission != null) {
                                return Center(
                                  child: EmissionOverviewGauge.withSampleData(
                                    personalGoal: snapshot.data.goal,
                                    monthlyEmission: snapshot.data.emission,
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }
                        }
                      },
                    ),
                  ),
                ],
              ),
              new Stack(
                children: <Widget>[
                  Container(
                    height: 102,
                    margin: EdgeInsets.only(top: 20.0),
                    child: SvgPicture.asset("images/wave.svg"),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 60.0),
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
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green.shade400, Colors.green.shade100],
                          stops: [0.1, 0.7]),
                    ),
                    padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 20.0),
                    width: maxWidth + 2 * padding,
                    child: new FutureBuilder(
                      future: _fetchData(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          default:
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<Widget> children = [];

                              if (snapshot.hasData && snapshot.data.receipts.length > 0) {
                                List<Widget> receiptWidgets = snapshot.data.receipts.map<Widget>((Receipt receipt) {
                                  List<Widget> imgWidgets = receipt.items.map((item) {
                                    Image img = new Image.asset("images/${item.foodType}.png");
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                                      child: new Image(image: img.image, width: 25),
                                    );
                                  }).toList();

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
                                                blurRadius: 1.0,
                                                // has the effect of softening the shadow
                                                spreadRadius: 1.0,
                                                // has the effect of extending the shadow
                                                offset: Offset(
                                                  1.0,
                                                  // horizontal, move right 1px
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
                                          padding: const EdgeInsets.only(left: 15.0, bottom: 10.0, top: 10.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    "${DateFormat("dd/MM/yyyy - HH:mm").format(receipt.timestamp)}",
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                  Text(" | "),
                                                  Text(
                                                    "${receipt.totalEmission.round()}kg CO₂",
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight: FontWeight.bold,
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
  final List<Receipt> receipts;

  Merged({this.goal, this.emission, this.receipts});
}
