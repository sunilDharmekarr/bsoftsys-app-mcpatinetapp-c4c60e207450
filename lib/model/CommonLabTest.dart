// To parse this JSON data, do
//
//     final weightModel = weightModelFromJson(jsonString);

import 'dart:convert';

CommonLabTest commonLabTestModelFromJson(String str) =>
    CommonLabTest.fromJson(json.decode(str));


class CommonLabTest {
  CommonLabTest({
    this.success,
    this.heightData,
    this.error,
    this.groupTest,
  });

  String success;
  List<CommonDatum> heightData=[];
  List<GroupTest> groupTest=[];
  String error;

  factory CommonLabTest.fromJson(Map<String, dynamic> json) => CommonLabTest(
        success: json["success"],
        heightData: List<CommonDatum>.from(
            json["payload"].map((x) => CommonDatum.fromJson(x))),
        error: json["error"],
      );

  factory CommonLabTest.fromGroupJson(Map<String, dynamic> json) => CommonLabTest(
    success: json["success"],
    groupTest: List<GroupTest>.from(
        json["payload"].map((x) => GroupTest.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(heightData.map((x) => x.toJson())),
        "error": error,
      };
}

class CommonDatum {
  CommonDatum({
    this.test,
  });

  dynamic test;

  factory CommonDatum.fromJson(Map<String, dynamic> json) => CommonDatum(
        test: json['test_name'],
      );

  Map<String, dynamic> toJson() => {
        "test_name": test,
      };
}

class GroupTest {
  GroupTest({
    this.id,
    this.test,
  });
  dynamic id;
  dynamic test;

  factory GroupTest.fromJson(Map<String, dynamic> json) => GroupTest(
    id: json.containsKey('ID')?json['ID']:'',
    test:json.containsKey('Name')?json['Name']:json['test_name'],
  );

  Map<String, dynamic> toJson() => {
    "ID":id,
    "Name": test,
  };
}
