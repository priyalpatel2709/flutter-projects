class StudentData {
  String? schoolName;
  String? admissionYear;
  String? fullName;
  String? parentName;
  String? residentialType;
  String? gender;
  String? category;
  String? contactNumber;
  String? address;
  String? sEMPTY8;

  StudentData(
      {this.schoolName,
      this.admissionYear,
      this.fullName,
      this.parentName,
      this.residentialType,
      this.gender,
      this.category,
      this.contactNumber,
      this.address,
      this.sEMPTY8});

  StudentData.fromJson(Map<String, dynamic> json) {
    schoolName =
        json['AHMEDABAD CITY 2024      ENGLISH MEDIUM'];
    admissionYear = json['__EMPTY'];
    fullName = json['__EMPTY_1'];
    parentName = json['__EMPTY_2'];
    residentialType = json['__EMPTY_3'];
    gender = json['__EMPTY_4'];
    category = json['__EMPTY_5'];
    contactNumber = json['__EMPTY_6'];
    address = json['__EMPTY_7'];
    sEMPTY8 = json['__EMPTY_8'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AHMEDABAD CITY 2024      ENGLISH MEDIUM'] =
        this.schoolName;
    data['__EMPTY'] = this.admissionYear;
    data['__EMPTY_1'] = this.fullName;
    data['__EMPTY_2'] = this.parentName;
    data['__EMPTY_3'] = this.residentialType;
    data['__EMPTY_4'] = this.gender;
    data['__EMPTY_5'] = this.category;
    data['__EMPTY_6'] = this.contactNumber;
    data['__EMPTY_7'] = this.address;
    data['__EMPTY_8'] = this.sEMPTY8;
    return data;
  }
}
