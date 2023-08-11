class AppointmentsOfUser {
  String? user;
  List<BookedTimeSlots>? bookedTimeSlots;

  AppointmentsOfUser({this.user, this.bookedTimeSlots});

  AppointmentsOfUser.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    if (json['bookedTimeSlots'] != null) {
      var slotsJson = json['bookedTimeSlots'] as List<dynamic>;
      bookedTimeSlots = slotsJson.map((slot) => BookedTimeSlots.fromJson(slot)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = user;
    if (bookedTimeSlots != null) {
      data['bookedTimeSlots'] = bookedTimeSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookedTimeSlots {
  String? startTime;
  String? endTime;
  String? name;

  BookedTimeSlots({this.startTime, this.endTime, this.name});

  factory BookedTimeSlots.fromJson(Map<String, dynamic> json) {
    return BookedTimeSlots(
      startTime: json['startTime'],
      endTime: json['endTime'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['name'] = name;
    return data;
  }
}
