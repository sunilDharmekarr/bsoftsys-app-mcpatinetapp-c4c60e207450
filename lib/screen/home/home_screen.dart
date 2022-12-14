import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart' as rtc;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/method_channel/fcm_message_channel.dart';
import 'package:mumbaiclinic/model/chatUrlModel.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/model/menu_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/repository/call_back_repo.dart';
import 'package:mumbaiclinic/screen/alert/alert_screen.dart';
import 'package:mumbaiclinic/screen/helpsupport/help_support_screen.dart';
import 'package:mumbaiclinic/screen/home/counsult_now_fragment.dart';
import 'package:mumbaiclinic/screen/home/home_fragment.dart';
import 'package:mumbaiclinic/screen/home/my_health_fragment.dart';
import 'package:mumbaiclinic/screen/settingscreen/setting_screen.dart';
import 'package:mumbaiclinic/screen/transaction/transaction_screen.dart';
import 'package:mumbaiclinic/screen/video_call/pick_up_screen.dart';
import 'package:mumbaiclinic/screen/video_call/video_call_screen.dart';
import 'package:mumbaiclinic/screen/wallet/my_wallet_screen.dart';
import 'package:mumbaiclinic/screen/webChat/webChat.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/html_screen.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:mumbaiclinic/view/menu/navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String imageData;
  bool dataLoaded = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final callBackRepo = CallBackRepo();
  int selectedIndex = 0;
  String alertCount = '0';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    FCMMessageChanel.get().init((data) {
      onFCMMessageReceived(data);
    });
    _handleInitialMessage();
    _initFCM();
    _getFamilyMembers();
  }

  _handleInitialMessage() async {
    Future.delayed(Duration(milliseconds: 300), () async {
      bool checkPermission = true;
      var message = await FCMMessageChanel.get().getInitialMessage();
      if (message != null) {
        checkPermission = false;
        onFCMMessageReceived(message);
      } else {
        RemoteMessage message =
            await FirebaseMessaging.instance.getInitialMessage();
        if (message != null) {
          checkPermission = false;
          message.data["notificationType"] =
              message.notification.android.channelId;
          onFCMMessageReceived(message.data);
        }
      }
      FCMMessageChanel.get().removeSavedData();
      if (checkPermission && PreferenceManager.checkForOverlay()) {
        bool hasOverlayPermission =
            await FCMMessageChanel.get().hasOverlayPermission();
        if (!hasOverlayPermission) {
          Utils.showAlertDialog(
              context: context,
              message: Constant.OVERLAY_PERMISSION_MESSAGE,
              onOK: () {
                PreferenceManager.setOverlayPref(false);
                FCMMessageChanel.get().getOverlayPermission();
              },
              onCancel: () {
                PreferenceManager.setOverlayPref(false);
              },
              cancellable: false);
        }
      }
    });
  }

  void onFCMMessageReceived(dynamic data) {
    print("onFCMMessageReceived: $data");
    onHandleFCMData(data);
  }

  // Future<String> downLoadImage(String url, String fileName) async {
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   PreferenceManager.setFilePath('${directory.path}');
  //   final String filePath = '${directory.path}/$fileName';
  //   print("the path is : $filePath");
  //   final http.Response response = await http.get(Uri.parse(url));
  //   final File file = File(filePath);
  //   await file.writeAsBytes(response.bodyBytes);
  //   return filePath;
  // }

  void navigateToChat(String appointmentid) async {
    Loader.showProgress();
    String _url;
    var body = {
      "appointment_id": appointmentid,
    };
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.getChatURL,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        if (response != null) {
          ResponseModel responseModel =
              ResponseModel.fromJson(json.decode(response));
          if (responseModel.success == 'true') {
            ChatUrlModel chatUrlModel =
                ChatUrlModel.fromJson(json.decode(response));
            _url = chatUrlModel.payload[0].chatUrl;
            Loader.hide();
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => WebChat('Chat', _url, appointmentid)));
          } else {
            Utils.showToast(
                message: 'Failed to load chat: ${responseModel.error}',
                isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to load chat', isError: true);
        }
      },
      onError: (error) {
        Utils.showToast(message: 'Failed to load chat: $error', isError: true);
      },
    );
    Loader.hide();
  }

  @override
  void dispose() {
    FCMMessageChanel.get().removeMessageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 6),
          child: Image.asset(
            AppAssets.header_logo,
            height: 26,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if (!_scaffoldKey.currentState.isDrawerOpen)
              _scaffoldKey.currentState.openDrawer();
          },
          icon: Image.asset(
            AppAssets.menu_icon,
            height: 24,
            width: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  _navigateToAlert();
                },
                icon: Image.asset(
                  AppAssets.notifications,
                  width: 20,
                  height: 20,
                ),
              ),
              if (alertCount != '0')
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        '$alertCount',
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: setView(),
      drawer: NavigationDrawer(
        onMenuClick: (MenuModel model) {
          _handleClick(model);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          setView();
        },
        unselectedLabelStyle: AppTextTheme.textTheme10Light
          ..apply(color: ColorTheme.darkGreen.withOpacity(0.4)),
        selectedLabelStyle: AppTextTheme.textTheme10Light
            .apply(color: ColorTheme.darkGreen.withOpacity(1)),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              AppAssets.home,
              width: 24,
              height: 24,
            ),
            label: "Home",
            /* title: Text('Home',
                textScaleFactor: 1.0, style: AppTextTheme.textTheme12Bold),*/
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              AppAssets.contact_us,
              width: 24,
              height: 24,
            ),
            icon: Opacity(
              opacity: 0.5,
              child: Image.asset(
                AppAssets.contact_us,
                width: 24,
                height: 24,
              ),
            ),
            label: 'Contact Us',
            /* title: Text(
              'Consult Now',
              textScaleFactor: 1.0,
              style: AppTextTheme.textTheme12Bold,
            ),*/
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AppAssets.my_health,
              width: 24,
              height: 24,
            ),
            label: 'My Health',
            /* title: Text(
              'My Health',
              textScaleFactor: 1.0,
              style: AppTextTheme.textTheme12Bold,
            ),*/
          )
        ],
      ),
    );
  }

  setView() {
    switch (selectedIndex) {
      case 0:
        return HomeFragment(
            (count) => setState(() {
                  alertCount = count.toString();
                  if (count > 99) {
                    alertCount = '99+';
                  }
                }),
            int.parse(alertCount.split('+')[0]));
      case 1:
        return ConsultNowFragment();
      case 2:
        return MyHealthFragment();
    }
  }

  _handleClick(MenuModel model) {
    Navigator.pop(context);
    switch (model.menuClick) {
      case 1:
        _navigate(TransactionScreen());
        break;
      case 2:
        _navigate(MyWalletScreen());
        break;
      case 3:
        _navigate(HtmlScreen(
          callBackType: CallBackType.GeneralEnquiry,
          url: '${PreferenceManager.url.aboutusUrl}',
          title: 'About Mumbai Clinic',
          buttonText: 'Click here to know more about Mumbai Clinic',
        ));
        break;
      case 4:
        _navigate(HtmlScreen(
          callBackType: CallBackType.GeneralEnquiry,
          url: '${PreferenceManager.url.termsandconditionUrl}',
          title: 'Terms and Conditions',
          buttonText: 'Click here to know more about Mumbai Clinic',
          visible: false,
        ));
        break;
      case 5:
        _navigate(HtmlScreen(
          callBackType: CallBackType.GeneralEnquiry,
          url: '${PreferenceManager.url.privacypolicyUrl}',
          title: 'Privacy Policy',
          buttonText: 'Click here to know more about Mumbai Clinic',
          visible: false,
        ));

        break;
      case 6:
        _navigate(HelpSupportScreen());
        break;
      case 7:
        _navigate(SettingScreen());
        break;
      case 8:
        Utils.showAlertDialog(
            context: context,
            message: 'Do you want to logout the session.',
            onOK: () {
              Loader.showProgress();
              Future.delayed(Duration(seconds: 1), _logOut);
            },
            actionNme: 'Logout');

        break;
    }
  }

  _logOut() {
    Loader.hide();
    PreferenceManager.logout();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  _navigate(screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  _getFamilyMembers() async {
    var pid = PreferenceManager.getUserId();
    Loader.showProgress();
    final data = await callBackRepo.getScreenUrls();
    try {
      final key = await callBackRepo.getRazorPayKey();

      if (kDebugMode) {
        print("___Razor_Key__ $key");
      }

      if (key != null) {
        RazorPayUtil.key = key;

        PreferenceManager.setRazorPayKey(key);

        print("ID_KEY" + key.toString());
      }
    } catch (e) {
      print(e.toString());
    }
    await MumbaiClinicNetworkCall.getRequest(
      endPoint: APIConfig.getFamily + pid,
      context: context,
      header: Utils.getHeaders(),
      onSuccess: (response) {
        Loader.hide();
        try {
          if (response != null) {
            final model = familyMemberModelFromJson(response);
            AppDatabase.db.addBatchUsers(model.familyMember);
            PreferenceManager.setUserFamily(response);
          }
        } catch (e) {
          print(e);
        }
      },
      onError: (error) {
        Loader.hide();
      },
    );
    setState(() {});
  }

  Future<dynamic> onHandleFCMData(dynamic message) async {
    String appointmentId = (message['cdata'] ?? message["body"])
        .toString()
        .split('|')[0]
        .toString();
    String notificationType = message["notificationType"] ?? "generic";
    print("onHandleFCMData: appointmentId: $appointmentId");
    print("onHandleFCMData: notificationType: $notificationType");
    if (notificationType == "chat") {
      navigateToChat(appointmentId);
    } else if (notificationType == "video_call") {
      bool answer = message["callResponse"] == "true";
      if (!answer) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PickUpScreen(
              fromForeground: true,
              doctorName: (message['cdata'] ?? message["body"])
                  .toString()
                  .split('|')[1]
                  .replaceAll('%20', ' '),
              appointmentID: appointmentId,
              imageUrl: message["image"],
            ),
          ),
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, VideoCallScreen.routeName, (route) => false,
            arguments: {
              "appointment_id": appointmentId,
              "role": rtc.ClientRole.Broadcaster,
            }
            // ScreenArguments(
            //   appointment_id: appointmentId,
            //   role: rtc.ClientRole.Broadcaster,
            // ),
            );
      }
    } else if (notificationType == "generic") {
      _navigateToAlert();
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => WebChat(
      //           "",
      //           appointmentId,
      //           "",
      //         )));
    }
  }

  _navigateToAlert() async {
    final result = await Navigator.push(
        context, CupertinoPageRoute(builder: (_) => MyAlertScreen()));

    if (result != null) {
      setState(() {
        alertCount = result.toString();
      });
    }
  }

  _initFCM() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message != null) {
        message.data["notificationType"] =
            message.notification.android.channelId;
        onFCMMessageReceived(message.data);
      }
    });
    try {
      _firebaseMessaging.getToken().then((value) {
        Utils.log("Main Token generated:  $value");
      });
    } catch (e) {
      print("Error in getting token: $e");
    }
  }
}
