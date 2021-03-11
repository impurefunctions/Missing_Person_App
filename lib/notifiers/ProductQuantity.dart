import 'package:flutter/foundation.dart';

class ProductQuantity with ChangeNotifier {
  int _noOfProducts = 0;

  int get noOfProducts => _noOfProducts;

  display(int number) {
    _noOfProducts = number;
    notifyListeners();
  }
}
