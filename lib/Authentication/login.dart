import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/SellItems/Police_Store.dart';
import 'package:ecommerce/Cleint/SellItems/Public_Store.dart';
import 'package:ecommerce/Cleint/SellItems/addProduct.dart';
import 'package:ecommerce/Cleint/storehome.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/Widgets/customTextField.dart';
import 'package:ecommerce/dialogs/errorDialog.dart';
import 'package:ecommerce/dialogs/loadingDialog.dart';
import 'package:ecommerce/modals/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future readDataToDataBase(FirebaseUser currentUser) async {
  await Tswana_Search.firestore
      .collection(Tswana_Search.collectionUser)
      .document(currentUser.uid)
      .get()
      .then((snapshot) async {
    print(snapshot.data);
    await Tswana_Search.sharedPreferences
        .setString(Tswana_Search.userUID, snapshot.data[Tswana_Search.userUID]);
    await Tswana_Search.sharedPreferences.setString(
        Tswana_Search.userEmail, snapshot.data[Tswana_Search.userEmail]);
    await Tswana_Search.sharedPreferences.setString(
        Tswana_Search.userName, snapshot.data[Tswana_Search.userName]);
    await Tswana_Search.sharedPreferences.setString(Tswana_Search.userAvatarUrl,
        snapshot.data[Tswana_Search.userAvatarUrl]);
    //  print(snapshot.data[AbsaCompetitionApp.userFriendList]);
    //List<String> cart = snapshot.data[AbsaCompetitionApp.userFriendList].cast<String>();
    //await AbsaCompetitionApp.sharedPreferences.setStringList(AbsaCompetitionApp.userFriendList, cart);
  });
//      .setData({
//    DeliveryApp.userUID: currentUser.uid,
//    DeliveryApp.userEmail: currentUser.email,
//  });
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Login to your account',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    data: Icons.person_outline,
                    controller: _emailController,
                    hintText: 'Email',
                    isObsecure: false,
                  ),
                  CustomTextField(
                    data: Icons.lock_outline,
                    controller: _passwordController,
                    hintText: 'Password',
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                _emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty
                    ? _login()
                    : showDialog(
                        context: context,
                        builder: (con) {
                          return ErrorAlertDialog(
                            message: 'Please fill the desired fields',
                          );
                        });
              },
              color: Colors.blue,
              child: Text('Log in'),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 3,
              width: _screenWidth * 0.8,
              color: Colors.blue,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    showDialog(
        context: context,
        builder: (con) {
          return LoadingAlertDialog(
            message: 'Please wait',
          );
        });
    FirebaseUser firebaseUser;
    UserModel currentUser;

    await _auth
        .signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
        .then((auth) {
      firebaseUser = auth.user;
      print('UserID is: ${firebaseUser.email}');
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .get()
          .then((value) {
        currentUser = UserModel.fromSnapshot(value);

        if (currentUser != null) {
          print('User name is: ${currentUser.name}');
          if (currentUser.role == "RELEVANT AUTHORITIES") {
            Navigator.pop(context);
            // TODO navigate to homescreen

            Route newRoute = MaterialPageRoute(builder: (_) => Police_Store());
            Navigator.pushReplacement(context, newRoute);
          } else if (currentUser.role == "REPORTER") {
            Navigator.pop(context);
            // TODO navigate to homescreen

            readDataToDataBase(firebaseUser);

            Route newRoute = MaterialPageRoute(builder: (_) => CleintStoreHome());
            Navigator.pushReplacement(context, newRoute);
          }
          if (currentUser.role == "PUBLIC") {
            Navigator.pop(context);
            // TODO navigate to homescreen

            Route newRoute = MaterialPageRoute(builder: (_) => Public_Store());
            Navigator.pushReplacement(context, newRoute);
          }
        } else {
          //   _success = false;
          //System.out.print();
        }

      });
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (con) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });


  }
}
