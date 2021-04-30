import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/Models/product.dart';
import 'package:ecommerce/Cleint/config/cleint.dart';
import 'package:ecommerce/Cleint/productPage.dart';
import 'package:ecommerce/Cleint/storehome.dart';
import 'package:ecommerce/chatApp/Config/config.dart';

import 'package:ecommerce/notifiers/cartitemcounter.dart';
import 'package:ecommerce/Config/light_color.dart';
import 'package:ecommerce/Config/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/Config/config.dart';
import '../Widgets/customAppBar.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import '../Widgets/searchBox.dart';

double width;

class MyProducts extends StatefulWidget {
  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: MyDrawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: MyAppBar(
                leading: BackButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(AbsaApp.collectionAllBook)
                    .where(
                      'uid',
                      isEqualTo: Tswana_Search.sharedPreferences
                          .getString(Tswana_Search.userUID),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? SliverToBoxAdapter(
                          child: Center(child: LoadingWidget()),
                        )
                      : SliverStaggeredGrid.countBuilder(
                          crossAxisCount: 1,
                          staggeredTileBuilder: (_) => StaggeredTile.fit(1),
                          itemBuilder: (context, index) {
                            ProductModel model = ProductModel.fromJson(
                                snapshot.data.documents[index].data);
                            return sourceInfo(model, context,
                                removeCartFunction: () => deleteProduct(
                                    snapshot.data.documents[index].documentID));
                          },
                          itemCount: snapshot.data.documents.length,
                        );
                }),
          ],
        ),
      ),
    );
  }

  deleteProduct(String documentID) {
    SnackBar snackBar = SnackBar(content: Text('Please wait, deleting..'));
    scaffoldKey.currentState.showSnackBar(snackBar);
    Tswana_Search.firestore
        .collection(AbsaApp.collectionAllBook)
        .document(documentID)
        .delete()
        .then((_) {
      SnackBar snackBar = SnackBar(content: Text('Deleted Succeessfully'));
      scaffoldKey.currentState.showSnackBar(snackBar);
    }).catchError((e) {
      SnackBar snackBar = SnackBar(content: Text('Some Error Occurred'));
      scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  personfound (String documentID)
  {
    Tswana_Search.firestore
        .collection(AbsaApp.collectionAllBook)
        .document(documentID).updateData({
      "found": "true",

    });

  }
}
