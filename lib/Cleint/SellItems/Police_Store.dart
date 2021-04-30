import 'dart:convert';
import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/Models/product.dart';

import 'package:ecommerce/Cleint/config/cleint.dart';
import 'package:ecommerce/Cleint/productPage.dart';
import 'package:ecommerce/Widgets/Police_Drawer.dart';
import 'package:ecommerce/Widgets/customAppBar.dart';
import 'package:ecommerce/Widgets/loadingWidget.dart';
import 'package:ecommerce/Widgets/searchBox.dart';
import 'package:ecommerce/chatApp/Config/config.dart';

import 'package:ecommerce/notifiers/cartitemcounter.dart';
import 'package:ecommerce/Config/light_color.dart';
import 'package:ecommerce/Config/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/Config/config.dart';


double width;

class Police_Store extends StatefulWidget {
  @override
  _Police_StoreState createState() => _Police_StoreState();
}

class _Police_StoreState extends State<Police_Store> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Tswana_Search.firestore
          .collection(ChatApp.collectionUser)
          .document(
          Tswana_Search.sharedPreferences.getString(Tswana_Search.userUID))
          .updateData({ChatApp.userToken: token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      // Change package name
      Platform.isAndroid
          ? 'com.example.ecommerce'
          : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  Widget build(BuildContext context) {

//    floatingActionButton: new Stack(
//      alignment: Alignment.topLeft,
//      children: <Widget>[
//        new FloatingActionButton(
//          onPressed: () {
//            Navigator.of(context).push(new CupertinoPageRoute(
//                builder: (BuildContext context) => new SellBook()));
//          },
//          child: new Icon(Icons.shopping_cart),
//        ),
//        new CircleAvatar(
//          radius: 10.0,
//          backgroundColor: Colors.red,
//          child: new Text(
//            "0",
//            style: new TextStyle(color: Colors.white, fontSize: 12.0),
//          ),
//        )
//      ],
//    );

    Widget image_carousel = new Container(
      height: 200.0,
      child: new Carousel(
        boxFit: BoxFit.cover,
        images: [
          AssetImage('images/new/1.jpeg'),
          AssetImage('images/new/2.jpg'),
          AssetImage('images/new/3.jpg'),
          AssetImage('images/new/4.jpg'),
          AssetImage('images/new/5.jpg'),
          AssetImage('images/new/6.jpg'),
        ],
        autoplay: true,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 1000),
        dotSize: 4.0,
        indicatorBgPadding: 2.1,
        dotColor: Colors.amber,
        dotBgColor: Colors.transparent,
      ),
    );

    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        drawer: Police_Drawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: MyAppBar(),
            ),
            SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(AbsaApp.collectionAllBook)
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
                      return sourceInfo(model, context);
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                }),
          ],
        ),
      ),
    );
  }
}

Widget sourceInfo(ProductModel model, BuildContext context,
    {Color background, removeCartFunction}) {
  print('Printing.. $removeCartFunction');
  return InkWell(
    onTap: () {
      Route route =
      MaterialPageRoute(builder: (_) => ProductPage(productModel: model));
      Navigator.push(context, route);
    },
    splashColor: LightColor.purple,
    child: Container(
        height: 170,
        width: width - 20,
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: .7,
              child: card(primaryColor: background, imgPath: model.urls[0]),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 15),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Text(model.name,
                                style: TextStyle(
                                    color: LightColor.purple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: background,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(width: 10)
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 0.0,
                              ),
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                //mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("Name: ",
                                      style: AppTheme.h6Style.copyWith(
                                        fontSize: 14,
                                        color: LightColor.grey,
                                      )),
                                  Text(model.name,
                                      style: AppTheme.h6Style.copyWith(
                                        fontSize: 14,
                                        color: Colors.red,
                                      )),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),



                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 0.0,
                              ),
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                //mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("Last_Seen: ",
                                      style: AppTheme.h6Style.copyWith(
                                        fontSize: 14,
                                        color: LightColor.grey,
                                      )),
                                  Text(DateFormat.yMMMd().format(model.last_seen),
                                      style: AppTheme.h6Style.copyWith(
                                        fontSize: 14,
                                        color: Colors.red,
                                      )),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: removeCartFunction == null
                          ? Container()
                          : IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            color: LightColor.purple,
                          ),
                          onPressed: () {
                            print('StoreHome.dart');
                            removeCartFunction();
                            //checkItemInCart(model.isbn, context);
                          }),
                    ),
                    Divider(
                      height: 4,
                    )
                  ],
                ))
          ],
        )),
  );
}

Widget _chip(String text, Color textColor,
    {double height = 0, bool isPrimaryCard = false}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Chip(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: height),
      label: Text(
        text,
        style: TextStyle(
            color: isPrimaryCard ? Colors.white : textColor, fontSize: 12),
      ),
    ),
  );
}

Widget card({Color primaryColor = Colors.redAccent, String imgPath}) {
  return Container(
      height: 150,
      width: width * .34,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                offset: Offset(0, 5), blurRadius: 10, color: Color(0x12000000))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Image.network(
          imgPath,
          height: 150,
          width: width * .34,
          fit: BoxFit.fill,
        ),
      ));
}

void checkItemInCart(String productID, BuildContext context) {
  print(productID);

  ///print(cartItems);
  Tswana_Search.sharedPreferences
      .getStringList(
    Tswana_Search.userFriendList,
  )
      .contains(productID)
      ? Fluttertoast.showToast(msg: 'Product is already in cat')
      : addToCart(productID, context);
}

void addToCart(String productID, BuildContext context) {
  List temp = Tswana_Search.sharedPreferences.getStringList(
    Tswana_Search.userFriendList,
  );
  temp.add(productID);
  Tswana_Search.firestore
      .collection(Tswana_Search.collectionUser)
      .document(Tswana_Search.sharedPreferences.getString(Tswana_Search.userUID))
      .updateData({Tswana_Search.userFriendList: temp}).then((_) {
    Fluttertoast.showToast(msg: 'Added Succesfully');
    Tswana_Search.sharedPreferences
        .setStringList(Tswana_Search.userFriendList, temp);
    Provider.of<CartItemCounter>(context, listen: false).displayResult();
  });
}
