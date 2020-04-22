import 'dart:convert';
import 'package:sembast/timestamp.dart';

class Receipt {
  // autoincrement by sembast
  int id;

  DateTime timestamp;
  List<ReceiptItem> items;
  double totalEmission;

  Receipt({
    this.timestamp,
    this.items,
    this.totalEmission,
  });

  factory Receipt.fromMap(Map<String, dynamic> json) => Receipt(
        timestamp: json["timestamp"].toDateTime(),
        items: List<ReceiptItem>.from(
            json["items"].map((x) => ReceiptItem.fromMap(x))),
        totalEmission: json["totalEmission"],
      );

  Map<String, dynamic> toMap() {
    return {
      "timestamp": Timestamp.fromDateTime(timestamp),
      "items": List<dynamic>.from(items.map((x) => x.toMap())),
      "totalEmission": totalEmission,
    };
  }
}

class ReceiptItem {
  String foodType;
  double quantity;
  double emission;

  ReceiptItem({this.foodType, this.quantity, this.emission});

  factory ReceiptItem.fromJson(String str) =>
      ReceiptItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReceiptItem.fromMap(Map<String, dynamic> json) => ReceiptItem(
      foodType: json["foodType"],
      quantity: json["quantity"].toDouble(),
      emission: json["emission"]);

  Map<String, dynamic> toMap() =>
      {"foodType": foodType, "quantity": quantity, "emission": emission};
}
