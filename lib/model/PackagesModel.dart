import 'dart:convert';

PackagesModel packagesModelFromJson(String data)=>PackagesModel.fromJson(jsonDecode(data));

class PackagesModel {
  String success;
  List<PackageData> packageData=[];
  String error;

  PackagesModel({this.success, this.packageData, this.error});

  PackagesModel.fromJson(Map<String, dynamic> json) {
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
  dynamic amount;
  dynamic discountedAmount;
  String packageImageFile;

  PackageData(
      {this.packageId,
        this.packageName,
        this.amount,
        this.discountedAmount,
        this.packageImageFile});

  PackageData.fromJson(Map<String, dynamic> json) {
    packageId = json['package_id'];
    packageName = json['package_name'];
    amount = json['Amount'];
    discountedAmount = json['discounted_amount'];
    packageImageFile = json['package_image_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['package_id'] = this.packageId;
    data['package_name'] = this.packageName;
    data['Amount'] = this.amount;
    data['discounted_amount'] = this.discountedAmount;
    data['package_image_file'] = this.packageImageFile;
    return data;
  }
}
