import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/BPModel.dart';
import 'package:mumbaiclinic/model/HeightModel.dart';
import 'package:mumbaiclinic/model/MyHealthModel.dart';
import 'package:mumbaiclinic/model/PulseModel.dart';
import 'package:mumbaiclinic/model/Spo2Model.dart';
import 'package:mumbaiclinic/model/TempModel.dart';
import 'package:mumbaiclinic/model/VitalIdModel.dart';
import 'package:mumbaiclinic/model/VitalModel.dart';
import 'package:mumbaiclinic/model/WeightModel.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class PatientRepo {
  Future<WeightModel> getPatientWeightHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientWeightHistory}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return weightModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<HeightModel> getPatientHeightHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientHeightHistory}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return heightModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<HeightModel> getPatientBMIHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientBMIHistory}$pId'),
        headers: Utils.getHeaders());
    if (response.statusCode == 201 || response.statusCode == 200)
      return heightModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<TempModel> getPatientTempHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientTempHistory}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return tempModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<PulseModel> getPatientPulseHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientPulseHistory}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return pulseModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<BpModel> getPatientBPHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientBPHistory}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return bpModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<Spo2Model> getPatientSpo2History() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientSpo2History}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return spo2ModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<Spo2Model> getPatientSugarHistory() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientSugarHistory}$pId'),
        headers: Utils.getHeaders());
    if (response.statusCode == 201 || response.statusCode == 200)
      return spo2ModelFromJson(response.body);
    else
      throw Exception('Failed to process request');
  }

  Future<VitalModel> getPatientLastVitals() async {
    final pId = PreferenceManager.getUserId();
    final response = await http.get(
        Uri.parse('${APIConfig.getPatientLastVitals}$pId'),
        headers: Utils.getHeaders());

    if (response.statusCode == 201 || response.statusCode == 200)
      return vitalModelFromJson(response.body);
    else
      return null;
  }

  Future<VitalIdModel> getVitals() async {
    final commentsResponse = await http.get(
        Uri.parse('${APIConfig.getVitalComments}0'),
        headers: Utils.getHeaders());
    if (commentsResponse.statusCode == 201 ||
        commentsResponse.statusCode == 200) {
      final response = await http.get(
          Uri.parse('${APIConfig.BASE_URL}Resource/getVitals'),
          headers: Utils.getHeaders());
      if (response.statusCode == 201 || response.statusCode == 200)
        return vitalIdModelFromJson(response.body, commentsResponse.body);
    }

    return null;
  }

  String validateVitalValue(String vitalType, String value) {
    if (vitalType.toLowerCase() == "weight".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 5 || intValue > 200) {
          return "Weight must be between 5 and 200 kg";
        }
      } on Exception catch (_) {
        return "Failed to parse weight value";
      }
    } else if (vitalType.toLowerCase() == "height".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 10 || intValue > 250) {
          return "Height must be between 10 and 250 cm";
        }
      } on Exception catch (_) {
        return "Failed to parse height value";
      }
    } else if (vitalType.toLowerCase() == "temperature".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 90 || intValue > 110) {
          return "Temperature must be between 90 and 110 Fahrenheit";
        }
      } on Exception catch (_) {
        return "Failed to parse temperature value";
      }
    } else if (vitalType.toLowerCase() == "pulse".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 50 || intValue > 120) {
          return "Pulse must be between 50 and 120 bpm";
        }
      } on Exception catch (_) {
        return "Failed to parse pulse value";
      }
    } else if (vitalType.toLowerCase() == "Blood Pressure".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 40 || intValue > 200) {
          return "Blood pressure must be between 40 and 200 mmHg";
        }
      } on Exception catch (_) {
        return "Failed to parse blood pressure value";
      }
    } else if (vitalType.toLowerCase() == "SPO2".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 50 || intValue > 100) {
          return "SPO2 must be between 50 and 100 %";
        }
      } on Exception catch (_) {
        return "Failed to parse SPO2 value";
      }
    } else if (vitalType.toLowerCase() == "Blood Sugar".toLowerCase()) {
      try {
        var intValue = double.parse(value);
        if (intValue < 50 || intValue > 200) {
          return "Blood sugar must be between 50 and 200 mg/dL";
        }
      } on Exception catch (_) {
        return "Failed to parse blood sugar value";
      }
    }
    return null;
  }

  Future<String> addVitals(int vId, String comment, String value,
      [String bp1, String bp2]) async {
    Map body = {
      "patid": PreferenceManager.getUserId(),
      "date": "${Utils.getServerDate()}",
      "vital_id": vId.toString(),
      "vital_value": value == null
          ? ""
          : value, //if vital_id <>5  value should be there  , refer resource/getVitals for vital ID
      "BP1": bp1 == null ? "" : bp1, //if vital_id =5 then value should be there
      "BP2": bp2 == null ? "" : bp2, //if vital_id =5 then value should be there
      "comments": comment != null && comment.length > 0 ? comment : " ",
    };

    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}Patient/AddVitals'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    var error = 'Failed to add vitals data';
    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        return null;
      } else {
        error = 'Add failed: ${model.error}';
      }
    }
    return error;
  }

  Future<String> editVitalValue(
      int id, int vitalId, DateTime date, String comment, String value,
      [String bp1, String bp2]) async {
    Map body = {
      "id": id.toString(),
      "patid": PreferenceManager.getUserId(),
      "date": "${Utils.getServerDate(dateTime: date)}",
      "vital_id": vitalId.toString(),
      "vital_value": value == null
          ? ""
          : value, //if vital_id <>5  value should be there  , refer resource/getVitals for vital ID
      "BP1": bp1 == null ? "" : bp1, //if vital_id =5 then value should be there
      "BP2": bp2 == null ? "" : bp2, //if vital_id =5 then value should be there
      "comments": comment != null && comment.length > 0 ? comment : " ",
    };

    final response = await http.post(Uri.parse(APIConfig.editPatientVital),
        body: jsonEncode(body), headers: Utils.getHeaders());

    var error = 'Failed to edit vitals data';
    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        return null;
      } else {
        error = 'Edit failed: ${model.error}';
      }
    }
    return error;
  }

  Future<String> deleteVitalValue(int id) async {
    Map body = {
      "id": id.toString(),
      "patid": PreferenceManager.getUserId(),
    };

    final response = await http.post(Uri.parse(APIConfig.deletePatientVital),
        body: jsonEncode(body), headers: Utils.getHeaders());

    var error = 'Failed to delete vitals entry';
    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        return null;
      } else {
        error = 'Delete failed: ${model.error}';
      }
    }
    return error;
  }

  Future<MyHealthModel> getHealthManagerDetails(String pid) async {
    final response = await http.get(
        Uri.parse('${APIConfig.getHealthManagerDetails}$pid'),
        headers: Utils.getHeaders());

    /* if (kDebugMode) {
      log(response.body);
    } */

    if (response.statusCode == 200 || response.statusCode == 201) {
      return myHealthModelFromJson(response.body);
    } else {
      throw Exception("Failed to process request");
    }
  }

  Future<AddressTypeModel> getAddressTypes() async {
    final response = await http.get(Uri.parse(APIConfig.getAddressTypes),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return addressTypeModelFromJson(response.body);
    } else {
      throw Exception("Failed to process request");
    }
  }

  Future<AddressModel> getAddresses({String patientId}) async {
    //final pid = 49231;
    final pid = patientId ?? PreferenceManager.getUserId();
    final response = await http.get(Uri.parse('${APIConfig.getAddresses}$pid'),
        headers: Utils.getHeaders());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return addressModelFromJson(response.body);
    } else {
      throw Exception("Failed to process request");
    }
  }

  Future<String> deleteAddress(int id) async {
    Map body = {
      "address_id": id.toString(),
      "patid": PreferenceManager.getUserId(),
    };

    final response = await http.post(Uri.parse(APIConfig.deleteAddress),
        body: jsonEncode(body), headers: Utils.getHeaders());
    var returnValue = 'Failed to delete address';
    if (response.statusCode == 201 || response.statusCode == 200) {
      ResponseModel model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        returnValue = null;
      } else {
        returnValue = 'Delete failed: ${model.error}';
      }
    }

    return returnValue;
  }

  Future<String> editAddAddress(AddressDatum address) async {
    Map body = {
      "address_id": address.id,
      "patid": address.patient,
      "address_type_id": address.typeId,
      "address_1": address.address1,
      "area": address.address2,
      "city": address.city,
      "State": address.state,
      "pincode": address.pinCode,
      "Landmark": address.landmark,
    };

    final response = await http.post(Uri.parse(APIConfig.addEditAddress),
        body: jsonEncode(body), headers: Utils.getHeaders());
    var returnValue = 'Failed to update address';
    if (response.statusCode == 201 || response.statusCode == 200) {
      ResponseModel model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        returnValue = null;
      } else {
        returnValue = 'Update failed: ${model.error}';
      }
    }

    return returnValue;
  }

  Future<String> editPatientDetails(Datum data) async {
    Map body = {
      "patid": data.patid,
      "first_name": data.firstName,
      "middle_name": data.middleName,
      "last_name": data.lastName,
      "mobile": data.mobile,
      "email": data.email,
      "gender": data.sex,
      "dob": data.dob,
      "emergency_contact": data.emergencyContact,
      "address1": data.address1,
      "address2": data.address2,
      "city": data.city,
      "state": data.state,
      "country": data.country,
      "pincode": data.pincode,
      "bg_id": data.bgId,
      "profile_pic": data.profile_pic,
    };
    final response = await http.post(Uri.parse(APIConfig.editPatientDetails),
        body: jsonEncode(body), headers: Utils.getHeaders());
    var returnValue = 'Failed to update user details';
    if (response.statusCode == 201 || response.statusCode == 200) {
      ResponseModel model = responseModelFromJson(response.body);
      if (model.success == 'true') {
        RegisterModel model =
            RegisterModel.fromJson(json.decode(response.body));
        if (model.data.length > 0) {
          var modelData = model.data[0];
          var dbMap = {
            AppDatabase.address1: modelData.address1,
            AppDatabase.address2: modelData.address2,
            AppDatabase.city: modelData.city,
            AppDatabase.state: modelData.state,
            AppDatabase.country: modelData.country,
            AppDatabase.pincode: modelData.pincode,
          };
          AppDatabase.db.updateUser("${data.patid}", dbMap);
        }

        returnValue = null;
      } else {
        returnValue = 'Edit failed: ${model.error}';
      }
    }

    return returnValue;
  }
}
