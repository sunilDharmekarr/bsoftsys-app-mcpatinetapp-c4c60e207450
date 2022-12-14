// To parse this JSON data, do
//
//     final profileDetailsModel = profileDetailsModelFromJson(jsonString);

import 'dart:convert';

ProfileDetailsModel profileDetailsModelFromJson(String str) => ProfileDetailsModel.fromJson(json.decode(str));

String profileDetailsModelToJson(ProfileDetailsModel data) => json.encode(data.toJson());

class ProfileDetailsModel {
  ProfileDetailsModel({
    this.success,
    this.profileDetail,
    this.error,
  });

  String success;
  List<ProfileDetail> profileDetail;
  String error;

  factory ProfileDetailsModel.fromJson(Map<String, dynamic> json) => ProfileDetailsModel(
    success: json["success"],
    profileDetail: List<ProfileDetail>.from(json["payload"].map((x) => ProfileDetail.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(profileDetail.map((x) => x.toJson())),
    "error": error,
  };
}

class ProfileDetail {
  ProfileDetail({
    this.profileId,
    this.profileCode,
    this.profileName,
    this.profileDetails,
    this.ageDetails,
    this.collectionMethod,
    this.gender,
    this.preparation,
    this.price,
    this.discountedPrice,
    this.tests,
  });

  int profileId;
  String profileCode;
  String profileName;
  String profileDetails;
  String ageDetails;
  String collectionMethod;
  dynamic gender;
  String preparation;
  dynamic price;
  dynamic discountedPrice;
  List<Test> tests=[];

  factory ProfileDetail.fromJson(Map<String, dynamic> json) => ProfileDetail(
    profileId: json["profile_id"],
    profileCode: json["profile_code"],
    profileName: json["profile_name"],
    profileDetails: json["profile_details"],
    ageDetails: json["age_details"],
    collectionMethod: json["collection_method"],
    gender: json["gender"],
    preparation: json["preparation"],
    price: json["price"],
    discountedPrice: json["discounted_price"],
    tests: List<Test>.from(json["Tests"].map((x) => Test.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "profile_id": profileId,
    "profile_code": profileCode,
    "profile_name": profileName,
    "profile_details": profileDetails,
    "age_details": ageDetails,
    "collection_method": collectionMethod,
    "gender": gender,
    "preparation": preparation,
    "price": price,
    "discounted_price": discountedPrice,
    "Tests": List<dynamic>.from(tests.map((x) => x.toJson())),
  };
}

class Test {
  Test({
    this.testId,
    this.testName,
  });

  int testId;
  String testName;

  factory Test.fromJson(Map<String, dynamic> json) => Test(
    testId: json["test_id"],
    testName: json["test_name"],
  );

  Map<String, dynamic> toJson() => {
    "test_id": testId,
    "test_name": testName,
  };
}
