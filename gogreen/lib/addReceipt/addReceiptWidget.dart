import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogreen/emissionData/emissionDataService.dart';

class AddReceiptWidget extends StatelessWidget {
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
          children: _createReceiptItems(context)),
    );
  }

  static List<Widget> _createReceiptItems(context) {
    final data = [
      new ReceiptItemType(
        "Beef",
        new Image.asset("images/beef.png"),
      ),
      new ReceiptItemType(
        "Milk",
        new Image.asset("images/milk.png"),
      ),
      new ReceiptItemType(
        "Bread",
        new Image.asset("images/bread.png"),
      ),
      new ReceiptItemType(
        "Cheese",
        new Image.asset("images/cheese.png"),
      ),
      new ReceiptItemType(
        "Vegetables",
        new Image.asset("images/vegetables.png"),
      ),
      new ReceiptItemType(
        "Coffee",
        new Image.asset("images/coffee.png"),
      ),
      new ReceiptItemType(
        "Juice",
        new Image.asset("images/juice.png"),
      ),
      new ReceiptItemType(
        "Pasta",
        new Image.asset("images/pasta.png"),
      ),
      new ReceiptItemType(
        "Rice",
        new Image.asset("images/rice.png"),
      ),
    ];

    return List.generate(data.length, (index) {
      final label = data[index].label;
      final img = data[index].img;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              iconSize: 48,
              tooltip: "Enter amount of $label",
              icon: img,
              onPressed: () async {
                final int amount = await _getAmount(context, label);
                print("entered $amount of $label");
              },
            ),
            Text(label),
          ],
        ),
      );
    });
  }
}

Future<int> _getAmount(context, label) async {
  String suffix, helperText;
  double emission = new EmissionDataService().getEmissionForType(label);

  if (label == "Juice" || label == "Milk") {
    suffix = "L";
    helperText = "1L ~ $emission kg CO2";
  } else {
    suffix = "g";
    helperText = "1kg ~ $emission kg CO2";
  }

  int amount = 0;

  return showDialog<int>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(label),
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
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  amount = num.parse(value);
                },
              ),
            ),
            Text(suffix)
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

class ReceiptItemType {
  final String label;
  final Image img;

  ReceiptItemType(this.label, this.img);
}
