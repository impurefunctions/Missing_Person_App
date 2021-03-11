class ProductModel {
  String title;
  String contacts;
  int type_of_Livestock;
  PublishedDate publishedDate;
  String thumbnailUrl;
  String longDescription;
  String status;
  String location;
  String price;
  List<dynamic> authors;
  List<String> categories;

  ProductModel(
      {this.title,
        this. contacts,
        this.type_of_Livestock,
        this.publishedDate,
        this.thumbnailUrl,
        this.location,
        this.status,
        this.price,
        this.authors,
        this.categories});

  ProductModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    contacts = json['contacts'];
    price = json['price'];
    location = json['location'];
    type_of_Livestock = json['type_of_Livestock'];
    publishedDate = json['publishedDate'] != null
        ? new PublishedDate.fromJson(json['publishedDate'])
        : null;
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    authors = json['authors'].cast<String>();
    categories = json['categories'].cast<String>();
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['contacts'] = this.contacts;
    data['location'] = this.location;
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
