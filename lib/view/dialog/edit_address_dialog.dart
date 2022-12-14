import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class EditAddressDialog extends StatefulWidget {
  final AddressDatum address;
  final int patient;

  EditAddressDialog({this.address, this.patient});

  @override
  _EditAddressDialogState createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  final patientRepo = PatientRepo();
  var _addressTypes = <AddressTypeDatum>[];
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final AddressService _addressService = AddressService.instance;

  var accessToken = '';
  String _pickedAddressType;
  Placemark _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _getAccessToken();
    _getCurrentLocation();
    if (widget.address != null) {
      _address1Controller.text = widget.address.address1 ?? '';
      _areaController.text = widget.address.address2 ?? '';
      if (_isNonPrimaryEdit()) {
        _landmarkController.text = widget.address.landmark ?? '';
      }
      _countryController.text = widget.address.country ?? '';
      _stateController.text = widget.address.state ?? '';
      _cityController.text = widget.address.city ?? '';
      _pinController.text = widget.address.pinCode ?? '';
      _pickedAddressType = widget.address.type;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      //key: UniqueKey(),
      backgroundColor: Colors.transparent,
      elevation: 6.0,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: AppText.getBoldText(
                        widget.address != null ? 'Edit address' : 'Add address',
                        16,
                        ColorTheme.darkGreen),
                  ),
                  _currentLocation == null
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextView(
                                text: 'Location',
                                style: TextStyle(
                                    fontSize: AppTextTheme.textSize14,
                                    color: ColorTheme.darkGreen,
                                    fontFamily: TextFont.poppinsLight),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: ColorTheme.darkGreen),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                var text1 = _currentLocation.thoroughfare;
                                if (text1 != null && text1.isNotEmpty) {
                                  var text2 = _currentLocation.subThoroughfare;
                                  if (text2 != null && text2.isNotEmpty) {
                                    text1 = "$text1, $text2";
                                  }
                                  _address1Controller.text = text1;
                                } else {
                                  _address1Controller.text = '';
                                }
                                text1 = _currentLocation.subLocality;
                                if (text1 != null && text1.isNotEmpty) {
                                  _areaController.text = text1;
                                } else {
                                  _areaController.text = '';
                                }
                                text1 = _currentLocation.locality;
                                if (text1 != null && text1.isNotEmpty) {
                                  _cityController.text = text1;
                                } else {
                                  _cityController.text = '';
                                }
                                text1 = _currentLocation.administrativeArea;
                                if (text1 != null && text1.isNotEmpty) {
                                  _stateController.text = text1;
                                } else {
                                  _stateController.text = '';
                                }
                                text1 = _currentLocation.country;
                                if (text1 != null && text1.isNotEmpty) {
                                  _countryController.text = text1;
                                } else {
                                  _countryController.text = '';
                                }
                                text1 = _currentLocation.postalCode;
                                if (text1 != null && text1.isNotEmpty) {
                                  _pinController.text = text1;
                                } else {
                                  _pinController.text = '';
                                }
                                _landmarkController.text = '';
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextView(
                                  text: 'Use location',
                                  style: TextStyle(
                                      fontSize: AppTextTheme.textSize14,
                                      color: ColorTheme.darkGreen,
                                      fontFamily: TextFont.poppinsLight),
                                ),
                                Image.asset(
                                  AppAssets.location,
                                  width: 16,
                                  height: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              if (widget.address == null || widget.address.id > 0)
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorTheme.lightGreenOpacity,
                    boxShadow: Utils.getShadow(),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyText1,
                    underline: Container(
                      height: 0,
                      color: ColorTheme.darkGreen,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        _pickedAddressType = newValue;
                      });
                    },
                    hint: AppText.getLightText(
                        'Select address type', 14, ColorTheme.darkGreen),
                    value: _pickedAddressType,
                    items: _addressTypes
                        .where((element) => element.id > 0)
                        .map((e) => DropdownMenuItem(
                              child: Text(e.name),
                              value: e.name,
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.lightGreenOpacity,
                  boxShadow: Utils.getShadow(),
                ),
                child: TextField(
                  controller: _address1Controller,
                  autofocus: false,
                  onSubmitted: (val) {
                    FocusScope.of(context).unfocus();
                  },
                  maxLines: 1,
                  maxLength: 100,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
                    hintText: 'Address Line 1*',
                    hintStyle: Theme.of(context).textTheme.bodyText1,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                    counterText: '',
                    counter: null,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.lightGreenOpacity,
                  boxShadow: Utils.getShadow(),
                ),
                child: TextField(
                  controller: _areaController,
                  autofocus: false,
                  onSubmitted: (val) {
                    FocusScope.of(context).unfocus();
                  },
                  maxLines: 1,
                  maxLength: 100,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodyText1,
                  onChanged: (val) {},
                  decoration: InputDecoration(
                    hintText: 'Area',
                    hintStyle: Theme.of(context).textTheme.bodyText1,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                    counterText: '',
                    counter: null,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (widget.address == null || _isNonPrimaryEdit())
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorTheme.lightGreenOpacity,
                    boxShadow: Utils.getShadow(),
                  ),
                  child: TextField(
                    controller: _landmarkController,
                    autofocus: false,
                    onSubmitted: (val) {
                      FocusScope.of(context).unfocus();
                    },
                    maxLines: 1,
                    maxLength: 100,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.bodyText1,
                    onChanged: (val) {},
                    decoration: InputDecoration(
                      hintText: 'Landmark',
                      hintStyle: Theme.of(context).textTheme.bodyText1,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      counterText: '',
                      counter: null,
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorTheme.lightGreenOpacity,
                  boxShadow: Utils.getShadow(),
                ),
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Utils.showCountryPicker(context, false, _getCountryName);
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
                      contentPadding: const EdgeInsets.all(10),
                      counterText: '',
                      counter: null,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorTheme.lightGreenOpacity,
                  boxShadow: Utils.getShadow(),
                ),
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_countryController.text.isEmpty) {
                      Utils.showToast(
                          message: 'Select country first', isError: true);
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
                      contentPadding: const EdgeInsets.all(10),
                      counterText: '',
                      counter: null,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorTheme.lightGreenOpacity,
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
                      contentPadding: const EdgeInsets.all(10),
                      counterText: '',
                      counter: null,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
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
                    contentPadding: const EdgeInsets.all(10),
                    counterText: '',
                    counter: null,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isNonPrimaryEdit())
                    IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          size: 32,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.all(4),
                        onPressed: () async {
                          String error = await patientRepo
                              .deleteAddress(widget.address.id);
                          if (error != null) {
                            Utils.showAlertDialog(
                                context: context, message: error);
                          } else {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop(true);
                          }
                        }),
                  Expanded(
                      child: Container(
                    height: 40,
                    child: AppButton(
                      text: widget.address != null ? 'Update' : 'Add',
                      buttonTextColor: Colors.white,
                      color: ColorTheme.buttonColor,
                      onClick: () async {
                        if (_validate()) {
                          if (widget.address != null &&
                              widget.address.id == 0) {
                            /* Utils.showToast(
                                message: "TODO: Primary address update"); */
                            var userData = await AppDatabase.db
                                .getUser("${widget.address.patient}") as Datum;
                            userData.address1 = _address1Controller.text.trim();
                            userData.address2 = _areaController.text.trim();
                            userData.city = _cityController.text.trim();
                            userData.state = _stateController.text.trim();
                            userData.country = _countryController.text.trim();
                            userData.pincode = _pinController.text.trim();
                            Loader.showProgress();
                            String error =
                                await patientRepo.editPatientDetails(userData);
                            Loader.hide();
                            if (error != null) {
                              Utils.showAlertDialog(
                                  context: context, message: error);
                            } else {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            AddressDatum editedAddress = AddressDatum(
                              id: widget.address == null
                                  ? 0
                                  : widget.address.id,
                              typeId: _mapAddressType(_pickedAddressType),
                              type: _pickedAddressType,
                              patient: widget.address == null
                                  ? (widget.patient == null
                                      ? int.parse(PreferenceManager.getUserId())
                                      : widget.patient)
                                  : widget.address.patient,
                              address1: _address1Controller.text.trim(),
                              address2: _areaController.text.trim(),
                              city: _cityController.text.trim(),
                              state: _stateController.text.trim(),
                              country: _countryController.text.trim(),
                              pinCode: _pinController.text.trim(),
                              landmark: _landmarkController.text.trim(),
                            );
                            Loader.showProgress();
                            String error =
                                await patientRepo.editAddAddress(editedAddress);
                            Loader.hide();
                            if (error != null) {
                              Utils.showAlertDialog(
                                  context: context, message: error);
                            } else {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop(true);
                            }
                          }
                        }
                      },
                      style: TextStyle(fontSize: 16),
                    ),
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validate() {
    if (_address1Controller.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please enter address line-1.', isError: true);
      return false;
    } else if (_address1Controller.text.toString().trim().length > 100) {
      Utils.showToast(
          message: 'Address line-1 cannot have more than 100 characters.',
          isError: true);
      return false;
    } else if (_areaController.text.toString().trim().length > 100) {
      Utils.showToast(
          message: 'Area field cannot have more than 100 characters.',
          isError: true);
      return false;
    } else if (_landmarkController.text.toString().trim().length > 100) {
      Utils.showToast(
          message: 'Landmark field cannot have more than 100 characters.',
          isError: true);
      return false;
    } else if (_countryController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please select country.', isError: true);
      return false;
    } else if (_stateController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please select state.', isError: true);
      return false;
    } else if (_cityController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please enter city.', isError: true);
      return false;
    } else if (_pinController.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Please enter PIN code.', isError: true);
      return false;
    } else if (_pickedAddressType == null) {
      Utils.showToast(message: 'Please select address type', isError: true);
      return false;
    } else {
      var typeName = _mapAddressType(_pickedAddressType);
      if (typeName == null) {
        Utils.showToast(message: "Please select address type");
        return false;
      }
    }
    return true;
  }

  _loadAddresses() async {
    Loader.showProgress();
    try {
      AddressTypeModel model = await patientRepo.getAddressTypes();
      setState(() {
        _addressTypes.clear();
        _addressTypes.add(AddressTypeDatum(id: 0, name: 'Primary'));
        _addressTypes.addAll(model.addressTypes);
      });
    } catch (_) {
      log("Failed to load address types");
    }
    Loader.hide();
  }

  int _mapAddressType(String name) {
    return _addressTypes
        .firstWhere((element) => element.name == name,
            orElse: () => AddressTypeDatum(id: 0, name: ''))
        .id;
  }

  _getCurrentLocation() async {
    try {
      final position = await _addressService.getCurrentLocation();
      if (position.latitude != 0.0 || position.longitude != 0.0) {
        final place = await _addressService.getAddressFromLatLng(position);
        if (place.thoroughfare.isNotEmpty ||
            place.locality.isNotEmpty ||
            place.subLocality.isNotEmpty ||
            place.administrativeArea.isNotEmpty ||
            place.country.isNotEmpty ||
            place.postalCode.isNotEmpty) {
          setState(() {
            _currentLocation = place;
          });
        }
      }
    } catch (e) {
      print(e);
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

  bool _isNonPrimaryEdit() {
    return widget.address != null && widget.address.id > 0;
  }
}
