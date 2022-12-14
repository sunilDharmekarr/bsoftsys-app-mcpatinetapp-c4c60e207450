import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/rtc_engine.dart' as rtc;
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/create_appointment.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/myappointment_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/datetimescreen/date_time_screen.dart';
import 'package:mumbaiclinic/screen/home/home_screen.dart';
import 'package:mumbaiclinic/screen/payment/make_payment_screen.dart';
import 'package:mumbaiclinic/screen/video_call/video_call_screen.dart';
import 'package:mumbaiclinic/screen/view_prescription_screen.dart';
import 'package:mumbaiclinic/screen/webChat/webChat.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/cancel_dialog.dart';
import 'package:mumbaiclinic/view/dialog/resechedul_appointment.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class MyAppointmentScreen extends StatefulWidget {
  @override
  _MyAppointmentScreenState createState() => _MyAppointmentScreenState();
}

class _MyAppointmentScreenState extends State<MyAppointmentScreen> {
  List<Appointment> _appointment = [];
  Doctor _selectedDoctor = null;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _getAppointment();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Appointments',
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      //On WillPopScope is used here to override the OS back button.
      //The user will land on this(My Appointment) screen either from home page or from appointment booking screen(date_time_screen.dart)
      //or from the make_payment_screen. After booking appointment or making payment all routes are destroyed,
      //so we navigate the user back to home screen by using push method, instead of pop(which closes app as previous routes are destroyed).

      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          return true;
        },
        child: Container(
          color: ColorTheme.white,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: error
                      ? Center(
                          child:
                              AppText.getBoldText('No Data.', 14, Colors.grey),
                        )
                      : null),
              SliverList(
                delegate: SliverChildListDelegate(
                  _appointment
                      .map((e) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: ColorTheme.lightGreenOpacity,
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    TextView(
                                      text: e.status,
                                      color: _getColor(e.status),
                                      style: TextStyle(
                                        fontSize: AppTextTheme.textSize12,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: TextView(
                                        text: e.chiefComplaint,
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        color: ColorTheme.darkGreen,
                                        style: TextStyle(
                                          fontSize: AppTextTheme.textSize12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: InkWell(
                                        onTap: () {
                                          _shareAppointment(e);
                                        },
                                        child: Icon(
                                          Icons.share,
                                          color: ColorTheme.lightGreen,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      AppAssets.book_appointment,
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: TextView(
                                        text: Utils.getReadableDate(
                                                e.appointmentDate) +
                                            ' | ' +
                                            Utils.getReadableTime(
                                                e.appointmentDate),
                                        color: ColorTheme.darkGreen,
                                        style: TextStyle(
                                            fontSize: AppTextTheme.textSize14),
                                      ),
                                    ),
                                    Container(
                                      child: FittedBox(
                                        child: AppText.getLightText(
                                          e.appointmentType,
                                          13,
                                          ColorTheme.darkGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    AppText.getLightText(
                                        e.doctor, 14, ColorTheme.darkGreen),
                                    Expanded(
                                        child: Container(
                                      alignment: Alignment.centerRight,
                                      child: AppText.getLightText(
                                          ' Appointment ID:${e.appointmentId}',
                                          14,
                                          ColorTheme.darkGreen),
                                    ))
                                  ],
                                ),
                                if (e.status
                                    .toLowerCase()
                                    .contains('Pending confirm'.toLowerCase()))
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      AppButton(
                                        color: ColorTheme.buttonColor,
                                        buttonTextColor: ColorTheme.white,
                                        onClick: () => _cancelApt(e),
                                        style: TextStyle(
                                          fontSize: AppTextTheme.textSize12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        text: 'Cancel',
                                      ),
                                      AppButton(
                                        color: ColorTheme.buttonColor,
                                        buttonTextColor: ColorTheme.white,
                                        onClick: () => _rescheduleApt(e),
                                        style: TextStyle(
                                          fontSize: AppTextTheme.textSize12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        text: 'Reschedule  ',
                                      ),
                                      e.amountPayable != 0.0
                                          ? AppButton(
                                              color: ColorTheme.buttonColor,
                                              buttonTextColor: ColorTheme.white,
                                              onClick: () {
                                                print(
                                                    "Price: ${e.amountPayable}");
                                                String appointmentType;
                                                if (e.appointmentType ==
                                                    'Video Consult')
                                                  appointmentType = '1';
                                                if (e.appointmentType ==
                                                    'Clinic Consult')
                                                  appointmentType = '2';
                                                if (e.appointmentType ==
                                                    'Home Visit')
                                                  appointmentType = '3';
                                                Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (_) =>
                                                        MakePaymentScreen(
                                                      CreateAppointment(
                                                        patid:
                                                            e.patid.toString(),
                                                        docId: e.doctorId
                                                            .toString(),
                                                        amount: double.parse(e
                                                                .amountPayable
                                                                .toString())
                                                            .toStringAsFixed(0),
                                                        slotId: 0,
                                                        appointmentType:
                                                            appointmentType,
                                                        appointmentDate: e
                                                            .appointmentDate
                                                            .toString(),
                                                      ),
                                                      Doctor(
                                                        doctorId: e.doctorId,
                                                        name: e.doctor,
                                                        specializationName: e
                                                            .doctorSpecialization,
                                                      ),
                                                      follow: false,
                                                      isFast: false,
                                                      isAlreadyBooked: true,
                                                      appointmentId: e
                                                          .appointmentId
                                                          .toString(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    AppTextTheme.textSize12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              text:
                                                  'Pay ${double.parse(e.amountPayable.toString()).toStringAsFixed(0)}',
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: e.status.toLowerCase().contains(
                                              'completed'.toLowerCase())
                                          ? FittedBox(
                                              child: AppButton(
                                                color: ColorTheme.buttonColor,
                                                buttonTextColor:
                                                    ColorTheme.white,
                                                onClick: () {
                                                  _getPrescriptionByAppointment(
                                                      e.appointmentId);
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      AppTextTheme.textSize12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                text: 'Prescription',
                                              ),
                                            )
                                          : Container(),
                                    ),
                                    Container(width: 10),
                                    Expanded(
                                      child: e.followUpAptAvailable == 1
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: ColorTheme.buttonColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                              onPressed: () {
                                                pid = e.patid.toString();

                                                _getAppointmentDoctorDetails(
                                                    e.appointmentId,
                                                    e.appointmentType);
                                              },
                                              child: FittedBox(
                                                  child: Text(
                                                'Book Follow-up \nAppointment',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: ColorTheme.white),
                                              )),
                                            )
                                          : Container(),
                                    ),
                                    Container(width: 10),
                                    e.connectUrl.length > 0 &&
                                            (e.status == 'Confirmed' ||
                                                e.status == 'Re-scheduled')
                                        ? AppButton(
                                            color: ColorTheme.buttonColor,
                                            buttonTextColor: ColorTheme.white,
                                            onClick: () =>
                                                _launchInBrowser(e.connectUrl),
                                            style: TextStyle(
                                              fontSize: AppTextTheme.textSize12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            text: 'Connect')
                                        : Container(),
                                    Expanded(
                                      child: e.chatUrl != ""
                                          ? IconButton(
                                              onPressed: () => navigateToChat(
                                                  e.chatUrl,
                                                  e.appointmentId.toString()),
                                              icon: Image.asset(AppAssets.chat,
                                                  width: 30,
                                                  height: 30,
                                                  color: ColorTheme.iconColor),
                                            )
                                          : Container(),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                                //TODO: to be removed later /@@/
                                Row(
                                  children: [
                                    if (e.appointmentId == 289)
                                      AppButton(
                                        color: ColorTheme.buttonColor,
                                        buttonTextColor: ColorTheme.white,
                                        onClick: () {
                                          Navigator.pushNamed(context,
                                              VideoCallScreen.routeName,
                                              arguments: {
                                                "appointment_id":
                                                    e.appointmentId,
                                                "role":
                                                    rtc.ClientRole.Broadcaster,
                                              }
                                              // arguments: ScreenArguments(
                                              //     appointment_id: '289',
                                              //     role: rtc.ClientRole.Broadcaster),
                                              );
                                        },
                                        style: TextStyle(
                                          fontSize: AppTextTheme.textSize12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        text: 'Video Test',
                                      ),
                                  ],
                                ),
                                /*@@*/
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final appointmentRepository = AppointmentRepository();

  _getAppointment() async {
    Loader.showProgress();
    final model = await appointmentRepository.getAppointments();
    Loader.hide();
    if (model != null) {
      _appointment.clear();
      _appointment.addAll(model.appointments);
    }
    error = _appointment.length == 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  _getPrescriptionByAppointment(dynamic ids) async {
    Loader.showProgress();
    final response =
        await appointmentRepository.getPrescriptionByAppointment(ids);
    Loader.hide();
    if (response != null) {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) =>
              ViewPrescriptionScreen(response['prescription_path'])));
    }
  }

  String pid = '';
  String specialization = '';

  _getAppointmentDoctorDetails(dynamic ids, String type) async {
    Loader.showProgress();
    final response =
        await appointmentRepository.getAppointmentDoctorDetails(ids);
    Loader.hide();
    if (response != null) {
      _selectedDoctor = response.doctors[0];
      PreferenceManager.specializationId = response.doctors[0].specializationId;
      specialization = response.doctors[0].specializationName;
      Utils.showBookAppointmentDialog(
        context: context,
        doctor: _selectedDoctor,
        type: _getConsultType(type),
        onTypeSelect: bookAppointment,
        follow: true,
      );
    } else {
      Utils.showToast(message: 'Failed to process request');
    }
  }

  bookAppointment(ConsulationType type, String amount, int Id) {
    int consuld = 0;
    if (type == ConsulationType.Online) consuld = 1;
    if (type == ConsulationType.Clinic) consuld = 2;
    if (type == ConsulationType.Home) consuld = 3;
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => DateTimeScreen(
          CreateAppointment(
            patid: pid,
            docId: Id.toString(),
            amount: amount,
            appointmentType: consuld.toString(),
            specialization: specialization,
          ),
          _selectedDoctor,
          follow: true,
        ),
      ),
    );
  }

  _getConsultType(String type) {
    switch (type) {
      case 'Video Consult':
        return ConsulationType.Online;
      case 'Clinic Consult':
        return ConsulationType.Clinic;
        break;
      case 'Home Visit':
        return ConsulationType.Home;
        break;
    }
  }

  Color _getColor(String status) {
    if (status.toString().toLowerCase().contains("Cancelled".toLowerCase()) ||
        status.toString().toLowerCase().contains("pending".toLowerCase()))
      return Colors.redAccent;
    else if (status
        .toString()
        .toLowerCase()
        .contains('Re-scheduled'.toLowerCase()))
      return Colors.orangeAccent;
    else
      return ColorTheme.darkGreen;
  }

  _shareAppointment(Appointment data) async {
    String message = '''
        AppointmentID:${data.appointmentId} 
        Chief complaints:${data.chiefComplaint ?? ''}
        Appointment Type: ${data.appointmentType}
        Appointment Status: ${data.status}
        Doctor: ${data.doctor}
        Specialization: ${data.doctorSpecialization}
        Connect Url: ${data.connectUrl}
        ''';
    final RenderBox box = context.findRenderObject();
    await Share.share(message,
        subject: 'My Appointment',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _cancelApt(data) {
    showDialog(
        context: context,
        builder: (_) => CancelDialog(data, (sucess) {
              if (sucess) _getAppointment();
            }));
  }

  _rescheduleApt(data) {
    showDialog(
        context: context,
        builder: (_) => ResechedulAppointment(data, (sucess) {
              if (sucess) _getAppointment();
            }));
  }

  void navigateToChat(String _url, String appointmentId) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => WebChat('Chat', _url, appointmentId)));
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
