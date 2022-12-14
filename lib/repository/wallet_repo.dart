import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/key_name.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/transaction_model.dart';
import 'package:mumbaiclinic/model/wallet_model.dart';
import 'package:http/http.dart' as http;
import 'package:mumbaiclinic/utils/utils.dart';

class WalletRepo {
  WalletRepo();

  Future<ResponseModel> addMoneyToWallet(
      String money, String pid, String paymentId) async {
    final token = PreferenceManager.getToken();
    Map<String, String> body = {
      "patid": pid,
      "amount": money,
      "transaction_ref": paymentId,
    };

    final response = await http.post(
      Uri.parse(APIConfig.addMoneyToWallet),
      headers: Utils.getHeaders(token: token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (kDebugMode) {
        log('Params -- $body');
        log('End Point addMoneyToWallet ---> ${APIConfig.addMoneyToWallet}');
        log(response.body);
      }
      return responseModelFromJson(response.body);
    }
    return null;
  }

  Future<Wallet> getWalletBalance({String patientId}) async {
    Map<String, dynamic> body = {
      KeyName.PID: patientId ?? PreferenceManager.getUserId()
    };
    final response = await http.post(
      Uri.parse(APIConfig.checkWalletBalance),
      headers: Utils.getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        log('Params -- $body');
        log('End Point getWalletBalance ---> ${APIConfig.checkWalletBalance}');
        log(response.body);
      }
      return walletFromJson(response.body);
    }
    return null;
  }

  Future<TransactionModel> getTransactionsData() async {
    Map<String, String> body = {
      "patid": PreferenceManager.getUserId(),
      "start_date": null,
      "end_date": null
    };
    final response = await http.post(
      Uri.parse(APIConfig.getTransactionDetails),
      body: jsonEncode(body),
      headers: Utils.getHeaders(),
    );

    if (kDebugMode) {
      log('Params -- $body');
      log('End Point getTransactionsData ---> ${APIConfig.getTransactionDetails}');
      log(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = transactionModelFromJson(response.body);
      if (model.success == 'true') {
        return model;
      } else {
        throw Utils.errorAsString(
            'Failed to load transaction info: ${model.error}');
      }
    } else {
      throw Utils.error(response);
    }
  }
}
