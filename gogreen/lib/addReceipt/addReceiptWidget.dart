import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogreen/database/receiptDAO.dart';
import 'package:gogreen/emissionData/emissionDataService.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'package:gogreen/receipt/Receipt.dart';
import 'package:gogreen/helper/constants.dart';
import 'package:gogreen/helper/stringHelper.dart';

class AddReceiptWidget extends StatefulWidget {
  final Receipt receiptToEdit;

  AddReceiptWidget([this.receiptToEdit]);

  @override
  AddReceiptWidgetState createState() => AddReceiptWidgetState();
}

class AddReceiptWidgetState extends State<AddReceiptWidget> {
  Map<String, double> _amountMap = new Map<String, double>();
  Map<String, double> _emissionMap = new Map<String, double>();

  Receipt receiptToEdit;

  @override
  void initState() {
    receiptToEdit = widget.receiptToEdit;

    if (receiptToEdit != null) {
      receiptToEdit.items.forEach((ReceiptItem item) {
        _amountMap[item.foodType] = item.quantity;
        _emissionMap[item.foodType] = item.emission;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new receipt"),
        actions: <Widget>[
          Builder(
              builder: (context) => receiptToEdit == null
                  ? IconButton(
                      icon: Image.asset("images/receipt-scan.png"),
                      onPressed: () {
                        // Go to Settings screen
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Scanning receipts coming soon!"),
                        ));
                      },
                    )
                  : FlatButton(
                      child: Text("Delete", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await deleteReceipt();
                        Navigator.pop(context, null);
                      },
                    ))
        ],
      ),
      body: GridView.count(
        // Create a grid with 3 columns.
        crossAxisCount: 3,
        // Generate widgets that display their index in the List.
        children: _createReceiptItems(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Receipt newReceipt = await saveReceiptToDB(_amountMap, _emissionMap);
          Navigator.pop(context, newReceipt);
        },
        tooltip: 'Confirm',
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<Receipt> saveReceiptToDB(Map<String, double> amountMap, Map<String, double> emissionMap) async {
    ReceiptDao _receiptDao = new ReceiptDao();

    if (receiptToEdit == null) {
      if (amountMap.isEmpty) return null;
      List<ReceiptItem> itemList = new List();
      double totalEmission = 0;
      amountMap.forEach((key, value) {
        if (value > 0) {
          itemList.add(new ReceiptItem(foodType: key, quantity: value, emission: emissionMap[key]));
          totalEmission += emissionMap[key];
        }
      });
      Receipt receipt = new Receipt(timestamp: DateTime.now(), items: itemList, totalEmission: totalEmission);
      int result = await _receiptDao.insertReceipt(receipt);
      if (result != null)
        return receipt;
      else
        return null;
    } else {
      if (amountMap.isEmpty) {
        await deleteReceipt();
        return null;
      }

      List<ReceiptItem> itemList = new List();
      double totalEmission = 0;
      amountMap.forEach((key, value) {
        if (value > 0) {
          itemList.add(new ReceiptItem(foodType: key, quantity: value, emission: emissionMap[key]));
          totalEmission += emissionMap[key];
        }
      });
      receiptToEdit.items = itemList;
      receiptToEdit.totalEmission = totalEmission;
      int result = await _receiptDao.updateReceipt(receiptToEdit);
      if (result != null)
        return receiptToEdit;
      else
        return null;
    }
  }

  Future deleteReceipt() async {
    ReceiptDao _receiptDao = new ReceiptDao();
    await _receiptDao.delete(receiptToEdit);
  }

  List<Widget> _createReceiptItems(context) {
    List<ReceiptItemType> data = new List();
    FOOD_PROPERTIES.forEach((key, item) {
      data.add(new ReceiptItemType(key, new Image.asset(item["image"]), item["unit"]));
    });

    return List.generate(data.length, (index) {
      ReceiptItemType item = data[index];
      String label = item.label;
      Image img = item.img;
      Color color = (_amountMap != null && _amountMap.containsKey(label) && _amountMap[label] > 0)
          ? Color(0xFFE8F6E6)
          : Color(0xFFF5E9F8);
      Color textColor =
          (_amountMap != null && _amountMap.containsKey(label) && _amountMap[label] > 0) ? Colors.green : Colors.purple;
      double emission = new EmissionDataService().getEmissionForType(label);
      double factor = item.unit == "g" ? 1000.0 : 1.0;
      if (label == "eggs") {
        factor = 20.0; // 1 egg ~ 50g
      }

      return Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: color,
                ),
                child: IconButton(
                  iconSize: 48,
                  tooltip: "Enter amount of $label",
                  icon: img,
                  onPressed: () async {
                    // Get the amount from the dialog, account for the unit by dividing with a factor
                    final double amount = await _getAmount(context, item);
                    if (amount == null) return;
                    final double amountEmission = (amount * emission) / factor;
                    setState(() {
                      if (_amountMap.containsKey(label)) {
                        if (_amountMap[label] + amount > 0) {
                          _amountMap[label] += amount;
                          _emissionMap[label] += amountEmission;
                          item.amount += amount;
                        } else {
                          _amountMap.remove(label);
                          _emissionMap.remove(label);
                          item.amount = 0;
                        }
                      } else {
                        if (amount > 0) {
                          _amountMap[label] = amount;
                          _emissionMap[label] = amountEmission;
                          item.amount = amount;
                        }
                      }
                    });
                    print("entered $amount of $label");
                  },
                ),
              ),
              Text(capitalize(label), style: TextStyle(color: textColor)),
              Text((_amountMap != null && _amountMap.containsKey(label))
                  ? "${_amountMap[label].toInt().toString()} ${item.unit}"
                  : ""),
              Text((_emissionMap != null && _emissionMap.containsKey(label))
                  ? "${_emissionMap[label].toInt().toString()}kg CO₂ "
                  : ""),
            ],
          ),
        ),
      );
    });
  }
}

Future<double> _getAmount(context, ReceiptItemType item) async {
  String helperText;
  String _label = item.label;
  double emission = new EmissionDataService().getEmissionForType(_label);

  if (item.unit == "L") {
    helperText = "1L ~ $emission kg CO₂";
  } else {
    helperText = "1kg ~ $emission kg CO₂";
  }

  double amount;

  AlertDialog buildAlertDialog() {
    Widget cancelButton = FlatButton(
      child: Text(
        'CANCEL',
        style: TextStyle(color: Colors.purple),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget addButton = FlatButton(
      child: Text('ADD'),
      onPressed: () {
        Navigator.of(context).pop(amount);
      },
    );

    return AlertDialog(
      title: Text(capitalize(_label)),
      content: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new TextFormField(
              autofocus: true,
              controller: new TextEditingController(),
              decoration: InputDecoration(
                labelText: "Enter amount",
                helperText: helperText,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = double.parse(value);
              },
            ),
          ),
          Text(item.unit)
        ],
      ),
      actions: [cancelButton, addButton],
    );
  }

  return showDialog<double>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return buildAlertDialog();
      });
}
