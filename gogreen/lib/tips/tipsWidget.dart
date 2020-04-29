import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/emissionData/emissionDataService.dart';
import 'package:gogreen/helper/constants.dart';
import 'package:gogreen/helper/stringHelper.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'package:async/async.dart';

class TipsWidget extends StatefulWidget {
  const TipsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TipsWidgetState();
}

class _TipsWidgetState extends State<TipsWidget> {
  ReceiptDao _receiptDao = ReceiptDao();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Map<DateTime, List<Receipt>> monthData;

  Future<dynamic> _fetchData() {
    return this._memoizer.runOnce(() async {
      List<Receipt> receipt = await _receiptDao.getAllReceipts();
      return receipt;
    });
  }

  @override
  Widget build(BuildContext context) {
    _insertReceiptTest() {
      _receiptDao.insertFakeReceipt();
    }

    _getReceiptTest() async {
      List<Receipt> updatedReceiptList = await _receiptDao.getAllReceipts();
      updatedReceiptList.forEach((item) => print(item.toMap().toString()));
    }

    _deleteAllTest() async {
      await _receiptDao.deleteAll();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("GoGreen Tips"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     RaisedButton(
            //         child: Text(
            //           "ADD\nFAKE DATA",
            //           style: TextStyle(color: Colors.green),
            //         ),
            //         onPressed: _insertReceiptTest),
            //     RaisedButton(
            //         child: Text(
            //           "SHOW\nDB",
            //           style: TextStyle(color: Colors.green),
            //         ),
            //         onPressed: _getReceiptTest),
            //     RaisedButton(
            //         child: Text(
            //           "DELETE\nALL",
            //           style: TextStyle(color: Colors.green),
            //         ),
            //         onPressed: _deleteAllTest)
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<dynamic>(
                future: _fetchData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Widget> children = [];

                  if (snapshot.hasData && snapshot.data.length > 0) {
                    var data = snapshot.data;
                    Map<String, double> foodTypes = {};

                    // find unique foodTypes
                    data.forEach((Receipt receipt) {
                      receipt.items.forEach((ReceiptItem receiptItem) {
                        foodTypes.putIfAbsent(
                            receiptItem.foodType, () => receiptItem.emission);
                      });
                    });

                    EmissionDataService _emissionDataService =
                        new EmissionDataService();

                    children.add(Center(
                      child: Text(
                        "Here are some tips to decrease your footprint",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ));

                    children.addAll(List.generate(
                      foodTypes.length,
                      (index) {
                        Widget widget;
                        String foodType = foodTypes.keys.elementAt(index);
                        String suggestedFoodType =
                            _emissionDataService.getSuggestionForType(foodType);
                        if (suggestedFoodType == null) return Container();
                        double emission =
                            _emissionDataService.getEmissionForType(foodType);
                        double emissionSuggested = _emissionDataService
                            .getEmissionForType(suggestedFoodType);

                        int savings =
                            (100 * (emission - emissionSuggested) ~/ emission);

                        String imgPath = FOOD_PROPERTIES.entries
                            .firstWhere((type) => type.key == foodType)
                            .value["image"];
                        String imgPathSuggested = FOOD_PROPERTIES.entries
                            .firstWhere((type) => type.key == suggestedFoodType)
                            .value["image"];

                        widget = Column(
                          children: <Widget>[
                            Container(
                              height: 100,
                              padding: EdgeInsets.only(top: 10),
                              child: GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10.0,
                                childAspectRatio: 2.2,
                                crossAxisCount: 2,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.purple.shade100,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            imgPath,
                                          ),
                                        ),
                                        Container(
                                          width: 75,
                                          child: Text(
                                            capitalize(foodType),
                                            style: TextStyle(
                                              color: Colors.purple.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.green.shade200,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            imgPathSuggested,
                                          ),
                                        ),
                                        Container(
                                          width: 75,
                                          child: Text(
                                            capitalize(suggestedFoodType),
                                            style: TextStyle(
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Text(
                                "Exchange $foodType with $suggestedFoodType and save $savings% CO₂",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        );
                        return widget;
                      },
                    ));
                  } else if (snapshot.hasData && snapshot.data.length == 0) {
                    children = <Widget>[
                      Center(child: Text("Add a receipt to see tips"))
                    ];
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
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
