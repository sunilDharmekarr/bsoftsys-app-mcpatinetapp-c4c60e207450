import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/screen/home/home_screen.dart';
import 'package:mumbaiclinic/screen/launcher_screen.dart';
import 'package:mumbaiclinic/screen/login/login_screen.dart';
import 'package:mumbaiclinic/screen/video_call/video_call_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/device_util.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

import 'constant/text_fonts.dart';
import 'global/constant.dart';
import 'method_channel/app_version_channel.dart';
import 'method_channel/fcm_message_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PreferenceManager.init();
  await DeviceUtils.init();
  Loader.init();
  RazorPayUtil.get().init();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Constant.appVersionName = await AppVersionChannel.get().getAppVersionName();
  Constant.appVersionCode = await AppVersionChannel.get().getAppVersionCode();
  var message = await FCMMessageChanel.get().getInitialMessage();
  runApp(MumbaiClinicApp(
    hasInitialMessage: message != null,
  ));
}

class MumbaiClinicApp extends StatefulWidget {
  final bool hasInitialMessage;

  MumbaiClinicApp({this.hasInitialMessage = false});

  @override
  _MumbaiClinicAppState createState() =>
      _MumbaiClinicAppState(hasInitialMessage);
}

class _MumbaiClinicAppState extends State<MumbaiClinicApp> {
  bool hasInitialMessage = false;
  final AddressService _addressService = AddressService.instance;

  Map<int, Color> colorCodes = {
    50: Color.fromRGBO(0, 85, 42, .1),
    100: Color.fromRGBO(0, 85, 42, .2),
    200: Color.fromRGBO(0, 85, 42, .3),
    300: Color.fromRGBO(0, 85, 42, .4),
    400: Color.fromRGBO(0, 85, 42, .5),
    500: Color.fromRGBO(0, 85, 42, .6),
    600: Color.fromRGBO(0, 85, 42, .7),
    700: Color.fromRGBO(0, 85, 42, .8),
    800: Color.fromRGBO(0, 85, 42, .9),
    900: Color.fromRGBO(0, 85, 42, 1),
  };

  _MumbaiClinicAppState(this.hasInitialMessage);

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mumbai Clinic',
      navigatorKey: MyApplication.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          canvasColor: ColorTheme.white,
          primarySwatch: MaterialColor(0xff00552A, colorCodes),
          //visualDensity: VisualDensity.adaptivePlatformDensity,
          accentColor: ColorTheme.darkGreen,
          fontFamily: TextFont.poppinsRegular,
          primaryColorDark: Colors.blue,
          appBarTheme: AppBarTheme(
              elevation: 0,
              color: ColorTheme.white,
              textTheme: TextTheme(
                headline1: TextStyle(
                  fontSize: 16,
                  fontFamily: TextFont.poppinsBold,
                  color: ColorTheme.darkGreen,
                ),
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(color: Colors.black)),
          iconTheme: IconThemeData(size: 24),
          textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: AppTextTheme.textSize16,
                fontWeight: FontWeight.w800,
                color: ColorTheme.darkGreen),
            headline2: TextStyle(
                fontSize: AppTextTheme.textSize16,
                fontWeight: FontWeight.normal,
                color: ColorTheme.darkGreen),
            headline3: TextStyle(
                fontSize: AppTextTheme.textSize14,
                fontWeight: FontWeight.normal,
                color: ColorTheme.darkGreen),
            bodyText1: TextStyle(
              fontSize: AppTextTheme.textSize14,
              fontWeight: FontWeight.normal,
              color: ColorTheme.darkGreen,
            ),
            bodyText2: TextStyle(
                fontSize: AppTextTheme.textSize12,
                fontWeight: FontWeight.bold,
                color: ColorTheme.darkGreen),
            subtitle2: TextStyle(
                fontSize: AppTextTheme.textSize12,
                fontWeight: FontWeight.bold,
                color: ColorTheme.darkGreen),
            headline6: TextStyle(
                fontSize: AppTextTheme.textSize16,
                fontWeight: FontWeight.w900,
                color: Colors.grey[800]),
          )),
      initialRoute: 'launcher',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case "launcher":
            return MaterialPageRoute(builder: (context) => LauncherScreen());
          case "/home":
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case "/login":
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case VideoCallScreen.routeName:
            {
              Utils.log("Video Call Args: ${routeSettings.arguments}");
              Map<String, dynamic> args = routeSettings.arguments;
              return MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                        appointmentId: args["appointment_id"].toString(),
                      ));
            }
          default:
            return null;
        }
      },
      builder: (BuildContext context, Widget child) {
        /// make sure that loading can be displayed in front of all other widgets
        return FlutterEasyLoading(child: child);
      },
      home: LauncherScreen(),
    );
  }

  _setCurrentLocation() async {
    _addressService.currentPosition =
        await _addressService.getCurrentLocation();
    _addressService.currentLocation = await _addressService
        .getAddressFromLatLng(await _addressService.getCurrentLocation());
  }
}

class ScreenArguments {
  String appointment_id;
  var role;

  ScreenArguments({this.appointment_id, this.role});
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
