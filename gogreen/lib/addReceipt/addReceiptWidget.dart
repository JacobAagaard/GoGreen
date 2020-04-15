import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogreen/emissionData/emissionDataService.dart';
import 'package:gogreen/receipt/Receipt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReceiptWidget extends StatefulWidget {
  @override
  AddReceiptWidgetState createState() => AddReceiptWidgetState();
}

class AddReceiptWidgetState extends State<AddReceiptWidget> {
  Map<String, double> _amountMap;
  Map<String, double> _emissionMap;

  @override
  void initState() {
    super.initState();
    _amountMap = {"test": 0.0};
    _emissionMap = {"test": 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new receipt"),
      ),
      body: GridView.count(
        // Create a grid with 3 columns.
        crossAxisCount: 3,
        // Generate widgets that display their index in the List.
        children: _createReceiptItems(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _emissionMap),
        tooltip: 'COnfirm',
        child: const Icon(Icons.check),
      ),
    );
  }

  List<Widget> _createReceiptItems(context) {
    final data = [
      new ReceiptItemType("Beef", new Image.asset("images/beef.png"), "g"),
      new ReceiptItemType("Milk", new Image.asset("images/milk.png"), "L"),
      new ReceiptItemType("Bread", new Image.asset("images/bread.png"), "g"),
      new ReceiptItemType("Cheese", new Image.asset("images/cheese.png"), "g"),
      new ReceiptItemType(
          "Vegetables", new Image.asset("images/vegetables.png"), "kg"),
      new ReceiptItemType("Coffee", new Image.asset("images/coffee.png"), "g"),
      new ReceiptItemType("Juice", new Image.asset("images/juice.png"), "L"),
      new ReceiptItemType("Pasta", new Image.asset("images/pasta.png"), "kg"),
      new ReceiptItemType("Rice", new Image.asset("images/rice.png"), "kg"),
    ];

    return List.generate(data.length, (index) {
      ReceiptItemType item = data[index];
      String label = item.label;
      Image img = item.img;
      Color color = (_amountMap != null &&
              _amountMap.containsKey(label) &&
              _amountMap[label] > 0)
          ? Color(0xFFE8F6E6)
          : Color(0xFFF5E9F8);
      double emission = new EmissionDataService().getEmissionForType(label);
      double factor = item.unit == "g" ? 1000.0 : 1.0;

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
                    final double _emission = (amount * emission) / factor;
                    setState(() {
                      _amountMap.update(
                        label,
                        (cur) => cur + amount,
                        ifAbsent: () => amount,
                      );

                      _emissionMap.update(
                        label,
                        (cur) => cur + _emission,
                        ifAbsent: () => _emission,
                      );
                    });
                    item.amount = amount;
                    print("entered $amount of $label");
                  },
                ),
              ),
              Text((_amountMap.containsKey(label))
                  ? "${_amountMap[label].toString()} ${item.unit}"
                  : ""),
              Text((_emissionMap.containsKey(label))
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
    helperText = "1L ~ $emission kg CO2";
  } else {
    helperText = "1kg ~ $emission kg CO2";
  }

  double amount = 0;

  return showDialog<double>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(_label),
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
        actions: <Widget>[
          FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.purple),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('ADD'),
            onPressed: () {
              Navigator.of(context).pop(amount);
            },
          ),
        ],
      );
    },
  );
}
