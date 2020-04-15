import 'package:flutter/material.dart';

class ReceiptItemType {
  final String label;
  final Image img;
  final String unit;
  double amount;

  ReceiptItemType(this.label, this.img, this.unit, {this.amount = 0.0});
}
