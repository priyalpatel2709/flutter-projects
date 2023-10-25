// To parse this JSON data, do
//
//     final studentData = studentDataFromJson(jsonString);

import 'dart:convert';

List<StudentData> studentDataFromJson(String str) => List<StudentData>.from(
    json.decode(str).map((x) => StudentData.fromJson(x)));

String studentDataToJson(List<StudentData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentData {
  dynamic sinorKarjan2024;
  Empty empty;
  String empty1;
  String empty2;
  String empty3;
  Empty4 empty4;
  Empty5 empty5;
  Empty6 empty6;
  dynamic empty7;
  String empty8;
  String empty9;
  Empty10 empty10;
  String? empty11;

  StudentData({
    required this.sinorKarjan2024,
    required this.empty,
    required this.empty1,
    required this.empty2,
    required this.empty3,
    required this.empty4,
    required this.empty5,
    required this.empty6,
    required this.empty7,
    required this.empty8,
    required this.empty9,
    required this.empty10,
    this.empty11,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) => StudentData(
        sinorKarjan2024: json["SINOR KARJAN 2024"],
        empty: emptyValues.map[json["__EMPTY"]]!,
        empty1: json["__EMPTY_1"],
        empty2: json["__EMPTY_2"],
        empty3: json["__EMPTY_3"],
        empty4: empty4Values.map[json["__EMPTY_4"]]!,
        empty5: empty5Values.map[json["__EMPTY_5"]]!,
        empty6: empty6Values.map[json["__EMPTY_6"]]!,
        empty7: json["__EMPTY_7"],
        empty8: json["__EMPTY_8"],
        empty9: json["__EMPTY_9"],
        empty10: empty10Values.map[json["__EMPTY_10"]]!,
        empty11: json["__EMPTY_11"],
      );

  Map<String, dynamic> toJson() => {
        "SINOR KARJAN 2024": sinorKarjan2024,
        "__EMPTY": emptyValues.reverse[empty],
        "__EMPTY_1": empty1,
        "__EMPTY_2": empty2,
        "__EMPTY_3": empty3,
        "__EMPTY_4": empty4Values.reverse[empty4],
        "__EMPTY_5": empty5Values.reverse[empty5],
        "__EMPTY_6": empty6Values.reverse[empty6],
        "__EMPTY_7": empty7,
        "__EMPTY_8": empty8,
        "__EMPTY_9": empty9,
        "__EMPTY_10": empty10Values.reverse[empty10],
        "__EMPTY_11": empty11,
      };
}

enum Empty { BLOCK_NAME, KARJAN, SINOR }

final emptyValues = EnumValues({
  "Block Name": Empty.BLOCK_NAME,
  "KARJAN": Empty.KARJAN,
  "SINOR": Empty.SINOR
});

enum Empty10 { ENGLISH, GUJARATI, MEDIUM_OF_EXAM }

final empty10Values = EnumValues({
  "ENGLISH": Empty10.ENGLISH,
  "GUJARATI": Empty10.GUJARATI,
  "Medium of Exam": Empty10.MEDIUM_OF_EXAM
});

enum Empty4 { AREA, RURAL, URBAN }

final empty4Values = EnumValues(
    {"Area": Empty4.AREA, "Rural": Empty4.RURAL, "Urban": Empty4.URBAN});

enum Empty5 { FEMALE, GENDER, MALE }

final empty5Values = EnumValues(
    {"Female": Empty5.FEMALE, "Gender": Empty5.GENDER, "Male": Empty5.MALE});

enum Empty6 { CATEGORY, GEN, OBC, SC, ST }

final empty6Values = EnumValues({
  "Category": Empty6.CATEGORY,
  "GEN": Empty6.GEN,
  "OBC": Empty6.OBC,
  "SC": Empty6.SC,
  "ST": Empty6.ST
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
