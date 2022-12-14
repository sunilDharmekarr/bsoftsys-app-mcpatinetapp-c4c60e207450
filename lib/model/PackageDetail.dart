import 'dart:convert';

PackageDetail packageDetailFromJson(String response) =>
    PackageDetail.fromJson(json.decode(response));

class PackageDetail {
  String success;
  List<PackageData> packageData;
  String error;

  PackageDetail({this.success, this.packageData, this.error});

  PackageDetail.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['payload'] != null) {
      packageData = new List<PackageData>();
      json['payload'].forEach((v) {
        packageData.add(new PackageData.fromJson(v));
      });
    }
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.packageData != null) {
      data['payload'] = this.packageData.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    return data;
  }
}

class PackageData {
  int packageId;
  String packageName;
  String packageDetails;
  dynamic amount;
  dynamic discountedAmount;
  String ageDetails;
  String gender;
  String packageTestFile;
  String preparation;

  PackageData(
      {this.packageId,
      this.packageName,
      this.packageDetails,
      this.amount,
      this.discountedAmount,
      this.ageDetails,
      this.gender,
      this.packageTestFile,
      this.preparation});

  PackageData.fromJson(Map<String, dynamic> json) {
    packageId = json['package_id'];
    packageName = json['package_name'];
    packageDetails = json['package_details'];
    amount = json['Amount'];
    discountedAmount = json['discounted_amount'];
    ageDetails = json['age_details'];
    gender = json['gender'];
    packageTestFile = json['package_test_file'];
    preparation = json['preparation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['package_id'] = this.packageId;
    data['package_name'] = this.packageName;
    data['package_details'] = this.packageDetails;
    data['Amount'] = this.amount;
    data['discounted_amount'] = this.discountedAmount;
    data['age_details'] = this.ageDetails;
    data['gender'] = this.gender;
    data['package_test_file'] = this.packageTestFile;
    data['preparation'] = this.preparation;
    return data;
  }
}
