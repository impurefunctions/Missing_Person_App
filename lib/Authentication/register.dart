import 'dart:io';
import 'package:ecommerce/Authentication/authenication.dart';
import 'package:ecommerce/Authentication/login.dart';
import 'package:ecommerce/Cleint/SellItems/Police_Store.dart';
import 'package:ecommerce/Cleint/SellItems/Public_Store.dart';
import 'package:ecommerce/Cleint/SellItems/addProduct.dart';
import 'package:ecommerce/Cleint/storehome.dart';
import 'package:ecommerce/Widgets/customTextField.dart';
import 'package:ecommerce/chatApp/Config/config.dart';
import 'package:ecommerce/dialogs/errorDialog.dart';
import 'package:ecommerce/dialogs/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecommerce/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}
final TextEditingController _nameController = TextEditingController();
class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
  TextEditingController();
  String userPhotoUrl = "Choose whatever";


  String dropdownValue;

  File _image;

  Future<void> _pickImage() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  Future<void> uploadImage() async {

    if (_image == null) {
      showDialog(
          context: context,
          builder: (v) {
            return ErrorAlertDialog(
              message: "Please pick an photo",
            );
          });
    } else {

      _passwordController.text == _passwordConfirmController.text
          ? _emailController.text.isNotEmpty &&
          _passwordConfirmController.text.isNotEmpty &&
          _nameController.text.isNotEmpty
          ? upload()
          :
      showMyDialog('Please fill the desired fields')

          : showMyDialog('Password doesn\'t match');

    }
  }
  upload() async {
    showDialog(
        context: context,
        builder: (_) {
          return LoadingAlertDialog();
        });
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    StorageReference reference =
    FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(_image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    await storageTaskSnapshot.ref.getDownloadURL().then((url) {
      userPhotoUrl = url;
      print(userPhotoUrl);
      _register();
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery
        .of(context)
        .size
        .width,
        _screenHeight = MediaQuery
            .of(context)
            .size
            .height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[


            InkWell(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage: _image==null?null:FileImage(_image),
                  child: _image == null
                      ? Icon(
                    Icons.person_add,
                    size: _screenWidth * 0.15,
                    color: Colors.blueAccent,
                  )
                      : null,
//                        backgroundImage: _image == null
//                            ? AssetImage('assets/images/loading.png')
//                            : FileImage(_image)
                )),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    data: Icons.person_outline,
                    controller: _nameController,
                    hintText: 'Name',
                    isObsecure: false,
                  ),
                  CustomTextField(
                    data: Icons.person_outline,
                    controller: _emailController,
                    hintText: 'Email',
                    isObsecure: false,
                  ),
                  DropdownButton<String>(
                    hint: Text('Choose a role'),
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['RELEVANT AUTHORITIES','REPORTER','PUBLIC'].map< DropdownMenuItem<String>>((String value)
                    {
                      return DropdownMenuItem(

                        value: value,
                        child: new Text(value),

                      );
                    }).toList(),
                  ),
                  CustomTextField(
                    data: Icons.lock_outline,
                    controller: _passwordController,
                    hintText: 'Password',
                    isObsecure: true,
                  ),
                  CustomTextField(
                    data: Icons.lock_outline,
                    controller: _passwordConfirmController,
                    hintText: 'Confirm passsword',
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                uploadImage();
              },
              color: Colors.blue,
              child: Text('Sign up'),
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
  void _register() async {
    FirebaseUser currentUser;
    await _auth
        .createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ).then((auth) {
      currentUser = auth.user;
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

   /* if (currentUser != null) {
      if(currentUser.role == "RELEVANT AUTHORITIES") {
        writeDataToDataBase(currentUser).then((s) {
          Navigator.pop(context);
          // TODO navigate to homescreen

          Route newRoute = MaterialPageRoute(builder: (_) => Police_Store());
          Navigator.pushReplacement(context, newRoute);
        });
      }
      else if(currentUser.role == "REPORTER")
      {
        writeDataToDataBase(currentUser).then((s) {
          Navigator.pop(context);
          // TODO navigate to homescreen

          Route newRoute = MaterialPageRoute(builder: (_) => CleintStoreHome());
          Navigator.pushReplacement(context, newRoute);
        });
      }
      else if(currentUser.role == "PUBLIC")
      {
        writeDataToDataBase(currentUser).then((s) {
          Navigator.pop(context);
          // TODO navigate to homescreen

          Route newRoute = MaterialPageRoute(builder: (_) => Public_Store());
          Navigator.pushReplacement(context, newRoute);
        });

      }
      else
      {
        writeDataToDataBase(currentUser).then((s) {
          Navigator.pop(context);
          // TODO navigate to homescreen

          Route newRoute = MaterialPageRoute(builder: (_) => CleintStoreHome());
          Navigator.pushReplacement(context, newRoute);
        });

      }
    }*/
  }


  Future writeDataToDataBase(FirebaseUser currentUser) async {
    Tswana_Search.firestore
        .collection(Tswana_Search.collectionUser)
        .document(currentUser.uid)
        .setData({
      Tswana_Search.userUID: currentUser.uid,
      Tswana_Search.userEmail: currentUser.email,
      Tswana_Search.role: dropdownValue,
      Tswana_Search.userName: _nameController.text,
      //AbsaCompetitionApp.userFriendList: ['garbageValue'],
      Tswana_Search.userAvatarUrl: userPhotoUrl,
      ChatApp.userChattingWith : null
    });
    await Tswana_Search.sharedPreferences
        .setString(Tswana_Search.userUID, currentUser.uid);
    await Tswana_Search.sharedPreferences.setStringList(Tswana_Search.userFriendList, ['garbageValue']);
    await Tswana_Search.sharedPreferences
        .setString(Tswana_Search.userEmail, currentUser.email);
    await Tswana_Search.sharedPreferences
        .setString(Tswana_Search.userName, _nameController.text);
    await Tswana_Search.sharedPreferences
        .setString(Tswana_Search.userAvatarUrl, userPhotoUrl);
  }

  showMyDialog(String message) {

    showDialog(
        context: context,
        builder: (con) {
          return ErrorAlertDialog(
            message: message,
          );
        });

  }
}
final FirebaseAuth _auth = FirebaseAuth.instance;
