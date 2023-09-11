class UserLogIn {
  String? sId;
  String? name;
  String? email;
  String? token;
  String? pic;


  UserLogIn({this.sId, this.name, this.email, this.token,this.pic});

  UserLogIn.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
    pic = json['pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['token'] = this.token;
    data['pic'] = this.pic;
    return data;
  }
}