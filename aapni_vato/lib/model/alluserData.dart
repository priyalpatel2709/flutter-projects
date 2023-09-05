class FetchUser {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? pic;
  bool? isAdmin;
  int? iV;

  FetchUser(
      {this.sId,
      this.name,
      this.email,
      this.password,
      this.pic,
      this.isAdmin,
      this.iV});

  FetchUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    pic = json['pic'];
    isAdmin = json['isAdmin'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['pic'] = this.pic;
    data['isAdmin'] = this.isAdmin;
    data['__v'] = this.iV;
    return data;
  }
}
