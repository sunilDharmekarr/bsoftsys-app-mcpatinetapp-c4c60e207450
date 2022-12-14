import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/model/BloodGroupModel.dart';
import 'package:mumbaiclinic/model/RelationModel.dart';
import 'package:mumbaiclinic/model/add_family_member_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class UserRepository {
  UserRepository();

  Future<RelationModel> getRelationship() async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}Resource/getRelationship'),
        headers: Utils.getHeaders());
    log(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return relationModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<BloodGroupModel> getBloodGroup() async {
    final response = await http.get(
        Uri.parse('${APIConfig.BASE_URL}Resource/getBloodGroup'),
        headers: Utils.getHeaders());
    log(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return bloodGroupModelFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<FamilyDataResponse> addFamilyMember(Map body) async {
    FamilyDataResponse responseData = FamilyDataResponse();
    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}Patient/addFamilyMember'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201) {
      ResponseModel responseModel = responseModelFromJson(response.body);
      if (responseModel.success == 'true') {
        AddFamilyMemberModel addFamilyMemberModel =
            AddFamilyMemberModel.fromJson(json.decode(response.body));
        responseData.data = addFamilyMemberModel.data;
      } else {
        responseData.error = 'Add failed: ${responseModel.error}';
      }
    } else {
      responseData.error = 'Failed to add user';
    }
    return responseData;
  }

  Future<String> editFamilyMember(Map body) async {
    final response = await http.post(
        Uri.parse('${APIConfig.BASE_URL}Patient/editFamilyMember'),
        body: jsonEncode(body),
        headers: Utils.getHeaders());

    var returnValue = 'Failed to update user details';
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
}
