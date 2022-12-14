import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/call_back_model.dart';
import 'package:mumbaiclinic/model/urls_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class CallBackRepo {
  CallBackRepo();

  Future<CallBackModel> getCallBackType() async {
    final response = await http.get(Uri.parse(APIConfig.getCallBackType),
        headers: Utils.getHeaders());

    if (kDebugMode) {
      log(response.body);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return callBackModelFromJson(response.body);
    } else {
      return null;
    }
  }

  /* Future<bool> requestCall(String ids) async {
    Map body = {"patid": PreferenceManager.getUserId(), "callbck_type_id": ids};

    final response = await http.post(Uri.parse(APIConfig.logCallBack),
        headers: Utils.getHeaders(), body: jsonEncode(body));
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } */

  Future<String> logCallbackForPackage(String ids) async {
    Map body = {"patid": PreferenceManager.getUserId(), "package_id": ids};

    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}Package/logCallbackForPackage'),
        headers: Utils.getHeaders(),
        body: jsonEncode(body));
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 'true') {
        return Utils.fixNewLines(data['payload'][0]['msg']);
      } else {
        Utils.showToast(
            message: "Failed to process request: ${data['error']}",
            isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to process request', isError: true);
    }
    return null;
  }

  Future<String> logCallBack(String ids) async {
    Map body = {"patid": PreferenceManager.getUserId(), "callbck_type_id": ids};

    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}Resource/logCallBack'),
        headers: Utils.getHeaders(),
        body: jsonEncode(body));
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 'true') {
        return Utils.fixNewLines(data['payload'][0]['msg']);
      } else {
        Utils.showToast(message: data['error'], isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to process request', isError: true);
    }
    return null;
  }

  Future<bool> getScreenUrls() async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}Resource/getScreenURL'),
        headers: Utils.getHeaders());
    if (kDebugMode) {
      log(response.body);
    }

    if (response.statusCode == 200)
      PreferenceManager.url =
          UrlsModel.fromJson(jsonDecode(response.body)).urls;
    return true;
  }

  Future<String> getRazorPayKey() async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}Resource/getRazorpayKeyID'),
        headers: Utils.getHeaders());
    if (kDebugMode) {
      log("Razor API - ${response.body}");
    }

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["success"] == "true" &&
          data["payload"] != null &&
          data["payload"].length > 0) {
        return data["payload"][0]["razor_pay_key"].toString();
      } else {}
    }
    return null;
  }
}
