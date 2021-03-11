import 'package:flutter/foundation.dart';
import 'package:ecommerce/Config/config.dart';

class CartItemCounter extends ChangeNotifier{
  int _counter=AbsaCompetitionApp.sharedPreferences.getStringList(AbsaCompetitionApp.userFriendList).length-1;
  int get count => _counter;

   Future<void> displayResult() async {

    //_counter++;
    print(AbsaCompetitionApp.sharedPreferences.getStringList(AbsaCompetitionApp.userFriendList).length);
    _counter=AbsaCompetitionApp.sharedPreferences.getStringList(AbsaCompetitionApp.userFriendList).length-1;
    await Future.delayed(const Duration(milliseconds: 100), (){
      notifyListeners();
    });

  }

}