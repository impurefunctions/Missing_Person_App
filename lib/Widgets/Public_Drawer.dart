import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Authentication/authenication.dart';
import 'package:ecommerce/Cleint/SellItems/addProduct.dart';
import 'package:ecommerce/Cleint/about.dart';
import 'package:ecommerce/Cleint/contacts.dart';
import 'package:ecommerce/Cleint/storehome.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/MyProducts/myproducts.dart';
import 'package:ecommerce/chatApp/Chat/allFriends.dart';
import 'package:ecommerce/chatApp/Dialogs/errorDialog.dart';
import 'package:ecommerce/dialogs/loadingDialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Public_Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            accountName: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(Tswana_Search.sharedPreferences
                      .getString(Tswana_Search.userName)),
                  Expanded(child: Container()),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: () => updateName(context),
                  )
                ],
              ),
            ),
            accountEmail: Text(Tswana_Search.sharedPreferences
                .getString(Tswana_Search.userEmail)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              backgroundImage: NetworkImage(Tswana_Search.sharedPreferences
                  .getString(Tswana_Search.userAvatarUrl)),
              child: Padding(
                  padding: EdgeInsets.only(left: 40, top: 45),
                  child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: ()=>updateImage(context))),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Route newRoute =
              MaterialPageRoute(builder: (_) => CleintStoreHome());
              Navigator.push(context, newRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.track_changes),
            title: Text('Missing Person'),
            onTap: () {
              Route newRoute =
              MaterialPageRoute(builder: (_) => MyProducts());
              Navigator.push(context, newRoute);
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Details'),
            onTap: () {
              Navigator.pop(context);
              Route newRoute = MaterialPageRoute(builder: (_) => SellProduct());
              Navigator.push(context, newRoute);
            },
          ),

          ListTile(
            leading: Icon(Icons.message),
            title: Text('Chats'),
            onTap: () {
              Navigator.pop(context);
              Route newRoute = MaterialPageRoute(builder: (_) => MyChats());
              Navigator.push(context, newRoute);
            },
          ),
          //to do,,, allow to conduct relevant authorities
          /* ListTile(
            leading: Icon(Icons.message),
            title: Text('Conduct Authorities'),
            onTap: () {
              Navigator.pop(context);
              Route newRoute = MaterialPageRoute(builder: (_) => Contact());
              Navigator.push(context, newRoute);
            },
          ),*/



          ListTile(
            leading: Icon(Icons.help),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Route newRoute = MaterialPageRoute(builder: (_) => About());
              Navigator.push(context, newRoute);
            },
          ),

          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Route newRoute = MaterialPageRoute(builder: (_) => Contact());
              Navigator.push(context, newRoute);
            },
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              print('bh');
              Tswana_Search.auth.signOut().then((_) {
                Route newRoute =
                MaterialPageRoute(builder: (_) => AuthenticScreen());
                Navigator.pushReplacement(context, newRoute);
              });
            },
          ),
        ],
      ),
    );
  }

  updateName(BuildContext context) {
    final _nameController = TextEditingController();
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextFormField(
              decoration: InputDecoration(labelText: 'Enter Name'),
              controller: _nameController,
            ),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              RaisedButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: 'Updating');
                  Tswana_Search.firestore
                      .collection(Tswana_Search.collectionUser)
                      .document(Tswana_Search.sharedPreferences
                      .getString(Tswana_Search.userUID))
                      .updateData({
                    Tswana_Search.userName: _nameController.text,
                  }).then((_){
                    Tswana_Search.sharedPreferences
                        .setString(Tswana_Search.userName, _nameController.text);
                    Fluttertoast.showToast(msg: 'Updated');
                    Navigator.pop(context);
                  }).catchError((_){
                    Fluttertoast.showToast(msg: 'Error Occured');
                    Navigator.pop(context);
                  });

                },
                child: Text('Done'),
              )
            ],
          );
        });
  }

  updateImage(BuildContext context) {
    _pickImage().then((_){
      uploadImage(context);
    });


  }
  File _image;
  String userPhotoUrl='';
  Future<void> _pickImage() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadImage(BuildContext context) async {

    if (_image == null) {
      showDialog(
          context: context,
          builder: (v) {
            return ErrorAlertDialog(
              message: "Please pick an photo",
            );
          });
    } else {
      upload(context);
    }
  }
  upload(BuildContext context) async {
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
      updateImageUrl(context);
    });
  }
  updateImageUrl(BuildContext context){
    Fluttertoast.showToast(msg: 'Updating');
    Tswana_Search.firestore
        .collection(Tswana_Search.collectionUser)
        .document(Tswana_Search.sharedPreferences
        .getString(Tswana_Search.userUID))
        .updateData({
      Tswana_Search.userAvatarUrl: userPhotoUrl,
    }).then((_){
      Tswana_Search.sharedPreferences
          .setString(Tswana_Search.userAvatarUrl, userPhotoUrl);
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Updated');
      //Navigator.pop(context);
    }).catchError((_){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error Occured');
      //Navigator.pop(context);
    });

  }
}
