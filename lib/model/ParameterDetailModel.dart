// To parse this JSON data, do
//
//     final parameterDetailModel = parameterDetailModelFromJson(jsonString);

import 'dart:convert';

ParameterDetailModel parameterDetailModelFromJson(String str) => ParameterDetailModel.fromJson(json.decode(str));

String parameterDetailModelToJson(ParameterDetailModel data) => json.encode(data.toJson());

class ParameterDetailModel {
    ParameterDetailModel({
        this.success,
        this.parameters,
        this.error,
    });

    String success;
    List<Parameter> parameters;
    String error;

    factory ParameterDetailModel.fromJson(Map<String, dynamic> json) => ParameterDetailModel(
        success: json["success"],
        parameters: List<Parameter>.from(json["payload"].map((x) => Parameter.fromJson(x))),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(parameters.map((x) => x.toJson())),
        "error": error,
    };
}

class Parameter {
    Parameter({
        this.patid,
        this.testDate,
        this.testName,
        this.testValue,
        this.colorCode,
        this.color,
    });

    int patid;
    DateTime testDate;
    String testName;
    String testValue;
    String colorCode;
    String color;

    factory Parameter.fromJson(Map<String, dynamic> json) => Parameter(
        patid: json["patid"],
        testDate: DateTime.parse(json["test_date"]),
        testName: json["test_name"],
        testValue: json["test_value"],
        colorCode: json["color_code"],
        color: json["color"],
    );

    Map<String, dynamic> toJson() => {
        "patid": patid,
        "test_date": testDate.toIso8601String(),
        "test_name": testName,
        "test_value": testValue,
        "color_code": colorCode,
        "color": color,
    };
}
