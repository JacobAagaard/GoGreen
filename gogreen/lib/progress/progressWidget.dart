import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/helper/enumHelper.dart';
import 'package:gogreen/helper/stringHelper.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:async/async.dart';
import 'lineChart.dart';

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  ReceiptDao _receiptDao = ReceiptDao();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  bool firstRendering = true;
  String _chipValue;
  Map<DateTime, List<Receipt>> monthData;
  List<MonthEmission> monthEmission;
  List<MonthEmission> modifiedMonthEmission;
  List<charts.Series<MonthEmission, DateTime>> monthEmissionSeries;

  Future<dynamic> _fetchData() {
    return this._memoizer.runOnce(() async {
      List<Receipt> receipt = await _receiptDao.getAllReceipts();
      return receipt;
    });
  }

  void processRawData(List<Receipt> data) {
    if (monthData != null) return;

    print("process Raw Data");
    bool firstIter = true;

    // Divide by month
    data.forEach((Receipt receipt) {
      DateTime tempKey = DateTime(receipt.timestamp.year, receipt.timestamp.month);
      if (monthData != null && monthData.containsKey(tempKey)) {
        monthData[tempKey].add(receipt);
      } else if (monthData == null) {
        monthData = {
          tempKey: [receipt]
        };
      } else {
        monthData[tempKey] = [receipt];
      }
    });

    // calculate month emission
    monthData.forEach((month, list) {
      MonthEmission temp = new MonthEmission(month,
          list.fold(0, (value, element) => value + element.totalEmission));

      if (firstIter == true) {
        monthEmission = [temp];
        firstIter = false;
      } else
        monthEmission.add(temp);
    });

    //monthEmission.sort((a, b) => b.month.compareTo(a.month));

    monthEmissionSeries = [
      new charts.Series<MonthEmission, DateTime>(
        id: 'realEmission',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (MonthEmission item, _) => item.month,
        measureFn: (MonthEmission item, _) => item.emission,
        data: monthEmission,
      )
    ];
  }

  removeFoodType(List<String> foodList) {
    bool firstIter = true;
    modifiedMonthEmission = null;

    monthData.forEach((key, receiptList) {
      double totalEmission = 0;
      for (Receipt receipt in receiptList) {
        receipt.items.forEach((item) {
          if (!foodList.contains(item.foodType)) {
            totalEmission += item.emission;
          }
        });
      }

      MonthEmission temp = new MonthEmission(key, totalEmission);

      if (firstIter == true) {
        modifiedMonthEmission = [temp];
        firstIter = false;
      } else
        modifiedMonthEmission.add(temp);
    });

    if (monthEmissionSeries.length == 1) {
      monthEmissionSeries.add(new charts.Series<MonthEmission, DateTime>(
        id: 'modifiedEmission',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (MonthEmission item, _) => item.month,
        measureFn: (MonthEmission item, _) => item.emission,
        data: modifiedMonthEmission,
      ));
    } else {
      monthEmissionSeries[1] = new charts.Series<MonthEmission, DateTime>(
        id: 'modifiedEmission',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (MonthEmission item, _) => item.month,
        measureFn: (MonthEmission item, _) => item.emission,
        data: modifiedMonthEmission,
      );
    }
  }

  void modifyData(WhatIf whatIf) {
    firstRendering = false;
    print(whatIf == null ? "remove whafIf curve" : "add " + enumToString(whatIf) + " curve");
    switch (whatIf) {
      case WhatIf.vegetarian:
        removeFoodType(["beef", "chicken", "fish"]);
        break;

      case WhatIf.vegan:
        break;

      default:
        if (monthEmissionSeries.length>1) monthEmissionSeries.removeLast();

    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final screenWidth = queryData.size.width;

    Widget whatIfChip(WhatIf whatIf) {
      String label = enumToString(whatIf);
      return ChoiceChip(
        label: Text(capitalize(label)),
        labelStyle: TextStyle(
            color: _chipValue == label ? Colors.black : Colors.white),
        selected: _chipValue == label,
        onSelected: (bool selected) {
          setState(() {
            _chipValue = selected ? label : null;
            selected ? modifyData(whatIf) : modifyData(null);
          });
        },
        selectedColor: Theme.of(context).accentColor,
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Progress"),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: new FutureBuilder<dynamic>(
              future: _fetchData(),
              // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                List<Widget> children;

                if (snapshot.hasData && snapshot.data.length > 0) {
                  processRawData(snapshot.data);

                  children = <Widget>[
                    Expanded(
                        child: Container(
                            width: screenWidth,
                            child:
                                new StackedAreaLineChart(monthEmissionSeries, animate: firstRendering))),
                    Text("What would if you changed what you ate?"),
                    Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: [
                        whatIfChip(WhatIf.vegetarian),
                      ],
                    ),
                  ];
                } else if (snapshot.hasData && snapshot.data.length == 0) {
                  children = <Widget>[Text("No data available yet")];
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ];
                } else {
                  children = <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 60,
                      height: 60,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    )
                  ];
                }
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                );
              },
            )));
  }
}

class MonthEmission {
  DateTime month;
  double emission;

  MonthEmission(this.month, this.emission);

  @override
  String toString() {
    return "{month: $month, emission: $emission}";
  }
}

enum WhatIf { vegetarian, vegan, none }
