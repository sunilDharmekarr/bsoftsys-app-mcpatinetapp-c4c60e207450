// To parse this JSON data, do
//
//     final vitalIdModel = vitalIdModelFromJson(jsonString);

import 'dart:convert';

VitalIdModel vitalIdModelFromJson(String vitals, String vitalComments) {
  var vitalModel = VitalIdModel.fromJson(json.decode(vitals));
  if (vitalComments != null) {
    var commentsJson = json.decode(vitalComments);
    var comments = List<VitalComment>.from(
        commentsJson["payload"].map((x) => VitalComment.fromJson(x)));
    for (var commentObj in comments) {
      vitalModel.vitalData
          .firstWhere((element) => element.vitalId == commentObj.vitalId)
          .comments
          .add(commentObj.comment);
    }
  }
  return vitalModel;
}

String vitalIdModelToJson(VitalIdModel data) => json.encode(data.toJson());

class VitalIdModel {
  VitalIdModel({
    this.success,
    this.vitalData,
    this.error,
  });

  String success;
  List<VitalDatum> vitalData;
  String error;

  factory VitalIdModel.fromJson(Map<String, dynamic> json) => VitalIdModel(
        success: json["success"],
        vitalData: List<VitalDatum>.from(
            json["payload"].map((x) => VitalDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(vitalData.map((x) => x.toJson())),
        "error": error,
      };
}

class VitalDatum {
  VitalDatum({
    this.vitalId,
    this.vitalName,
    this.units,
  });

  int vitalId;
  String vitalName;
  String units;
  var comments = <String>[];

  factory VitalDatum.fromJson(Map<String, dynamic> json) => VitalDatum(
        vitalId: json["vital_id"],
        vitalName: json["vital_name"],
        units: json["units"],
      );

  Map<String, dynamic> toJson() => {
        "vital_id": vitalId,
        "vital_name": vitalName,
        "units": units,
      };
}

class VitalComment {
  VitalComment({
    this.vitalId,
    this.comment,
  });

  int vitalId;
  String comment;
  var comments = <String>[];

  factory VitalComment.fromJson(Map<String, dynamic> json) => VitalComment(
        vitalId: json["vital_id"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "vital_id": vitalId,
        "comment": comment,
      };
}
