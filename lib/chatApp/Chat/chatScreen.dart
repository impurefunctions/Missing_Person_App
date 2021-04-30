import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/Config/config.dart';
import 'package:ecommerce/chatApp/Config/config.dart';
import 'package:ecommerce/chatApp/Theme/colors.dart';
import 'package:ecommerce/chatApp/WIdgets/myMessageBox.dart';
import 'package:ecommerce/chatApp/WIdgets/peerMessageBox.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

List<Asset> images1 = List<Asset>();
List<Asset> imagesTemp = List<Asset>();
List<String> imageUrls = <String>[];

class ChatScreen extends StatefulWidget {
  final String adminId, userID;

  ChatScreen({Key key, @required this.userID, @required this.adminId})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(adminId: adminId, userID: userID);
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatScreenState({Key key, @required this.adminId, @required this.userID});

  bool isUploading = false, isLoading;
  String adminId, userID, groupChatId, imageUrl;
  var listMessage;
  int currentPageIndex = 0;
  File imageFile;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  PageController _pageController, p2;
  List<String> _timeOfUploading = <String>[];


  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    p2 = PageController();
    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
    initialisingData();

  } //initState()
@override
  void dispose() {
  WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state) {
      case AppLifecycleState.detached:
        print('detached');
        break;
      case AppLifecycleState.resumed:
        readLocal();
        print('resumed');
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.paused:
        Tswana_Search.firestore
            .collection(ChatApp.collectionUser)
            .document(userID)
            .updateData({ChatApp.userChattingWith: null});
        print('paused');
        break;
    }
  }


  void onFocusChange() {
    if (focusNode.hasFocus) {}
  }

  readLocal() async {
    //id = ChatApp.sharedPreferences.getString("Uid") ?? "";
    if (userID.hashCode <= adminId.hashCode) {
      groupChatId = '$userID-$adminId';
    } else {
      groupChatId = '$adminId-$userID';
    }
    Tswana_Search.firestore
        .collection(ChatApp.collectionUser)
        .document(userID)
        .updateData({ChatApp.userChattingWith: adminId});
    setState(() {});
  }

  // TODO Upcoming feature


  Future<void> onSendMessage(String content, int type, [String time,bool updating=true]) async {

    print('Date $time');
    String dateTime = time ?? DateTime.now().millisecondsSinceEpoch.toString();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      await Firestore.instance
          .collection(ChatApp.collectionUser)
          .document(adminId)
          .get().then((snapshot) async {
        print(snapshot.data);
        print(snapshot.data[ChatApp.userChattingWith]);
        print(userID);
         if(snapshot.data[ChatApp.userChattingWith]==userID){



         }
         else{
           DocumentSnapshot snapshot = await Firestore.instance
               .collection(ChatApp.collectionMessage)
               .document(groupChatId)
               .collection(adminId)
               .document(adminId)
               .get()
               .then((snapshot) {
             print(snapshot.documentID);
             print(!snapshot.exists);

             print(snapshot.documentID);
             print(snapshot.data[UserMessage.count]);
             var documentReference1 = Firestore.instance
                 .collection(ChatApp.collectionMessage)
                 .document(groupChatId)
                 .collection(adminId)
                 .document(adminId);
//print('Upd value $updating');
             if(updating){
               Firestore.instance.runTransaction((transaction) async {
                 await transaction.update(
                   documentReference1,
                   {
                     UserMessage.count: (snapshot.data[UserMessage.count] + 1)
                   },
                 );
               });
             }
             return snapshot;
           });
         }
      });
//      print(snapshot.data['count']);

      var documentReference = Firestore.instance
          .collection(ChatApp.collectionMessage)
          .document(groupChatId)
          .collection(groupChatId)
          .document(dateTime);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            UserMessage.idFrom: userID,
            UserMessage.idTo: adminId,
            UserMessage.timestamp: dateTime,
            UserMessage.content: content,
            UserMessage.type: type
          },
        );
      }).catchError((e) {
        print("Eroor strart");
        print(e.toString());
      });

      //response(content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print(content);
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future<bool> onBackPress() {
    print('Backing...');
    Tswana_Search.firestore
        .collection(ChatApp.collectionUser)
        .document(userID)
        .updateData({ChatApp.userChattingWith: null});
        Navigator.pop(context);
    return Future.value(false);
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  void uploadImages() async {
    images1.forEach((f) {
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      onSendMessage('Image', 1, time,false);
      _timeOfUploading.add(time);
      if (_timeOfUploading.length == images1.length) {
        setState(() {
          //images = [];
          //imageUrls = [];
          imagesTemp = [];
          //_timeOfUploading=[];
          isUploading = false;
        });
      }
    });

    print('opploading......');

    images1.forEach((imageFile) {
      postImage(imageFile).then((downloadUrl) {
        onSendMessage(downloadUrl, 1, _timeOfUploading[imageUrls.length],true);
        imageUrls.add(downloadUrl.toString());
        if (imageUrls.length == images1.length) {
          setState(() {
            images1 = [];
            imageUrls = [];
            _timeOfUploading = [];
            isUploading = false;
          });
        }
      }).catchError((err) {
        print(err);
      });
    });
//    for ( var imageFile in images) {
//      postImage(imageFile).then((downloadUrl) {
//        imageUrls.add(downloadUrl.toString());
//        onSendMessage(downloadUrl, 1);
//        if(imageUrls.length==images.length) {
//          setState(() {
//            images = [];
//            imageUrls = [];
//            isUploading=false;
//          });
//        }
//      }).catchError((err) {
//        print(err);
//      });
//    }
  }

  Future loadAssets() async {
    print('d');
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images1,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {}
    if (!mounted) return;
    setState(() {
      images1 = resultList;
      imagesTemp = resultList;
      // _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
//          (images.length == 0)
//              ?
          Container(
            color: backgroundf,
            child: Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
//                    border: Border(
//                      top: BorderSide(
//                        color: Colors.red
//                      )
//                    )
                      ),
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: Tswana_Search.firestore
                          .collection(ChatApp.collectionMessage)
                          .document(groupChatId)
                          .collection(adminId)
                          .document(adminId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    snapshot.data.data[UserMessage.count] == 0
                                        ? Icon(Icons.remove_red_eye)
                                        : Container(),
                                    snapshot.data.data[UserMessage.count] == 0
                                        ? Text("Seen")
                                        : Text("Delivered"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
                (imagesTemp.length == 0)
                    ? Container()
                    : Container(
                        height: 100,
                        child: buildGridView(),
                      ),
                (imagesTemp.length == 0) ? buildInput() : buildSendImage(),
              ],
            ),
          )
//              : Stack(
//                  alignment: Alignment.bottomCenter,
//                  children: <Widget>[
//                    PageView.builder(
//                      itemCount: images.length,
//                      onPageChanged: (index){
//                        p2.jumpToPage(index);
//                          currentPageIndex=index;
//
////                          setState(() {
////
////                          });
//                        //});
//                      },
//                      controller: _pageController,
//                      itemBuilder: (c, index) {
//                        return Container(
//                          color: Colors.black,
//                          child: AssetThumb(
//                            asset: images[currentPageIndex],
//                            width: MediaQuery.of(context).size.width.toInt(),
//                            height: MediaQuery.of(context).size.height.toInt(),
//                            quality: 50,
//                          ),
//                        );
//                      },
//                    ),
//                    Container(
//                      alignment: Alignment.bottomCenter,
//                      height: 120,
//                      padding: EdgeInsets.only(top:10),
//                      color: Colors.grey.withOpacity(0.5),
//                      child: buildGridView(),
//                    ),
//                  ],
//                ),
          // Loading
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildGridView() {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      controller: p2,
      addAutomaticKeepAlives: true,
      children: List.generate(images1.length, (index) {
        Asset asset = images1[index];
        print(asset.getByteData(quality: 100));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _pageController.jumpToPage(index);
              //_pageController.animateTo(index.toDouble(), duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            },
            child: Container(
//              decoration: currentPageIndex == index
//                  ? BoxDecoration(
//                      color: Colors.black,
//                      border: Border.all(
//                        width: 2,
//                        color: Colors.red,
//                      ),
//                    )
//                  : null,
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
                quality: 50,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document[UserMessage.idFrom] == userID) {
      // Right (my message)
      return MyMessages(
        document: document,
        index: index,
        id: userID,
        listMessage: listMessage,
      );
    } else {
      // Left (peer message)
      return PeerMessageBox(
        document: document,
        index: index,
        id: userID,
        listMessage: listMessage,
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Tswana_Search.firestore
                  .collection(ChatApp.collectionMessage)
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy(UserMessage.timestamp, descending: true)
                  .limit(1000)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Icon(
                    Icons.blur_circular,
                    color: Colors.red,
                  ));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: textEditingController,
              //onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 2.0),
            child: new IconButton(
                icon: new Icon(
                  Icons.image,
                  color: Colors.red,
                ),
                onPressed: () {
                  loadAssets();
                }),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(
                Icons.send,
                color: Colors.red,
              ),
              onPressed: () {
                onSendMessage(textEditingController.text, 0);
                if (isLoading)
                  print("true");
                else
                  print("false");
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildSendImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          Flexible(child: Container()),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              onPressed: () {
                images1 = [];
                setState(() {});
              },
            ),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: isUploading
                ? Text('')
                : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.red,
                    ),
                    onPressed: isUploading
                        ? null
                        : () {
                            uploadImages();
                            //onSendMessage(textEditingController.text, 0);
                            if (isLoading)
                              print("true");
                            else
                              print("false");
                          },
                  ),
          )
        ],
      ),
    );
  }

  void initialisingData() async{
    Tswana_Search.firestore
        .collection(ChatApp.collectionMessage)
        .document(groupChatId)
        .collection(Tswana_Search.sharedPreferences.getString(Tswana_Search.userUID),)
        .document(Tswana_Search.sharedPreferences.getString(Tswana_Search.userUID))
        .setData({UserMessage.count: 0}).catchError((error) {
      print('Hello');
      print(error);
    });
    DocumentSnapshot snapshot = await Firestore.instance
        .collection(ChatApp.collectionMessage)
        .document(groupChatId)
        .collection(adminId)
        .document(adminId)
        .get()
        .then((snapshot) {
      print(snapshot.documentID);
      print(!snapshot.exists);
      if (!snapshot.exists){
        Firestore.instance
            .collection(ChatApp.collectionMessage)
            .document(groupChatId)
            .collection(adminId)
            .document(adminId)
            .setData({UserMessage.count: 0}).catchError((error) {
          print('Hello');
          print(error);
        });
      }
      return snapshot;
    });
  }
}

//
//import 'dart:convert';
//import 'dart:io';
//import 'dart:io' as io;
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dio/dio.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter_app/main.dart';
//import 'package:flutter_app/models/message_model.dart';
//import 'package:flutter_app/models/users_model.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:intl/intl.dart';
//import 'dart:ui';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_app/Fateh/sendPropasal.dart';
//final themeColor = Color(0xfff5a623);
//final primaryColor = Color(0xff203152);
//final greyColor = Color(0xffaeaeae);
//final greyColor2 = Color(0xffE8E8E8);
//
//class ChatScreen extends StatefulWidget {
//  final String peerID, id,peerIDName;
//
//  /// NOTE TO JORDAN : when your relate this to the backend you will
//  /// need a room id and pass the room id and based on the room id you will populate the messages
//
//  ChatScreen({this.peerID, this.id, this.peerIDName});
//
//  @override
//  _ChatScreenState createState() => _ChatScreenState(peerId: peerID, id: id,peerIDName: peerIDName);
//}
//
//class _ChatScreenState extends State<ChatScreen> {
//  _ChatScreenState({
//    Key key,
//    @required this.peerId,
//    @required this.id,
//    @required this.peerIDName,
//  });
//
//  String peerId;
//  String id;
//  String peerIDName;
//  var listMessage;
//  String groupChatId;
//  SharedPreferences prefs;
//  File imageFile;
//  bool isLoading;
//  bool isShowSticker;
//  String imageUrl;
//  String tempDT;
//  bool isContractFileUploading = false;
//  bool downloading = true;
//  String tempDTD;
//  final TextEditingController textEditingController =
//  new TextEditingController();
//  final ScrollController listScrollController = new ScrollController();
//  final FocusNode focusNode = new FocusNode();
//
//
////  _buildMessage(Message message, bool isMe) {
////    return Row(
////      children: <Widget>[
////        Container(
////          margin: isMe
////              ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0)
////              : EdgeInsets.only(
////                  top: 8.0,
////                  bottom: 8.0,
////                ),
////          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
////          width: MediaQuery.of(context).size.width * 0.75,
////          decoration: BoxDecoration(
////              color: isMe ? Theme.of(context).accentColor : Color(0xFFFFFEFEE),
////              borderRadius: isMe
////                  ? BorderRadius.only(
////                      topLeft: Radius.circular(15.0),
////                      bottomLeft: Radius.circular(15.0),
////                    )
////                  : BorderRadius.only(
////                      topRight: Radius.circular(15.0),
////                      bottomRight: Radius.circular(15.0),
////                    )),
////          child: Column(
////            crossAxisAlignment: CrossAxisAlignment.start,
////            children: <Widget>[
////              Text(
////                message.time,
////                style: TextStyle(
////                  color: Colors.blueGrey,
////                  fontWeight: FontWeight.w600,
////                  fontSize: 16.0,
////                ),
////              ),
////              SizedBox(height: 5.0),
////              Text(
////                message.text,
////                style: TextStyle(
////                  color: Colors.blueGrey,
////                  fontWeight: FontWeight.w600,
////                  fontSize: 16.0,
////                ),
////              ),
////            ],
////          ),
////        ),
////        !isMe
////            ? IconButton(
////                icon: message.isLiked
////                    ? Icon(Icons.favorite)
////                    : Icon(Icons.favorite_border),
////                iconSize: 30.0,
////                color: message.isLiked
////                    ? Theme.of(context).primaryColor
////                    : Colors.blueGrey,
////                onPressed: () {},
////              )
////            : SizedBox.shrink(),
////      ],
////    );
////  }
//
//  @override
//  void initState() {
//    super.initState();
//    focusNode.addListener(onFocusChange);
//
//    groupChatId = '';
//
//    isLoading = false;
//    isShowSticker = false;
//    imageUrl = '';
//
//    readLocal();
//  }
//
//
//  void onFocusChange() {
//    if (focusNode.hasFocus) {
//      // Hide sticker when keyboard appear
//      setState(() {
//        isShowSticker = false;
//      });
//    }
//  }
//
//  readLocal() async {
////    prefs = await SharedPreferences.getInstance();
//    //id = prefs.getString('id') ?? '';
//    if (id.hashCode <= peerId.hashCode) {
//      groupChatId = '$id-$peerId';
//    } else {
//      groupChatId = '$peerId-$id';
//    }
//// TODO Uncomment it
//    Firestore.instance
//        .collection('users')
//        .document(id)
//        .updateData({'chattingWith': peerId});
//
//    setState(() {});
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        backgroundColor: Theme
//            .of(context)
//            .primaryColor,
//        appBar: AppBar(
//          title: Center(
//            child: Text(
//              //            widget.user.name,
//              "hbhbhj",
//              style: TextStyle(
//                fontSize: 28.0,
//                fontWeight: FontWeight.bold,
//              ),
//            ),
//          ),
//          elevation: 0.0,
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.more_horiz),
//              iconSize: 30.0,
//              color: Colors.white,
//              onPressed: () {},
//            ),
//          ],
//        ),
//        body: Stack(
//          children: <Widget>[
//            Column(
//              children: <Widget>[
//                Expanded(
//                  child: Container(
//                      decoration: BoxDecoration(
//                          color: Colors.white,
//                          borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(30.0),
//                            topRight: Radius.circular(30.0),
//                          )),
//                      child: ClipRRect(
//                        //this one activates when you scroll up the text won't go above the border it clips the text to maintain the shaped rounded view
//                          borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(30.0),
//                            topRight: Radius.circular(30.0),
//                          ),
//                          child: buildListMessage())),
//                ),
//                showContact ? _buildFullContract() : Container(),
//                showContact ? Container() : _buildContract(),
//                showContact ? Container() : _buildKeyBoard()
//              ],
//            ),
//            buildLoading()
//          ],
//        ));
//  }
//
//  Widget buildListMessage() {
//    return groupChatId == ''
//        ? Center(
//        child: CircularProgressIndicator(
//            valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
//        : StreamBuilder(
//      stream: Firestore.instance
//          .collection('messages')
//          .document(groupChatId)
//          .collection(groupChatId)
//          .orderBy('timestamp', descending: true)
//          .snapshots(),
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return Center(
//              child: CircularProgressIndicator(
//                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
//        } else {
//          listMessage = snapshot.data.documents;
//          return ListView.builder(
//            padding: EdgeInsets.all(10.0),
//            itemBuilder: (context, index) =>
//                x(index, snapshot.data.documents[index]),
//            itemCount: snapshot.data.documents.length,
//            reverse: true,
//            controller: listScrollController,
//          );
//        }
//      },
//    );
//  }
//
//  Widget x(int index, DocumentSnapshot document) {
//    return Row(
//      children: <Widget>[
//        Container(
//          margin: document['idFrom'] == id
//              ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 70.0)
//              : EdgeInsets.only(
//            top: 8.0,
//            bottom: 8.0,
//          ),
//          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
//          width: MediaQuery
//              .of(context)
//              .size
//              .width * 0.75,
//          decoration: BoxDecoration(
//              color: document['idFrom'] == id
//                  ? Theme
//                  .of(context)
//                  .accentColor
//                  : Color(0xFFFFFEFEE),
//              borderRadius: document['idFrom'] == id
//                  ? BorderRadius.only(
//                topLeft: Radius.circular(15.0),
//                bottomLeft: Radius.circular(15.0),
//              )
//                  : BorderRadius.only(
//                topRight: Radius.circular(15.0),
//                bottomRight: Radius.circular(15.0),
//              )),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text(
//                DateFormat('dd MMM kk:mm').format(
//                    DateTime.fromMillisecondsSinceEpoch(
//                        int.parse(document['timestamp']))),
//                style: TextStyle(
//                  color: Colors.blueGrey,
//                  fontWeight: FontWeight.w600,
//                  fontSize: 10.0,
//                ),
//              ),
//              SizedBox(height: 5.0),
//              document['type'] == 0
//                  ? Text(
//                document['content'],
//                style: TextStyle(
//                  color: Colors.blueGrey,
//                  fontWeight: FontWeight.w600,
//                  fontSize: 16.0,
//                ),
//              )
//                  : Container(
//                child: Row(
//                  children: <Widget>[
//                    document['content'] == ''
//                        ? Container(
//                      height: 20,
//                      width: 20,
//                      child: Center(
//                        child: CircularProgressIndicator(
//                            valueColor:
//                            AlwaysStoppedAnimation<Color>(
//                                themeColor)),
//                      ),
//                    )
//                        : document[tempDTD] == null
//                        ? InkWell(
//                      onTap: () {
//                        tempDTD = DateTime
//                            .now()
//                            .millisecondsSinceEpoch
//                            .toString();
//
//                        downloadFile(document['content'],
//                            document['fileName'], document);
//                      },
//                      child: Icon(Icons.file_download),
//                    )
//                        : document[tempDTD] == false
//                        ? InkWell(
//                      onTap: () {
//                        tempDTD = DateTime
//                            .now()
//                            .millisecondsSinceEpoch
//                            .toString();
//
//                        downloadFile(document['content'],
//                            document['fileName'], document);
//                      },
//                      child: Icon(Icons.file_download),
//                    )
//                        : Container(
//                      height: 20,
//                      width: 20,
//                      child: Center(
//                        child: CircularProgressIndicator(
//                            valueColor:
//                            AlwaysStoppedAnimation<
//                                Color>(themeColor)),
//                      ),
//                    ),
//                    document['content'] == ''
//                        ? Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Text('File Uploading'),
//                    )
//                        : (document[tempDTD] == null
//                        ? Text('PDF File')
//                        : (document[tempDTD] == false)
//                        ? Text('PDF File')
//                        : Text('File Downloading')),
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ),
//      ],
//    );
//  }
//
//  Widget buildLoading() {
//    return Positioned(
//      child: isLoading
//          ? Container(
//        child: Center(
//          child: CircularProgressIndicator(
//              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
//        ),
//        color: Colors.white.withOpacity(0.8),
//      )
//          : Container(),
//    );
//  }
//
//  _buildKeyBoard() {
//    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 8.0),
//      color: Colors.white,
//      height: 60.0,
//      child: Row(
//        children: <Widget>[
//          IconButton(
//            icon: Icon(Icons.photo_library),
//            color: Theme
//                .of(context)
//                .primaryColor,
//            onPressed: () {
//              // TODO Pick File
//              showDialog(
//                  context: context,
//                  builder: (_) {
//                    return AlertDialog(
//                      content: Column(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          InkWell(
//                              onTap: () {
//                                pickFileFromPhone();
//                                Navigator.pop(context);
//                              },
//                              child: Text('Pick File From Phone')),
//                          InkWell(
//                              onTap: () {},
//                              child: Text('Pick File From Template')),
//                        ],
//                      ),
//                    );
//                  });
//            },
//          ),
//          Expanded(
//            child: TextField(
//              style: TextStyle(color: primaryColor, fontSize: 15.0),
//              controller: textEditingController,
//              decoration: InputDecoration.collapsed(
//                hintText: 'Type your message...',
//                hintStyle: TextStyle(color: greyColor),
//              ),
//              focusNode: focusNode,
//            ),
//          ),
//          Material(
//            child: new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 8.0),
//              child: new IconButton(
//                icon: new Icon(Icons.send),
//                onPressed: () => onSendMessage(textEditingController.text, 0),
//                color: Theme
//                    .of(context)
//                    .primaryColor,
//              ),
//            ),
//            color: Colors.white,
//          ),
//        ],
//      ),
//    );
//  }
//
//  bool isLastMessageLeft(int index) {
//    if ((index > 0 &&
//        listMessage != null &&
//        listMessage[index - 1]['idFrom'] == id) ||
//        index == 0) {
//      return true;
//    } else {
//      return false;
//    }
//  }
//
//  bool isLastMessageRight(int index) {
//    if ((index > 0 &&
//        listMessage != null &&
//        listMessage[index - 1]['idFrom'] != id) ||
//        index == 0) {
//      return true;
//    } else {
//      return false;
//    }
//  }
//
//  void onSendMessage(String content, int type) {
//    // type: 0 = text, 1 = file
//    if (content.trim() != '') {
//      textEditingController.clear();
//      var documentReference = Firestore.instance
//          .collection('messages')
//          .document(groupChatId)
//          .collection(groupChatId)
//          .document(DateTime
//          .now()
//          .millisecondsSinceEpoch
//          .toString());
//
//      Firestore.instance.runTransaction((transaction) async {
//        await transaction.set(
//          documentReference,
//          {
//            'idFrom': id,
//            'idTo': peerId,
//            'timestamp': DateTime
//                .now()
//                .millisecondsSinceEpoch
//                .toString(),
//            'content': content,
//            'type': type
//          },
//        );
//      });
//      listScrollController.animateTo(0.0,
//          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//    } else {
//      Fluttertoast.showToast(msg: 'Nothing to send');
//    }
//  }
//
//  Future<void> pickFileFromPhone() async {
//    imageFile =
//    await FilePicker.getFile(fileExtension: 'pdf', type: FileType.CUSTOM);
//
//    if (imageFile != null) {
//      setState(() {
//        isLoading = true;
//      });
//      tempDT = DateTime
//          .now()
//          .millisecondsSinceEpoch
//          .toString();
//      onSendMessagePDF('', 1, tempDT);
//      setState(() {
//        isLoading = false;
//      });
//      uploadFile();
//    }
//  }
//
//  Future<void> downloadFile(String url, String fileName,
//      DocumentSnapshot document) async {
//    downloadUpdate(document, true);
//
//    String extension = 'pdf';
//    var dio = new Dio();
//    var dir = await getExternalStorageDirectory();
//    var knockDir =
//    await new Directory('${dir.path}/AZAR').create(recursive: true);
//    print("Hello checking the pdf in Externaal Sorage ");
//    io.File('${knockDir.path}/$fileName.$extension').exists().then((a) async {
//      print(a);
//      if (a) {
//        print("Opening file");
//        downloadUpdate(document, false);
//        showDialog(
//            context: context,
//            builder: (_) {
//              return AlertDialog(
//                content: Text('File has already been downloaded'),
//                actions: <Widget>[
//                  RaisedButton(onPressed: () {
//                    // TODO change with your pdf viewer
//                    PdfViewer.loadFile('${knockDir.path}/$fileName.$extension');
//                  },
//                    child: Text('Open File'),
//                  )
//                ],
//              );
//            });
//
//        //PdfViewer.loadFile('${knockDir.path}/${fileName}.${extension}');
//        return;
//      } else {
//        print("Downloading file");
//        await dio.download(url, '${knockDir.path}/$fileName.$extension',
//            onReceiveProgress: (rec, total) {
//              //print("Rec: $rec , Total: $total");
//              if (mounted) {
//                setState(() {
//                  downloading = true;
//                  //progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
//                });
//              }
//            });
//        if (mounted) {
//          setState(() {
//            downloading = false;
//            //progressString = "Completed";
//            print('${knockDir.path}');
//
//            // TODO change with your pdf viewer
//            PdfViewer.loadFile('${knockDir.path}/$fileName.$extension');
//            //_message = "File is downloaded to your SD card 'iLearn' folder!";
//          });
//        }
//        downloadUpdate(document, false);
//        print("Download completed");
//      }
//    });
//    //Navigator.pop(context);
//  }
//
//  Future uploadFile() async {
//    String fileName = DateTime
//        .now()
//        .millisecondsSinceEpoch
//        .toString();
//    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
//    StorageUploadTask uploadTask = reference.putFile(imageFile);
//    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//      imageUrl = downloadUrl;
//      setState(() {
//        isLoading = false;
//        onSendMessagePDF(imageUrl, 1, tempDT);
//      });
//    }, onError: (err) {
//      setState(() {
//        isLoading = false;
//        imageFile = null;
//      });
//      Fluttertoast.showToast(msg: 'This file is not an pdf');
//    });
//  }
//
//  Future uploadContractFile() async {
//    onSendMessage(
//      'Contract has been sent to you, pleace trace it in contract section', 0,);
//    print(imageFile);
//    String fileName = DateTime
//        .now()
//        .millisecondsSinceEpoch
//        .toString();
//    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
//    StorageUploadTask uploadTask = reference.putFile(imageFile);
//    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//      imageUrl = downloadUrl;
//      print('H $imageUrl');
//      String temp = DateTime.now().millisecondsSinceEpoch.toString();
//      // Writing to own documents
//      Firestore.instance.collection('users')
//          .document(id)
//          .collection(id).document("$groupChatId-$temp").setData({
//        'contractByID': id,
//        'contractByName': fatehPreferences.getString('nickname'),
//        'contractByAgree': "Accepted",
//        'contractToID': peerId,
//        'contractToName': peerIDName,
//        'contractToAgree': 'Waiting',
//        'pdfUrl': imageUrl,
//        'time': temp,
//        'groupID': groupChatId
//      });
//      // Writing to other documents
//      Firestore.instance.collection('users')
//          .document(peerId)
//          .collection(peerId).document("$groupChatId-$temp").setData({
//        'contractByID': id,
//        'contractByName': fatehPreferences.getString('nickname'),
//        'contractByAgree': "Accepted",
//        'contractToID': peerId,
//        'contractToName': peerIDName,
//        'contractToAgree': 'Waiting',
//        'pdfUrl': imageUrl,
//        'time': temp,
//        'groupID': groupChatId
//      });
//      setState(() {
//        isLoading = false;
//        isContractFileUploading = false;
//        imageFile = null;
//      });
//    }, onError: (err) {
//      print(err);
//      setState(() {
//        isLoading = false;
//      });
//      Fluttertoast.showToast(msg: 'This file is not an pdf');
//    });
//
//    print('F $imageUrl');
//
//  }
//
//  void onSendMessagePDF(String content, int type, String time) {
//    var documentReference = Firestore.instance
//        .collection('messages')
//        .document(groupChatId)
//        .collection(groupChatId)
//        .document(tempDT);
//
//    Firestore.instance.runTransaction((transaction) async {
//      await transaction.set(
//        documentReference,
//        {
//          'idFrom': id,
//          'idTo': peerId,
//          'timestamp': DateTime
//              .now()
//              .millisecondsSinceEpoch
//              .toString(),
//          'content': content,
//          'type': type,
//          'fileName': tempDT
//        },
//      );
//    });
//    listScrollController.animateTo(0.0,
//        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//  }
//
//  downloadUpdate(DocumentSnapshot document, bool isDownloading) {
//    var documentReference = Firestore.instance
//        .collection('messages')
//        .document(groupChatId)
//        .collection(groupChatId)
//        .document(document.documentID);
//
//    Firestore.instance.runTransaction((transaction) async {
//      await transaction.update(
//        documentReference,
//        {tempDTD: isDownloading},
//      );
//    });
//  }
//
//  Widget _buildContract() {
//    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 8.0),
//      color: Colors.greenAccent,
//      height: 60.0,
//      child: InkWell(
//        onTap: () {
//          setState(() {
//            showContact = true;
//          });
//        },
//        child: Row(
//          children: <Widget>[
//            Icon(Icons.add),
//            Text('Make Contract'),
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget _buildFullContract() {
//    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 8.0),
//      color: Colors.grey,
//      height: 120.0,
//      child: Column(
//        children: <Widget>[
//          Text('Make Contract'),
//          Row(
//            children: <Widget>[
//              IconButton(
//                icon: Icon(Icons.attach_file),
//                color: Theme
//                    .of(context)
//                    .primaryColor,
//                onPressed: () async {
//                  imageFile = null;
//                  imageFile =
//                  await FilePicker.getFile(
//                      fileExtension: 'pdf', type: FileType.CUSTOM);
//                },
//              ),
//              Text('Pick PDF File'),
//            ],
//          ),
//          Row(
//            children: <Widget>[
//              Checkbox(value: checkBoxValue, onChanged: checkBoxFunction),
//              RaisedButton(onPressed: () {
//                if (imageFile != null) {
//                  if (checkBoxValue != true) {
//                    showDialog(context: context, builder: (_) {
//                      return AlertDialog(
//                        content: Text(
//                            'Please agree on contract terms and conditioons'),
//                        actions: <Widget>[
//                          RaisedButton(onPressed: () {
//                            Navigator.pop(context);
//                          },
//                            child: Text('OK'),
//                          )
//                        ],
//                      );
//                    });
//                  }
//                  else {
//                    uploadContractFile().then((k){
//
//                    });
//
//
//                    setState(() {
//                      showDialog(context: context, builder: (_) {
//                        return AlertDialog(
//                          content: Text(
//                              'Contract Send, You  can track the details in contract section'),
//                          actions: <Widget>[
//                            RaisedButton(onPressed: () {
//                              Navigator.pop(context);
//                            },
//                              child: Text('OK'),
//                            )
//                          ],
//                        );
//                      });
//                      showContact = false;
//                    });
//                  }
//                }
//                else {
//                  showDialog(context: context, builder: (_) {
//                    return AlertDialog(
//                      content: Text('Please attach pdf file'),
//                      actions: <Widget>[
//                        RaisedButton(onPressed: () {
//                          Navigator.pop(context);
//                        },
//                          child: Text('OK'),
//                        )
//                      ],
//                    );
//                  });
//                }
//              },
//                child: Text('Make Contrct'),
//              ),
//            ],
//          )
//        ],
//      ),
//    );
//  }
//
//  bool checkBoxValue = false;
//  bool showContact = false;
//
//  void checkBoxFunction(bool value) {
//    setState(() {
//      checkBoxValue = value;
//    });
//  }
//}
//
//class MakeContract extends StatefulWidget {
//  @override
//  _MakeContractState createState() => _MakeContractState();
//}
//
//class _MakeContractState extends State<MakeContract> {
//  bool checkBoxValue = false;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Column(
//        children: <Widget>[
//          Text('Please attach PDF file for contract '),
//          RaisedButton(onPressed: () {
//
//          },
//            child: Text('Attach File'),
//          ),
//          Checkbox(value: checkBoxValue, onChanged: checkBoxFunction),
//          RaisedButton(onPressed: () {
//
//          },
//            child: Text('Make Contrct'),
//          ),
//
//
//        ],
//      ),
//
//    );
//  }
//
//  void checkBoxFunction(bool value) {
//    setState(() {
//      checkBoxValue = value;
//    });
//  }
//}
//
//
