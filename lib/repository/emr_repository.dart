import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/LatestReportModel.dart';
import 'package:mumbaiclinic/model/ReportTypeModel.dart';
import 'package:mumbaiclinic/model/url_to_share_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class EMRRepository {
  EMRRepository();

  Future<ReportTypeModel> getEMRReportType() async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}EMR/getEMRReportType'),
        headers: Utils.getHeaders());

    if (kDebugMode) {
      log('End Point getEMRReportType --> ${APIConfig.BASE_URL}EMR/getEMRReportType');
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return reportTypeModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<LatestReportModel> getLatestEMRReport(String pid) async {
    Map body = {"patid": pid};

    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}EMR/getLatestEMRReport'),
        headers: Utils.getHeaders(),
        body: jsonEncode(body));

    if (kDebugMode) {
      log('End Point getLatestEMRReport --> ${APIConfig.BASE_URL}EMR/getLatestEMRReport');
      log(response.body);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = latestReportModelFromJson(response.body);
      if (model.success == 'true') {
        return model;
      } else {
        throw Utils.errorAsString(
            'Failed to load latest report: ${model.error}');
      }
    } else {
      throw Utils.error(response);
    }
  }

  Future<LatestReportModel> getPreviousEMRReport(
      String pid, String type) async {
    Map body = {"patid": pid, "reporttype_id": type};

    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}EMR/getPreviousEMRReport'),
        headers: Utils.getHeaders(),
        body: jsonEncode(body));

    if (kDebugMode) {
      log('End Point getPreviousEMRReport --> ${APIConfig.BASE_URL}EMR/getPreviousEMRReport');
      log(response.body);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = latestReportModelFromJson(response.body);
      if (model.success == 'true') {
        return model;
      } else {
        throw Utils.errorAsString(
            'Failed to load previous report: ${model.error}');
      }
    } else {
      throw Utils.error(response);
    }
  }

  Future<String> uploadEMRReport(String file, String reportTypeId,
      String reportType, String comment, String date) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${APIConfig.BASE_URL}EMR/UploadEMRReport'));
      request.headers.addAll(Utils.getHeaders());
      request.files.add(await http.MultipartFile.fromPath(
        '',
        file,
        filename: file.split('/').last,
      ));
      request.fields['patid'] = '${PreferenceManager.getUserId()}';
      request.fields['reporttype_id'] = '$reportTypeId';
      request.fields['reporttype'] = '$reportType';
      request.fields['report_date'] = '$date';
      request.fields['report_description'] = '$comment';

      http.Response response =
          await http.Response.fromStream(await request.send());
      return response.body;
    } catch (e) {
      print(e);
      return null;
    }
  }

  ///It will convert url to sharable url
  Future<UrlToShare> getFileURLToShare(String url) async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}Resource/getFileURLtoShare?URL=$url'),
        headers: Utils.getHeaders());

    if (kDebugMode) {
      log('End Point getFileURLToShare --> ${APIConfig.BASE_URL}Resource/getFileURLtoShare?URL=$url');
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (kDebugMode) {
        urlToShareFromJson(response.body);
      }

      return urlToShareFromJson(response.body);
    } else {
      log('NULL Responce');
      return null;
    }
  }
}
