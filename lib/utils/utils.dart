import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/view/bottomsheet/family_members.dart';
import 'package:mumbaiclinic/view/citystatepopup/select_country_screen.dart';
import 'package:mumbaiclinic/view/citystatepopup/state_city_screen.dart';
import 'package:mumbaiclinic/view/dialog/book_appointment_dialog.dart';
import 'package:mumbaiclinic/view/dialog/book_appointment_success_dialog.dart';
import 'package:mumbaiclinic/view/dialog/book_lab_test_success_dialog.dart';
import 'package:mumbaiclinic/view/dialog/single_button_dialog.dart';

import '../view/dialog/custom_dialog.dart';

class Utils {
  static void log(String msg) {
    if (kDebugMode) {
      print("MCM: $msg");
    }
  }

  static Future<bool> isInternetConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('not connected $e');
      return false;
    }
  }

  static showToast({@required String message, bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: /* isError ? Colors.red : */ Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static showCountryPicker(
      BuildContext context, bool isCodeVisible, Function function) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          child: SelectCountryScreen(
            onSelectCountry: function,
            isCodeVisible: isCodeVisible,
          ),
        );
      },
    );
  }

  static showStateCityPicker(
      {@required BuildContext context,
      @required String endponit,
      @required String token,
      @required String searchKey,
      Function onSelected}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          child: StateCityScreen(
            token: token,
            endpoint: endponit,
            searchKey: searchKey,
            onSelected: onSelected,
          ),
        );
      },
    );
  }

  static showFamilyPicker(
      {@required BuildContext context, Function onSelected}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return FamilyMembers(onSelected);
      },
    );
  }

  static showAlertDialog(
      {@required BuildContext context,
      @required String message,
      Function onOK,
      Function onCancel,
      String actionNme = 'Ok',
      String nagetive = 'Cancel',
      bool cancellable = true}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => cancellable,
            child: CustomDialog(
              message: message,
              onCancel: onCancel,
              onOk: onOK,
              actionName: actionNme,
              nagetive: nagetive,
            ),
          );
        });
  }

  static showSingleButtonAlertDialog(
      {@required BuildContext context,
      @required String message,
      Function onClick,
      bool cancellable = true,
      String buttonText = 'OK'}) {
    showDialog(
        context: context,
        barrierDismissible: cancellable,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => cancellable,
            child: SingleButtonDialog(
              message: message,
              onClick: onClick,
              buttonText: buttonText,
            ),
          );
        });
  }

  static showBookAppointmentDialog({
    @required BuildContext context,
    @required Doctor doctor,
    @required ConsulationType type,
    Function onTypeSelect,
    bool follow = false,
    bool fast = false,
  }) {
    showDialog(
        context: context,
        builder: (ctx) {
          return BookAppointmentDialog(
            doctor: doctor,
            type: type,
            onTypeClick: (data, amount, id) {
              Navigator.pop(context);
              onTypeSelect(data, amount, id);
            },
            follow: follow,
            isFast: fast,
          );
        });
  }

  static showAppointmentSuccessDialog(
      BuildContext context, Appointment appointment, Function onAction) {
    showDialog(
      context: context,
      builder: (_) => BookAppointmentSuccessDialog(
        appointment: appointment,
        onClick: () => onAction(),
      ),
    );
  }

  static showLabTestSuccessDialog(
      BuildContext context, LabtestResponse data, Function onAction) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: BookLabTestSuccessDialog(
              data: data,
              onClick: () => onAction(),
            ),
          );
        });
  }

  static getShadow({double shadow = 2, Color color = Colors.black}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.2),
        spreadRadius: 0.8,
        blurRadius: 1,
        offset: Offset(1, 1.5), // changes position of shadow
      ),
    ];
  }

  static String getYears({@required String date}) {
    try {
      print(date);
      DateTime dob = DateTime.parse('${date.replaceAll('T', ' ')}');
      Duration dur = DateTime.now().difference(dob);
      String differenceInYears = (dur.inDays / 365).floor().toString();
      return differenceInYears ?? '';
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Map<String, String> getHeaders({String token}) {
    String username = 'api_user';
    String password = 'MumB@1\$c1Nic#%20';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    print("*********** AUTH **********");
    print("HttpHeaders.authorizationHeader: $basicAuth");
    print("x-access-token: ${PreferenceManager.getToken()}");
    print("*********** AUTH **********");
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: basicAuth,
      'x-access-token': PreferenceManager.getToken() ?? ''
    };
  }

  static Map<String, String> getHeaders1({String token}) {
    String username = 'api_user';
    String password = 'MumB@1\$c1Nic#%20';
    String basicAuth = 'Basic ' + '$username:$password';
    return {
      HttpHeaders.authorizationHeader: basicAuth,
    };
  }

  static String graphDate(DateTime date) {
    return DateFormat('dd MMM yyyy hh:mm').format(date);
  }

  static String parametersDate(DateTime date) {
    return DateFormat('dd-MM-yy').format(date);
  }

  static String getReadableDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String getYYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String getReadableDateTime(DateTime dateTime) {
    return DateFormat('dd MMM, yyyy hh:mm a').format(dateTime);
  }

  static String getReadableTime(DateTime date) {
    try {
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String getReadableAppointmentTime(DateTime date) {
    try {
      return DateFormat('h:mma').format(date);
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String getReadableTimeFromTimeOfDay(TimeOfDay date) {
    try {
      return DateFormat('hh:mm a').format(
          DateTime(DateTime.now().year, 1, 1, date.hour, date.minute, 0));
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String convertTime12TO24hr(TimeOfDay date) {
    try {
      final time = ''; //;
      return DateFormat('hh:mm a').format(
          DateTime(DateTime.now().year, 1, 1, date.hour, date.minute, 0));
    } catch (e) {
      print(e);
      return '';
    }
  }

  static String getServerDate({DateTime dateTime}) {
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime == null ? DateTime.now() : dateTime);
  }

  static Exception error(Response response) {
    if (response.statusCode == 500) {
      return Exception('Server not reachable');
    } else if (response.statusCode == 501) {
      return Exception('Server timeout');
    } else {
      return Exception(Constant.defaultErrorMessage);
    }
  }

  static Exception errorAsString(String error) {
    return Exception(error);
  }

  static Widget getAppBar(String title,
      {Color color = Colors.white, Widget action}) {
    return AppBar(
      centerTitle: false,
      backgroundColor: color,
      title: Text(
        '$title',
        style: Theme.of(MyApplication.navigatorKey.currentContext)
            .appBarTheme
            .textTheme
            .headline1,
      ),
      leading: IconButton(
        onPressed: () {
          MyApplication.pop();
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color:
              Theme.of(MyApplication.navigatorKey.currentContext).primaryColor,
        ),
      ),
      actions: [
        if (action != null) action,
      ],
    );
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
      return Color(int.parse('0x$hexColor'));
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  static String fixNewLines(String text) => const LineSplitter()
      .convert(text)
      .fold<StringBuffer>(
          StringBuffer(), (buffer, line) => buffer..writeln(line.trim()))
      .toString();

  static String formatAmount(double v) {
    if (v == null) return '0';

    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 2;
    return formatter.format(v);
  }

  static void openAppStore() {
    LaunchReview.launch(writeReview: false);
  }
}
