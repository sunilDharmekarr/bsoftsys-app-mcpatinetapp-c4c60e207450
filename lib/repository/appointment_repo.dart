import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/model/frequently_doctor.dart';
import 'package:mumbaiclinic/model/myappointment_model.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/specialization_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class AppointmentRepository {
  AppointmentRepository();

  Future<SpecializationModel> getSpecialization() async {
    final response = await get(Uri.parse('${APIConfig.getSpecialization}'),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getSpecialization - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201)
      return specializationModelFromJson(response.body);
    else
      return null;
  }

  Future<SpecializationModel> getFastAppointmentSpecialization() async {
    final response = await get(
        Uri.parse(
            '${APIConfig.BASE_URL}Resource/getFastAppointmentSpecialization'),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getFastAppointmentSpecialization - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201)
      return specializationModelFromJson(response.body);
    else
      return null;
  }

  Future<FrequentlyDoctor> getFrequentlyConsultedDoctor() async {
    final response = await post(
        Uri.parse('${APIConfig.GetFrequentlyConsultedDoctor}'),
        body: jsonEncode({'patid': PreferenceManager.getUserId()}),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getFrequentlyConsultedDoctor - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201)
      return FrequentlyDoctor.fromJson(json.decode(response.body));
    else
      return null;
  }

  Future<DocBySpecialization> getFastAppointmentDoctorBySpecialization(
      dynamic ids) async {
    final response = await post(
        Uri.parse(
            '${APIConfig.BASE_URL}Resource/getFastAppointmentDoctorBySpecialization'),
        body: jsonEncode({'specialization_id': ids}),
        headers: Utils.getHeaders());

    /* if (kDebugMode) {
      log("getFastAppointmentDoctorBySpecialization - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201)
      return docBySpecializationFromJson(response.body);
    return null;
  }

  Future<MyappointmentModel> getAppointments() async {
    final pid = PreferenceManager.getUserId();
    final response = await get(Uri.parse('${APIConfig.getAppointment}$pid'),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getAppointments - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201) {
      return myappointmentModelFromJson(response.body);
    } else
      return null;
  }

  Future<dynamic> getPrescriptionByAppointment(dynamic ids) async {
    final response = await get(
        Uri.parse(
            '${APIConfig.BASE_URL}Patient/getPrescriptionByAppointment?appointment_id=$ids'),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getPrescriptionByAppointment - ${response.body}");
    } */

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == 'false') {
        Utils.showToast(message: data['error']);
        return null;
      }
      return data['payload'][0];
    } else
      return null;
  }

  Future<DocBySpecialization> getAppointmentDoctorDetails(dynamic ids) async {
    final response = await get(
        Uri.parse(
            '${APIConfig.BASE_URL}Appointment/getFollowupAptDoctorDetails?appointment_id=$ids'),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("getAppointmentDoctorDetails - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201)
      return DocBySpecialization.fromJson(jsonDecode(response.body));
    else
      return null;
  }

  Future<String> validateAppointmentRequest(Map<String, dynamic> body) async {
    String error = 'Failed to validate appointment';
    try {
      final response = await post(
          Uri.parse(
              '${APIConfig.BASE_URL}Appointment/validateAppointmentRequest'),
          body: jsonEncode(body),
          headers: Utils.getHeaders());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == 'true') {
          error = null;
        } else {
          error = 'Validation failed: ${data['error']}';
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return error;
  }

  Future<AppointmentModel> createFastAppointment(
      Map<String, dynamic> body) async {
    final response = await post(
        Uri.parse('${APIConfig.BASE_URL}Appointment/CreateFastAppointment'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201)
      return appointmentModelFromJson(response.body);
    else
      return null;
  }

  Future<AppointmentModel> requestFastAppointment(
      Map<String, dynamic> body) async {
    final response = await post(
        Uri.parse('${APIConfig.BASE_URL}Appointment/RequestFastAppointment'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201)
      return appointmentModelFromJson(response.body);
    else
      return null;
  }

  Future<AppointmentModel> requestAppointment(Map<String, dynamic> body) async {
    final response = await post(
        Uri.parse('${APIConfig.BASE_URL}Appointment/RequestAppointment'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201)
      return appointmentModelFromJson(response.body);
    else
      return null;
  }

  Future<String> cancelAppointment(Map<String, dynamic> body) async {
    try {
      final response = await post(
          Uri.parse('${APIConfig.BASE_URL}Appointment/cancelAppointment'),
          body: jsonEncode(body),
          headers: Utils.getHeaders());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = responseModelFromJson(response.body);
        if (model.success == 'true') {
          final data =
              jsonDecode(response.body)['payload'][0]['refund_comments'];
          return data;
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<String> rescheduleAppointment(Map<String, dynamic> body) async {
    String error = 'Failed to reschedule appointment';
    final response = await post(
        Uri.parse('${APIConfig.BASE_URL}Appointment/rescheduleAppointment'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());
    /* if (kDebugMode) {
      log("rescheduleAppointment - ${response.body}");
    } */
    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        return null;
      } else {
        error = 'Reschedule failed: ${model.error}';
      }
    }
    return error;
  }
}
