// To parse this JSON data, do
//
//     final relationModel = relationModelFromJson(jsonString);

import 'dart:convert';

RelationModel relationModelFromJson(String str) => RelationModel.fromJson(json.decode(str));

String relationModelToJson(RelationModel data) => json.encode(data.toJson());

class RelationModel {
  RelationModel({
    this.success,
    this.relationData,
    this.error,
  });

  String success;
  List<RelationDatum> relationData=[];
  String error;

  factory RelationModel.fromJson(Map<String, dynamic> json) => RelationModel(
    success: json["success"],
    relationData: List<RelationDatum>.from(json["payload"].map((x) => RelationDatum.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(relationData.map((x) => x.toJson())),
    "error": error,
  };
}

class RelationDatum {
  RelationDatum({
    this.relationId,
    this.relationName,
  });

  int relationId;
  String relationName;

  factory RelationDatum.fromJson(Map<String, dynamic> json) => RelationDatum(
    relationId: json["relation_id"],
    relationName: json["relation_name"],
  );

  Map<String, dynamic> toJson() => {
    "relation_id": relationId,
    "relation_name": relationName,
  };
}
