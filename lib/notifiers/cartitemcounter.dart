import 'package:flutter/foundation.dart';
import 'package:ecommerce/Config/config.dart';

class CartItemCounter extends ChangeNotifier{
  int _counter=Tswana_Search.sharedPreferences.getStringList(Tswana_Search.userFriendList).length-1;
  int get count => _counter;

   Future<void> displayResult() async {

    //_counter++;
    print(Tswana_Search.sharedPreferences.getStringList(Tswana_Search.userFriendList).length);
    _counter=Tswana_Search.sharedPreferences.getStringList(Tswana_Search.userFriendList).length-1;
    await Future.delayed(const Duration(milliseconds: 100), (){
      notifyListeners();
    });

  }

}