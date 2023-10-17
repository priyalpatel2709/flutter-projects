class StudentData {
  dynamic  srNo;
  dynamic  candidateName;
  String? motherName;
  String? fatherName;
  String? area;
  String? gender;
  String? category;
  dynamic  contactNumber;
  String? schoolName;
  String? address;

  StudentData(
      {this.srNo,
      this.candidateName,
      this.motherName,
      this.fatherName,
      this.area,
      this.gender,
      this.category,
      this.contactNumber,
      this.schoolName,
      this.address});

  StudentData.fromJson(Map<String, dynamic> json) {
    srNo =
        json['AHMEDABAD CITY 2024      ENGLISH MEDIUM'];
    candidateName = json['__EMPTY'];
    motherName = json['__EMPTY_1'];
    fatherName = json['__EMPTY_2'];
    area = json['__EMPTY_3'];
    gender = json['__EMPTY_4'];
    category = json['__EMPTY_5'];
    contactNumber = json['__EMPTY_6'];
    schoolName = json['__EMPTY_7'];
    address = json['__EMPTY_8'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AHMEDABAD CITY 2024      ENGLISH MEDIUM'] =
        srNo;
    data['__EMPTY'] = candidateName;
    data['__EMPTY_1'] = motherName;
    data['__EMPTY_2'] = fatherName;
    data['__EMPTY_3'] = area;
    data['__EMPTY_4'] = gender;
    data['__EMPTY_5'] = category;
    data['__EMPTY_6'] = contactNumber;
    data['__EMPTY_7'] = schoolName;
    data['__EMPTY_8'] = address;
    return data;
  }
}
