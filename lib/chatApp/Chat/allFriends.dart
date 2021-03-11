import 'dart:convert';
import 'dart:io';

import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/Widgets/loadingWidget.dart';
import 'package:ecommerce/chatApp/Config/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'chat.dart';

class MyChats extends StatefulWidget {
  @override
  _MyChatsState createState() => _MyChatsState();
}

class _MyChatsState extends State<MyChats> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    readLocal();
    // TODO: define these methods in your homepage
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
      AbsaCompetitionApp.firestore
          .collection(ChatApp.collectionAdmin)
          .document(AbsaCompetitionApp.sharedPreferences.getString(ChatApp.userUID))
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
      // TODO: Change package name
      Platform.isAndroid
          ? 'com.example.customersuppert_admin'
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

  readLocal() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: Text('Messages'),
        //leading: Container(),
      ),
      body: _buildBody(context),
    ));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AbsaCompetitionApp.firestore
          .collection(AbsaCompetitionApp.collectionUser)
          .document(AbsaCompetitionApp.sharedPreferences.getString(ChatApp.userUID))
          .collection(AbsaCompetitionApp.userFriendList)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    return InkWell(
      onTap: () {
        Route route = MaterialPageRoute(
            builder: (builder) => Chat(
                  peerId: data.documentID,
                  userID:
                      AbsaCompetitionApp.sharedPreferences.getString(ChatApp.userUID),
                ));
        Navigator.push(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
        child: InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        //child: Image.network(data[ChatApp.userPhotoUrl]),
                        backgroundImage:
                            NetworkImage(data.data[AbsaCompetitionApp.userAvatarUrl]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data[ChatApp.userName].toUpperCase(),
                          style: Theme.of(context).textTheme.title),
//                      Text(data[AbsaCompetitionApp.user],
//                          style: Theme.of(context)
//                              .textTheme
//                              .title
//                              .copyWith(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                ),
//                Flexible(child: Container()),
//                StreamBuilder(
//                    stream: AbsaCompetitionApp.firestore
//                        .collection(ChatApp.collectionUser)
//                        .document()
//                        .snapshots(),
//                    builder: (_, snap) {
//                      return snap.hasData
//                          ? StreamBuilder<DocumentSnapshot>(
//                              stream: AbsaCompetitionApp.firestore
//                                  .collection(ChatApp.collectionMessage)
//                                  .document(groupChatId)
//                                  .collection(AbsaCompetitionApp.sharedPreferences
//                                      .getString(ChatApp.userUID))
//                                  .document(AbsaCompetitionApp.sharedPreferences
//                                      .getString(ChatApp.userUID))
//                                  .snapshots(),
//                              builder: (context, snapshot) {
//                                print(groupChatId);
//                                if (snapshot.hasData) {
//                                  return snapshot.data.exists
//                                      ? snapshot.data.data['count'] == 0
//                                          ? Container()
//                                          : CircleAvatar(
//                                              backgroundColor: Theme.of(context)
//                                                  .primaryColor,
//                                              radius: 15,
//                                              child: Text(
//                                                snapshot.data.data['count']
//                                                    .toString(),
//                                                style: TextStyle(fontSize: 15),
//                                              ),
//                                            )
//                                      : Container();
//                                } else if (snapshot.hasError) {
//                                  return Text('0');
//                                } else {
//                                  return Text('');
//                                }
//                              },
//                            )
//                          : LoadingWidget();
//                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
