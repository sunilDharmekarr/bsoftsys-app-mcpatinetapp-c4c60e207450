import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/banner_model.dart';
import 'package:mumbaiclinic/model/otp_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/settingsModel.dart';
import 'package:mumbaiclinic/model/validate_model.dart';
import 'package:mumbaiclinic/screen/register/register_screen.dart';
import 'package:mumbaiclinic/utils/device_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _OTPcontroller = TextEditingController();

  List<int> indicators =
      List.generate(BannerModel.getBanners().length, (index) => index);

  String countryCode = '+91';
  bool isEnables = true;
  Payload payload = null;

  @override
  void initState() {
    super.initState();
    PreferenceManager.isdCode = countryCode;
    setToken();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isEnables = true;
      setState(() {});
    }
  }

  void setToken() async {
    // String token = await FCMMessageChanel.get().getFCMToken();
    String token = await FirebaseMessaging.instance.getToken();
    setState(() {
      PreferenceManager.setFCMToken(token);
      Utils.log("the token is :${PreferenceManager.getFCMToken()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(top: 0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _getCarouselView(),
                Positioned(
                  bottom: 5,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: indicators
                              .map((e) => Container(
                                    height: 10,
                                    width: 10,
                                    margin: EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: e == selectedIndex
                                            ? ColorTheme.darkGreen
                                            : ColorTheme.lightGreenOpacity),
                                  ))
                              .toList(),
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 8,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: Utils.getShadow(),
                        ),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: GestureDetector(
                                  onTap: () {
                                    Utils.showCountryPicker(
                                        context, true, _getCountryCode);
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text('$countryCode  ',
                                          textScaleFactor: 1.0,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.safeBlockHorizontal *
                                                    5,
                                            fontFamily: TextFont.poppinsBold,
                                          )
                                          // style: AppTextTheme.textTheme14Bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                                height: 20,
                                child: Container(
                                  color: ColorTheme.darkGreen,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: TextField(
                                    controller: _controller,
                                    enabled: true,
                                    autofocus: false,
                                    maxLines: 1,
                                    maxLength: 20,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    style: AppTextTheme.textTheme14Bold
                                        .apply(color: ColorTheme.darkGreen),
                                    onChanged: (val) {
                                      isEnables = true;
                                      _OTPcontroller.text = '';
                                      PreferenceManager.setMobile(
                                          val.toString().trim());
                                      setState(() {});
                                    },
                                    onSubmitted: (val) {
                                      FocusScope.of(context).unfocus();
                                      PreferenceManager.setMobile(
                                          val.toString().trim());
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Mobile',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal * 5,
                                        fontFamily: TextFont.poppinsBold,
                                        color: ColorTheme.darkGreen,
                                      ),
                                      // Theme.of(context).textTheme.headline3,
                                      contentPadding: const EdgeInsets.all(14),
                                      counterText: '',
                                      counter: null,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical * 10,
                                width: SizeConfig.blockSizeHorizontal * 17,
                                child: GestureDetector(
                                  onTap: (_controller.text
                                              .toString()
                                              .trim()
                                              .length >
                                          9)
                                      ? () {
                                          PreferenceManager.setMobile(
                                              _controller.text
                                                  .toString()
                                                  .trim());
                                          FocusScope.of(context).unfocus();
                                          _login();
                                        }
                                      : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorTheme.buttonColor,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      isEnables
                          ? Container()
                          : Container(
                              height: SizeConfig.blockSizeVertical * 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ColorTheme.lightGreenOpacity,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: Utils.getShadow(),
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Icon(
                                            Icons.vpn_key,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                      height: 20,
                                      child: Container(
                                        color: ColorTheme.darkGreen,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: TextField(
                                          controller: _OTPcontroller,
                                          maxLines: 1,
                                          maxLength: 6,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          style: AppTextTheme.textTheme14Bold
                                              .apply(
                                                  color: ColorTheme.darkGreen),
                                          onChanged: (val) {
                                            if (val.trim().length == 6) {
                                              FocusScope.of(context).unfocus();
                                            }
                                            setState(() {});
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'OTP',
                                            hintStyle: TextStyle(
                                              fontSize: SizeConfig
                                                      .safeBlockHorizontal *
                                                  4,
                                              fontFamily: TextFont.poppinsLight,
                                            ),
                                            // hintStyle: Theme.of(context)
                                            //     .textTheme
                                            //     .headline3,
                                            contentPadding:
                                                const EdgeInsets.all(14),
                                            counterText: '',
                                            counter: null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical * 10,
                                      width:
                                          SizeConfig.blockSizeHorizontal * 17,
                                      child: GestureDetector(
                                        onTap: _OTPcontroller.text
                                                    .toString()
                                                    .trim()
                                                    .length ==
                                                6
                                            ? () {
                                                _verifyOTP();
                                              }
                                            : null,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: ColorTheme.buttonColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10))),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  int selectedIndex = 0;

  ///  this method is use to return the carousel view
  _getCarouselView() {
    return CarouselSlider(
      options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 1,
          viewportFraction: 1.0,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
          enableInfiniteScroll: true,
          onPageChanged: (index, reason) {
            setState(() {
              selectedIndex = index;
            });
          }),
      items: BannerModel.getBanners().map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Image.asset(
                    i.bg,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SizedBox(height: 20,),
                      Center(
                          child: Image.asset(
                        i.image,
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.height < 600
                            ? SizeConfig.blockSizeVertical * 45
                            : SizeConfig.blockSizeVertical * 55,
                      )),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        '${i.header}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? SizeConfig.safeBlockHorizontal * 4
                              : SizeConfig.safeBlockHorizontal * 5,
                          fontWeight: FontWeight.w700,
                          color: ColorTheme.buttonColor,
                          fontFamily: TextFont.poppinsBold,
                        ),
                        // textScaleFactor: 1.0,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '${i.header1}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? SizeConfig.safeBlockHorizontal * 4
                              : SizeConfig.safeBlockHorizontal * 5,
                          fontWeight: FontWeight.w800,
                          color: ColorTheme.buttonColor,
                          fontFamily: TextFont.poppinsExtraBold,
                        ),
                        // textScaleFactor: 1.0,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '${i.message}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? 11
                              : AppTextTheme.textSize12,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.buttonColor,
                          fontFamily: TextFont.poppinsLight,
                        ),
                        // textScaleFactor: 1.0,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      }).toList(),
    );
  }

  ///this function is use to get the country code

  _getCountryCode(String text) {
    print(text);
    countryCode = text;
    setState(() {});
  }

  ///this method will call for checking mobile number is register or not
  _login() async {
    Map<String, String> body = {'mobile': _controller.text.toString().trim()};
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.MobileAuthentication,
      body: body,
      header: Utils.getHeaders(),
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          ResponseModel model = ResponseModel.fromJson(json.decode(response));
          if (model.success == 'true') {
            ValidateModel validateModel =
                ValidateModel.fromJson(json.decode(response));
            if (validateModel.payload.length > 0) {
              isEnables = false;
              payload = validateModel.payload[0];
              Utils.showToast(
                  message: 'OTP sent successfully.', isError: false);
              setState(() {});
            }
          } else {
            Utils.showToast(
                message: 'Failed to sign in: ${model.error}\nResend OTP',
                isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to sign in', isError: true);
        }
      },
      onError: (error) {
        //EasyLoading.dismiss();
        Loader.hide();
        Utils.showToast(message: 'Failed to sign in: $error', isError: true);
      },
    );
  }

  ///this method will call for checking mobile number is register or not
  _verifyOTP() async {
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    Map<String, String> body = {
      'mobile': PreferenceManager.getMobile(),
      'otp': _OTPcontroller.text.toString().trim(),
      'device_name': DeviceUtils.getDeviceName(),
      'device_id': DeviceUtils.getDeviceID(),
      'imei_no': Platform.isIOS
          ? DeviceUtils.getDeviceID()
          : DeviceUtils
              .getIMEI(), //As IOS doesn't give access to IMEI number deviceId is used instead.
      'mac_id': '${DeviceUtils.macId}',
      'google_token': '${PreferenceManager.getFCMToken()}'
    };

    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.ValidateOTP,
      body: body,
      header: Utils.getHeaders(),
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          ResponseModel model = ResponseModel.fromJson(json.decode(response));

          if (model.success != 'true') {
            Utils.showToast(
                message: 'Failed to verify OTP: ${model.error}', isError: true);
          } else {
            OtpModel model = OtpModel.fromJson(json.decode(response));
            PreferenceManager.setToken(model.payload[0].token);
            if (payload.isRegisteredMobile == 1) {
              PreferenceManager.isLogin(true);
              _getUserData();
            } else {
              Utils.showSingleButtonAlertDialog(
                  context: context,
                  message:
                      'Sorry! this number is not registered with us. Please complete  registration to continue.',
                  onClick: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()));
                  });
            }
          }
        } else {
          Utils.showToast(message: 'Failed to verify OTP', isError: true);
        }
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(message: 'Failed to verify OTP: $error', isError: true);
      },
    );
  }

  _getUserData() async {
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    var mobile = PreferenceManager.getMobile();
    var token = PreferenceManager.getToken();
    await MumbaiClinicNetworkCall.getRequest(
      endPoint: APIConfig.getPatientDetails + mobile,
      context: context,
      header: Utils.getHeaders(token: token),
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          RegisterModel model = RegisterModel.fromJson(json.decode(response));
          if (model.data.length > 0) {
            var data = model.data[0];
            AppDatabase.db.addUser(data.toDatabase());
            PreferenceManager.setMobile(data.mobile);
            PreferenceManager.setEmail(data.email);
            PreferenceManager.setActiveUserID(data.patid.toString());
            PreferenceManager.setUserId(data.patid.toString());
            _getSettings();
            MyApplication.navigateAndClear('/home');
            /*SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
            });*/
          } else {
            Utils.showToast(message: 'User not found.', isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to process request.', isError: true);
        }
      },
      onError: (error) {
        //EasyLoading.dismiss();
        Loader.hide();
        Utils.showToast(message: error.toString(), isError: true);
      },
    );
  }

  _getSettings() async {
    await MumbaiClinicNetworkCall.getRequest(
        endPoint: APIConfig.BASE_URL +
            'Resource/getSettings?patid=${PreferenceManager.getUserId()}',
        context: context,
        header: Utils.getHeaders(),
        onSuccess: (response) {
          ResponseModel responseModel =
              ResponseModel.fromJson(json.decode(response));
          if (responseModel.success == 'true') {
            SettingsModel settingsModel =
                SettingsModel.fromJson(json.decode(response));
            PreferenceManager.setIsLocationEnabled(settingsModel?.settings
                ?.firstWhere((element) => element.isLocationEnable != null)
                ?.isLocationEnable);
            PreferenceManager.setIsNotificationEnabled(settingsModel?.settings
                ?.firstWhere((element) => element.isNotificationEnable != null)
                ?.isNotificationEnable);
          }
        });
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
