import 'package:ecommerce/Cleint/Models/product.dart';
import 'package:ecommerce/Cleint/config/cleint.dart';
import 'package:ecommerce/chatApp/Dialogs/loadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/Widgets/customAppBar.dart';
import 'package:ecommerce/modals/address.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class SellProduct extends StatefulWidget {
  @override
  _SellProductState createState() => _SellProductState();
}

class _SellProductState extends State<SellProduct> {
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  String _error = 'No Error Dectected';
  bool isUploading = false;
  final name = TextEditingController();
  final description = TextEditingController();
  //final last_seen = TextEditingController();
  final age = TextEditingController();
  DateTime selectedDate;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  done() {
    if (images.length ==0) {
//imlength > 8)ages.length < 3 || images.

      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Text("Minimum 3 and Maximum  8 images required",
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    height: 30,
                    child: Center(
                        child: Text(
                          "Ok",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                )
              ],
            );
          });
    } else {

      uploadImages();
      SnackBar snackbar =
      SnackBar(content: Text('Please wait, we are uploading'));
      scaffoldKey.currentState.showSnackBar(snackbar);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return LoadingAlertDialog(
              message: 'Please wait,loading data',
            );
          });

    }
  }

  void uploadImages() {
    for (var imageFile in images) {
      postImage(imageFile).then((downloadUrl) {
        imageUrls.add(downloadUrl.toString());
        print('Images Upload done');
        print('L1 ${imageUrls.length}');
        print('L2 ${images.length}');
        if (imageUrls.length == images.length) {
          print('Images Upload done 2');
          String documnetID = DateTime.now().millisecondsSinceEpoch.toString();
          ProductModel model = ProductModel(
              last_seen: selectedDate,
              name: name.text,
              description: description.text,
              age: age.text,
              found: "false",
              uid: Tswana_Search.sharedPreferences
                  .getString(Tswana_Search.userUID),
              urls: imageUrls);

          // TODO CHnge collection name

          Tswana_Search.firestore
              .collection(AbsaApp.collectionAllBook)
              .document(documnetID)
              .setData(model.toJson())
              .then((_) {
            print('Upload Done');
            Navigator.pop(context);
            SnackBar snackbar =
            SnackBar(content: Text('Uploaded Successfully'));

            scaffoldKey.currentState.showSnackBar(snackbar);

            setState(() {
              images = [];
              imageUrls = [];
              name.clear();
              description.clear();

              age.clear();
            });
          }).catchError((e) {
            Navigator.pop(context);
            print('In error ${e.toString()}');
            setState(() {
              images = [];
              imageUrls = [];
            });
          });
        }
      }).catchError((err) {
        print(err);
        setState(() {
          images = [];
          imageUrls = [];
        });
      });
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      print(resultList.length);
      print((await resultList[0].getThumbByteData(122, 100)));
      print((await resultList[0].getByteData()));
      print((await resultList[0].metadata));
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask =
    reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print('DownloadURL');
    print(storageTaskSnapshot.ref.getDownloadURL());
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        print(asset.getByteData(quality: 100));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(
          leading: BackButton(
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (formKey.currentState.validate()) {
              done();
//              final model = AddressModel(
//                      name: title.text,
//                      state: _cState.text,
//                      pincode: _cPincode.text,
//                      phoneNumber: _cPincode.text,
//                      landmark: _clandmark.text,
//                      flatNumber: isbn.text,
//                      city: _cCity.text,
//                      area: _cArea.text)
//                  .toJson();
//              AbsaCompetitionApp.firestore
//                  .collection(AbsaCompetitionApp.collectionUser)
//                  .document(AbsaCompetitionApp.sharedPreferences
//                      .getString(AbsaCompetitionApp.userUID))
//                  .collection(AbsaCompetitionApp.subCollectionAddress)
//                  .document(DateTime.now().millisecondsSinceEpoch.toString())
//                  .setData(model)
//                  .then((_) {
//                final snackbar =
//                    SnackBar(content: Text('Address added successfully'));
//                scaffoldKey.currentState.showSnackBar(snackbar);
//                FocusScope.of(context).requestFocus(FocusNode());
//                formKey.currentState.reset();
//              });
            }
          },
          label: Text('Done'),
          backgroundColor: Colors.blue,
          icon: Icon(Icons.check),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Add Missing Person',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        MyTextField(
                          hint: 'Name',
                          controller: name,
                        ),
                        MyTextField(
                          hint: 'Description',
                          controller: description,
                        ),
                        MyTextField(
                          hint: 'Age',
                          controller: age,
                        ),

                          FlatButton(
                            child: Text("Date: " + selectedDate.toString()),
                            onPressed: () async{
                              DateTime date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2010),
                                  lastDate: DateTime.now().add(Duration(days: 1)));

                              if (date != null){
                                setState((){
                                  selectedDate = date;
                                });
                              }
                            },
                          )


                      ],
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.grey,
                    margin: EdgeInsets.all(10),
                    height: 30,
                    width: 100,
                    child: InkWell(
                      onTap: loadAssets,
                      child: Center(
                          child: Text(
                            "Add Picture",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 250,
                  child: buildGridView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType textInputType;

  const MyTextField(
      {Key key,
        this.hint,
        this.controller,
        this.textInputType = TextInputType.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        keyboardType: textInputType,
        validator: (value) => value.isEmpty ? 'Field can\'t be blank' : null,
      ),
    );
  }
}
