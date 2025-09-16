// models/cart.dart
import 'package:flutter/foundation.dart';

class CartItem {
  final Product product;
  int quantity;
  Map<String, dynamic> customizations;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.customizations = const {},
  });

  double get totalPrice => product.price * quantity;
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product, {Map<String, dynamic> customizations = const {}}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && 
                _mapsEqual(item.customizations, customizations),
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        product: product,
        customizations: Map.from(customizations),
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (String key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}