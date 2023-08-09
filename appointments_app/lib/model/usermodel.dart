class UserModel {
  String? sId;
  String? name;
  String? description;
  String? maxSlots;
  List<BookedSlots>? bookedSlots;
  int? iV;

  UserModel(
      {this.sId,
      this.name,
      this.description,
      this.maxSlots,
      this.bookedSlots,
      this.iV});

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    maxSlots = json['MaxSlots'];
    if (json['bookedSlots'] != null) {
      bookedSlots = <BookedSlots>[];
      json['bookedSlots'].forEach((v) {
        bookedSlots!.add(new BookedSlots.fromJson(v));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['MaxSlots'] = this.maxSlots;
    if (this.bookedSlots != null) {
      data['bookedSlots'] = this.bookedSlots!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class BookedSlots {
  String? date;
  int? count;
  String? sId;

  BookedSlots({this.date, this.count, this.sId});

  BookedSlots.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    count = json['count'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['count'] = this.count;
    data['_id'] = this.sId;
    return data;
  }
}