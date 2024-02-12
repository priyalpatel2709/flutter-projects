import 'dart:convert';

class AppInfo {
    final String? id;
    final String appVresion;
    final String appUpdateVersion;
    final String appforceUpdateVersion;
    final String appname;
    final int? v;

    AppInfo({
        this.id,
        required this.appVresion,
        required this.appUpdateVersion,
        required this.appforceUpdateVersion,
        required this.appname,
        this.v,
    });

    factory AppInfo.fromRawJson(String str) => AppInfo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        id: json["_id"],
        appVresion: json["appVresion"],
        appUpdateVersion: json["appUpdateVersion"],
        appforceUpdateVersion: json["appforceUpdateVersion"],
        appname: json["appname"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "appVresion": appVresion,
        "appUpdateVersion": appUpdateVersion,
        "appforceUpdateVersion": appforceUpdateVersion,
        "appname": appname,
        "__v": v,
    };
}
