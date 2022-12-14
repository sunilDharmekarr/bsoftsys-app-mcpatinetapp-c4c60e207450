import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayUtil {
  static RazorPayUtil _instance = RazorPayUtil.internal();
  static String key = "rzp_live_f9pnTmpx22fUUs"; //active
  //static String key = "rzp_test_sOdMqCZYqVGA8E";
  // "rzp_live_f9pnTmpx22fUUs";
  // "rzp_test_sOdMqCZYqVGA8E";
  RazorPayUtil factory() {
    return _instance;
  }

  RazorPayUtil.internal();

  Razorpay _razorPay;
  Function(String transactionId) onSuccess;
  Function(String) onFailure;

  static RazorPayUtil get() {
    return _instance;
  }

  init() {
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  open(double amount, String name, String desc, Function(String) success,
      Function(String) failure) {
    this.onSuccess = success;
    this.onFailure = failure;
    _razorPay.open(_getOptions(amount, name, desc));
  }

  dynamic _getOptions(double amount, String name, String desc) {
//    kDebugMode ? 'rzp_test_bxHTff2ATMg1Zc' : 'rzp_live_hTCoRgT8zsNsjP',

    var options = {
      // 'key': 'rzp_live_f9pnTmpx22fUUs', //Production key
      // 'key': 'rzp_test_sOdMqCZYqVGA8E',//Development key
      'key': PreferenceManager.getRazorPayKey(), //Dynamic key from api
      'amount': (amount * 100).round(),
      'name': name,
      'description': desc,
      'prefill': {
        'contact': PreferenceManager.getMobile(),
        'email': PreferenceManager.getEmail() ?? ''
      }
    };

    if (kDebugMode) {
      log("Razor pay called --- $options");
    }
    return options;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    onFailure?.call(response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    onFailure?.call("Error processing payment");
  }

  clear() {
    _razorPay.clear();
  }

  removeListener() {
    onSuccess = null;
    onFailure = null;
  }
}
