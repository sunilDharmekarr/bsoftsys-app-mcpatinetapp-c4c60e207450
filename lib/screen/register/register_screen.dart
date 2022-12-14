import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as IDB;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
import 'package:mumbaiclinic/screen/register/contact_info_screen.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fName = TextEditingController();
  final TextEditingController _mName = TextEditingController();
  final TextEditingController _lName = TextEditingController();
  final TextEditingController _familyDoc = TextEditingController();

  File _image, _compressed;
  final _picker = ImagePicker();

  String _dob = 'DOB*';
  bool _isVisited = true;
  bool _isSkipped = false;
  bool _isChecked = false;
  int _value = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fName.dispose();
    _lName.dispose();
    _mName.dispose();
    _familyDoc.dispose();
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
        margin: const EdgeInsets.only(top: 4),
        width: double.infinity,
        height: double.infinity,
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
                        children: <Widget>[
                          const SizedBox(
                            width: 10,
                          ),
                          TextView(
                            text: 'Personal Details',
                            color: ColorTheme.darkGreen,
                            style: AppTextTheme.textTheme16ExtraBold,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: _image == null
                                  ? Container()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(_compressed)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  _showImagePicker();
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorTheme.buttonColor,
                                  ),
                                  child: Image.asset(
                                    AppAssets.take_pic,
                                    color: ColorTheme.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _fName,
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                                replacementString: '', allow: true),
                          ],
                          textCapitalization: TextCapitalization.words,
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
                            hintText: 'First Name*',
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
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                                replacementString: '', allow: true),
                          ],
                          controller: _mName,
                          textCapitalization: TextCapitalization.words,
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
                            hintText: 'Middle Name',
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
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                                replacementString: '', allow: true),
                          ],
                          controller: _lName,
                          textCapitalization: TextCapitalization.words,
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
                            hintText: 'Last Name*',
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
                        width: double.infinity,
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: DropdownButton(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down),
                          underline: Container(),
                          value: _value,
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                'Gender*',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Male',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              value: 2,
                            ),
                            DropdownMenuItem(
                                child: Text(
                                  'Female',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                value: 3),
                            DropdownMenuItem(
                                child: Text('Other',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                value: 4)
                          ],
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                            });
                          },
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
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _showDatePicker();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Text(
                                    '$_dob',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    _showDatePicker();
                                  },
                                  icon: Image.asset(
                                    AppAssets.calander,
                                    width: 24,
                                    height: 24,
                                    color: ColorTheme.iconColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            )
                          ],
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
                          color: ColorTheme.lightGreenOpacity,
                          boxShadow: Utils.getShadow(),
                        ),
                        child: TextField(
                          controller: _familyDoc,
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
                            hintText: 'Family Doctor',
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                                value: _isVisited,
                                onChanged: (checked) {
                                  setState(() {
                                    _isVisited = checked;
                                  });
                                }),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: TextView(
                                text: 'I have visited Mumbai Clinic before',
                                style: AppTextTheme.textTheme14Regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text:
                                        'By signing up, I confirm that I have read and agree to the ',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  TextSpan(
                                      text: 'terms and conditions ',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MumbaiWebView(
                                                title: 'Terms and conditions',
                                                url:
                                                    'https://mumbaiclinic.net/pages/terms-condition.html',
                                              ),
                                            ),
                                          );
                                        }),
                                  TextSpan(
                                    text: 'and ',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  TextSpan(
                                      text: 'privacy policy',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MumbaiWebView(
                                                title: 'Privacy Policy',
                                                url:
                                                    'https://mumbaiclinic.net/pages/privacy-policy.html',
                                              ),
                                            ),
                                          );
                                        }),
                                ]),
                                textScaleFactor: 1.0,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
              padding: EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                          side: BorderSide(color: Colors.white),
                          value: _isSkipped,
                          onChanged: (value) {
                            setState(() {
                              _isSkipped = value;
                            });
                          }),
                      TextView(
                        text: 'Skip to register',
                        style: AppTextTheme.textTheme14Regular,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      if (_validate()) {
                        UserModel userModel = UserModel(
                          mobile: PreferenceManager.getMobile(),
                          fname: _fName.text.trim(),
                          mname: _mName.text.trim(),
                          lname: _lName.text.trim(),
                          gender: _getGender(),
                          dob: _dob,
                          familyDoctor: _familyDoc.text.trim() ?? ' ',
                          existingPatient: _isVisited ? '0' : '1',
                          file: _compressed,
                        );
                        if (_isSkipped) {
                          _registerUser(userModel);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContactInfoScreen(
                                userModel,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Center(
                      child: Text(
                        _isSkipped ? 'REGISTER' : 'Add contact info',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ///get gender
  _getGender() {
    switch (_value) {
      case 2:
        return 'M';
      case 3:
        return 'F';
      case 4:
        return 'O';
    }
  }

  /// using this method for getting date
  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      helpText: "",
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dob = DateFormat('dd MMM yyyy').format(picked);
      });
    }
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
              child: AppText.getButtonText('Gallery', 16, Colors.black, () {
                Navigator.of(context).pop();
                getImage(2);
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
    final pickedFile = await _picker.pickImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });

    print("stat: ${await _image.stat()}");
    Loader.showProgress();
    IDB.Image mImageFile = IDB.decodeImage(_image.readAsBytesSync());
    _compressed = File(pickedFile.path)
      ..writeAsBytesSync(IDB.encodeJpg(
        mImageFile,
        quality: 80,
      ));
    Loader.hide();

    //To check if the file size is compressed or not.
    print("compressed path: ${_compressed.path}");
    print("compressed stat: ${await _compressed.stat()}");
  }

  ///this methods will return true if all fields are filled.

  bool _validate() {
    if (_fName.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please enter first name.', isError: true);
      return false;
    } else if (_lName.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please enter last name.', isError: true);
      return false;
    } else if (_value == 1) {
      Utils.showToast(message: 'Please select gender.', isError: true);
      return false;
    } else if (_dob == 'DOB*') {
      Utils.showToast(message: 'Please select date of birth.', isError: true);
      return false;
    } else if (!_isChecked) {
      Utils.showToast(
          message: 'Please accept terms and conditions.', isError: true);
      return false;
    } else {
      return true;
    }
  }

  _registerUser(UserModel userModel) {
    if (userModel.file != null) {
      _upload(userModel);
    } else {
      _register(userModel);
    }
  }

  _upload(UserModel userModel) async {
    Loader.showProgress();
    final ImageUploadRepo imageUploadRepo = ImageUploadRepo();
    final response = await imageUploadRepo.uploadRegisterProfile(
        userModel.file, userModel.mobile);
    Loader.hide();
    if (response != null) {
      userModel.setProfileName = response;
      _register(userModel);
    }
  }

  ///register patient
  _register(UserModel userModel) async {
    final token = PreferenceManager.getToken();

    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.RegisterPatient,
      body: userModel.toJson(),
      header: Utils.getHeaders(token: token),
      onSuccess: (response) {
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
            if (datum.displayMessage != null &&
                datum.displayMessage.isNotEmpty) {
              Utils.showSingleButtonAlertDialog(
                  context: context,
                  message: datum.displayMessage,
                  cancellable: false,
                  onClick: () {
                    MyApplication.navigateAndClear('/home');
                  });
              Utils.showToast(message: datum.displayMessage);
            } else {
              MyApplication.navigateAndClear('/home');
            }
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
