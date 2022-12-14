// To parse this JSON data, do
//
//     final weightModel = weightModelFromJson(jsonString);

import 'dart:convert';

WeightModel weightModelFromJson(String str) =>
    WeightModel.fromJson(json.decode(str));

String weightModelToJson(WeightModel data) => json.encode(data.toJson());

class WeightModel {
  WeightModel({
    this.success,
    this.weightData,
    this.error,
  });

  String success;
  List<WeightDatum> weightData;
  String error;

  factory WeightModel.fromJson(Map<String, dynamic> json) => WeightModel(
        success: json["success"],
        weightData: List<WeightDatum>.from(
            json["payload"].map((x) => WeightDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(weightData.map((x) => x.toJson())),
        "error": error,
      };
}

class WeightDatum {
  WeightDatum({
    this.id,
    this.patid,
    this.date,
    this.weight,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic weight;
  String comment;

  factory WeightDatum.fromJson(Map<String, dynamic> json) {
    return WeightDatum(
      id: (json["id"] as double).round(),
      patid: json["patid"],
      date: DateTime.parse(json["Date"]),
      weight: json["weight"].toDouble(),
      comment: json.containsKey('comments')
          ? (json['comments'] as String).trim()
          : '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "patid": patid,
        "Date": date.toIso8601String(),
        "weight": weight,
        "comments": comment,
      };
}
