class AllObject {
  String? url;
  String? name;
  String? type;

  AllObject({this.url, this.name, this.type});

  AllObject.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}
