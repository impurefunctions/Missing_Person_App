import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  String email;
  String name;
  String role;
  String uid;
  String url;
  String userToken;

  DocumentReference dBReference;

  UserModel(this.email, this.name, this.role, this.uid, this.url,
      this.userToken);

  UserModel.fromMap(Map<String, dynamic> json, {this.dBReference})
      : assert (json["uid"] != null),
        assert (json["email"] != null),
        assert (json["name"] != null),
        assert (json["role"] != null),
  assert (json["url"] != null),
  assert (json["userToken"] != null),
 uid=  json["uid"],
        email=  json["email"],
  name =   json["name"],
  role =  json["role"],
  url =  json["url"],
  userToken =  json["userToken"];


  UserModel.fromSnapshot(DocumentSnapshot snapshot):
      this.fromMap(snapshot.data, dBReference: snapshot.reference);

  Map<String, Object> toJSon(UserModel userModel) => <String, dynamic>{
    'uid': uid,
    'email': email,
    'name': name,
    'role': role,
    'url': url,
    'userToken': userToken
  };
}