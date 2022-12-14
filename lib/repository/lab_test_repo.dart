import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/CommonLabTest.dart';
import 'package:mumbaiclinic/model/ConsultFees.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/ParameterDetailModel.dart';
import 'package:mumbaiclinic/model/ServiceModel.dart';
import 'package:mumbaiclinic/model/lab_slot_model.dart';
import 'package:mumbaiclinic/model/profile_details_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class LabTestRepo {
  final AddressService _addressService = AddressService.instance;
  LabTestRepo();

  Future<String> addLabTest(Map body) async {
    var error = 'Failed to add lab test';
    try {
      final response = await http.post(Uri.parse(APIConfig.AddTestOrder),
          headers: Utils.getHeaders(), body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        //print("ANAMOY: RESPONSE: ${response.body}");
        final responseModel = responseModelFromJson(response.body);
        if (responseModel.success == 'true') {
          return null;
        } else {
          error = 'Failed to to add lab test: ${responseModel.error}';
        }
      }
    } catch (e) {
      print('error--> $e');
    }
    return error;
  }

  Future<LabTestResponseModel> addLabTestWithResponse(Map body) async {
    try {
      final response = await http.post(Uri.parse(APIConfig.AddTestOrder),
          headers: Utils.getHeaders(), body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return labTestResponseModelFromJson(response.body);
      }
    } catch (e) {
      print('error--> $e');
    }
    return null;
  }

  Future<LabTestModel> getLabTset(String id) async {
    final response = await http.get(
      Uri.parse('${APIConfig.getLabTest}${id}'),
      headers: Utils.getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return labtestModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<LabSlotModel> getLabSlots() async {
    final response = await http.get(
      Uri.parse('${APIConfig.BASE_URL}/LabTest/getLabSlots'),
      headers: Utils.getHeaders(),
    );

    log(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return labSlotModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<LabTestModel> getProfileTest(String id) async {
    final response = await http.get(
      Uri.parse('${APIConfig.getLabProfile}${id}'),
      headers: Utils.getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      log('deepak-->${response.body}');
      return labtestModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<LabTestModel> getFrequentlyAskedTest(String id) async {
    final response = await http.get(
      Uri.parse('${APIConfig.getFrequentlyAskedTest}${id}'),
      headers: Utils.getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("anamoy: body: ${response.body}");
      return labtestModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<ProfileDetailsModel> getLabProfileDetails(String id) async {
    final response = await http.get(
      Uri.parse('${APIConfig.getLabProfileDetails}${id}'),
      headers: Utils.getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return profileDetailsModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<ServiceModel> getLabServiceFee(String labId) async {
    Position position = _addressService.currentLatLon;
    Map body = {
      "patid": PreferenceManager.getUserId(),
      "lab_id": labId,
      "current_latitude": "${position?.latitude}",
      "current_longitude": "${position?.longitude}"
    };
    final response = await http.post(
      Uri.parse('${APIConfig.getLabServiceFee}'),
      body: jsonEncode(body),
      headers: Utils.getHeaders(),
    );

    if (kDebugMode) {
      log(jsonEncode(body));
      log(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return serviceModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<ConsultFees> getDoctorFees(String docId) async {
    try {
      Map body = {
        "doctor_id": '$docId',
      };
      final response = await http.post(
          Uri.parse('${APIConfig.BASE_URL}Resource/getDoctorfee'),
          body: jsonEncode(body),
          headers: Utils.getHeaders());

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(response.body);
        return consultFeesFromJson(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<ConsultFees> getFastAppointmentDoctorFee(String docId) async {
    try {
      Map body = {
        "doctor_id": '$docId',
      };
      final response = await http.post(
          Uri.parse(
              '${APIConfig.BASE_URL}Resource/getFastAppointmentDoctorFee'),
          body: jsonEncode(body),
          headers: Utils.getHeaders());

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(response.body);
        return consultFeesFromJson(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<CommonLabTest> getCommonLabParameter() async {
    final response = await http.get(
      Uri.parse('${APIConfig.BASE_URL}Resource/getCommonLabParameter'),
      headers: Utils.getHeaders(),
    );
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return commonLabTestModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<ParameterDetailModel> getLabParameterDetails(
      DateTime fromDate, DateTime toDate, String pId, String testName) async {
    try {
      Map body = {
        "from_date": Utils.getYYYYMMDD(fromDate),
        "to_date": Utils.getYYYYMMDD(toDate),
        "patid": int.parse(pId),
        "test_name": testName,
      };

      final response = await http.post(
          Uri.parse('${APIConfig.BASE_URL}Patient/getLabParameterDetails'),
          headers: Utils.getHeaders(),
          body: jsonEncode(body));
      if (kDebugMode) {
        log(response.request.toString());
        log("Request-> $body");
        log(response.body);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return parameterDetailModelFromJson(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<CommonLabTest> getTestGroup() async {
    final response = await http.get(
      Uri.parse('${APIConfig.BASE_URL}Resource/getTestGroup'),
      headers: Utils.getHeaders(),
    );
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommonLabTest.fromGroupJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<CommonLabTest> getTestName(String ids) async {
    final response = await http.get(
      Uri.parse('${APIConfig.BASE_URL}Resource/getTestName?group_id=$ids'),
      headers: Utils.getHeaders(),
    );
    if (kDebugMode) {
      log(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommonLabTest.fromGroupJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<String> uploadLabTestPrescription(String file, String pid) async {
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('${APIConfig.BASE_URL}LabTest/uploadLabTestPrescription'));
      request.headers.addAll(Utils.getHeaders());
      request.files.add(await http.MultipartFile.fromPath(
        '',
        file,
        filename: file.split('/').last,
      ));
      request.fields['patid'] = '$pid';

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  ////Appointment/getConferenceCharge?doctor_id=568

  Future<String> getConferenceCharge(String docId) async {
    try {
      final response = await http.get(
          Uri.parse(
              '${APIConfig.BASE_URL}Appointment/getConferenceCharge?doctor_id=$docId'),
          headers: Utils.getHeaders());
      log(response.body.toString());
      //{"success":"true","payload":[{"conference_charge":100}],"error":""}
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        var charges = data['payload'][0]['conference_charge'] ?? '0';
        return charges.toString();
      } else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
