import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class ImageUploadRepo {
  Future<String> uploadRegisterProfile(File file, String mobile) async {
    String error = 'Failed to upload image';
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${APIConfig.setPatProfileimageByMobile}'));
      request.headers.addAll(Utils.getHeaders());
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: file.path.split('/').last,
      ));
      request.fields['mobile'] = '$mobile';

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data['payload'];
        } else {
          error = data['error'] ?? error;
        }
      }
    } catch (e) {
      print(e);
    }
    Utils.showToast(message: error, isError: true);
    return null;
  }

  Future<String> setPatProfileImage(File file, String mobile) async {
    String error = 'Failed to upload image';
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${APIConfig.BASE_URL}Patient/setPatProfileimage'));
      request.headers.addAll(Utils.getHeaders());
      request.files.add(await http.MultipartFile.fromPath(
        '',
        file.path,
        filename: file.path.split('/').last,
      ));
      request.fields['mobile'] = '$mobile';

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data['payload'];
        } else {
          error = data['error'] ?? error;
        }
      }
    } catch (e) {
      print(e);
    }
    Utils.showToast(message: error, isError: true);
    return null;
  }

  Future<String> uploadQAImage(
      String file, String apt_id, String question_id, String attType) async {
    String error = 'Failed to upload image';
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('${APIConfig.addAppointmentQuestAnswerAttachment}'));
      request.headers.addAll(Utils.getHeaders());
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file,
        filename: file.split('/').last,
      ));
      request.fields['att_type'] = '$attType';
      request.fields['apt_id'] = '$apt_id';
      request.fields['question_id'] = '$question_id';
      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'true') {
          return data['payload'];
        } else {
          error = data['error'] ?? error;
        }
      }
    } catch (e) {
      print(e);
    }
    Utils.showToast(message: error, isError: true);
    return null;
  }
}
