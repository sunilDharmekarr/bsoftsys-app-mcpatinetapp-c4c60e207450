import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as IDB;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/BloodGroupModel.dart';
import 'package:mumbaiclinic/model/RelationModel.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/image_upload_repo.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/repository/user_repository.dart';
import 'package:mumbaiclinic/screen/home/home_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/utils/validation_utils.dart';
import 'package:mumbaiclinic/view/app_text_field.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/dialog/edit_address_dialog.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:path_provider/path_provider.dart';

class UserFormScreen extends StatefulWidget {
  final bool isEdit;
  final String pId;
  final bool profile;
  final bool quickAdd;
  UserFormScreen(this.isEdit,
      {this.pId, this.profile = false, this.quickAdd = false});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final patientRepo = PatientRepo();
  static const dobFormat = 'dd MMM yyyy';
  File /* _image, */ _compressed;
  final UserRepository _userRepository = UserRepository();
  final ImageUploadRepo _imageUploadRepo = ImageUploadRepo();

  final picker = ImagePicker();
  final TextEditingController _fName = TextEditingController();
  final TextEditingController _mName = TextEditingController();
  final TextEditingController _lName = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();

  String dob = 'DOB*';
  bool radio = false;
  int relation = 0;
  int bloodGrId = 0;
  int _gender = 1;
  String profilePic = "";

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      radio = true;
      loadData();
      _loadAddresses();
    } else {
      _getInitData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: widget.profile
            ? Text(
                'Profile',
                style: Theme.of(context).appBarTheme.textTheme.headline1,
              )
            : Text(
                widget.isEdit ? "Edit profile" : 'Add family member',
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
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: _compressed == null
                          ? Container(
                              child: profilePic.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        profilePic,
                                        headers: Utils.getHeaders(),
                                      ))
                                  : Container(),
                            )
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
              const SizedBox(
                height: 10,
              ),
              AppTextField(
                controller: _fName,
                textHint: 'First Name*',
                enable: !widget.profile,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.text,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                      replacementString: '', allow: true),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              AppTextField(
                controller: _mName,
                textHint: 'Middle Name',
                enable: !widget.profile,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.text,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[a-zA-Z]'),
                      replacementString: '', allow: true),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              AppTextField(
                controller: _lName,
                textHint: 'Last Name*',
                enable: !widget.profile,
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
                height: 10,
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
              const SizedBox(
                height: 10,
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
              AppTextField(
                controller: _mobile,
                textHint: 'Mobile*',
                enable: !widget.isEdit,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.phone,
                onSubmit: (value) {},
                onChanged: (value) {},
                formatter: [
                  FilteringTextInputFormatter(RegExp('[0-9]'),
                      replacementString: '', allow: true),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              AppTextField(
                controller: _email,
                textHint: 'Email*',
                enable: !widget.profile,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.emailAddress,
                onSubmit: (value) {},
                onChanged: (value) {},
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
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
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$dob',
                            style: dob == 'DOB*'
                                ? Theme.of(context).textTheme.bodyText1
                                : Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .apply(fontFamily: TextFont.poppinsBold),
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
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _height,
                      textHint: 'Height',
                      enable: !widget.profile,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      onSubmit: (value) {},
                      onChanged: (value) {},
                      suffixText: 'in CM',
                      formatter: [
                        FilteringTextInputFormatter(RegExp('[0-9.]'),
                            replacementString: '', allow: true),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _weight,
                      enable: !widget.profile,
                      textHint: 'Weight',
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.phone,
                      onSubmit: (value) {},
                      onChanged: (value) {},
                      suffixText: "in Kg",
                      formatter: [
                        FilteringTextInputFormatter(RegExp('[0-9.]'),
                            replacementString: '', allow: true),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 80,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: _bloodGroups
                      .map(
                        (e) => InkWell(
                          onTap: () {
                            setState(() {
                              bloodGrId = e.bgId;
                            });
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bloodGrId == e.bgId
                                  ? ColorTheme.buttonColor
                                  : ColorTheme.lightGreenOpacity,
                              boxShadow: Utils.getShadow(),
                            ),
                            child: AppText.getRegularText(
                                e.bgName,
                                12,
                                bloodGrId == e.bgId
                                    ? ColorTheme.white
                                    : ColorTheme.darkGreen),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              widget.isEdit
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText.getLightText(
                                  "Addresses", 13, ColorTheme.darkGreen,
                                  maxLine: 1),
                              IconButton(
                                onPressed: () async {
                                  bool isUpdated = await showDialog(
                                      context: context,
                                      builder: (_) => EditAddressDialog());
                                  if (isUpdated != null && isUpdated) {
                                    _loadAddresses();
                                  }
                                },
                                icon: Image.asset(
                                  AppAssets.add,
                                  width: 24,
                                  height: 24,
                                  color: ColorTheme.iconColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorTheme.lightGreenOpacity,
                            ),
                            constraints: BoxConstraints(maxHeight: 120),
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, index) {
                                  var address = _addresses[index];
                                  return InkWell(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppText.getLightText(
                                                address.type, 12, Colors.grey,
                                                maxLine: 1),
                                            AppText.getRegularText(
                                                _mapAddress(address),
                                                14,
                                                ColorTheme.darkGreen,
                                                maxline: 12),
                                          ]),
                                    ),
                                    onTap: () async {
                                      bool isUpdated = await showDialog(
                                          context: context,
                                          builder: (_) => EditAddressDialog(
                                                address: address,
                                              ));
                                      if (isUpdated != null && isUpdated) {
                                        _loadAddresses();
                                      }
                                    },
                                  );
                                },
                                separatorBuilder: (_, index) => Container(
                                      width: 1,
                                      color: Colors.black26,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                itemCount: _addresses.length),
                          )
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                                  'I herby declare that I am lawfully authorized to provide The above Information on behalf of the owner of the information.',
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
              if (!widget.profile)
                Container(
                  width: double.infinity,
                  height: 40,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: AppButton(
                    text: widget.isEdit ? 'Update' : 'Create',
                    style: AppTextTheme.textTheme14Bold,
                    onClick: () {
                      if (_validate()) {
                        if (widget.isEdit) {
                          if (_compressed == null) {
                            _editUser();
                          } else {
                            _updateImage();
                          }
                        } else {
                          if (_compressed != null) {
                            _uploadImage();
                          } else {
                            _addUser();
                          }
                        }
                      }
                    },
                  ),
                ),
              const SizedBox(
                height: 30,
              ),
            ]),
          )
        ],
      ),
    );
  }

  ///get gender
  _getGender() {
    switch (_gender) {
      case 2:
        return 'M';
      case 3:
        return 'F';
      case 4:
        return 'O';
    }
  }

  _getGenderId(String data) {
    switch (data) {
      case "M":
        return 2;
      case "F":
        return 3;
      case 'O':
        return 4;
      default:
        return 1;
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
      Utils.showToast(message: 'Select gender.');
      return false;
    } else if (relation == 0) {
      Utils.showToast(message: 'Select relationship with Family head.');
      return false;
    } else if (_mobile.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Mobile number is empty.');
      return false;
    } else if (_email.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Email ID is empty.');
      return false;
    } else if (!ValidationUtils.validateEmail(_email.text.toString().trim())) {
      Utils.showToast(message: 'Invalid email Id', isError: true);
      return false;
    } else if (dob == 'DOB*') {
      Utils.showToast(message: 'Select DOB.');
      return false;
    } else if (!radio) {
      Utils.showToast(message: 'Accept T&C.');
      return false;
    } else {
      return true;
    }
  }

  /// using this method for getting date
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
    final pickedFile = await picker.pickImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200);

    setState(() {});

    Loader.showProgress();
    if (pickedFile != null) {
      try {
        print("image path: ${pickedFile.path}");
        File sourceFile = File(pickedFile.path);
        if (sourceFile.existsSync()) {
          IDB.Image mImageFile =
              IDB.decodeImage(File(pickedFile.path).readAsBytesSync());

          if (mImageFile != null) {
            Directory tempFolder = await getTemporaryDirectory();
            if (!await tempFolder.exists()) {
              tempFolder.create(recursive: true);
            }
            final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
            final outFile = File('${tempFolder.path}/$fileName')
              ..writeAsBytesSync(
                  IDB.encodeJpg(
                    mImageFile,
                    quality: 80,
                  ),
                  flush: true);
            if (outFile.existsSync()) {
              setState(() {
                _compressed = outFile;
              });
            }
            //To check if the file size is compressed or not.
            print("compressed path: ${_compressed.path}");
          } else {
            Utils.showToast(
                message:
                    'Failed to process image, please select an image from local storage on your device');
          }
        } else {
          Utils.showToast(
              message:
                  'Failed to read image file. Please select an image from local storage on your device');
        }
      } catch (e) {
        print(e);
        Utils.showToast(
            message:
                'Failed to process image. Please select an image from local storage on your device');
      }
      Loader.hide();
    }
  }

  _uploadImage() async {
    Loader.showProgress();
    final response = await _imageUploadRepo.uploadRegisterProfile(
        _compressed, _mobile.text.toString().trim());
    Loader.hide();
    if (response != null) {
      profilePic = response;
      _addUser();
    }
  }

  _updateImage() async {
    Loader.showProgress();
    final response = await _imageUploadRepo.setPatProfileImage(
        _compressed, _mobile.text.toString().trim());
    Loader.hide();
    if (response != null) {
      profilePic = response;
      _editUser();
    }
  }

  List<BloodGroup> _bloodGroups = [];
  List<RelationDatum> _relationData = [];

  _getInitData() async {
    Loader.showProgress();
    final data = await _userRepository.getBloodGroup();
    final res = await _userRepository.getRelationship();
    Loader.hide();
    _relationData.add(RelationDatum(
        relationId: 0, relationName: 'Relation with family head*'));
    if (data != null) {
      _bloodGroups.addAll(data.bloodGroups);
    }

    if (res != null) {
      _relationData.addAll(res.relationData);
    }

    if (widget.isEdit) {
      relation = userData.relationId == 0
          ? 0
          : _relationData
              .firstWhere(
                  (element) => element.relationId == userData.relationId)
              .relationId;
      bloodGrId = userData.bgId == 0
          ? 0
          : _bloodGroups
              .firstWhere((element) => element.bgId == userData.bgId)
              .bgId;
    }

    setState(() {});
  }

  Datum userData;
  loadData() async {
    userData = await AppDatabase.db.getUser(widget.pId) as Datum;
    print(userData.toDatabase());
    if (userData != null) {
      _fName.text = userData.firstName;
      _mName.text = userData.middleName;
      _lName.text = userData.lastName;
      _height.text = userData.height;
      _weight.text = userData.weight;
      _mobile.text = userData.mobile;
      _email.text = userData.email;

      /* print("ANAMOY: ADDRESS: ${userData.address1}, ${userData.address2}, "
          "${userData.city}, ${userData.state}, ${userData.country}, ${userData.pincode}");
      _address1Controller.text = userData.address1;
      _address2Controller.text = userData.address2;
      _cityController.text = userData.city;
      _stateController.text = userData.state;
      _countryController.text = userData.country;
      _pinController.text = userData.pincode; */

      profilePic = userData.profile_pic;
      dob = DateFormat(dobFormat).format(DateTime.parse(userData.dob));
      _gender = _getGenderId(userData.sex);
      _getInitData();
    }
  }

  var _addresses = <AddressDatum>[];
  _loadAddresses() async {
    Loader.showProgress();
    var addresses = <AddressDatum>[];
    try {
      final tempData = await AppDatabase.db.getUser(widget.pId) as Datum;
      if (tempData != null) {
        addresses.add(AddressDatum(
          id: 0,
          patient: tempData.patid,
          typeId: 0,
          type: 'Primary',
          address1: tempData.address1,
          address2: tempData.address2,
          city: tempData.city,
          state: tempData.state,
          country: tempData.country,
          pinCode: tempData.pincode,
          landmark: '',
        ));
      }
      AddressModel addressModel =
          await patientRepo.getAddresses(patientId: widget.pId);
      if (addressModel != null && addressModel.success == 'true') {
        addresses.addAll(addressModel.addresses);
      }
    } catch (_) {}
    setState(() {
      _addresses = addresses;
    });
    Loader.hide();
  }

  _addUser() async {
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
      "height": "${_height.text.toString().trim()}",
      "weight": "${_weight.text.toString().trim()}",
      "bg_id": bloodGrId,
      "existing_patient": "false",
      "profile_pic": "$profilePic"
    };
    final response = await _userRepository.addFamilyMember(body);

    if (response.error != null) {
      Loader.hide();
      Utils.showToast(message: response.error, isError: true);
    } else if (response.data.isEmpty) {
      Loader.hide();
      Utils.showToast(message: Constant.defaultErrorMessage, isError: true);
    } else {
      await _reloadFamilyMembers();
      Loader.hide();
      /* await AppDatabase.db.addUser(Datum(
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
        height: _height.text.toString().trim(),
        weight: _weight.text.toString().trim(),
        bgId: bloodGrId,
        profile_pic: profilePic,
      ).toDatabase()); */
      if (widget.quickAdd) {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop(true);
      } else {
        var years =
            DateTime.now().difference(DateFormat(dobFormat).parse(dob)).inDays /
                365;
        Utils.showSingleButtonAlertDialog(
          context: context,
          message: years > 12
              ? response.data
                      ?.firstWhere((element) => (element.displayMsg != null &&
                          element.displayMsg.isNotEmpty))
                      ?.displayMsg
                      ?.toString() ??
                  'User has been successfully added'
              : 'User has been successfully added',
          onClick: () {
            PreferenceManager.setUserId(response.data
                ?.firstWhere((element) => element.patId != null)
                ?.patId
                ?.toString());
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        );
      }
    }
  }

  _editUser() async {
    Loader.showProgress();
    Map body = {
      "entered_patid": PreferenceManager.getUserId(),
      "patid": widget.pId,
      "first_name": "${_fName.text.toString().trim()}",
      "middle_name": "${_mName.text.toString().trim()}",
      "last_name": "${_lName.text.toString().trim()}",
      "relation_id": relation,
      "mobile": "${_mobile.text.toString().trim()}",
      "email": "${_email.text.toString().trim()}",
      "gender": "${_getGender()}",
      "dob": "$dob",
      "height": "${_height.text.toString().trim()}",
      "weight": "${_weight.text.toString().trim()}",
      "bg_id": bloodGrId,
      "profile_pic": _compressed == null ? '' : "$profilePic"
    };
    final response = await _userRepository.editFamilyMember(body);

    if (response == null) {
      await _reloadFamilyMembers();
      Loader.hide();
      Utils.showSingleButtonAlertDialog(
          context: context,
          message:
              '${_fName.text} ${_mName.text} ${_lName.text} Updated successfully.',
          onClick: () {
            MyApplication.navigateAndClear('/home');
          });
    } else {
      Loader.hide();
      Utils.showToast(
        message: response,
        isError: true,
      );
    }
  }

  _reloadFamilyMembers() async {
    await MumbaiClinicNetworkCall.getRequest(
      endPoint: APIConfig.getFamily + PreferenceManager.getUserId(),
      context: context,
      header: Utils.getHeaders(),
      onSuccess: (response) {
        try {
          if (response != null) {
            final model = familyMemberModelFromJson(response);
            if (model.success == 'true') {
              AppDatabase.db.addBatchUsers(model.familyMember);
              PreferenceManager.setUserFamily(response);
            } else {
              Utils.showToast(
                  message: 'Failed to load family data: ${model.error}');
            }
          } else {
            Utils.showToast(message: 'Failed to load family data');
          }
        } catch (e) {
          print(e);
          Utils.showToast(message: 'Failed to load family data');
        }
      },
    );
  }

  String _mapAddress(AddressDatum address) {
    StringBuffer buffer = StringBuffer();
    if (address.address1 != null && address.address1.isNotEmpty) {
      buffer.writeln(address.address1);
    }
    if (address.address2 != null && address.address2.isNotEmpty) {
      buffer.writeln(address.address2);
    }
    if (address.city != null && address.city.isNotEmpty) {
      buffer.writeln("City: ${address.city}".trim());
    }
    if (address.state != null && address.state.isNotEmpty) {
      buffer.writeln("State: ${address.state}".trim());
    }
    if (address.country != null && address.country.isNotEmpty) {
      buffer.writeln("Country: ${address.country}".trim());
    }
    if (address.pinCode != null && address.pinCode.isNotEmpty) {
      buffer.writeln("PIN: ${address.pinCode}".trim());
    }
    if (address.landmark != null && address.landmark.isNotEmpty) {
      buffer.writeln("Landmark: ${address.landmark}".trim());
    }

    if (buffer.isEmpty)
      return 'No data\nTap to edit address';
    else
      return buffer.toString().trim();
  }
}
