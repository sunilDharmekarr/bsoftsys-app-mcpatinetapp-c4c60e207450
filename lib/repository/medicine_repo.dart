import 'dart:developer';

import 'package:http/http.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/CurrentMedicineModel.dart';
import 'package:mumbaiclinic/model/PrescriptionModel.dart';
import 'package:mumbaiclinic/model/PreviousMedicineModel.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class MedicineRepo {
  MedicineRepo();

  Future<CurrentMedicineModel> getCurrentMedicines() async {
    String pid = PreferenceManager.getUserId();
    final response = await get(
        Uri.parse(
            '${APIConfig.BASE_URL}Patient/getCurrentMedicines?patid=$pid'),
        headers: Utils.getHeaders());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return currentMedicineModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<PreviousMedicineModel> getPreviousMedicines() async {
    String pid = PreferenceManager.getUserId();
    final response = await get(
        Uri.parse(
            '${APIConfig.BASE_URL}Patient/getPreviousMedicines?patid=$pid'),
        headers: Utils.getHeaders());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return previousMedicineModelFromJson(response.body);
    } else {
      return null;
    }
  }

  ///Patient/getPrescription?patid=49231
  Future<PrescriptionModel> getPrescription(String pId) async {
    final response = await get(
        Uri.parse('${APIConfig.BASE_URL}Patient/getPrescription?patid=$pId'),
        headers: Utils.getHeaders());

    log(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return prescriptionModelFromJson(response.body);
    } else
      return null;
  }
}
