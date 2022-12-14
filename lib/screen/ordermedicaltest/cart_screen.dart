import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/app_icons.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/CartData.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/model/lab_slot_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/wallet_model.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/repository/package_repository.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/repository/promo_code%20repo.dart';
import 'package:mumbaiclinic/repository/wallet_repo.dart';
import 'package:mumbaiclinic/screen/payment/payment_result_screen.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/edit_address_dialog.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class CartScreen extends StatefulWidget {
  final Lab lab;
  final bool packege;

  CartScreen(this.lab, {this.packege = false});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _applyController = TextEditingController();

  final promoRepo = PromoCodeRepo();
  final labtestrepo = LabTestRepo();
  final packageRepo = PackageRepository();
  final walletRepo = WalletRepo();

  List<TestData> testData = [];
  List<TestData> profileData = [];
  String discount = "0";
  String finalAmount = "0";

  String walletBalance = '0';
  File _image;
  File _file;
  final picker = ImagePicker();
  String filePath = "";
  String fileName = "";
  String paymentId = "";
  double serviceCharge = 0.0;
  double tempCharge = 0.0;
  bool changeData = false;
  bool homeVisit = false;
  bool labVisit = false;
  bool visible = false;
  bool wallet = false;
  String date = 'Select Date';
  String time = 'Select Time';
  DateTime _dateTime;
  TimeOfDay _timeOfDay;
  var _addresses = <String>[];
  var _pickedAddress;

  @override
  void initState() {
    super.initState();
    if (!widget.packege && CartData.getItems.length > 0) getServiceCharge();

    cheackWalletBalance();
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(changeData);
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'My Cart',
            style: Theme.of(context).appBarTheme.textTheme.headline1,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(changeData);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        body: CartData.getItems.length == 0
            ? Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.my_cart,
                      width: 50,
                      height: 50,
                    ),
                    AppText.getErrorText('Cart is empty.', 16)
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate(
                    CartData.getItems
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: ColorTheme.lightGreenOpacity,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      if (!widget.packege)
                                        Container(
                                          height: 50,
                                          width: 50,
                                          margin: const EdgeInsets.all(6),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: ColorTheme.buttonColor,
                                          ),
                                          child: Image.asset(
                                            AppAssets.tests,
                                            color: ColorTheme.white,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                widget.packege ? 20 : 0),
                                            child: TextView(
                                              text:
                                                  '${e.profileName ?? e.testName ?? e.packageName}',
                                              style: AppTextTheme
                                                  .textTheme14Regular,
                                            ),
                                          ),
                                        ],
                                      )),
                                      if (!widget.packege)
                                        Container(
                                          color: ColorTheme.buttonColor,
                                          width: 1,
                                          height: 40,
                                        ),
                                      if (!widget.packege)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          child: TextView(
                                            text: 'Rs.${e.discountedPrice}',
                                            style: AppTextTheme.textTheme14Bold,
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      CartData.removeItems(e);
                                      changeData = true;
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ColorTheme.buttonColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        color: ColorTheme.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  )),
                  if (!widget.packege)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextView(
                          text: 'Select Service:',
                          style: AppTextTheme.textTheme14Regular,
                        ),
                      ),
                    ),
                  if (!widget.packege)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: labVisit,
                                    onChanged: (value) {
                                      labVisit = value;
                                      homeVisit = !labVisit;
                                      serviceCharge = 0.0;
                                      setState(() {});
                                    },
                                  ),
                                  TextView(
                                    text: 'Lab Visit',
                                    style: AppTextTheme.textTheme12Light,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: homeVisit,
                                    onChanged: (value) {
                                      if (value) {
                                        homeVisit = value;
                                        labVisit = !homeVisit;
                                        serviceCharge = tempCharge;
                                        setState(() {});
                                      } else {
                                        homeVisit = value;
                                        labVisit = !homeVisit;
                                        serviceCharge = 0.0;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  TextView(
                                    text: 'Home Visit',
                                    style: AppTextTheme.textTheme12Light,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (!widget.packege)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextView(
                                    text: 'Amount',
                                    style: AppTextTheme.textTheme14Regular,
                                  ),
                                ),
                                Expanded(
                                  child: TextView(
                                    text:
                                        ': Rs.${double.parse(calculatePrice().toString()).round()}',
                                    style: AppTextTheme.textTheme14Regular,
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (homeVisit)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextView(
                                    text: 'Service Amount',
                                    style: AppTextTheme.textTheme14Regular,
                                  ),
                                ),
                                Expanded(
                                  child: TextView(
                                    text: ': Rs.${serviceCharge.round()}',
                                    style: AppTextTheme.textTheme14Regular,
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (homeVisit && !widget.packege)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: ColorTheme.lightGreenOpacity,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: Utils.getShadow(),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () => _showDatePicker(),
                                    child: Image.asset(
                                      AppAssets.calander,
                                      width: 24,
                                      height: 24,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () => _showDatePicker(),
                                        child: AppText.getBoldText('$date', 14,
                                            ColorTheme.darkGreen))),
                                const SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  AppAssets.fast_appointment,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: DropdownButton(
                                  value: _selectedSlots,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSlots = value;
                                    });
                                  },
                                  underline: Container(),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  items: _slots
                                      .map<DropdownMenuItem>(
                                          (e) => DropdownMenuItem(
                                                child: AppText.getBoldText(
                                                    e.collectionSlot,
                                                    14,
                                                    ColorTheme.darkGreen),
                                                value: e.collectionSlot,
                                              ))
                                      .toList(),
                                )),
                              ],
                            ),
                          ),
                        if (homeVisit && !widget.packege)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: ColorTheme.lightGreenOpacity,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: Utils.getShadow(),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              style: Theme.of(context).textTheme.bodyText1,
                              underline: Container(
                                height: 0,
                                color: ColorTheme.darkGreen,
                              ),
                              onChanged: (String newValue) async {
                                if (newValue != null && newValue.isEmpty) {
                                  bool isUpdated = await showDialog(
                                      context: context,
                                      builder: (_) => EditAddressDialog());
                                  if (isUpdated != null && isUpdated) {
                                    _loadAddresses(isAdd: true);
                                  }
                                } else {
                                  setState(() {
                                    _pickedAddress = newValue;
                                  });
                                }
                              },
                              hint: AppText.getLightText(
                                  'Select collection address',
                                  14,
                                  ColorTheme.darkGreen),
                              value: _pickedAddress,
                              items: _addresses
                                  .map((e) => DropdownMenuItem(
                                        child: e.isNotEmpty
                                            ? Text(e)
                                            : Text('ADD NEW ADDRESS'),
                                        value: e,
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        color: ColorTheme.lightGreenOpacity,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: Utils.getShadow(),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    text:
                                        'Rs.${double.parse((calculatePrice() + serviceCharge).toString()).round()}',
                                    style: AppTextTheme.textTheme14Bold,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
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
                                          color: ColorTheme.lightGreen
                                              .withOpacity(0.8),
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
                                            textInputAction:
                                                TextInputAction.done,
                                            style: AppTextTheme.textTheme12Bold,
                                            onChanged: (val) {},
                                            decoration: InputDecoration(
                                              hintText: 'Enter coupon code',
                                              hintStyle:
                                                  AppTextTheme.textTheme12Light,
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
                                              if (_applyController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                _ValidateCouponCode();
                                              } else {
                                                Utils.showToast(
                                                    message:
                                                        'Enter coupon code');
                                              }
                                            },
                                            child: Center(
                                              child: TextView(
                                                text: 'Apply',
                                                color: ColorTheme.white,
                                                style: AppTextTheme
                                                    .textTheme12Bold,
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
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  color: Colors.transparent,
                                  child: Center(
                                    child: visible
                                        ? TextView(
                                            text:
                                                'Rs.${double.parse(discount).round()}',
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
                            height: 50,
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
                                    text:
                                        'Rs.${double.parse((calculatePrice() - double.parse(discount) + serviceCharge).toString()).round()}',
                                    style: AppTextTheme.textTheme14Bold,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
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
                                  text:
                                      'Rs.${double.parse(walletBalance).round()} Balance in wallet',
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
                  ),
                  if (!widget.packege)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: Utils.getShadow(),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: TextView(
                                    text: fileName.isEmpty
                                        ? 'Prescription'
                                        : fileName,
                                    color: ColorTheme.darkGreen,
                                    style: AppTextTheme.textTheme12Light,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showImagePicker();
                                },
                                child: Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ColorTheme.buttonColor,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: TextView(
                                    text: 'Upload',
                                    color: ColorTheme.white,
                                    style: AppTextTheme.textTheme14Regular,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () {
                        if (CartData.getItems.length == 0) {
                          Utils.showToast(message: ('Cart is empty'));
                        } else if (!homeVisit && !labVisit && !widget.packege) {
                          Utils.showToast(message: 'Select service type');
                        } else if (homeVisit &&
                            _dateTime == null &&
                            _selectedSlots == null) {
                          Utils.showToast(
                              message: 'Select Collection Date and Time.');
                        } else if (homeVisit &&
                            !widget.packege &&
                            _pickedAddress == null) {
                          Utils.showToast(
                              message: 'Select collection address.');
                        } else {
                          var charges = homeVisit ? serviceCharge : 0.0;
                          var finalAmount = (calculatePrice() -
                              double.parse(discount) +
                              charges);
                          if (wallet) {
                            if (double.parse(walletBalance) >= finalAmount)
                              widget.packege
                                  ? createPackage()
                                  : createLabTest();
                            else
                              Utils.showSingleButtonAlertDialog(
                                  context: context,
                                  message: 'You have not enough balance.');
                          } else if (finalAmount <= 0) {
                            widget.packege ? createPackage() : createLabTest();
                          } else {
                            _pay();
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
                              text:
                                  'Pay ${double.parse((calculatePrice() - double.parse(discount) + serviceCharge).toString()).round()}',
                              color: Colors.white,
                              style: AppTextTheme.textTheme14Bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  calculatePrice() {
    testData.clear();
    profileData.clear();
    dynamic sum = 0;
    CartData.getItems.forEach((element) {
      sum += element.discountedPrice;

      if (element.testName != null && !widget.packege)
        testData.add(TestData(
            lab_id: widget.lab.labId.toString(),
            test_id: element.testId.toString()));

      if (element.profileName != null && !widget.packege)
        profileData.add(TestData(
            lab_id: widget.lab.labId.toString(),
            profile_id: element.profileId.toString()));
    });
    return sum;
  }

  _ValidateCouponCode() async {
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    dynamic sum = calculatePrice();
    final data = await promoRepo.validateCoupon(_applyController.text.trim(),
        PreferenceManager.getUserId(), sum?.toString());
    visible = true;
    discount = data.toString();
    finalAmount = (sum - double.parse(discount) + serviceCharge).toString();
    // EasyLoading.dismiss();
    Loader.hide();
    setState(() {});
  }

  getServiceCharge() async {
    Loader.showProgress();
    final data =
        await labtestrepo.getLabServiceFee(widget.lab.labId.toString());
    var error = 'Failed to load lab service charges';
    if (data != null) {
      if (data.success == 'true') {
        if (data.serviceData.length > 0) {
          error = null;
          tempCharge =
              double.parse(data.serviceData[0].serviceAmount.toString());
          setState(() {});
        }
      } else {
        error = 'Failed to load lab service charges: ${data.error}';
      }
    }
    Loader.hide();

    if (error != null) {
      Utils.showToast(message: error, isError: true);
    }
  }

  final labTestRepo = LabTestRepo();
  List<Slot> _slots = [];
  String _selectedSlots = '8am - 10am';

  cheackWalletBalance() async {
    final data = await walletRepo.getWalletBalance();
    if (data != null && data.success == 'true') {
      WalletBalance balance = data.walletBalance[0];
      if (balance.walletBalance != null) {
        walletBalance = balance.walletBalance.toString() ?? '0';
      } else {
        walletBalance = '0';
      }
    } else {
      Utils.showToast(message: 'Failed to load balance');
    }

    final lab = await labTestRepo.getLabSlots();
    if (lab != null) {
      _slots = lab.slots;
    }

    setState(() {});
  }

  _pay() {
    var charges = homeVisit ? serviceCharge : 0.0;
    finalAmount =
        (calculatePrice() - double.parse(discount) + charges).toString();
    RazorPayUtil.get()
        .open(double.parse(finalAmount), 'Mumbai-Clinic', "Order payment",
            (String value) async {
      paymentId = value;
      final data = await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => PaymentResultScreen(
            success: true,
            needToPop: true,
          ),
        ),
      );

      if (data) {
        widget.packege ? createPackage() : createLabTest();
      }
    }, (String value) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => PaymentResultScreen(
            success: false,
          ),
        ),
      );
    });
  }

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.camera);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       filePath = _image.path;
  //       fileName = _image.path.split("/").last;
  //     }
  //   });
  // }

  _showImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: ColorTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Expanded(
                child: Center(
              child: AppText.getButtonText('Camera', 16, Colors.black, () {
                Navigator.of(context).pop();
                getImage(1);
              }),
            )),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                child: Center(
              child: AppText.getButtonText('File', 16, Colors.black, () {
                Navigator.of(context).pop();
                getFile();
              }),
            )),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                child: Center(
              child: AppText.getButtonText('Cancel', 16, Colors.black, () {
                Navigator.of(context).pop();
              }),
            )),
          ],
        ),
      ),
    );
  }

  Future getImage(int type) async {
    final pickedFile = await picker.pickImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        fileName = pickedFile.path.split('/').last;
        _file = File(pickedFile.path);
      }
    });
  }

  Future getFile() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [
      'jpeg',
      'jpg',
      'png',
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
    ]);

    if (pickedFile != null) {
      setState(() {
        PlatformFile file = pickedFile.files.first;
        fileName = file.name;
        _file = File(file.path);
      });
    }
  }

  convertAsString(String path) {
    try {
      if (path == null || path.isEmpty) return '';
      final bytes = File(path).readAsBytesSync();
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  createLabTest() async {
    Loader.showProgress();
    Map body = {
      "TestOrder": [
        {
          "date": Utils.getServerDate(),
          "patid": PreferenceManager.getUserId(),
          'prescription_path': convertAsString(_image?.path),
          'service_amount': homeVisit ? '$serviceCharge' : '0',
          'amount': '${calculatePrice()}',
          'discount': discount,
          'paid': finalAmount,
          'payment_ref': paymentId,
          'coupon_code': _applyController.text,
          'is_home_collection': homeVisit ? 1 : 0,
          'is_wallet_payment': wallet ? 1 : 0,
          "collection_date": homeVisit ? "$date" : '',
          "collection_slot": "$_selectedSlots",
          "collection_address": _pickedAddress ?? '',
        }
      ],
      'TestOrderTest': List<dynamic>.from(testData.map((x) => x.toTestBody())),
      'TestOrderProfile':
          List<dynamic>.from(profileData.map((x) => x.toProfileBody())),
    };
    if (_image != null) {
      final response = await labtestrepo.uploadLabTestPrescription(
          _image.path, PreferenceManager.getUserId());
    }
    final result = await labtestrepo.addLabTest(body);
    // EasyLoading.dismiss();
    Loader.hide();
    if (result == null) {
      Utils.showToast(message: 'Order Placed successfully');
      CartData.clearData();
      MyApplication.navigateAndClear('/home');
    } else {
      Utils.showToast(message: result, isError: true);
    }
  }

  createPackage() async {
    //EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    Map body = {
      "patid": PreferenceManager.getUserId(),
      "package_id": CartData.getItems[0].packageId,
      "amount": CartData.getItems[0].discountedPrice,
      "coupon_code": "${_applyController.text.toString().trim()}",
      "discount": discount,
      "paid": finalAmount,
      "payment_ref": "$paymentId",
      "is_wallet_payment": wallet ? '1' : "0",
    };

    final result = await packageRepo.orderPackage(body);
    // EasyLoading.dismiss();
    if (kDebugMode) {
      log("Package -- ${body}");
    }
    Loader.hide();
    if (result != null) {
      CartData.clearData();
      Utils.showSingleButtonAlertDialog(
          context: context,
          message:
              'Package order placed\n successfully.\n\n${result.packageName}\nInvoice Number : ${result.invoiceNumber}',
          onClick: () => MyApplication.navigateAndClear('/home'));
    } else {
      Utils.showToast(message: 'Failed to process request.');
    }
  }

  _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateTime = picked;
        date = Utils.getReadableDate(_dateTime);
      });
    }
  }

  _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeOfDay = picked;
        time = Utils.getReadableTimeFromTimeOfDay(_timeOfDay);
      });
    }
  }

  _loadAddresses({bool isAdd = false}) async {
    Loader.showProgress();
    var addresses = <String>[];
    var selectedAddress = '';
    try {
      final patientRepo = PatientRepo();
      AddressModel addressModel = await patientRepo.getAddresses();
      Datum userData =
          await AppDatabase.db.getUser(PreferenceManager.getUserId()) as Datum;

      addresses.add(''); //Blank for ADD NEW
      if (userData != null) {
        addresses.add(_mapAddress(AddressDatum(
          id: 0,
          patient: userData.id,
          typeId: 0,
          type: 'Primary',
          address1: userData.address1,
          address2: userData.address2,
          city: userData.city,
          state: userData.state,
          country: userData.country,
          pinCode: userData.pincode,
          landmark: '',
        )));
      }
      addresses.addAll(addressModel.addresses.map((e) => _mapAddress(e)));
      if (isAdd &&
          addressModel.addresses != null &&
          addressModel.addresses.isNotEmpty) {
        addressModel.addresses.sort((a, b) => a.id - b.id);
        selectedAddress = _mapAddress(addressModel.addresses[0]);
      }
    } catch (_) {}

    setState(() {
      _addresses = addresses;
      if (selectedAddress.isNotEmpty) _pickedAddress = selectedAddress;
    });
    Loader.hide();
  }
}

String _mapAddress(AddressDatum address) {
  var buffer = StringBuffer();
  if (address.address1 != null && address.address1.isNotEmpty) {
    buffer.write(address.address1);
    buffer.write(", ");
  }
  if (address.address2 != null && address.address2.isNotEmpty) {
    buffer.write(address.address2);
    buffer.write(", ");
  }
  if (address.landmark != null && address.landmark.isNotEmpty) {
    buffer.write("Landmark: ");
    buffer.write(address.landmark);
    buffer.write(", ");
  }
  if (address.city != null && address.city.isNotEmpty) {
    buffer.write(address.city);
    buffer.write(", ");
  }
  if (address.state != null && address.state.isNotEmpty) {
    buffer.write(address.state);
    buffer.write(", ");
  }
  if (address.country != null && address.country.isNotEmpty) {
    buffer.write(address.country);
    buffer.write(", ");
  }
  if (address.pinCode != null && address.pinCode.isNotEmpty) {
    buffer.write(address.pinCode);
  }
  var output = buffer.toString();
  if (output.endsWith(", ")) output.substring(0, output.length - 2);

  return output;
}

class TestData {
  String test_id;
  String lab_id;
  String profile_id;

  TestData({this.test_id, this.lab_id, this.profile_id});

  Map<String, dynamic> toTestBody() {
    return {
      'test_id': test_id,
      'lab_id': lab_id,
    };
  }

  Map<String, dynamic> toProfileBody() {
    return {
      'profile_id': profile_id,
    };
  }
}
