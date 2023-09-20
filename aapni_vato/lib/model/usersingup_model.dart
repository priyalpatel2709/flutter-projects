class UserSingUp {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? token;
  String? pic;
  String? deviceToken;

  UserSingUp(
      {this.sId, this.name, this.email, this.password, this.token, this.pic,this.deviceToken});

  UserSingUp.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    token = json['token'];
    pic = json['pic'];
    deviceToken = json['deviceToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['token'] = this.token;
    data['pic'] = this.pic;
    data['deviceToken'] = this.deviceToken;
    return data;
  }
}