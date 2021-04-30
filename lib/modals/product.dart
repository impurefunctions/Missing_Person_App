import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String name;
  String contacts;

  PublishedDate publishedDate;
  String thumbnailUrl;
  String longDescription;
  String status;
  DateTime last_seen;
  String found;
  String age;
  List<dynamic> authors;
  List<String> categories;

  ProductModel(
      {this.name,
        this. contacts,

        this.publishedDate,
        this.thumbnailUrl,
        this.last_seen,
        this.status,
        this.age,
        this.found,
        this.authors,
        this.categories});

  ProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    contacts = json['contacts'];
    age = json['age'];
    final Timestamp timestamp = json['last_seen'] as Timestamp;
    last_seen = timestamp.toDate();

    found = json['found'];

    publishedDate = json['publishedDate'] != null
        ? new PublishedDate.fromJson(json['publishedDate'])
        : null;
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    authors = json['authors'].cast<String>();
    categories = json['categories'].cast<String>();
    last_seen = json['last_seen'];
    found = json['found'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['contacts'] = this.contacts;
    data['last_seen'] = this.last_seen;
    //data['pageCount'] = this.pageCount;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate.toJson();
    }
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['longDescription'] = this.longDescription;
    data['status'] = this.status;
    data['authors'] = this.authors;
    data['categories'] = this.categories;
    return data;
  }
}

class PublishedDate {
  String date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
