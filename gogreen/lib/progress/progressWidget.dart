import 'package:flutter/material.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/models/ReceiptModel.dart';

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  ReceiptDao _receiptDao = ReceiptDao();

  @override
  Widget build(BuildContext context) {
    List<Receipt> _receiptList = new List();

    _insertReceiptTest() {
      Receipt receipt = new Receipt(
          timestamp: DateTime.now(),
          totalEmission: 100,
          items: [new ReceiptItem(foodType: "beef", quantity: 1000)]);

      _receiptDao.insertReceipt(receipt);
    }

    _getReceiptTest() async {
      List<Receipt> updatedReceiptList = await _receiptDao.getAllReceipts();

      updatedReceiptList.forEach((item)=>print(item.toMap().toString()));

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
                      "TEST\nINSERT",
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
