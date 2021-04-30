import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/storehome.dart';
import 'package:ecommerce/notifiers/ProductQuantity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/authenication.dart';
import 'package:ecommerce/Config/config.dart';
import 'notifiers/cartitemcounter.dart';
import 'notifiers/changeAddresss.dart';
import 'notifiers/totalMoney.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Tswana_Search.sharedPreferences = await SharedPreferences.getInstance();
  Tswana_Search.auth = FirebaseAuth.instance;
  Tswana_Search.firestore = Firestore.instance;
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartItemCounter()),
          ChangeNotifierProvider(create: (_) => ProductQuantity()),
          ChangeNotifierProvider(create: (_) => AddressChanger()),
          ChangeNotifierProvider(create: (_) => TotalAmount()),
        ],
        child: MaterialApp(
            title: 'SEARCH_TSWANA APP',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.blueGrey,
            ),
            home:
            //SellBook()
            SplashScreen()
        ));
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    Timer(Duration(seconds: 2), () async {
      if (await Tswana_Search.auth.currentUser() != null) {
        Route newRoute = MaterialPageRoute(builder: (_) => CleintStoreHome());
        Navigator.pushReplacement(context, newRoute);
      } else {
        /// Not SignedIn
        Route newRoute = MaterialPageRoute(builder: (_) => AuthenticScreen());
        Navigator.pushReplacement(context, newRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/images.png'),
              Text('WELCOME TO SEARCH_TSWANA APP',
                style: TextStyle(
                  //  fontSize: ScreenUtil.getInstance().setSp(45),
                  fontFamily: 'Poppins-Bold',
                  letterSpacing: .6,
                  color: Colors.blue.withOpacity(0.7),),)
            ],
          ),
        ),
      ),
    );
  }
}
