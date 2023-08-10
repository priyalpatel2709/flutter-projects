class AppointmentsOfUser {
  String? user;
  List<BookedTimeSlots>? bookedTimeSlots;

  AppointmentsOfUser({this.user, this.bookedTimeSlots});

  AppointmentsOfUser.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    if (json['bookedTimeSlots'] != null) {
      bookedTimeSlots = <BookedTimeSlots>[];
      json['bookedTimeSlots'].forEach((v) {
        bookedTimeSlots!.add(new BookedTimeSlots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    if (this.bookedTimeSlots != null) {
      data['bookedTimeSlots'] =
          this.bookedTimeSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookedTimeSlots {
  String? startTime;
  String? endTime;
  String? name;

  BookedTimeSlots({this.startTime, this.endTime, this.name});

  BookedTimeSlots.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['name'] = this.name;
    return data;
  }
}