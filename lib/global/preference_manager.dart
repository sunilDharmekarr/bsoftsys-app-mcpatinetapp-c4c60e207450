import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/key_name.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/model/selected_user_model.dart';
import 'package:mumbaiclinic/model/urls_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  PreferenceManager._();

  static SharedPreferences _preferences = null;

  static init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static int _specId = 0;

  static String _isd_code;

  static SelectedUser _user = null;

  static int _appointment_id;

  static Appointment _appointment;

  static Url _url;

  static set url(Url url) => _url = url;

  static Url get url => _url;

  static get getappointment_id => _appointment_id;

  static get getAppoint => _appointment;

  static set setAppointment(Appointment appoint) {
    _appointment = appoint;
  }

  static set setappointment_id(int id) {
    _appointment_id = id;
  }

  static String get isdCode {
    return _isd_code;
  }

  static set isdCode(String code) {
    _isd_code = code;
  }

  static int get specializationId {
    return _specId;
  }

  static set specializationId(int id) {
    _specId = id;
  }

  static SelectedUser get selectedUser {
    return _user;
  }

  static set setSelectedUser(SelectedUser u) {
    _user = u;
  }

  static void setUserId(String userId) {
    _preferences.setString(KeyName.USER_ID, userId);
  }

  static String getUserId() {
    return _preferences.getString(KeyName.USER_ID) ?? '';
  }

  static void setUserFamily(String family) {
    _preferences.setString(KeyName.FAMILY, family);
  }

  static String getUserFamily() {
    return _preferences.getString(KeyName.FAMILY) ?? 'null';
  }

  static void isLogin(bool flag) {
    _preferences.setBool(KeyName.IS_LOGIN, flag);
  }

  static bool getLogin() {
    return _preferences.getBool(KeyName.IS_LOGIN) ?? false;
  }

  static void setMobile(String data) {
    _preferences.setString(KeyName.MOBILE, data);
  }

  static String getMobile() {
    return _preferences.getString(KeyName.MOBILE) ?? '';
  }

  static void setEmail(String data) {
    _preferences.setString(KeyName.EMAIL, data);
  }

  static String getEmail() {
    return _preferences.getString(KeyName.EMAIL) ?? '';
  }

  static void setToken(String data) {
    _preferences.setString(KeyName.TOKEN, data);
  }

  static String getToken() {
    return _preferences.getString(KeyName.TOKEN) ?? '';
  }

  static void setActiveUserName(String data) {
    _preferences.setString(KeyName.ACTIVE_USER, data);
  }

  static String getActiveUserName() {
    return _preferences.getString(KeyName.ACTIVE_USER) ?? 'Unknown';
  }

  static void setActiveUserGender(String data) {
    _preferences.setString(KeyName.ACTIVE_USER_G, data);
  }

  static String getActiveUserGender() {
    return _preferences.getString(KeyName.ACTIVE_USER_G) ?? '';
  }

  static void setActiveUserID(String data) {
    _preferences.setString(KeyName.ACTIVE_USER_ID, data);
  }

  static String getActiveUserID() {
    return _preferences.getString(KeyName.ACTIVE_USER_ID) ?? '';
  }

  static void setActiveUserDOB(String data) {
    _preferences.setString(KeyName.ACTIVE_USER_DOB, data);
  }

  static String getActiveUserDOB() {
    return _preferences.getString(KeyName.ACTIVE_USER_DOB) ?? '';
  }

  static void setMinusSize(int data) {
    _preferences.setInt(KeyName.DISPLAY, data);
  }

  static int getMinusSize() {
    return _preferences.getInt(KeyName.DISPLAY) ?? 0;
  }

  static void logout() async {
    bool overlayPref = checkForOverlay();
    _preferences.clear();
    _preferences.setBool(KeyName.IS_LOGIN, false);
    setOverlayPref(overlayPref);
    await AppDatabase.db.deleteUserTable();
  }

  static void setFCMToken(String data) {
    _preferences.setString('fcm_token', data);
  }

  static String getFCMToken() {
    return _preferences.getString('fcm_token') ?? '';
  }

  static String setIsLocationEnabled(bool value) {
    _preferences.setBool(KeyName.IS_LOCATION_ENABLED, value);
  }

  static bool getIsLocationEnabled() {
    return _preferences.getBool(KeyName.IS_LOCATION_ENABLED);
  }

  static String setIsNotificationEnabled(bool value) {
    _preferences.setBool(KeyName.IS_NOTIFICATION_ENABLED, value);
  }

  static bool getIsNotificationEnabled() {
    return _preferences.getBool(KeyName.IS_NOTIFICATION_ENABLED);
  }

  static void setFilePath(String filePath) {
    _preferences.setString(KeyName.FILE_PATH, filePath);
  }

  static String getFilePath() {
    return _preferences.getString(KeyName.FILE_PATH);
  }

  static bool checkForOverlay() {
    return _preferences.getBool(KeyName.OVERLAY_PREF) ?? true;
  }

  static void setOverlayPref(bool pref) {
    _preferences.setBool(KeyName.OVERLAY_PREF, pref);
  }

  static void setRazorPayKey(String key) {
    _preferences.setString(KeyName.RAZOR_KEY, key);
  }

  static String getRazorPayKey() {
    return _preferences.getString(KeyName.RAZOR_KEY) ?? '';
  }
}
