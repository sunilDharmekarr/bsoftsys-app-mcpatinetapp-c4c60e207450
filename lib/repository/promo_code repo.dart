import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class PromoCodeRepo {
  PromoCodeRepo();

  Future<String> validateCoupon(String code, String pid, String amount) async {
    Map<String, String> body = {
      "promocode": code.trim(),
      "patid": pid,
      "test_amount": amount
    };

    final response = await http.post(
      Uri.parse(APIConfig.ValidateCouponCode),
      headers: Utils.getHeaders(),
      body: jsonEncode(body),
    );

    log(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == 'true') {
        return data['payload'][0]['discount'].toString();
      } else {
        Utils.showToast(
            message: 'Failed to validate coupon: ${data['error']}',
            isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to validate coupon', isError: true);
    }
    return "0";
  }
}
