import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String name;
  DateTime last_seen;
  String description;
  String uid;
  List<String> urls;
  String found;
  String age;

  ProductModel(
      {this.name,
        this.last_seen,
        this.description,
        this.uid,
        this.found,
        this.urls,
        this.age});

  ProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    final Timestamp timestamp = json['last_seen'] as Timestamp;
    last_seen = timestamp.toDate();
    description = json['description'];
    uid = json['uid'];
    urls = json['urls'].cast<String>();
    age = json['age'];
    found = json['found'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['last_seen'] = this.last_seen;
    data['description'] = this.description;
    data['uid'] = this.uid;
    data['urls'] = this.urls;
    data['age'] = this.age;
    data['found'] = this.found;
    return data;
  }
}