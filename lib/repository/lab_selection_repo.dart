import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/MyTestModel.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/repository/download_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class LabSelectionRepo {
  LabSelectionRepo();

  Future<LabsModel> getLabs() async {
    final response = await http.get(Uri.parse(APIConfig.getPathLabs),
        headers: Utils.getHeaders());

    if (kDebugMode) {
      log('EndPoint getLabs --> ${APIConfig.getPathLabs}');
      log('${response.statusCode}');
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return labsModelFromJson(response.body);
    } else {
      throw Utils.error(response);
    }
  }

  Future<List<Payload>> myTestOrders() async {
    final pid = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse("${APIConfig.BASE_URL}LabTest/myTestOrders?patid=$pid"),
        headers: Utils.getHeaders());

    if (kDebugMode) {
      log('EndPoint myTestOrders --> ${APIConfig.BASE_URL}LabTest/myTestOrders?patid=$pid"');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = myTestModelFromJson(response.body);
      return model.payload;
    } else {
      throw Exception('Failed to process request');
    }
  }

  //LabTest/getTestReport?test_order_id=41
  Future<String> getTestReport(String ids) async {
    try {
      final response = await http.get(
          Uri.parse(
              "${APIConfig.BASE_URL}LabTest/getTestReport?test_order_id=$ids"),
          headers: Utils.getHeaders());
      if (kDebugMode) {
        log('EndPoint getTestReport --> ${APIConfig.BASE_URL}LabTest/getTestReport?test_order_id=$ids');
      }
      final downloadRepo = DownloadRepo();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['payload'][0];
        final String url = data['report_path'];
        // await downloadRepo.downloadReport(url);
        return url;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Resource/getInvoice?invoice_number=AVN-362593
  Future<String> getInvoice(String invoice_number) async {
    String url;
    try {
      final response = await http.get(
          Uri.parse(
              "${APIConfig.BASE_URL}Resource/getInvoice?invoice_number=$invoice_number"),
          headers: Utils.getHeaders());

      if (kDebugMode) {
        log('EndPoint getInvoice --> ${APIConfig.BASE_URL}Resource/getInvoice?invoice_number=$invoice_number');
      }

      final downloadRepo = DownloadRepo();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['payload'][0];
        url = data['invoice_path'];
        // await downloadRepo.downloadReport(url);
      }
      return url;
    } catch (e) {
      print(e);
    }
    return url;
  }
}
