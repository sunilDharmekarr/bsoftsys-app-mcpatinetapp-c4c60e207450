import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/constant.dart';

class MumbaiClinicNetworkCall {
  ///get request
  static getRequest({
    @required String endPoint,
    @required BuildContext context,
    Map<String, String> body,
    Map<String, String> header = const {
      HttpHeaders.contentTypeHeader: 'application/json'
    },
    Function onSuccess,
    Function onError,
  }) async {
    if (Foundation.kDebugMode) {
      log('endpoint-->$endPoint');
      log('body-->$body');
      log('header-->$header');
    }
    try {
      var response = await http.get(Uri.parse(endPoint), headers: header);

      log('Response code-->${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('success-->${response.body}');
        onSuccess(response.body);
      } else {
        log('error-->${response.body}');
        onError(response.body);
      }
    } catch (error) {
      if (Foundation.kDebugMode) print(error);
      onError(error);
    }
  }

  static getCountryRequest(
      {@required String endPoint,
      @required BuildContext context,
      Map<String, String> body,
      Map<String, String> header = const {
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      Function onSuccess,
      Function onError}) async {
    if (Foundation.kDebugMode) {
      log('endpoint-->$endPoint');
      log('body-->$body');
      log('header-->$header');
    }
    try {
      var response =
          await http.get(Uri.parse(Constant.COUNTRY_BASE_URL + endPoint), headers: header);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('success-->${response.body}');
        onSuccess(response.body);
      } else {
        log('error-->${response.body}');
        onError(response.body);
      }
    } catch (error) {
      if (Foundation.kDebugMode) print(error);
      onError(error);
    }
  }

  static postRequest(
      {@required String endPoint,
      bool encoded = false,
      Map<String, String> body,
      Map<String, String> header,
      dynamic body1,
      Function onSuccess,
      Function onError}) async {
    if (Foundation.kDebugMode) {
      log('endpoint-->$endPoint');
      log('body-->$body');
      log('header-->$header');
    }
    try {
      var response =
          await http.post(Uri.parse(endPoint), headers: header, body: jsonEncode(body==null?body1:body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Loader.hide();
        // print('success-->${response.body}');
        log('success-->${response.body}');
        onSuccess(response.body);
      } else {
        // Loader.hide();
        print('error-->${response.body}');

        onError(response.body);
      }
    } catch (error) {
      //Loader.hide();
      if (Foundation.kDebugMode) print(error);
      onError(error);
    }
  }
}
