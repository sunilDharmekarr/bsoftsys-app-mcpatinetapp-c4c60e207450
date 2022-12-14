import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:http/http.dart' as http;

class OrderTestRepo {
  OrderTestRepo();

  Future<String> getFrequentlyOrderedTest() async {
    final token =  PreferenceManager.getToken();
    final response = await http.get(Uri.parse(APIConfig.getPathLabs),
        headers: Utils.getHeaders(token: token));

    if (kDebugMode) {
      log('${response.statusCode}');
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return '';
    } else {
      throw Utils.error(response);
    }
  }


  Future<void> getOrderTest() async {
    final token =  PreferenceManager.getToken();
    final response = await http.get(Uri.parse(APIConfig.getPathLabs),
        headers: Utils.getHeaders(token: token));

    if (kDebugMode) {
      log('${response.statusCode}');
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Utils.error(response);
    }
  }
}
