import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/alert_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class AlertRepo {
  @override
  Future<AlertModel> getAlertData() async {
    final pid = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientAlerts}$pid'),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201)
      return alertModelFromJson(response.body);
    else
      return null;
  }

  Future<bool> readAlert(dynamic alertId) async {
    Map<String, dynamic> body = {'alert_id': alertId};
    final response = await http.post(Uri.parse(APIConfig.readPatientAlert),
        body: json.encode(body), headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201)
      return true;
    else
      return false;
  }

  Future<String> readAllAlerts() async {
    String output = 'Failed to process request';
    Map<String, dynamic> body = {'patid': PreferenceManager.getUserId()};
    final response = await http.post(Uri.parse(APIConfig.readAllPatientAlerts),
        body: jsonEncode(body), headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == 'true') {
        return null;
      } else if (data['error'] != null) {
        output = data['error'];
      }
    }
    return output;
  }
}
