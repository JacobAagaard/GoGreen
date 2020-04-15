import 'package:flutter/material.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/models/FoodType.dart';
import 'package:gogreen/models/ReceiptModel.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  ReceiptDao _receiptDao = ReceiptDao();

  @override
  Widget build(BuildContext context) {

    _insertReceiptTest() {
      Receipt receipt = new Receipt(
          timestamp: DateTime.now(),
          carbonEmission: 100,
          items: [new Item(foodType: FoodType.beef, quantity: 1000)]);

      _receiptDao.insertReceipt(receipt);
    }

    _getReceiptTest() async {
      List<Receipt> receipts = await _receiptDao.getAllReceipts();
      final snackBar =
          SnackBar(content: Text(receipts[0].items[0].foodType.toString()));
      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Timeline"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("TO BE DONE"),
                // TEST DB
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    child: Text(
                      "TEST INSERT",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _insertReceiptTest),
                RaisedButton(
                    child: Text(
                      "SHOW DB",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _getReceiptTest)
              ],
            )
          ],
        ),
      ),
    );
  }
}
