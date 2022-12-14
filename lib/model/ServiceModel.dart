import 'dart:convert';

ServiceModel serviceModelFromJson(String json) =>
    ServiceModel.fromJson(jsonDecode(json));

class ServiceModel {
  String success;
  List<ServiceData> serviceData = [];
  String error;

  ServiceModel({this.success, this.serviceData, this.error});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['payload'] != null) {
      serviceData = new List<ServiceData>();
      json['payload'].forEach((v) {
        serviceData.add(new ServiceData.fromJson(v));
      });
    }
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.serviceData != null) {
      data['payload'] = this.serviceData.map((v) => v.toJson()).toList();
    }
    data['error'] = this.error;
    return data;
  }
}

class ServiceData {
  dynamic serviceAmount;

  ServiceData({this.serviceAmount});

  ServiceData.fromJson(Map<String, dynamic> json) {
    serviceAmount = json['service_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_amount'] = this.serviceAmount;
    return data;
  }
}
