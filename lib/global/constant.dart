class Constant {
  Constant._();

  //error image place holder
  static const String error =
      'https://incident-prevention.com/components/com_easyblog/themes/wireframe/images/placeholder-image.png';
  //base url
  //static const String BASE_URL = 'http://mumbaiclinic.co.in:5004/api/';

  static const String COUNTRY_BASE_URL =
      'https://www.universal-tutorial.com/api/';

  static const double padding = 10;

  //text size
  static const double TITLE_SIZE = 24;
  static const double TITLE_MEDIUM_SIZE = 20;
  static const double BODY_SIZE = 16;

  //text font
  static const BOOK_APPOINTMENT = 'Book Appointments';
  static const MAKE_PAYMENT = 'Make Payment';
  static const TEST_DETAILS = 'Test Details';

  // Message
  static const INTERNET_MSG =
      "No internet connection detected. Please check your internet connection and try again.";
  static const OVERLAY_PERMISSION_MESSAGE =
      "App requires overlay permission to display video calls as full screen";
  static const defaultErrorMessage =
      "Failed to process request. Please try again later.";

  static var appVersionName = "";
  static var appVersionCode = 1;
}

enum ConsulationType {
  Online,
  Clinic,
  Home,
}

enum LoadingState { Loading, Success, Failure }
