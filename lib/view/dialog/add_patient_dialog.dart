import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/RelationModel.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/repository/user_repository.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/utils/validation_utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

import 'package:mumbaiclinic/view/app_text_field.dart';

class AddPatientDialog extends StatefulWidget {
  @override
  _AddPatientDialogState createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final patientRepo = PatientRepo();
  final TextEditingController _fName = TextEditingController();
  final TextEditingController _mName = TextEditingController();
  final TextEditingController _lName = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String dob = 'DOB*';
  int _gender = 1;
  int relation = 0;
  bool radio = false;
  List<RelationDatum> _relationData = [];
  static const dobFormat = 'dd MMM yyyy';

  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _getInitData();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: AppText.getBoldText(
                    'Add family member', 16, ColorTheme.darkGreen),
              ),
              AppTextField(
                controller: _fName,
                textHint: 'First name*',
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.text,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                      replacementString: '', allow: true),
                ],
              ),
              AppTextField(
                controller: _mName,
                textHint: 'Middle Name',
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.text,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                      replacementString: '', allow: true),
                ],
              ),
              AppTextField(
                controller: _lName,
                textHint: 'Last Name*',
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.text,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                      replacementString: '', allow: true),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                height: 50,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  value: relation,
                  onChanged: (value) {
                    setState(() {
                      relation = value;
                    });
                  },
                  items: _relationData
                      .map(
                        (e) => DropdownMenuItem(
                          child: Text(
                            e.relationName,
                            style: _relationData.indexOf(e) == 0
                                ? Theme.of(context).textTheme.bodyText1
                                : Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .apply(fontFamily: TextFont.poppinsBold),
                          ),
                          value: e.relationId,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        value: _gender,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .apply(fontFamily: TextFont.poppinsBold),
                            ),
                            value: 2,
                          ),
                          DropdownMenuItem(
                              child: Text(
                                'Female',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .apply(fontFamily: TextFont.poppinsBold),
                              ),
                              value: 3),
                          DropdownMenuItem(
                              child: Text(
                                'Other',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .apply(fontFamily: TextFont.poppinsBold),
                              ),
                              value: 4)
                        ],
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '$dob',
                                  style: dob == 'DOB*'
                                      ? Theme.of(context).textTheme.bodyText1
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .apply(
                                              fontFamily: TextFont.poppinsBold),
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
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: AppTextField(
                        controller: _mobile,
                        textHint: 'Mobile*',
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.phone,
                        onSubmit: (value) {},
                        onChanged: (value) {},
                        formatter: [
                          FilteringTextInputFormatter(RegExp('[0-9]'),
                              replacementString: '', allow: true),
                        ],
                      )),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: AppTextField(
                        controller: _email,
                        textHint: 'Email*',
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        onSubmit: (value) {},
                        onChanged: (value) {},
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        radio = !radio;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          radio
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: ColorTheme.buttonColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: AppText.getLightText(
                            'I am lawfully authorized to provide the above information.',
                            14,
                            ColorTheme.darkGreen,
                            maxLine: 5,
                            textAlign: TextAlign.justify)),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 40,
                margin:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: AppButton(
                  text: 'ADD',
                  style: AppTextTheme.textTheme14Bold,
                  onClick: () {
                    if (_validate()) _addUser();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getInitData() async {
    Loader.showProgress();
    final res = await _userRepository.getRelationship();
    _relationData.add(RelationDatum(
        relationId: 0, relationName: 'Relation with family head*'));

    if (res != null) {
      _relationData.addAll(res.relationData);
    }
    Loader.hide();
    setState(() {});
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      helpText: "",
      context: context,
      initialDate:
          dob == 'DOB*' ? DateTime.now() : DateFormat(dobFormat).parse(dob),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dob = DateFormat(dobFormat).format(picked);
      });
    }
  }

  String _getGender() {
    switch (_gender) {
      case 2:
        return 'M';
      case 3:
        return 'F';
      default:
        return 'O';
    }
  }

  bool _validate() {
    if (_fName.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'First name is empty');
      return false;
    } else if (_lName.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Last  name is empty');
      return false;
    } else if (_gender == 1) {
      Utils.showToast(message: 'Please select gender.');
      return false;
    } else if (relation == 0) {
      Utils.showToast(message: 'Please select relationship with family head.');
      return false;
    } else if (_mobile.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Mobile number is empty.');
      return false;
    } else if (_email.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Email address is empty.');
      return false;
    } else if (!ValidationUtils.validateEmail(_email.text.toString().trim())) {
      Utils.showToast(message: 'Invalid email address', isError: true);
      return false;
    } else if (dob == 'DOB*') {
      Utils.showToast(message: 'Please select date of birth.');
      return false;
    } else if (!radio) {
      Utils.showToast(message: 'Please accept T&C.');
      return false;
    } else {
      return true;
    }
  }

  void _addUser() async {
    Loader.showProgress();
    Map body = {
      "entered_patid": PreferenceManager.getUserId(),
      "first_name": "${_fName.text.toString().trim()}",
      "middle_name": "${_mName.text.toString().trim()}",
      "last_name": "${_lName.text.toString().trim()}",
      "relation_id": relation,
      "mobile": "${_mobile.text.toString().trim()}",
      "email": "${_email.text.toString().trim()}",
      "gender": "${_getGender()}",
      "dob": "$dob",
      "height": "0",
      "weight": "0",
      "bg_id": 0,
      "existing_patient": "false",
      "profile_pic": ""
    };
    final response = await _userRepository.addFamilyMember(body);
    Loader.hide();
    //TODO
    if (response.error != null) {
      Utils.showToast(message: response.error, isError: true);
    } else if (response.data.isEmpty) {
      Utils.showToast(message: Constant.defaultErrorMessage, isError: true);
    } else {
      AppDatabase.db.addUser(Datum(
        patid:
            response.data.firstWhere((element) => element.patId != null).patId,
        firstName: _fName.text.toString().trim(),
        middleName: _mName.text.toString().trim(),
        lastName: _lName.text.toString().trim(),
        relationId: relation,
        mobile: _mobile.text.toString().trim(),
        sex: _getGender(),
        dob: DateFormat(dobFormat).parse(dob).toIso8601String(),
        email: _email.text.toString().trim(),
        height: '0',
        weight: '0',
        bgId: '0',
        profile_pic: '',
      ).toDatabase());
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop(true);
    }
  }
}
