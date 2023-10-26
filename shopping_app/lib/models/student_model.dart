import 'dart:convert';

class StudentData {
  int srNo;
  BlockName? blockName;
  String? candidateName;
  String? motherName;
  String? fatherName;
  Area? area;
  Gender? gender;
  Category? category;
  int? mobileNumber;
  String? nameOfSchool;
  String? presentPostalAddress;
  MediumOfExam? mediumOfExam;

  StudentData({
    required this.srNo,
    this.blockName,
    this.candidateName,
    this.motherName,
    this.fatherName,
    this.area,
    this.gender,
    this.category,
    this.mobileNumber,
    this.nameOfSchool,
    this.presentPostalAddress,
    this.mediumOfExam,
  });

  StudentData copyWith({
    int? srNo,
    BlockName? blockName,
    String? candidateName,
    String? motherName,
    String? fatherName,
    Area? area,
    Gender? gender,
    Category? category,
    int? mobileNumber,
    String? nameOfSchool,
    String? presentPostalAddress,
    MediumOfExam? mediumOfExam,
  }) =>
      StudentData(
        srNo: srNo ?? this.srNo,
        blockName: blockName ?? this.blockName,
        candidateName: candidateName ?? this.candidateName,
        motherName: motherName ?? this.motherName,
        fatherName: fatherName ?? this.fatherName,
        area: area ?? this.area,
        gender: gender ?? this.gender,
        category: category ?? this.category,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        nameOfSchool: nameOfSchool ?? this.nameOfSchool,
        presentPostalAddress: presentPostalAddress ?? this.presentPostalAddress,
        mediumOfExam: mediumOfExam ?? this.mediumOfExam,
      );

  factory StudentData.fromRawJson(String str) =>
      StudentData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentData.fromJson(Map<String, dynamic> json) => StudentData(
        srNo: json["Sr.\nNo."],
        blockName: blockNameValues.map[json["Block Name"]]!,
        candidateName: json["Candidate Name"],
        motherName: json["Mother Name"],
        fatherName: json["Father Name"],
        area: areaValues.map[json["Area"]]!,
        gender: genderValues.map[json["Gender"]]!,
        category: categoryValues.map[json["Category"]]!,
        mobileNumber: json["Mobile Number"],
        nameOfSchool: json["Name Of School"],
        presentPostalAddress: json["Present Postal Address"],
        mediumOfExam: mediumOfExamValues.map[json["Medium of Exam"]]!,
      );

  Map<String, dynamic> toJson() => {
        "Sr.\nNo.": srNo,
        "Block Name": blockNameValues.reverse[blockName],
        "Candidate Name": candidateName,
        "Mother Name": motherName,
        "Father Name": fatherName,
        "Area": areaValues.reverse[area],
        "Gender": genderValues.reverse[gender],
        "Category": categoryValues.reverse[category],
        "Mobile Number": mobileNumber,
        "Name Of School": nameOfSchool,
        "Present Postal Address": presentPostalAddress,
        "Medium of Exam": mediumOfExamValues.reverse[mediumOfExam],
      };
}

enum Area { RURAL, URBAN }

final areaValues = EnumValues({"Rural": Area.RURAL, "Urban": Area.URBAN});

enum BlockName { KARJAN, SINOR }

final blockNameValues =
    EnumValues({"KARJAN": BlockName.KARJAN, "SINOR": BlockName.SINOR});

enum Category { GEN, OBC, SC, ST }

final categoryValues = EnumValues({
  "GEN": Category.GEN,
  "OBC": Category.OBC,
  "SC": Category.SC,
  "ST": Category.ST
});

enum Gender { FEMALE, MALE }

final genderValues = EnumValues({"Female": Gender.FEMALE, "Male": Gender.MALE});

enum MediumOfExam { ENGLISH, GUJARATI }

final mediumOfExamValues = EnumValues(
    {"ENGLISH": MediumOfExam.ENGLISH, "GUJARATI": MediumOfExam.GUJARATI});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
