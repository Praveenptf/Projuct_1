import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String, String>> _cartItems = [];

  List<Map<String, String>> get cartItems => _cartItems;

  void addItem(Map<String, String> item) {
    _cartItems.add(item);
    notifyListeners(); // Notify listeners to update UI
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners(); // Notify listeners to update UI
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      // Assuming the price is stored as a string in the 'price' key
      String priceString = item['price'] ?? '0.0';
      double price = double.tryParse(priceString) ?? 0.0; // Convert to double
      total += price;
    }
    return total;
  }
}
