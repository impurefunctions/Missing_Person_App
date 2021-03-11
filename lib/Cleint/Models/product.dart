class ProductModel {
  String title;
  String location;
  String description;
  String uid;
  List<String> urls;
  String price;

  ProductModel(
      {this.title,
        this.location,
        this.description,
        this.uid,
        this.urls,
        this.price});

  ProductModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    location = json['location'];
    description = json['description'];
    uid = json['uid'];
    urls = json['urls'].cast<String>();
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['location'] = this.location;
    data['description'] = this.description;
    data['uid'] = this.uid;
    data['urls'] = this.urls;
    data['price'] = this.price;
    return data;
  }
}