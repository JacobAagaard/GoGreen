import 'package:flutter/material.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/models/ReceiptModel.dart';

class TipsWidget extends StatefulWidget {
  const TipsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TipsWidgetState();
}

class _TipsWidgetState extends State<TipsWidget> {
  ReceiptDao _receiptDao = ReceiptDao();

  @override
  Widget build(BuildContext context) {
    List<Receipt> _receiptList = new List();

    _insertReceiptTest() {
      _receiptDao.insertFakeReceipt();
    }

    _getReceiptTest() async {
      List<Receipt> updatedReceiptList = await _receiptDao.getAllReceipts();

      updatedReceiptList.forEach((item) => print(item.toMap().toString()));

      setState(() => _receiptList = updatedReceiptList);
    }

    _deleteAllTest() async {
      await _receiptDao.deleteAll();
      setState(() => _receiptList = new List());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Progress"),
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
                      "ADD\nFAKE DATA",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _insertReceiptTest),
                RaisedButton(
                    child: Text(
                      "SHOW\nDB",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _getReceiptTest),
                RaisedButton(
                    child: Text(
                      "DELETE\nALL",
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _deleteAllTest)
              ],
            ),
            Container(
                height: 44,
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _receiptList
                        .map((value) => Container(
                            height: 50,
                            color: Colors.amber[600],
                            child: Center(child: Text(value.toString()))))
                        .toList()))
          ],
        ),
      ),
    );
  }
}
