class AllProductList {
  String? sId;
  String? name;
  String? price;
  String? category;
  String? userId;
  String? company;
  int? iV;

  AllProductList(
      {this.sId,
      this.name,
      this.price,
      this.category,
      this.userId,
      this.company,
      this.iV});

  AllProductList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    price = json['price'];
    category = json['category'];
    userId = json['userId'];
    company = json['company'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['price'] = price;
    data['category'] = category;
    data['userId'] = userId;
    data['company'] = company;
    data['__v'] = iV;
    return data;
  }
}