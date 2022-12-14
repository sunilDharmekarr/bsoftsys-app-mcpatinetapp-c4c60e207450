import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/app_icons.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/model/create_appointment.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/wallet_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/repository/promo_code%20repo.dart';
import 'package:mumbaiclinic/repository/wallet_repo.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/screen/payment/payment_result_screen.dart';
import 'package:mumbaiclinic/screen/symptom/symptom_screen.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/skip_chat_sheet.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

//The variable isAlreadyBooked is used to identify if the appointment is already booked, but payment is not yet done.
//This scenario arise in case of Request Appointment.
class MakePaymentScreen extends StatefulWidget {
  final CreateAppointment model;
  final Doctor doctor;
  final bool follow;
  final bool isFast;
  final bool isAlreadyBooked;
  final String appointmentId;

  MakePaymentScreen(this.model, this.doctor,
      {this.follow = false,
      this.isFast = false,
      this.isAlreadyBooked = false,
      this.appointmentId});

  @override
  _MakePaymentScreenState createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final promoRepo = PromoCodeRepo();
  final labTestRepo = LabTestRepo();
  final _applyController = TextEditingController();
  String finalAmount = '';
  String totalAmt = '';
  String discount = '0';
  String username = '';
  String contact = '';
  String email = '';
  bool visible = false;
  bool wallet = false;
  bool conference = false;
  String walletBalance = '0';
  String charges = '0';
  String paymentId = '0';
  var options = null;

  @override
  void initState() {
    super.initState();
    _getFinalAmount();
    print(widget.model.toJson());
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dynamic _getFinalAmount() {
    double orgAmt = double.parse(widget.model.amount);
    double chargeAmt = double.parse(charges);
    double disAmt = double.parse(discount);
    double totalAmount = orgAmt + (conference ? chargeAmt : 0);
    double amtAfterDiscount = totalAmount - disAmt;
    if (amtAfterDiscount == amtAfterDiscount.toInt()) {
      finalAmount = amtAfterDiscount.toStringAsFixed(0);
    } else {
      finalAmount = amtAfterDiscount.toStringAsFixed(2);
    }
    if (totalAmount == totalAmount.toInt()) {
      totalAmt = totalAmount.toStringAsFixed(0);
    } else {
      totalAmt = totalAmount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Constant.MAKE_PAYMENT,
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.model.appointmentType == '1')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: ColorTheme.lightGreenOpacity,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: conference,
                              activeColor: ColorTheme.lightGreen,
                              onChanged: (value) {
                                setState(() {
                                  conference = value;
                                  _getFinalAmount();
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextView(
                              text: 'My family members will accompany me.',
                              style: AppTextTheme.textTheme14Bold,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      AppText.getLightText(
                          '(Other members can join using conference link)',
                          12,
                          ColorTheme.buttonColor),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Container(
                            child: AppText.getBoldText(
                                'Conference charges', 16, ColorTheme.darkGreen),
                          ),
                          Expanded(child: Container()),
                          Container(
                            child: AppText.getBoldText(
                                'Rs.$charges', 16, ColorTheme.darkGreen),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: ColorTheme.lightGreenOpacity,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextView(
                        text: 'Total Amount',
                        style: AppTextTheme.textTheme14Bold,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: TextView(
                        text: 'Rs.${widget.model.amount}',
                        style: AppTextTheme.textTheme14Bold,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: ColorTheme.lightGreen.withOpacity(0.8),
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <Widget>[
                            const SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              AppAssets.apply_coupon,
                              width: 20,
                              height: 20,
                              fit: BoxFit.fill,
                              color: ColorTheme.lightGreen.withOpacity(0.8),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _applyController,
                                autofocus: false,
                                onSubmitted: (val) {
                                  FocusScope.of(context).unfocus();
                                },
                                maxLines: 1,
                                maxLength: 40,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                style: AppTextTheme.textTheme12Bold,
                                onChanged: (val) {},
                                decoration: InputDecoration(
                                  hintText: 'Enter coupon code',
                                  hintStyle: AppTextTheme.textTheme12Light,
                                  border: InputBorder.none,
                                  counterText: '',
                                  counter: null,
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: ColorTheme.buttonColor,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (_applyController.text.trim().isNotEmpty) {
                                    _ValidateCouponCode();
                                  } else {
                                    Utils.showToast(
                                        message: 'Enter coupon code',
                                        isError: true);
                                  }
                                },
                                child: Center(
                                  child: TextView(
                                    text: 'Apply',
                                    color: ColorTheme.white,
                                    style: AppTextTheme.textTheme12Bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      color: Colors.transparent,
                      child: Center(
                        child: visible
                            ? TextView(
                                text: 'Rs.$discount',
                                color: ColorTheme.darkGreen,
                                textAlign: TextAlign.left,
                                style: AppTextTheme.textTheme14Bold,
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: ColorTheme.lightGreenOpacity,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextView(
                        text: 'Payable Amount',
                        style: AppTextTheme.textTheme14Bold,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: TextView(
                        text: 'Rs.$finalAmount',
                        style: AppTextTheme.textTheme14Bold,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.my_wallet,
                          size: 24,
                          color: ColorTheme.lightGreen,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextView(
                            text: 'Rs.$walletBalance Balance in wallet',
                            style: AppTextTheme.textTheme14Bold,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: wallet,
                            activeColor: ColorTheme.lightGreen,
                            onChanged: (value) {
                              setState(() {
                                wallet = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: TextView(
                        text: 'Pay from wallet',
                        style: AppTextTheme.textTheme14Light,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () async {
                  //This if function is used to check if the appointment is not a type of Request Appointment.
                  //If it is not a request appointment then we verify the appointment and then procced with payment.
                  if (!widget.isAlreadyBooked) {
                    final result = await validateApt();
                    if (result) {
                      if (!wallet) {
                        _createPayment();
                      } else {
                        if (double.parse(walletBalance ?? '0.0') <
                            double.parse(finalAmount ?? '0.0')) {
                          Utils.showSingleButtonAlertDialog(
                              context: context,
                              message: 'You have not enough balance.');
                        } else {
                          if (widget.isFast)
                            _createFastAppointment();
                          else
                            _createAppointment();
                        }
                      }
                    }
                  }
                  //If it is a Request Appointment, hence the appointment is already booked.
                  //So we proceed directly with payment without checking appointment details.
                  else {
                    if (!wallet) {
                      _createPayment();
                    } else {
                      if (double.parse(walletBalance ?? '0.0') <
                          double.parse(finalAmount ?? '0.0')) {
                        Utils.showSingleButtonAlertDialog(
                            context: context,
                            message: 'You have not enough balance.');
                      } else {
                        updateAppointmentPendingPayment();
                      }
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColorTheme.buttonColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: Utils.getShadow(shadow: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: TextView(
                        text: 'Pay $finalAmount',
                        color: Colors.white,
                        style: AppTextTheme.textTheme14Bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> validateApt() async {
    Loader.showProgress();
    Map<String, dynamic> body = {
      "patid": widget.model.patid,
      "doc_id": widget.doctor.doctorId,
      "appointment_date": widget.model.appointmentDate,
      "appointment_type": widget.model.appointmentType,
    };
    final validationError =
        await appointmentRepository.validateAppointmentRequest(body);
    Loader.hide();

    if (validationError != null) {
      Utils.showSingleButtonAlertDialog(
          context: context, message: validationError);
      return false;
    }
    return true;
  }

  void _createPayment() async {
    double pay = double.parse(finalAmount);

    if (pay > 0) {
      RazorPayUtil.get().open(
        pay,
        "Mumbai-Clinic",
        "Appointment Payment",
        (value) async {
          paymentId = value;

          if (!widget.isAlreadyBooked) {
            final result =
                await Navigator.of(context).push<bool>(CupertinoPageRoute(
                    builder: (_) => PaymentResultScreen(
                          success: true,
                          needToPop: true,
                        )));
            if (result) {
              if (widget.isFast)
                _createFastAppointment();
              else
                _createAppointment();
            }
          } else {
            final result =
                await Navigator.of(context).push<bool>(CupertinoPageRoute(
                    builder: (_) => PaymentResultScreen(
                          success: true,
                          needToPop: true,
                        )));
            if (result) {
              updateAppointmentPendingPayment();
            }
          }
        },
        (value) {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (_) => PaymentResultScreen(
                    success: false,
                  )));
        },
      );
    } else {
      paymentId = "";
      if (!widget.isAlreadyBooked) {
        if (widget.isFast)
          _createFastAppointment();
        else
          _createAppointment();
      } else {
        updateAppointmentPendingPayment();
      }
    }
  }

  void loadData() async {
    final pid = PreferenceManager.getUserId();
    final Datum usermodel = await AppDatabase.db.getUser(pid);

    email = usermodel.email;
    contact = usermodel.mobile;

    _checkWalletBalance();
  }

  _ValidateCouponCode() async {
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    final data = await promoRepo.validateCoupon(
        _applyController.text.trim(), widget.model.patid, totalAmt);
    visible = true;
    discount = data.toString();
    _getFinalAmount();
    // EasyLoading.dismiss();
    Loader.hide();
    setState(() {});
  }

  final walletRepo = WalletRepo();

  _checkWalletBalance() async {
    Loader.showProgress();
    final wal = await walletRepo.getWalletBalance();
    final charges = await labTestRepo
        .getConferenceCharge(widget.doctor.doctorId.toString());
    Loader.hide();

    if (charges != null) {
      this.charges = '$charges';
    }

    if (wal != null && wal.success == 'true') {
      WalletBalance balance = wal.walletBalance[0];
      if (balance.walletBalance != null) {
        walletBalance = balance.walletBalance.toString() ?? '0';
      } else {
        walletBalance = '0';
      }

      setState(() {});
    } else {
      Utils.showToast(message: 'Failed to load balance');
    }
  }

  final appointmentRepository = AppointmentRepository();

  _createAppointment() async {
    Loader.showProgress();

    Map<String, String> body = {
      "patid": widget.model.patid,
      "doc_id": widget.model.docId,
      "slot_id": widget.model.slotId.toString(),
      "is_wallet_payment": wallet ? '1' : '0',
      "appointment_date": widget.model.appointmentDate,
      "appointment_type": widget.model.appointmentType,
      "promo_code": _applyController.text.toString().trim(),
      "amount": totalAmt,
      "discount": discount,
      "paid_amount": finalAmount,
      "payment_id": paymentId,
      "is_followup_apt": widget.follow ? '1' : '0',
      "is_multiple_participant": conference ? '1' : '0',
      "conference_charge": conference ? charges : '0'
    };

    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.CreateAppointment,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        if (response != null) {
          log(response);
          Loader.hide();
          final data = responseModelFromJson(response);

          if (data.success != 'true') {
            Utils.showToast(
                message: 'Failed to create appointment: ${data.error}',
                isError: true);
          } else {
            Utils.showToast(message: 'Appointment created.');

            final appointment = appointmentModelFromJson(response);

            if (appointment.appointment != null &&
                appointment.appointment.length > 0) {
              Appointment model = appointment.appointment[0];
              PreferenceManager.setappointment_id = model.appointmentId;
              PreferenceManager.setAppointment = model;

              Future.delayed(Duration(milliseconds: 200),
                  _showSkipSheet(appointment.appointment[0]));
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppointmentScreen()),
                  (route) => false);
            }
          }
        } else {
          Utils.showToast(
              message: 'Failed to create appointment', isError: true);
        }
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(
            message: 'Failed to create appointment: $error', isError: true);
      },
    );
  }

  _createFastAppointment() async {
    Loader.showProgress();

    Map<String, String> body = {
      "patid": widget.model.patid,
      "doc_id": widget.model.docId,
      "is_wallet_payment": wallet ? '1' : '0',
      "appointment_date": widget.model.appointmentDate,
      "appointment_type": widget.model.appointmentType,
      "promo_code": _applyController.text.toString().trim(),
      "amount": totalAmt,
      "discount": discount,
      "paid_amount": finalAmount,
      "payment_id": paymentId,
      "is_multiple_participant": conference ? '1' : '0',
      "conference_charge": conference ? charges : '0'
    };

    final response = await appointmentRepository.createFastAppointment(body);

    Loader.hide();

    if (response != null) {
      if (response.success != 'true')
        Utils.showToast(message: response.error, isError: true);
      else {
        Utils.showToast(message: 'Appointment created.');

        if (response.appointment != null && response.appointment.length > 0) {
          Appointment model = response.appointment[0];
          PreferenceManager.setappointment_id = model.appointmentId;
          PreferenceManager.setAppointment = model;

          Future.delayed(Duration(milliseconds: 200),
              _showSkipSheet(response.appointment[0]));
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyAppointmentScreen()),
              (route) => false);
        }
      }
    } else {
      Utils.showToast(message: 'Failed to add appointment', isError: true);
    }
  }

  _showSkipSheet(appoint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return SkipChatSheet(
          onAction: (action) {
            if (action == ActionType.skip) {
              Utils.showAppointmentSuccessDialog(
                context,
                appoint,
                () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAppointmentScreen()),
                        (route) => false);
                  });
                },
              );
            } else {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => SymptomScreen(
                    widget.doctor,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  updateAppointmentPendingPayment() async {
    var body = {
      "appointment_id": widget.appointmentId,
      "is_wallet_payment": wallet ? '1' : '0',
      "promo_code": _applyController.text.toString().trim(),
      "amount": totalAmt,
      "discount": discount,
      "paid_amount": finalAmount,
      "payment_id": paymentId,
      "is_multiple_participant": conference ? '1' : '0',
      "conference_charge": conference ? charges : '0'
    };
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.UpdateAppointmentPendingPayment,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        Loader.hide();
        if (response != null) {
          log(response);
          final data = responseModelFromJson(response);

          if (data.success != 'true') {
            Utils.showToast(
                message: 'Failed to update appointment: ${data.error}',
                isError: true);
          } else {
            final appointment = appointmentModelFromJson(response);

            if (appointment.appointment != null &&
                appointment.appointment.length > 0) {
              Appointment model = appointment.appointment[0];
              PreferenceManager.setappointment_id = model.appointmentId;
              PreferenceManager.setAppointment = model;
              Utils.showAppointmentSuccessDialog(
                context,
                appointment.appointment[0],
                () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAppointmentScreen()),
                        (route) => false);
                  });
                },
              );
            } else {
              Utils.showToast(message: 'Appointment successfully updated');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppointmentScreen()),
                  (route) => false);
            }
          }
        } else {
          Utils.showToast(
              message: 'Failed to update appointment', isError: true);
        }
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(
            message: 'Failed to update appointment: $error', isError: true);
      },
    );
  }
}
