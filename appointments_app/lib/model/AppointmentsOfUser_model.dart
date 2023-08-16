class appointmentsOfUser {
  String? sId;
  String? slotname;
  String? name;
  List<GridDetails>? gridDetails;
  int? iV;

  appointmentsOfUser({
    this.sId,
    this.slotname,
    this.name,
    this.gridDetails,
    this.iV,
  });

  appointmentsOfUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    slotname = json['slotname'];
    name = json['name'];
    if (json['gridDetails'] != null) {
      gridDetails = <GridDetails>[];
      (json['gridDetails'] as List<dynamic>).forEach((v) {
        gridDetails!.add(GridDetails.fromJson(v as Map<String, dynamic>));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['slotname'] = slotname;
    data['name'] = name;
    if (gridDetails != null) {
      data['gridDetails'] = gridDetails!.map((v) => v.toJson()).toList();
    }
    data['__v'] = iV;
    return data;
  }
}

class GridDetails {
  String? date;
  String? startTime;
  String? endTime;
  String? sId;

  GridDetails({this.date, this.startTime, this.endTime, this.sId});

  GridDetails.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['_id'] = sId;
    return data;
  }
}