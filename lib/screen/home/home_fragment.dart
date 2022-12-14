import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/PackagesModel.dart';
import 'package:mumbaiclinic/model/alert_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/alert_repo.dart';
import 'package:mumbaiclinic/repository/package_repository.dart';
import 'package:mumbaiclinic/screen/alert/alert_screen.dart';
import 'package:mumbaiclinic/screen/bookappointment/book_appointment.dart';
import 'package:mumbaiclinic/screen/login/login_screen.dart';
import 'package:mumbaiclinic/screen/emr/mediacal_emr_screen.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/screen/ordermedicaltest/select_lab_screen.dart';
import 'package:mumbaiclinic/screen/ordertest/order_test.dart';
import 'package:mumbaiclinic/screen/packagedetail/package_detail_screen.dart';
import 'package:mumbaiclinic/screen/vital/my_vital_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/cell/home_button_view.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/dialog/select_member_dialog.dart';
import 'package:mumbaiclinic/view/html_screen.dart';

class HomeFragment extends StatefulWidget {
  final Function(int count) onAlert;
  int count = 0;
  HomeFragment(this.onAlert, [this.count]);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  var screen = null;

  final repo = PackageRepository();
  final AlertRepo _alertRepo = AlertRepo();

  Timer _timer;

  List<Alert> alert = [];

  List<String> menus = [
    AppAssets.Health,
    AppAssets.packages,
    AppAssets.offers,
  ];

  String username = '';
  String gender = '';
  String age = '';

  @override
  void initState() {
    super.initState();
    if (widget.count == 0) {
      alert.clear();
    }
    _loadData();
    _gePackageData();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () => _loadFamilyMembers,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: FittedBox(
                            child: Text(
                              'Hi $username ($gender/$age)',
                              textScaleFactor: 1.0,
                              style: AppTextTheme.textThemeNameLabel,
                            ),
                          ),
                        ),
                        Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'how can we help you?'.toUpperCase(),
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return SelectMemberDialog(
                                selectionType: SelectionType.chooseMember,
                                onSelected: (_) {
                                  _loadData();
                                },
                              );
                            });
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image.asset(
                                  AppAssets.change_member,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                'Change Member',
                                textScaleFactor: 1.0,
                                style: AppTextTheme.textTheme12Light,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              alert.length == 0
                  ? Container()
                  : Container(
                      width: double.infinity,
                      height: 90,
                      color: Colors.transparent,
                      child: _getReminder(),
                    ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.book_appointment,
                        title: 'Book\nAppointment',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          screen = BookAppointment(
                            isFastAppointment: false,
                          );
                          _navigate();
                        },
                      ),
                    ),
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.fast_appointment,
                        title: 'Fast\nAppointment',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          screen = BookAppointment(
                            isFastAppointment: true,
                          );
                          _navigate();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.order_tests,
                        title: 'Order Tests',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          screen = OrderTestScreen(); // SelectLabScreen();
                          _navigate();
                        },
                      ),
                    ),
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.my_medical_reports,
                        title: 'Medical\nReports(EMR)',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => MedicalEMRScreen()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.vitals,
                        title: 'Vitals',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          screen = MyVitalScreen();
                          _navigate();
                        },
                      ),
                    ),
                    Expanded(
                      child: MenuItemView(
                        icon: AppAssets.my_appointments,
                        title: 'My\nAppointments',
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        onClick: () {
                          screen = MyAppointmentScreen();
                          _navigate();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              /* const SizedBox(
                height: 10,
              ),
             Row(
                children: <Widget>[
                  Expanded(
                    child: MenuItemView(
                      icon: AppAssets.home_concierge,
                      title: 'Covid Concierge\nfor home quarantine',
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorTheme.lightGreenOpacity,
                        boxShadow: Utils.getShadow(),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(AppAssets.Covid_button_bg)),
                      ),
                      onClick: () {
    
                      },
                    ),
                  ),
                  Expanded(
                    child: MenuItemView(
                      icon: AppAssets.post_covid_care,
                      title: 'Post\nCovid care',
                      decoration: BoxDecoration(
                        color: ColorTheme.lightGreenOpacity,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                              AppAssets.Covid_button_bg,
                            )),
                        boxShadow: Utils.getShadow(),
                      ),
                      onClick: () {
                       // screen =  HtmlScreen(url: '${PreferenceManager.url.}',title: 'Home Care',buttonText: 'Request call back to know more',);
                       // _navigate();
                      },
                    ),
                  ),
                ],
              ),*/
              if (packageData.length > 0)
                Container(
                  height: 80,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  color: Colors.transparent,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: packageData.length,
                    itemBuilder: (cntx, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => PakageDetailScreen(
                                  packageData[index].packageId,
                                  packageData[index].packageImageFile)));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  packageData[index].packageImageFile,
                                  fit: BoxFit.fill,
                                  headers: Utils.getHeaders(),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: AppText.getLightText(
                                        packageData[index].packageName,
                                        12,
                                        ColorTheme.white,
                                        maxLine: 2),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MenuItemView(
                      icon: AppAssets.home_care,
                      title: 'Home Care',
                      decoration: BoxDecoration(
                        color: ColorTheme.lightGreenOpacity,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: Utils.getShadow(),
                      ),
                      onClick: () {
                        screen = HtmlScreen(
                          callBackType: CallBackType.HomeCare,
                          url: '${PreferenceManager.url.homecareUrl}',
                          title: 'Home Care',
                          buttonText: 'Request call back to know more',
                        );
                        _navigate();
                      },
                    ),
                  ),
                  Expanded(
                    child: MenuItemView(
                      icon: AppAssets.adult_immunization,
                      title: 'Adult\nImmunization',
                      decoration: BoxDecoration(
                        color: ColorTheme.lightGreenOpacity,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: Utils.getShadow(),
                      ),
                      onClick: () {
                        screen = HtmlScreen(
                          callBackType: CallBackType.immunization,
                          url: '${PreferenceManager.url.immunizationUrl}',
                          title: 'Adult Immunization',
                          buttonText: 'Request call back',
                        );
                        _navigate();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  screen = HtmlScreen(
                    callBackType: CallBackType.PlanSurgery,
                    url: '${PreferenceManager.url.plansurgeryUrl}',
                    title: 'Plan A Surgery',
                    buttonText: 'Request call back From our team',
                  );
                  _navigate();
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: Utils.getShadow(),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(AppAssets.plan_a_surgery))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  screen = HtmlScreen(
                    callBackType: CallBackType.VIPConcierge,
                    url: '${PreferenceManager.url.vipconciergeUrl}',
                    title: 'VIP Concierge',
                    buttonText: 'Request call back From our team',
                  );
                  _navigate();
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(AppAssets.VIP_button),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///get alert
  _getReminder() {
    return CarouselSlider(
      options: CarouselOptions(
        scrollDirection: Axis.horizontal,
        height: 80,
        viewportFraction: 1.0,
        autoPlay: alert.length > 1,
        enableInfiniteScroll: true,
      ),
      items: alert.map((e) {
        return GestureDetector(
          onTap: () {
            screen = MyAlertScreen();
            _navigate();
          },
          child: Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorTheme.lightGreenOpacity,
              borderRadius: BorderRadius.circular(12),
              boxShadow: Utils.getShadow(),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 70,
                  width: 30,
                  child: Center(
                    child: Image.asset(
                      AppAssets.alert_red,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.0,
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${Utils.getReadableDateTime(e.alertDate)}\n',
                          style: TextStyle(
                              color: ColorTheme.darkGreen,
                              fontSize: AppTextTheme.textSize15,
                              fontFamily: TextFont.poppinsBold),
                        ),
                        TextSpan(
                          text: e.alertDetails,
                          style: TextStyle(
                              color: ColorTheme.darkRed,
                              fontSize: AppTextTheme.textSize13,
                              fontFamily: TextFont.poppinsLight),
                        )
                      ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  ///change the login ui and password

  _loadData() async {
    await _loadFamilyMembers();
    if (mounted) {
      _timer = Timer.periodic(Duration(seconds: 8), (timer) {
        _getAlert();
      });
    }
  }

  _loadFamilyMembers() async {
    Datum model = await AppDatabase.db.getUser(PreferenceManager.getUserId());
    if (model != null) {
      setState(() {
        username = model.fullName;
        gender = model.sex.toUpperCase();
        var date = model.dob;
        age = Utils.getYears(date: date);
      });
    }
  }

  _navigate() async {
    final result = await Navigator.push(
        context, CupertinoPageRoute(builder: (_) => screen));

    if (result != null) {
      widget.onAlert(result);
      _getAlert();
    }
  }

  _getAlert() async {
    alert.clear();
    final model = await _alertRepo.getAlertData();
    if (model != null) {
      alert = model.alert.where((element) => !element.isRead).toList();
      widget.onAlert(alert.length);
      setState(() {});
    } else if (model == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    }
  }

  List<PackageData> packageData = [];

  _gePackageData() async {
    packageData.clear();
    final data = await repo.getPackages();
    if (data != null) {
      packageData = data.packageData;
    }
    setState(() {});
  }
}
