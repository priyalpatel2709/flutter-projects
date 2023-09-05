class UserLogIn {
  String? sId;
  String? name;
  String? email;
  String? token;

  UserLogIn({this.sId, this.name, this.email, this.token});

  UserLogIn.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['token'] = this.token;
    return data;
  }
}