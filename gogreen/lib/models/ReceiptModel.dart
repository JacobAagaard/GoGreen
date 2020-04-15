import 'dart:convert';
import 'package:gogreen/models/FoodType.dart';
import 'package:sembast/timestamp.dart';

class Receipt {

  // autoincrement by sembast
  int id;

  DateTime timestamp;
  List<Item> items;
  int carbonEmission;

  Receipt({
    this.timestamp,
    this.items,
    this.carbonEmission,
  });

  factory Receipt.fromMap(Map<String, dynamic> json) => Receipt(
    timestamp: json["timestamp"].toDateTime(),
    items: List<Item>.from(json["items"].map((x) => Item.fromMap(x))),
    carbonEmission: json["carbonEmission"],
  );

  Map<String, dynamic> toMap() => {
    "timestamp": Timestamp.fromDateTime(timestamp),
    "items": List<dynamic>.from(items.map((x) => x.toMap())),
    "carbonEmission": carbonEmission,
  };
}

class Item {
  FoodType foodType;
  int quantity;

  Item({
    this.foodType,
    this.quantity,
  });

  factory Item.fromJson(String str) => Item.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Item.fromMap(Map<String, dynamic> json) => Item(
    foodType: FoodType.values.firstWhere((e) => e.toString() == 'FoodType.' + json["foodType"]),
    quantity: json["quantity"],
  );

  Map<String, dynamic> toMap() => {
    "foodType": foodType.toString(),
    "quantity": quantity,
  };
}
