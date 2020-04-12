// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gogreen/addReceipt/addReceiptWidget.dart';
import 'package:gogreen/overview/emissionOverviewGauge.dart';
import 'package:gogreen/settings/settingsWidget.dart';
import 'package:intl/intl.dart';

class OverviewWidget extends StatelessWidget {
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Go to Settings screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsWidget(),
                ),
              );
            },
          )
        ],
        title: Text('Carbon Emission'),
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
                  child: EmissionOverviewGauge.withSampleData(),
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
