import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/settingsModel.dart';
import 'package:mumbaiclinic/model/user_model.dart';
import 'package:mumbaiclinic/repository/image_upload_repo.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/utils/validation_utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class ContactInfoScreen extends StatefulWidget {
  final UserModel userModel;

  ContactInfoScreen(this.userModel);

  @override
  _ContactInfoScreenState createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _EmgrMobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final AddressService _addressService = AddressService.instance;

  String latitude = '0.0';
  String longitude = '0.0';
  String accessToken = '';
  UserModel _userModel = UserModel();

  @override
  void initState() {
    super.initState();
    print(widget.userModel.toJson());
    _initData();
    _getAccessToken();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Image.asset(
          AppAssets.header_logo,
          height: 30,
          fit: BoxFit.fill,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 4),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Constant.padding),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 30,
                            child: Center(
                              child: TextView(
                                text: 'Contact Info',
                                color: ColorTheme.darkGreen,
                                style: AppTextTheme.textTheme16ExtraBold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    _getCurrentLocation();
                                  },
                                  child: Container(
                                    child: Image.asset(
                                      AppAssets.location,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.fill,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _mobileController,
                          autofocus: false,
                          enabled: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 40,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'Mobile No*',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _EmgrMobileController,
                          autofocus: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 40,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp('[+0-9 ]'),
                                replacementString: '', allow: true),
                          ],
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'Emergency Contact No.*',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 40,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'Email ID*',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _address1Controller,
                          autofocus: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 40,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'Address Line 1*',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _address2Controller,
                          autofocus: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 40,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'Address Line 2',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Utils.showCountryPicker(
                                context, false, _getCountryName);
                          },
                          child: TextField(
                            enableInteractiveSelection: false,
                            controller: _countryController,
                            autofocus: false,
                            enabled: false,
                            onSubmitted: (val) {
                              FocusScope.of(context).unfocus();
                            },
                            maxLines: 1,
                            maxLength: 40,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp('[a-zA-Z ]'),
                                  replacementString: '', allow: true),
                            ],
                            style: Theme.of(context).textTheme.bodyText1,
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              hintText: 'Country*',
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(14),
                              counterText: '',
                              counter: null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (_countryController.text.isEmpty) {
                              Utils.showToast(
                                  message: 'Select country first',
                                  isError: true);
                            } else {
                              Utils.showStateCityPicker(
                                  context: context,
                                  endponit: 'states/${_countryController.text}',
                                  token: accessToken,
                                  searchKey: 'state',
                                  onSelected: (val) {
                                    setState(() {
                                      _stateController.text = val;
                                      _cityController.text = '';
                                    });
                                  });
                            }
                          },
                          child: TextField(
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp('[a-zA-Z ]'),
                                  replacementString: '', allow: true),
                            ],
                            controller: _stateController,
                            autofocus: false,
                            enabled: false,
                            onSubmitted: (val) {
                              FocusScope.of(context).unfocus();
                            },
                            maxLines: 1,
                            maxLength: 40,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: Theme.of(context).textTheme.bodyText1,
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              hintText: 'State*',
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(14),
                              counterText: '',
                              counter: null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (_stateController.text.isEmpty) {
                              Utils.showToast(
                                  message: 'Select state first', isError: true);
                            } else {
                              Utils.showStateCityPicker(
                                  context: context,
                                  endponit: 'cities/${_stateController.text}',
                                  token: accessToken,
                                  searchKey: 'city',
                                  onSelected: (val) {
                                    setState(() {
                                      _cityController.text = val;
                                    });
                                  });
                            }
                          },
                          child: TextField(
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp('[a-zA-Z ]'),
                                  replacementString: '', allow: true),
                            ],
                            controller: _cityController,
                            autofocus: false,
                            enabled: false,
                            onSubmitted: (val) {
                              FocusScope.of(context).unfocus();
                            },
                            maxLines: 1,
                            maxLength: 40,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: Theme.of(context).textTheme.bodyText1,
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              hintText: 'City*',
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(14),
                              counterText: '',
                              counter: null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _pinController,
                          autofocus: false,
                          onSubmitted: (val) {
                            FocusScope.of(context).unfocus();
                          },
                          maxLines: 1,
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp('[a-zA-Z0-9]'),
                                replacementString: '', allow: true),
                          ],
                          style: Theme.of(context).textTheme.bodyText1,
                          onChanged: (val) {},
                          decoration: InputDecoration(
                            hintText: 'PIN Code*',
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            counterText: '',
                            counter: null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: ColorTheme.buttonColor,
              height: 50,
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  if (_validate()) {
                    _userModel = UserModel(
                      fname: widget.userModel.fname,
                      mname: widget.userModel.mname,
                      lname: widget.userModel.lname,
                      gender: widget.userModel.gender,
                      dob: widget.userModel.dob,
                      existingPatient: widget.userModel.existingPatient,
                      familyDoctor: widget.userModel.familyDoctor,
                      mobile: _mobileController.text.toString(),
                      emergencyContact: _EmgrMobileController.text.trim(),
                      email: _emailController.text.trim(),
                      address1: _address1Controller.text.trim(),
                      address2: _address2Controller.text.trim(),
                      city: _cityController.text.trim(),
                      state: _stateController.text.trim(),
                      country: _countryController.text.trim(),
                      pincode: _pinController.text.trim(),
                      isdCode: PreferenceManager.isdCode,
                      profilePic: '',
                    );

                    if (widget.userModel.file != null) {
                      _upload();
                    } else {
                      _register();
                    }
                  }
                },
                child: Center(
                  child: Text(
                    'Next',
                    textScaleFactor: 1.0,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///this method is used to fetch the current location

  _getCurrentLocation() async {
    final position = await _addressService.getCurrentLocation();

    try {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      _getAddressFromLatLng(position);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  ///this method will return the readable address from lat & long

  _getAddressFromLatLng(Position position) async {
    try {
      final place = await _addressService.getAddressFromLatLng(position);
      this.setState(() {
        _countryController.text = place?.country;
        _stateController.text = place?.administrativeArea;
        _cityController.text = place?.locality ?? '';
        _pinController.text = place?.postalCode;
      });
    } catch (e) {
      print(e);
    }
  }

  /// this method will set initial data to ui
  void _initData() async {
    _mobileController.text = PreferenceManager.getMobile();
    setState(() {});
  }

  bool _validate() {
    if (_mobileController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Mobile is mandatory filed.', isError: true);
      return false;
    } else if (_EmgrMobileController.text.toString().trim().isEmpty) {
      Utils.showToast(
          message: 'Emergency mobile number is mandatory filed.',
          isError: true);
      return false;
    } else if (_emailController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Email is mandatory filed.', isError: true);
      return false;
    } else if (!ValidationUtils.validateEmail(
        _emailController.text.toString().trim())) {
      Utils.showToast(message: 'Invalid email Id', isError: true);
      return false;
    } else if (_address1Controller.text.toString().trim().isEmpty) {
      Utils.showToast(
          message: 'Address line 1 is mandatory filed.', isError: true);
      return false;
    } else if (_countryController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Country is mandatory filed.', isError: true);
      return false;
    } else if (_stateController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'State is mandatory filed.', isError: true);
      return false;
    } else if (_cityController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'City is mandatory filed.', isError: true);
      return false;
    }
    // } else if (_pinController.text.toString().trim().isEmpty) {
    //   Utils.showToast(message: 'City is mandatory filed.', isError: true);
    //   return false;
    else {
      return true;
    }
  }

  void _getAccessToken() async {
    Map<String, String> header = {
      "Accept": "application/json",
      "api-token":
          "FkpxpjsdRD-dobMQALDzl7whe-6X83wPie_JgjmNDvDdSzo-upd-TlI8VgLoGcZKCPk",
      "user-email": "anilanilguptaa@gmail.com"
    };

    await MumbaiClinicNetworkCall.getCountryRequest(
      endPoint: 'getaccesstoken',
      header: header,
      context: context,
      onSuccess: (response) {
        accessToken = jsonDecode(response)['auth_token'];
      },
      onError: (error) {
        accessToken = '';
      },
    );
  }

  _getCountryName(String name) {
    setState(() {
      _countryController.text = name;
      _stateController.text = '';
      _cityController.text = '';
    });
  }

  final ImageUploadRepo imageUploadRepo = ImageUploadRepo();

  _upload() async {
    Loader.showProgress();
    final response = await imageUploadRepo.uploadRegisterProfile(
        widget.userModel.file, widget.userModel.mobile);
    Loader.hide();
    if (response != null) {
      _userModel.setProfileName = response;
      _register();
    }
  }

  ///register patient
  _register() async {
    final token = PreferenceManager.getToken();

    //EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.RegisterPatient,
      body: _userModel.toJson(),
      header: Utils.getHeaders(token: token),
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          ResponseModel model = ResponseModel.fromJson(json.decode(response));
          if (model.success == 'true') {
            RegisterModel model = RegisterModel.fromJson(json.decode(response));
            Datum datum = model.data[0];
            PreferenceManager.isLogin(true);
            PreferenceManager.setActiveUserID(datum.patid.toString());
            PreferenceManager.setUserId(datum.patid.toString());
            PreferenceManager.setEmail(datum.email);
            PreferenceManager.setMobile(datum.mobile);
            AppDatabase.db.addUser(datum.toDatabase());
            _getSettings();
            MyApplication.navigateAndClear('/home');
            /* SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
            });*/
          } else {
            Utils.showToast(
                message: 'Registration failed: ${model.error}', isError: true);
          }
        } else {
          Utils.showToast(message: 'Registration failed', isError: true);
        }
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(message: 'Registration failed: $error', isError: true);
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
