// To parse this JSON data, do
//
//     final myTestModel = myTestModelFromJson(jsonString);

import 'dart:convert';

MyTestModel myTestModelFromJson(String str) => MyTestModel.fromJson(json.decode(str));

String myTestModelToJson(MyTestModel data) => json.encode(data.toJson());

class MyTestModel {
  MyTestModel({
    this.success,
    this.payload,
    this.error,
  });

  String success;
  List<Payload> payload=[];
  String error;

  factory MyTestModel.fromJson(Map<String, dynamic> json) => MyTestModel(
    success: json["success"],
    payload: List<Payload>.from(json["payload"].map((x) => Payload.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(payload.map((x) => x.toJson())),
    "error": error,
  };
}

class Payload {
  Payload({
    this.testOrderId,
    this.date,
    this.amountPaid,
    this.invoiceNumber,
    this.tests,
  });

  dynamic testOrderId;
  DateTime date;
  dynamic amountPaid;
  String invoiceNumber;
  List<Test> tests=[];

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
    testOrderId: json["test_order_id"],
    date: DateTime.parse(json["date"]),
    amountPaid: json["amount_paid"],
    invoiceNumber: json["invoice_number"],
    tests: List<Test>.from(json["Tests"].map((x) => Test.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "test_order_id": testOrderId,
    "date": date.toIso8601String(),
    "amount_paid": amountPaid,
    "invoice_number": invoiceNumber,
    "Tests": List<dynamic>.from(tests.map((x) => x.toJson())),
  };
}

class Test {
  Test({
    this.testOrderId,
    this.testId,
    this.testName,
    this.status,
  });

  dynamic testOrderId;
  dynamic testId;
  String testName;
  String status;

  factory Test.fromJson(Map<String, dynamic> json) => Test(
    testOrderId: json["test_order_id"],
    testId: json["test_id"],
    testName: json["test_name"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "test_order_id": testOrderId,
    "test_id": testId,
    "test_name": testName,
    "status": status,
  };
}
