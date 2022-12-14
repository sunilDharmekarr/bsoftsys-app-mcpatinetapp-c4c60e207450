import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/model/PackageDetail.dart' as details;
import 'package:mumbaiclinic/model/PackageResponse.dart';
import 'package:mumbaiclinic/model/PackagesModel.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class PackageRepository {
  PackageRepository();

  Future<PackagesModel> getPackages() async {
    final data = await http.get(Uri.parse(APIConfig.getPackages),
        headers: Utils.getHeaders());
    if (kDebugMode) {
      log(data.body);
    }

    if (data.statusCode == 200 || data.statusCode == 201) {
      return packagesModelFromJson(data.body);
    } else {
      return null;
    }
  }

  Future<details.PackageData> getPackaeDetail(String id) async {
    final data = await http.get(Uri.parse('${APIConfig.getPackageDetails}$id'),
        headers: Utils.getHeaders());
    if (kDebugMode) {
      log(data.body);
    }

    if (data.statusCode == 201 || data.statusCode == 200) {
      final model = details.packageDetailFromJson(data.body);
      if (model.packageData.length > 0)
        return model.packageData[0];
      else
        throw Exception('No Data');
    } else {
      throw Exception('Failed to process request');
    }
  }

  Future<PackageResponse> orderPackage(Map body) async {
    final data = await http.post(
      Uri.parse('${APIConfig.BASE_URL}Package/orderPackage'),
      body: jsonEncode(body),
      headers: Utils.getHeaders(),
    );
    if (kDebugMode) {
      log(data.body);
    }

    if (data.statusCode == 201 || data.statusCode == 200) {
      final json = jsonDecode(data.body);
      if (json['success'] == 'true') {
        final response = json['payload'][0];
        return PackageResponse.fromJson(response);
      }
    }
    return null;
  }
}
