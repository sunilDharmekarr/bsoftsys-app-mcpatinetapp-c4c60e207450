import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/app_upgrade_model.dart';
import 'package:mumbaiclinic/screen/login/login_screen.dart';

import '../global/constant.dart';
import '../utils/utils.dart';

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen>
    with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController _controller;
  var _updateCheckDone = false;
  var _timerDone = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    animation = new CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.forward();
    _checkUpdate();
    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() async {
    _timer = Timer.periodic(Duration(milliseconds: 2500), (timer) async {
      timer.cancel();
      if (_updateCheckDone) {
        _nextPage(); //Update check complete, continue
      } else {
        //Waiting for update check
        //Set flag for deferred navigation
        _timerDone = true;
      }
    });
  }

  void _checkUpdate() async {
    var isContinue = true;
    if (await Utils.isInternetConnected()) {
      var platformId = 0;
      if (Platform.isAndroid)
        platformId = 1;
      else if (Platform.isIOS) platformId = 2;

      var body = {
        //"current_version": "1.0.0",
        "current_version": Constant.appVersionName != null &&
                Constant.appVersionName.isNotEmpty
            ? "Version: ${Constant.appVersionName}"
            : "",
        "platform_id": '$platformId',
      };
      await MumbaiClinicNetworkCall.postRequest(
        endPoint: APIConfig.checkAppUpgrade,
        body: body,
        header: Utils.getHeaders(),
        onSuccess: (response) {
          if (response != null) {
            AppUpgradeModel appUpgradeModel =
                AppUpgradeModel.fromJson(json.decode(response));
            if (appUpgradeModel.success == 'true') {
              if (appUpgradeModel.payload.isNotEmpty) {
                if (_timer != null) _timer.cancel();
                _showUpgradeDialog(
                    appUpgradeModel.payload[0].version,
                    appUpgradeModel.payload[0].releaseNotes,
                    appUpgradeModel.payload[0].releaseType == 'M');
                isContinue = false;
              }
            } else if (kDebugMode) {
              log('Update check failed: ${appUpgradeModel.error}');
            }
          } else if (kDebugMode) {
            log('Update check failed');
          }
        },
        onError: (error) {
          if (kDebugMode) {
            log('Update check failed: $error');
          }
        },
      );
    }

    //Continue if no updates
    if (isContinue) {
      if (_timerDone) {
        //Load next page if animation has finished
        _nextPage();
      } else {
        //Set flag for deferred navigation on animation end
        _updateCheckDone = true;
      }
    }
  }

  void _nextPage() async {
    if (await Utils.isInternetConnected()) {
      Navigator.pop(context);
      if (PreferenceManager.getLogin()) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } else {
      Utils.showSingleButtonAlertDialog(
          context: context,
          message: Constant.INTERNET_MSG,
          onClick: () {
            if (Platform.isIOS) {
              Navigator.pop(context);
            } else {
              SystemNavigator.pop(animated: true);
            }
          });
    }
  }

  void _showUpgradeDialog(
      String version, String releaseNotes, bool isMandatory) {
    if (isMandatory) {
      Utils.showSingleButtonAlertDialog(
          context: context,
          cancellable: false,
          buttonText: 'Upgrade now',
          onClick: () {
            Utils.openAppStore();
            Navigator.pop(context);
          },
          message:
              'A new version of the app ($version) is available for download. You must update the app to continue.\n\nRelease notes: $releaseNotes');
    } else {
      Utils.showAlertDialog(
          context: context,
          cancellable: false,
          actionNme: 'Update',
          nagetive: 'Ignore',
          onOK: () {
            Utils.openAppStore();
            Navigator.pop(context);
          },
          onCancel: () => _nextPage(),
          message:
              'A new version of the app ($version) is available for download. Please update the app to enjoy the latest features.\n\nRelease notes: $releaseNotes');
    }
  }

  @override
  Widget build(BuildContext context) {
    _setDisplayData();
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: animation,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(
                          AppAssets.main_screen_logo,
                          height: 80,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Text(
                        'Live Longer Live Healthier',
                        textScaleFactor: 1.0,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Container(
                        child: Text(
                          'winner of best clinic \n competition 2019',
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        margin: const EdgeInsets.all(10),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  void _setDisplayData() {
    var data = MediaQuery.of(context).size.width;
    if (data < 380) {
      PreferenceManager.setMinusSize(2);
    } else {
      PreferenceManager.setMinusSize(0);
    }
  }
}
