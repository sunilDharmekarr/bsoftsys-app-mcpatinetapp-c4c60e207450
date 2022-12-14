// To parse this JSON data, do
//
//     final labModel = labModelFromJson(jsonString);

import 'dart:convert';

LabTestModel labtestModelFromJson(String str) =>
    LabTestModel.fromJson(json.decode(str));

String labModelToJson(LabTestModel data) => json.encode(data.toJson());

class LabTestModel {
  LabTestModel({
    this.success,
    this.labtest,
    this.error,
  });

  String success;
  List<Labtest> labtest;
  String error;

  factory LabTestModel.fromJson(Map<String, dynamic> json) => LabTestModel(
        success: json["success"],
        labtest:
            List<Labtest>.from(json["payload"].map((x) => Labtest.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(labtest.map((x) => x.toJson())),
        "error": error,
      };
}

class Labtest {
  Labtest({
    this.testId,
    this.testCode,
    this.testName,
    this.testDetails,
    this.ageDetails,
    this.collectionMethod,
    this.gender,
    this.preparation,
    this.price,
    this.discountedPrice,
    this.profileId,
    this.profileCode,
    this.profileName,
  });

  int testId;
  String testCode;
  String testName;
  String testDetails;
  String ageDetails;
  String collectionMethod;
  String gender;
  String preparation;
  dynamic price = 0;
  dynamic discountedPrice = 0;
  int profileId;
  String profileCode;
  String profileName;
  dynamic _packageId;
  dynamic _packageName;

  factory Labtest.fromJson(Map<String, dynamic> json) => Labtest(
        testId: json["test_id"],
        testCode: json["test_code"],
        testName: json["test_name"],
        testDetails: json["test_details"],
        ageDetails: json["age_details"],
        collectionMethod: json["collection_method"],
        gender: json["gender"],
        preparation: json["preparation"],
        price: json["price"],
        discountedPrice: json["discounted_price"] ?? 0,
        profileId: json["profile_id"],
        profileCode: json["profile_code"],
        profileName: json["profile_name"],
      );

  Map<String, dynamic> toJson() => {
        "test_id": testId,
        "test_code": testCode,
        "test_name": testName,
        "test_details": testDetails,
        "age_details": ageDetails,
        "collection_method": collectionMethod,
        "gender": gender,
        "preparation": preparation,
        "price": price,
        "discounted_price": discountedPrice,
        "profile_id": profileId,
        "profile_code": profileCode,
        "profile_name": profileName,
      };

  dynamic get packageName => _packageName;

  set packageName(dynamic value) => _packageName = value;

  dynamic get packageId => _packageId;

  set packageId(dynamic value) => _packageId = value;

  set setPrice(dynamic amount) => price = amount;

  set setDiscount(dynamic amount) => discountedPrice = amount;
}

//Lab test order response
LabTestResponseModel labTestResponseModelFromJson(String str) =>
    LabTestResponseModel.fromJson(json.decode(str));

class LabTestResponseModel {
  LabTestResponseModel({
    this.success,
    this.data,
    this.error,
  });

  String success;
  List<LabtestResponse> data;
  String error;

  factory LabTestResponseModel.fromJson(Map<String, dynamic> json) =>
      LabTestResponseModel(
        success: json["success"],
        data: List<LabtestResponse>.from(
            json["payload"].map((x) => LabtestResponse.fromJson(x))),
        error: json["error"],
      );
}

class LabtestResponse {
  LabtestResponse({
    this.orderId,
    this.invoiceNumber,
    this.paymentReference,
    this.collectionDate,
    this.collectionSlot,
    this.isHomeCollection,
    this.totalAmount,
    this.paidAmount,
  });

  int orderId;
  String invoiceNumber;
  String paymentReference;
  DateTime collectionDate;
  String collectionSlot;
  bool isHomeCollection;
  double totalAmount;
  double paidAmount;

  factory LabtestResponse.fromJson(Map<String, dynamic> json) {
    var amount = 0.0;
    var paidAmount = 0.0;
    amount += json["amount"];
    amount += json["service_amount"];
    amount -= json["discount"];
    paidAmount += json["paid"];

    return LabtestResponse(
      orderId: json["test_order_id"],
      invoiceNumber: json["invoice_number"],
      paymentReference: json["payment_ref"],
      collectionDate: DateTime.parse(json["preffered_collection_date"]),
      collectionSlot: json["collection_slot"],
      isHomeCollection: json["pref_lab_id"] == 0,
      totalAmount: amount,
      paidAmount: paidAmount,
    );
  }
}
