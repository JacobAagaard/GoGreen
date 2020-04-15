// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key}) : super(key: key);

  @override
  SettingWidgetState createState() => SettingWidgetState();
}

class SettingWidgetState extends State<SettingsWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<double> _personalGoal;
  static String _personalGoalInput;
  var _textController = TextEditingController(text: _personalGoalInput);

  Future<void> _setGoal() async {
    final SharedPreferences prefs = await _prefs;
    final personalGoal = double.parse(_personalGoalInput);

    setState(() {
      _personalGoal =
          prefs.setDouble("personalGoal", personalGoal).then((bool success) {
        return personalGoal;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _personalGoal = _prefs.then((SharedPreferences prefs) {
      return (prefs.getDouble('personalGoal') ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose your goal"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              FutureBuilder<double>(
                future: _personalGoal,
                builder:
                    (BuildContext context, AsyncSnapshot<double> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          children: <Widget>[
                            Text(
                              "Personal Goal: ",
                              style: TextStyle(fontSize: 30),
                            ),
                            Text(
                              "${(snapshot.data.toInt()).toString()} kg",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ],
                        );
                      }
                  }
                },
              ),
              Container(
                padding: EdgeInsets.only(top: 20, left: 120, right: 120),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: "Enter goal",
                          helperText: "Average is 580kg",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          print('new value: $value');
                          setState(() {
                            _personalGoalInput = (value);
                          });
                        },
                        onSubmitted: (value) {
                          _setGoal();
                          Navigator.pop(context, value);
                        },
                      ),
                    ),
                    Text("kg"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
