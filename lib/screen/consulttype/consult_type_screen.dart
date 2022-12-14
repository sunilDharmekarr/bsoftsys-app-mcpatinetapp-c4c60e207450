import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/create_appointment.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/datetimescreen/date_time_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/select_member_dialog.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class ConsultTypeScreen extends StatefulWidget {
  final String name;
  final int SId;
  final bool isFastAppointment;

  ConsultTypeScreen(this.name, this.SId, {this.isFastAppointment = false});

  @override
  _ConsultTypeScreenState createState() => _ConsultTypeScreenState();
}

class _ConsultTypeScreenState extends State<ConsultTypeScreen>
    with TickerProviderStateMixin {
  var _Alldoctors = <Doctor>[];
  var _doctors = <Doctor>[];
  Doctor _selectedDoctor = null;
  var username = '';
  var gender = '';
  var age = '';
  var pid = '';
  var index = 0;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.lightGreenOpacity,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextView(
                text: _getAddress(),
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
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: ColorTheme.lightGreenOpacity,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextView(
                          text: 'Patient: $username ($gender/$age)',
                          color: Colors.black87,
                          style: AppTextTheme.textThemeNameLabel,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(
                          Icons.mode_edit,
                          color: ColorTheme.buttonColor,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return SelectMemberDialog(
                            selectionType: SelectionType.pickMember,
                            onSelected: (String id) {
                              setState(() {
                                _loadUserData(userId: id);
                              });
                            },
                          );
                        });
                  },
                ),
                TextView(
                  text: 'Speciality: ${widget.name}',
                  color: Colors.black54,
                  style: AppTextTheme.textTheme14Light,
                ),
              ],
            ),
          ),
          Container(
            color: ColorTheme.lightGreenOpacity,
            height: 10,
          ),
          Container(
            color: ColorTheme.lightGreenOpacity,
            height: 36,
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              isScrollable: false,
              unselectedLabelColor: ColorTheme.darkGreen,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              indicator: BoxDecoration(
                color: ColorTheme.buttonColor,
              ),
              onTap: (index) {
                this.index = index;
                _filterDoctors(index);
              },
              tabs: ['Video Consult', 'Clinic Consult', 'Home Visit']
                  .map((e) => Tab(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 0.5, color: Colors.grey))),
                          child: Center(
                            child: Text(
                              e,
                              maxLines: 1,
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  fontSize: AppTextTheme.textSize12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: _doctors
                    .map((e) => InkWell(
                          onTap: () {
                            _selectedDoctor = e;
                            Utils.showBookAppointmentDialog(
                              context: context,
                              doctor: e,
                              type: _getConsultType(),
                              onTypeSelect: _bookAppointment,
                              fast: widget.isFastAppointment,
                            );
                          },
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      height: 80,
                                      width: 80,
                                      margin: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage('${e.photopath}',
                                              headers: Utils.getHeaders()),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            TextView(
                                              text: e.name,
                                              style:
                                                  AppTextTheme.textTheme14Bold,
                                            ),
                                            TextView(
                                              text: e.specializationName +
                                                  '/' +
                                                  e.qualification,
                                              style:
                                                  AppTextTheme.textTheme10Light,
                                            ),
                                            _getConsultType() ==
                                                    ConsulationType.Clinic
                                                ? Row(
                                                    children: [
                                                      Image.asset(
                                                          AppAssets.location,
                                                          width: 18,
                                                          height: 18,
                                                          color: ColorTheme
                                                              .lightGreen),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: TextView(
                                                          text: e.clinicAddress,
                                                          maxLine: 2,
                                                          style: AppTextTheme
                                                              .textTheme10Light,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            const SizedBox(height: 6),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: ColorTheme.buttonColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: Utils.getShadow(
                                                    shadow: 0.5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Center(
                                                  child: TextView(
                                                    text: 'Book Appointment',
                                                    color: Colors.white,
                                                    style: AppTextTheme
                                                        .textTheme14Bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                    height: 0.7,
                                    thickness: 0.7,
                                    color: ColorTheme.darkGreen)
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  _getConsultType() {
    switch (index) {
      case 0:
        return ConsulationType.Online;
      case 1:
        return ConsulationType.Clinic;
        break;
      case 2:
        return ConsulationType.Home;
        break;
    }
  }

  _loadData() async {
    _loadUserData();
    if (widget.isFastAppointment)
      _getFastAppointmentDoctorBySpecialization();
    else
      _getDocBySpecialization();
  }

  _loadUserData({String userId}) async {
    pid = userId ?? PreferenceManager.getUserId();
    //print("ANAMOY: PID... $pid");
    Datum model = await AppDatabase.db.getUser(pid);
    if (model != null) {
      username = model.fullName;
      gender = model.sex.toUpperCase();
      var date = model.dob;
      age = Utils.getYears(date: date);
    }
  }

  String _getAddress() {
    final addressService = AddressService.instance;
    final data = addressService.place;
    if (data != null) {
      return data.administrativeArea + '-' + data.locality;
    }
    return 'Loading..';
  }

  final appointmentRepo = AppointmentRepository();

  _getFastAppointmentDoctorBySpecialization() async {
    Loader.showProgress();
    final model = await appointmentRepo
        .getFastAppointmentDoctorBySpecialization(widget.SId);
    Loader.hide();

    if (model != null) {
      if (model.success == 'true') {
        _doctors.clear();
        _doctors.addAll(model.doctors);
        _Alldoctors.clear();
        _Alldoctors.addAll(model.doctors);
        _filterDoctors(0);
      } else {
        Utils.showToast(message: model.error ?? 'Failed to load doctors data');
      }
    } else {
      Utils.showToast(message: 'Failed to load doctors data');
    }

    setState(() {});
  }

  _getDocBySpecialization() async {
    Loader.showProgress();
    Map<String, String> body = {'specialization_id': widget.SId.toString()};
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.getDoctorBySpecialization,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        Loader.hide();
        if (response != null) {
          DocBySpecialization model =
              DocBySpecialization.fromJson(json.decode(response));
          if (model.success == 'true') {
            _doctors.clear();
            _doctors.addAll(model.doctors);
            _Alldoctors.clear();
            _Alldoctors.addAll(model.doctors);
            _filterDoctors(0);
          } else {
            Utils.showToast(
                message: 'Failed to load doctors: ${model.error}',
                isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to load doctors', isError: true);
        }
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(
            message: 'Failed to load doctors: $error', isError: true);
      },
    );
  }

  _filterDoctors(int index) async {
    _doctors.clear();
    _Alldoctors.forEach((element) {
      if (index == 0 && element.videoConsult == 'true') {
        _doctors.add(element);
      } else if (index == 1 && element.clinicConsult == 'true') {
        _doctors.add(element);
      } else if (index == 2 && element.homeVisit == 'true') {
        _doctors.add(element);
      }
    });
    setState(() {});
  }

  _bookAppointment(ConsulationType type, String amount, int Id) {
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
              specialization: widget.name),
          _selectedDoctor,
          isFast: widget.isFastAppointment,
        ),
      ),
    );
  }
}
