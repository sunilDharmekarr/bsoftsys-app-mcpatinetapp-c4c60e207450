import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/wallet_model.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/repository/promo_code%20repo.dart';
import 'package:mumbaiclinic/repository/wallet_repo.dart';
import 'package:mumbaiclinic/screen/payment/payment_result_screen.dart';
import 'package:mumbaiclinic/screen/wallet/my_wallet_screen.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/app_text_field.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

enum PaymentType { Online, Wallet, Cash }

class OrderSummaryScreen extends StatefulWidget {
  final List<Labtest> tests;
  final Datum patient;
  final AddressDatum address;
  final Lab lab;
  final DateTime date;
  final String slot;
  OrderSummaryScreen(
      this.tests, this.patient, this.address, this.lab, this.date, this.slot);
  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> {
  double _discountedTotal = 0;
  double _actualTotal = 0;
  double _serviceCharge = 0;
  double _couponDiscount = 0;
  String _couponCode = '';
  double _walletBalance;

  var _paymentType = PaymentType.Online;
  var _isCouponOpen = false;
  var _couponCodeController = TextEditingController();
  String _fileName = "";
  String _filePath = "";
  final picker = ImagePicker();
  final labTestRepo = LabTestRepo();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = _calculateFinalAmount();
    return Scaffold(
      appBar: Utils.getAppBar('Order summary'),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(
              color: ColorTheme.lightGreenOpacity,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(children: [
                  for (int index = 0; index < widget.tests.length; index++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: '${index + 1}. ',
                            style: AppTextTheme.textTheme16Regular,
                            color: Colors.black87,
                          ),
                          Expanded(
                            child: TextView(
                              text:
                                  '${widget.tests[index].testId != null ? widget.tests[index].testName : widget.tests[index].profileName}',
                              style: AppTextTheme.textTheme16Regular,
                              color: Colors.black87,
                              maxLine: 2,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          TextView(
                            text: 'Rs. ',
                            style: AppTextTheme.textTheme16Regular,
                            color: ColorTheme.darkGreen,
                            maxLine: 1,
                          ),
                          if (widget.tests[index].price >
                              widget.tests[index].discountedPrice)
                            TextView(
                              text:
                                  '${Utils.formatAmount(widget.tests[index].price)}',
                              style: AppTextTheme.textTheme16Strikethrough,
                              color: ColorTheme.darkGreen,
                              maxLine: 1,
                              fontStyle: FontStyle.italic,
                            ),
                          TextView(
                            text:
                                ' ${Utils.formatAmount(widget.tests[index].discountedPrice)}',
                            style: AppTextTheme.textTheme16Regular,
                            color: ColorTheme.darkGreen,
                            maxLine: 1,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    color: ColorTheme.darkGreen,
                    height: 1,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextView(
                            text: 'Total price',
                            style: AppTextTheme.textTheme16Regular,
                            color: Colors.black87,
                          ),
                        ),
                        TextView(
                          text: 'Rs. ${Utils.formatAmount(_actualTotal)}',
                          style: AppTextTheme.textTheme16Bold,
                          color: ColorTheme.darkGreen,
                          maxLine: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextView(
                            text: 'Discounted price',
                            style: AppTextTheme.textTheme16Regular,
                            color: Colors.black87,
                          ),
                        ),
                        TextView(
                          text: 'Rs. ${Utils.formatAmount(_discountedTotal)}',
                          style: AppTextTheme.textTheme16Bold,
                          color: ColorTheme.darkGreen,
                          maxLine: 1,
                        ),
                      ],
                    ),
                  ),
                  if (widget.lab == null)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextView(
                              text: 'Lab service fee',
                              style: AppTextTheme.textTheme16Regular,
                              color: Colors.black87,
                            ),
                          ),
                          TextView(
                            text: 'Rs. ${Utils.formatAmount(_serviceCharge)}',
                            style: AppTextTheme.textTheme16Bold,
                            color: ColorTheme.darkGreen,
                            maxLine: 1,
                          ),
                        ],
                      ),
                    ),
                  if (_couponDiscount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextView(
                              text: 'Coupon discount',
                              style: AppTextTheme.textTheme16Regular,
                              color: Colors.black87,
                            ),
                          ),
                          TextView(
                            text: 'Rs. ${Utils.formatAmount(_couponDiscount)}',
                            style: AppTextTheme.textTheme16Bold,
                            color: ColorTheme.darkGreen,
                            maxLine: 1,
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextView(
                            text: 'Final price',
                            style: AppTextTheme.textTheme16Bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextView(
                          text: 'Rs. ${Utils.formatAmount(finalAmount)}',
                          style: AppTextTheme.textTheme16Bold,
                          color: ColorTheme.darkGreen,
                          maxLine: 1,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            _couponDiscount > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextView(
                        text:
                            "Coupon applied (Rs ${Utils.formatAmount(_couponDiscount)})",
                        style: AppTextTheme.textTheme13Bold,
                        color: ColorTheme.darkGreen,
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _couponCodeController.text = '';
                              _couponDiscount = 0;
                              _couponCode = '';
                            });
                          },
                          icon: Icon(Icons.delete_forever))
                    ],
                  )
                : _isCouponOpen
                    ? Stack(
                        children: [
                          AppTextField(
                              controller: _couponCodeController,
                              textHint: 'Enter coupon code',
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onSubmit: (value) {},
                              onChanged: (value) {},
                              margin: EdgeInsets.symmetric(vertical: 12)),
                          Positioned(
                            right: 0,
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isCouponOpen = false;
                                      });
                                    },
                                    icon: Icon(Icons.close),
                                    color: Colors.black45,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      var couponCode =
                                          _couponCodeController.text.trim();
                                      if (couponCode.isEmpty) {
                                        Utils.showToast(
                                            message:
                                                'Please enter coupon code');
                                      } else {
                                        var discount =
                                            await _validateCouponCode(
                                                _discountedTotal, couponCode);
                                        if (discount > 0) {
                                          setState(() {
                                            _couponDiscount = discount;
                                            _couponCode = couponCode;
                                          });
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      size: 24,
                                    ),
                                    color: ColorTheme.buttonColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => setState(() => _isCouponOpen = true),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 6, 4, 16),
                              child: TextView(
                                text: "APPLY  COUPON",
                                style: AppTextTheme.textTheme13Bold,
                                color: ColorTheme.darkGreen,
                              )),
                        ),
                      ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: ColorTheme.buttonColor,
                  )),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Patient',
                      style: AppTextTheme.textTheme12Light,
                      color: Colors.black45,
                    ),
                    TextView(
                      text: '${widget.patient.fullName}',
                      style: AppTextTheme.textTheme14Regular,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 8),
                    TextView(
                      text: 'Sample collection location',
                      style: AppTextTheme.textTheme12Light,
                      color: Colors.black45,
                    ),
                    TextView(
                      text:
                          widget.address != null ? 'At own address' : 'At lab',
                      style: AppTextTheme.textTheme14Regular,
                      color: Colors.black87,
                    ),
                    TextView(
                      text: widget.address != null
                          ? '(${_mapAddress(widget.address)})'
                          : '(${widget.lab.labName}, ${widget.lab.labAddress})',
                      style: AppTextTheme.textTheme14Regular,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 8),
                    TextView(
                      text: 'Sample collection time',
                      style: AppTextTheme.textTheme12Light,
                      color: Colors.black45,
                    ),
                    TextView(
                      text:
                          '${DateFormat.yMMMMd('en_US').format(widget.date)}, ${widget.slot}',
                      style: AppTextTheme.textTheme14Regular,
                      color: Colors.black87,
                    ),
                  ]),
            ),
            SizedBox(height: 12),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorTheme.lightGreenOpacity,
                borderRadius: BorderRadius.circular(8),
                boxShadow: Utils.getShadow(),
              ),
              /* margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10), */
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: TextView(
                          text: _fileName.isEmpty
                              ? 'Upload prescription'
                              : _fileName,
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
                        constraints: BoxConstraints(minWidth: 80),
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
                          text: 'Select',
                          color: ColorTheme.white,
                          style: AppTextTheme.textTheme14Regular,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36),
            if (finalAmount > 0)
              Column(
                children: [
                  TextView(
                    text: 'Payment mode:',
                    style: AppTextTheme.textTheme16Regular,
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          if (_paymentType != PaymentType.Online)
                            setState(() {
                              _paymentType = PaymentType.Online;
                            });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _paymentType == PaymentType.Online
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: ColorTheme.buttonColor,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              TextView(
                                text: 'Online',
                                style: AppTextTheme.textTheme16Regular,
                                color: ColorTheme.darkGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          if (_paymentType != PaymentType.Wallet)
                            setState(() {
                              _paymentType = PaymentType.Wallet;
                            });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _paymentType == PaymentType.Wallet
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: ColorTheme.buttonColor,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              TextView(
                                text: 'Wallet',
                                style: AppTextTheme.textTheme16Regular,
                                color: ColorTheme.darkGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          if (_paymentType != PaymentType.Cash)
                            setState(() {
                              _paymentType = PaymentType.Cash;
                            });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _paymentType == PaymentType.Cash
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: ColorTheme.buttonColor,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              TextView(
                                text: 'Cash',
                                style: AppTextTheme.textTheme16Regular,
                                color: ColorTheme.darkGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (finalAmount > 0 && _paymentType == PaymentType.Wallet)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: TextView(
                    text:
                        'Wallet Balance: Rs ${Utils.formatAmount(_walletBalance)}',
                    style: AppTextTheme.textTheme14Regular,
                    color: Colors.black45,
                  ),
                ),
              ),
            finalAmount > 0
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (_paymentType == PaymentType.Wallet)
                        Expanded(
                          child: AppButton(
                            text: 'RECHARGE WALLET',
                            style: AppTextTheme.textTheme14Bold,
                            onClick: () async {
                              bool isAdded = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) =>
                                          MyWalletScreen(popOnAdd: true)));
                              if (isAdded) {
                                Loader.showProgress();
                                _getWalletBalance();
                                Loader.hide();
                              }
                            },
                          ),
                        ),
                      if (_paymentType == PaymentType.Wallet)
                        SizedBox(
                          width: 8,
                        ),
                      Expanded(
                        child: AppButton(
                          text: _paymentType == PaymentType.Cash
                              ? 'ORDER NOW'
                              : 'PAY NOW & ORDER',
                          style: AppTextTheme.textTheme14Bold,
                          onClick: () {
                            if (_paymentType == PaymentType.Cash) {
                              _createLabTest('', false);
                            } else if (_paymentType == PaymentType.Wallet) {
                              if (_walletBalance < finalAmount) {
                                Utils.showSingleButtonAlertDialog(
                                    context: context,
                                    message:
                                        'Insufficient wallet balance. Please recharge your wallet or choose another payment method.');
                              } else {
                                _createLabTest('', true);
                              }
                            } else if (_paymentType == PaymentType.Online) {
                              _pay(finalAmount);
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : AppButton(
                    text: 'ORDER NOW',
                    style: AppTextTheme.textTheme14Bold,
                    onClick: () {
                      _createLabTest('', false);
                    },
                  ),
          ]),
        ),
      ),
    );
  }

  void _loadData() async {
    Loader.showProgress();
    _calculateTotal();
    _getWalletBalance();
    if (widget.lab == null) _getServiceCharge();
    Loader.hide();
  }

  void _calculateTotal() {
    _discountedTotal = 0;
    _actualTotal = 0;
    for (var test in widget.tests) {
      _discountedTotal += test.discountedPrice;
      _actualTotal += test.price;
    }
  }

  double _calculateFinalAmount() {
    var amount = _discountedTotal - _couponDiscount;
    if (widget.lab == null) amount += _serviceCharge;
    if (amount < 0) amount = 0;
    return amount;
  }

  _getWalletBalance() async {
    var amount = 0.0;
    final walletRepo = WalletRepo();
    final data = await walletRepo
        .getWalletBalance(); //patientId: widget.patient.patid.toString());
    if (data != null) {
      if (data.success == 'true') {
        WalletBalance balance = data.walletBalance[0];
        if (balance != null && balance.walletBalance != null) {
          amount = balance.walletBalance ?? 0.0;
        }
      } else {
        Utils.showToast(message: 'Failed to load balance: ${data.error}');
      }
    } else {
      Utils.showToast(message: 'Failed to load balance');
    }

    setState(() {
      _walletBalance = amount;
    });
  }

  Future<double> _validateCouponCode(double amount, String code) async {
    Loader.showProgress();
    final promoRepo = PromoCodeRepo();
    final data = await promoRepo.validateCoupon(
        code, widget.patient.patid.toString(), amount.toString());
    Loader.hide();
    return double.parse(data);
  }

  void _getServiceCharge() async {
    final data = await labTestRepo.getLabServiceFee(
        widget.lab != null ? widget.lab.labId.toString() : '0');
    var error = 'Failed to load lab service charges';
    if (data != null) {
      if (data.success == 'true') {
        if (data.serviceData.length > 0) {
          error = null;
          _serviceCharge =
              double.parse(data.serviceData[0].serviceAmount.toString());
        }
      } else {
        error = 'Failed to load lab service charges: ${data.error}';
      }
    }

    if (error != null) {
      Utils.showToast(message: error, isError: true);
      Navigator.pop(context);
      /* Utils.showSingleButtonAlertDialog(
          context: context,
          message: error,
          dismissable: false,
          onClick: () {
            Navigator.pop(context);
          }); */
    }
  }

  String _mapAddress(AddressDatum address) {
    StringBuffer buffer = StringBuffer();
    if (address.address1 != null && address.address1.isNotEmpty) {
      buffer.write(address.address1);
      buffer.write(', ');
    }
    if (address.address2 != null && address.address2.isNotEmpty) {
      buffer.write(address.address2);
      buffer.write(', ');
    }
    if (address.landmark != null && address.landmark.isNotEmpty) {
      buffer.write("Landmark: ${address.landmark}".trim());
      buffer.write(', ');
    }
    if (address.city != null && address.city.isNotEmpty) {
      buffer.write("${address.city}, ".trim());
      buffer.write(', ');
    }
    if (address.state != null && address.state.isNotEmpty) {
      buffer.write("${address.state}".trim());
      buffer.write(', ');
    }
    if (address.country != null && address.country.isNotEmpty) {
      buffer.write("${address.country}, ".trim());
      buffer.write(', ');
    }
    if (address.pinCode != null && address.pinCode.isNotEmpty) {
      buffer.writeln("PIN: ${address.pinCode}".trim());
    }

    if (buffer.isEmpty)
      return 'Invalid address data';
    else
      return buffer.toString().trim();
  }

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
        _filePath = pickedFile.path;
        _fileName = _filePath.split('/').last;
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
        _filePath = file.path;
        _fileName = file.name;
      });
    }
  }

  void _createLabTest(String paymentId, bool isWallet) async {
    Loader.showProgress();
    var testData = <TestData>[];
    var profileData = <TestData>[];
    final labId = widget.lab != null ? widget.lab.labId.toString() : '0';
    for (var test in widget.tests) {
      if (test.testId != null) {
        testData.add(TestData(
          testId: test.testId.toString(),
          labId: '0',
        ));
      } else {
        profileData.add(TestData(
          profileId: test.profileId.toString(),
          labId: '0',
        ));
      }
    }

    var uploadPath = '';
    var uploadError;
    if (_filePath != null && _filePath.isNotEmpty) {
      final response = await labTestRepo.uploadLabTestPrescription(
          _filePath, '${widget.patient.patid}');
      if (response != null) {
        final model = responseModelFromJson(response);
        if (model.success == 'true') {
          uploadPath = jsonDecode(response)['payload'];
        } else {
          uploadError = 'Failed to upload prescription: ${model.error}';
        }
      } else {
        uploadError = 'Failed to upload prescription';
      }
    }

    if (uploadError != null) {
      Loader.hide();
      Utils.showSingleButtonAlertDialog(context: context, message: uploadError);
    } else {
      Map body = {
        "TestOrder": [
          {
            "date": Utils.getServerDate(),
            "patid": '${widget.patient.patid}',
            'prescription_path': uploadPath,
            'service_amount': widget.lab == null ? '$_serviceCharge' : '0',
            'amount': '$_discountedTotal',
            'discount': _couponDiscount,
            'paid':
                paymentId.isEmpty && !isWallet ? 0 : _calculateFinalAmount(),
            'payment_ref': paymentId ?? '',
            'coupon_code': _couponCode,
            'is_home_collection': widget.lab == null ? 1 : 0,
            'is_wallet_payment': isWallet ? 1 : 0,
            "collection_datetime": "${Utils.getYYYYMMDD(widget.date)}",
            "collection_slot": "${widget.slot}",
            "collection_address":
                widget.lab == null ? "${_mapAddress(widget.address)}" : '',
            "pref_lab_id": labId,
          }
        ],
        'TestOrderTest':
            List<dynamic>.from(testData.map((x) => x.toTestBody())),
        'TestOrderProfile':
            List<dynamic>.from(profileData.map((x) => x.toProfileBody())),
      };

      final result = await labTestRepo.addLabTestWithResponse(body);
      // EasyLoading.dismiss();
      Loader.hide();
      if (result != null) {
        if (result.success == 'true') {
          Utils.showLabTestSuccessDialog(
            context,
            result.data[0],
            () {
              MyApplication.navigateAndClear('/home');
            },
          );
        } else {
          Utils.showToast(
              message: 'Failed to request lab test: ${result.error}',
              isError: true);
        }
      } else {
        Utils.showToast(message: 'Failed to request lab test', isError: true);
      }
    }
  }

  void _pay(double amount) {
    RazorPayUtil.get().open(amount, 'Mumbai-Clinic', "Order payment",
        (String paymentId) async {
      final data = await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => PaymentResultScreen(
            success: true,
            needToPop: true,
          ),
        ),
      );
      _createLabTest(paymentId, false);
    }, (String value) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => PaymentResultScreen(
            success: false,
            needToPop: true,
          ),
        ),
      );
    });
  }
}

class TestData {
  String testId;
  String labId;
  String profileId;

  TestData({this.testId, this.labId, this.profileId});

  Map<String, dynamic> toTestBody() {
    return {
      'test_id': testId,
      'lab_id': labId,
    };
  }

  Map<String, dynamic> toProfileBody() {
    return {
      'profile_id': profileId,
    };
  }
}
