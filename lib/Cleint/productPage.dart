import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Cleint/Models/product.dart';
import 'package:ecommerce/Cleint/config/cleint.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/Widgets/customAppBar.dart';
import 'package:ecommerce/Widgets/loadingWidget.dart';
import 'package:ecommerce/Widgets/myDrawer.dart';
import 'package:ecommerce/chatApp/Chat/chat.dart';
import 'package:ecommerce/chatApp/Config/config.dart';
import 'package:ecommerce/notifiers/ProductQuantity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProductPage extends StatefulWidget {
  final ProductModel productModel;

  ProductPage({this.productModel});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<NetworkImage> _listOfImages = <NetworkImage>[];

  @override
  Widget build(BuildContext context) {
    _listOfImages = [];
    for (int i = 0;
    i <
        widget.productModel.urls
            .length;
    i++) {
      _listOfImages.add(NetworkImage(widget.productModel.urls[i]));
    }
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: BackButton(
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        drawer: MyDrawer(),
        body: ListView(children: <Widget>[
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 18.0),
                  child: Text(widget.productModel.name,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Carousel(
                      boxFit: BoxFit.cover,
                      images: _listOfImages,
                      autoplay: false,
                      indicatorBgPadding: 5.0,
                      dotPosition: DotPosition.bottomCenter,
                      animationCurve: Curves.fastOutSlowIn,
                      animationDuration:
                      Duration(milliseconds: 2000)),
                ),



                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "DESCRIPTION: ",
                        style: TextStyle(),
                      ),

                      Text(
                        widget.productModel.description.toString(),
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "AGE: ",
                        style: TextStyle(),
                      ),

                      Text(
                        widget.productModel.age.toString(),
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('DETAILS OF POSTEE'),
                ),
                FutureBuilder<DocumentSnapshot>(
                    future: Firestore.instance.collection(
                        AbsaApp.collectionUser).document(widget.productModel.uid).get(),
                    builder: (context, snapshot) {
                      return snapshot.hasData?OwnerCard(snapshot.data):LoadingWidget();
                    })
              ],
            ),
          ),
        ]),
      ),
    );
  }
}


class OwnerCard extends StatelessWidget {
  final DocumentSnapshot snapshot;
  OwnerCard(this.snapshot);
  @override
  Widget build(BuildContext context) {
    return
      snapshot.data[Tswana_Search.userUID]==Tswana_Search.sharedPreferences
          .getString(Tswana_Search.userUID)?Container(
        child: Text('This post was reported by you'),
      ):
      Container(
        child: UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          accountName:
          Text(snapshot.data[Tswana_Search.userName]),
          accountEmail: Row(
            children: <Widget>[
              Text(snapshot.data[Tswana_Search.userEmail]),
              SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: (){
                  List friendList = Tswana_Search.sharedPreferences
                      .getStringList(Tswana_Search.userFriendList);
                  if(!friendList.contains(snapshot.data[ChatApp.userUID])){
                    friendList.add(snapshot.data[ChatApp.userUID]);

                    Tswana_Search.firestore
                        .collection(Tswana_Search.collectionUser)
                        .document(Tswana_Search.sharedPreferences.getString(ChatApp.userUID)).collection(
                        Tswana_Search.userFriendList).document(snapshot.data[ChatApp.userUID]).setData({
                      'name': snapshot.data[ChatApp.userName],
                      'url' :snapshot.data[Tswana_Search.userAvatarUrl]
                    });
                    Tswana_Search.firestore
                        .collection(Tswana_Search.collectionUser)
                        .document(snapshot.data[ChatApp.userUID]).collection(
                        Tswana_Search.userFriendList).document(Tswana_Search.sharedPreferences.getString(ChatApp.userUID)).setData({
                      'name': Tswana_Search.sharedPreferences.getString(ChatApp.userName),
                      'url': Tswana_Search.sharedPreferences.getString(Tswana_Search.userAvatarUrl),
                    });
                    Tswana_Search.sharedPreferences.setStringList(Tswana_Search.userFriendList, friendList);
                  }
                  Route route = MaterialPageRoute(
                      builder: (builder) => Chat(
                        // TODO Change peerID with admin ID
                        peerId: snapshot.data[ChatApp.userUID],
                        userID: Tswana_Search.sharedPreferences.getString(ChatApp.userUID),
                      ));
                  Navigator.push(context, route);
                },
                child: Container(
                  color: Colors.white,
                  width: 80,
                  height: 30,
                  child: Center(child: Text('Chat',style: TextStyle(color: Colors.blueGrey),)),
                ),
              ),
            ],
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
            backgroundImage: NetworkImage(snapshot.data[Tswana_Search.userAvatarUrl]),
          ),
        ),
      );
  }
}
//
//class MyApp extends StatefulWidget {
//  @override
//  _MyAppState createState() => _MyAppState();
//}
//
//class _MyAppState extends State<MyApp> {
//  var rating = 0.0;
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Rating bar demo',
//      theme: ThemeData(
//        primarySwatch: Colors.green,
//      ),
//      debugShowCheckedModeBanner: false,
//      home: Scaffold(
//        body: Center(
//            child: SmoothStarRating(
//              rating: rating,
//              size: 45,
//              starCount: 5,
//              onRatingChanged: (value) {
//                setState(() {
//                  rating = value;
//                });
//              },
//            )),
//      ),
//    );
//  }
//}
