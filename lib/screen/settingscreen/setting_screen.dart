import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool notification = false;
  bool location = false;

  @override
  void initState() {
    super.initState();
    notification = PreferenceManager.getIsNotificationEnabled();
    location = PreferenceManager.getIsLocationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        update();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Settings',
            style: Theme.of(context).appBarTheme.textTheme.headline1,
          ),
          leading: IconButton(
            onPressed: update,
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
              SwitchListTile(
                value: notification,
                onChanged: (data) {
                  notification = data;
                  PreferenceManager.setIsNotificationEnabled(data);
                  setState(() {});
                },
                title: TextView(
                  text: "Notification",
                  style: AppTextTheme.textTheme14Light,
                ),
              ),
              SwitchListTile(
                value: location,
                onChanged: (data) {
                  location = data;
                  PreferenceManager.setIsLocationEnabled(data);
                  setState(() {});
                },
                title: TextView(
                  text: "Location",
                  style: AppTextTheme.textTheme14Light,
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: AppButton(
                  buttonTextColor: ColorTheme.white,
                  color: ColorTheme.buttonColor,
                  text: 'Clear Data',
                  onClick: clearData,
                  style: TextStyle(),
                ),
              ),
            ]))
          ],
        ),
      ),
    );
  }

  Future update() async {
    Loader.showProgress();
    var body = {
      "patid": PreferenceManager.getUserId().toString(),
      "is_notification_enable": notification.toString(),
      "is_location_enable": location.toString(),
    };
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.manageSettings,
      body: body,
      header: Utils.getHeaders(),
      onSuccess: (response) {
        if (response != null) {
          ResponseModel responseModel =
              ResponseModel.fromJson(json.decode(response));
          if (responseModel.success != 'true') {
            Utils.showToast(
                message: 'Update failed: ${responseModel.error}',
                isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to update data', isError: true);
        }
      },
      onError: (error) {
        Utils.showToast(message: 'Update failed: $error', isError: true);
      },
    );
    Loader.hide();
    Navigator.of(context).pop();
  }

  Future clearData() async {
    Loader.showProgress();
    var filePath = PreferenceManager.getFilePath();
    if (filePath != null && filePath.isNotEmpty) {
      try {
        var directory = Directory(PreferenceManager.getFilePath());
        await directory.delete(recursive: true);
      } catch (error) {
        if (error.toString().contains('FileSystemException: Deletion failed'))
          Utils.showToast(message: 'Nothing to clear!');
        else
          Utils.showToast(message: 'Error: ${error.toString()}');
      }
    } else {
      Utils.showToast(message: 'Nothing to clear!');
    }
    Loader.hide();
    //Navigator.of(context).pop();
  }
}
