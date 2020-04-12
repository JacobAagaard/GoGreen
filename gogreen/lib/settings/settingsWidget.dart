import 'package:flutter/material.dart';
import 'package:gogreen/emissionData/emissionDataService.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  static final edService = new EmissionDataService();
  double _personalGoal = edService.getPersonalGoal();

  void setGoal(double value) {
    setState(() {
      _personalGoal = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _c;
    String helperText = "Average is 580kg";
    double amount = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Choose your goal"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                new Expanded(
                  child: TextField(
                    // autofocus: true,
                    controller: _c,
                    decoration: InputDecoration(
                      labelText: "Enter personal goal",
                      helperText: helperText,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      amount = double.parse(value);
                      setState(() {
                        _personalGoal = amount;
                      });
                    },
                  ),
                ),
                Text("kg"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Builder(
                  builder: (rowContext) => Center(
                    child: RaisedButton(
                      onPressed: () {
                        print("amount is $_personalGoal");
                        if (_personalGoal > 0.0) {
                          edService.setPersonalGoal(_personalGoal);
                          Navigator.of(context).pop(_personalGoal);
                        } else {
                          Scaffold.of(rowContext).showSnackBar(
                              SnackBar(content: Text("Amount invalid")));
                        }
                      },
                      child: Text(
                        "SET GOAL",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
