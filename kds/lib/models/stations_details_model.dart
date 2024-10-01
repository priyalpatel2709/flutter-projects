class StationsDetails {
  int? kdsId;
  int? storeId;
  String? name;
  String? description;
  bool? isActive;

  StationsDetails(
      {this.kdsId, this.storeId, this.name, this.description, this.isActive});

  StationsDetails.fromJson(Map<String, dynamic> json) {
    kdsId = json['kdsId'];
    storeId = json['storeId'];
    name = json['name'];
    description = json['description'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kdsId'] = this.kdsId;
    data['storeId'] = this.storeId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['isActive'] = this.isActive;
    return data;
  }
}

class OrderTypeOption {
  final String value;
  final String title;

  OrderTypeOption(this.value, this.title);
}

class PageOption {
  final int index;
  final String title;

  PageOption(this.index, this.title);
}
