import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/model/available_time.dart';
import 'package:mumbaiclinic/model/create_appointment.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/bookappointment/book_appointment.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/screen/payment/make_payment_screen.dart';
import 'package:mumbaiclinic/screen/symptom/symptom_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/skip_chat_sheet.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/cell/grid_view_item.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/select_member_dialog.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class DateTimeScreen extends StatefulWidget {
  final CreateAppointment model;
  final Doctor doctor;
  final bool follow;
  final bool isFast;
  DateTimeScreen(this.model, this.doctor,
      {this.follow = false, this.isFast = false});

  @override
  _DateTimeScreenState createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  final _controller = ScrollController();

  final appointmentRepo = AppointmentRepository();

  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate;
  List<DateTime> time = [];
  List<SlotTime> selectTimeList = [];
  List<SlotTime> filterList = [];
  List<SlotTime> morning = [];
  List<SlotTime> afternoon = [];
  List<SlotTime> evening = [];
  List<SlotTime> night = [];
  List<SlotTime> _selectedData = [];
  List<TimeModel> _timeList = List<TimeModel>.generate(
      2,
      (index) => TimeModel(index == 0 ? 'Today' : 'Tomorrow',
          DateTime.now().add(Duration(days: index)))).toList();

  var username = '';
  var gender = '';
  var age = '';
  var _value = 0;
  var _selectedTime = '';
  var _selectedTimeId = 0;
  TimeOfDay _selectedTimeOfDay;
  var name = 'Today';
  var pid = '';

  @override
  void initState() {
    super.initState();
    if (widget.isFast) _selectedDate = DateTime.now();
    _loadData(widget.model.patid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        persistentFooterButtons: [
          GestureDetector(
            onTap: () {
              if (_selectedTime.isNotEmpty) {
                if (widget.model.amount != '0') {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => MakePaymentScreen(
                        CreateAppointment(
                          patid: pid,
                          docId: widget.model.docId,
                          amount: widget.model.amount,
                          slotId: _selectedTimeId,
                          appointmentType: widget.model.appointmentType,
                          appointmentDate: DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate) +
                              ' ${_selectedTimeOfDay.hour}:${_selectedTimeOfDay.minute}:00',
                        ),
                        widget.doctor,
                        follow: widget.follow,
                        isFast: widget.isFast,
                      ),
                    ),
                  );
                } else {
                  widget.isFast
                      ? _requestFastAppointment()
                      : _requestAppointment();
                }
              } else {
                Utils.showToast(
                    message: 'Select appointment time', isError: true);
              }
            },
            child: Container(
              height: 44,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              decoration: BoxDecoration(
                color: _selectedTime.isNotEmpty
                    ? ColorTheme.buttonColor
                    : ColorTheme.lightGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: Utils.getShadow(shadow: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: TextView(
                    text: widget.model.amount == '0'
                        ? 'Request Appointment'
                        : 'Next',
                    color: Colors.white,
                    style: AppTextTheme.textTheme14Bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  text: getAddress(),
                  style: TextStyle(
                      fontSize: AppTextTheme.textSize14,
                      color: ColorTheme.darkGreen,
                      fontFamily: TextFont.poppinsLight),
                ),
                Image.asset(
                  AppAssets.location,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(
                  width: 8,
                )
              ],
            ),
          ],
        ),
        // body: CustomScrollView(slivers: [
        //   SliverList(
        //     delegate: SliverChildListDelegate(
        //       [
        //         Container(
        //           width: double.infinity,
        //           color: ColorTheme.lightGreenOpacity,
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        //           child: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: <Widget>[
        //               FittedBox(
        //                 child: TextView(
        //                   text: 'Patient: Mr.$username($gender/$age)',
        //                   color: Colors.black87,
        //                   style: AppTextTheme.textThemeNameLabel,
        //                 ),
        //               ),
        //               TextView(
        //                 text: 'Speciality: ${widget.model.specialization}',
        //                 color: Colors.black54,
        //                 style: AppTextTheme.textTheme14Light,
        //               ),
        //               TextView(
        //                 text: 'Doctor : ${widget?.doctor?.name}',
        //                 color: Colors.black54,
        //                 style: AppTextTheme.textTheme14Light,
        //               ),
        //               const SizedBox(
        //                 height: 20,
        //               ),
        //               if(!widget.isFast)
        //               TextView(
        //                 text:'Select Date',
        //                 color: ColorTheme.darkGreen,
        //                 style: AppTextTheme.textTheme14Bold,
        //               ),
        //             ],
        //           ),
        //         ),
        //         if(!widget.isFast)
        //         AbsorbPointer(
        //           absorbing: widget.isFast,
        //           child: Row(
        //             children: <Widget>[
        //               SizedBox(
        //                 width: 24,
        //               ),
        //               Image.asset(
        //                 AppAssets.book_appointment,
        //                 width: 30,
        //                 height: 30,
        //               ),
        //               _getMonths(),
        //             ],
        //           ),
        //         ),
        //         if(!widget.isFast)
        //         ConstrainedBox(
        //           child: _getCalendarView(),
        //           constraints: BoxConstraints(maxHeight: 350, minHeight: 330),
        //         ),

        //         if(!widget.isFast)
        //         Row(
        //           children: [
        //             Expanded(
        //               child: SizedBox()
        //             ),
        //             Container(
        //               margin: EdgeInsets.only(right: 10.0),
        //               child: AppButton(
        //                 color: ColorTheme.buttonColor,
        //                 buttonTextColor: ColorTheme.white,
        //                 onClick: () {
        //                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookAppointment(isFastAppointment: true,)));
        //                 },
        //                 style: TextStyle(
        //                   fontSize: AppTextTheme.textSize12,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //                 text: 'Want Early Appointment?',
        //               ),
        //             )
        //           ],
        //         ),

        //         if (widget.isFast)
        //          Container(
        //             width: double.infinity,
        //             height: 100,
        //             margin: const EdgeInsets.symmetric(horizontal: 14,vertical: 20),

        //             child: Column(
        //               children: [
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                    AppText.getRegularText('Select Date', 14, ColorTheme.darkGreen),
        //                   ],
        //                 ),
        //                 const SizedBox(height: 10,),
        //                 Container(
        //                   decoration: BoxDecoration(
        //                     color: ColorTheme.lightGreenOpacity,
        //                     borderRadius: BorderRadius.circular(12),
        //                     boxShadow: Utils.getShadow(),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                         Expanded(
        //                           child: Container(
        //                             padding: const EdgeInsets.only(left: 20),
        //                             child: DropdownButton(value: name,onChanged: (value){setState(() {
        //                             name = value;
        //                             _selectedDate = _timeList.firstWhere((element) => element.name==value).dateTime;
        //                             _genearte();
        //                             },
        //                             );

        //                              },
        //                             underline: Container(),
        //                             isExpanded: true,
        //                             icon: Icon(Icons.keyboard_arrow_down),
        //                             items: _timeList.map<DropdownMenuItem>((e) => DropdownMenuItem(child: AppText.getBoldText(e.name, 14, ColorTheme.darkGreen),value: e.name,)).toList(),
        //                         ),
        //                           ),
        //                         ),
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             )
        //           ),

        //         Container(
        //             width: double.infinity,
        //             padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 10),
        //             child:  TextView(
        //               text: 'Select Time',
        //               color: ColorTheme.darkGreen,
        //               style: AppTextTheme.textTheme14Bold,
        //             ),
        //         ),

        //       ],
        //     ),
        //   ),
        //     SliverGrid.count(
        //       crossAxisCount: 4,
        //       childAspectRatio: 3,
        //       children: [
        //         AppAssets.morning,
        //         AppAssets.afternoon,
        //         AppAssets.evening,
        //         AppAssets.night,
        //       ]
        //           .map((e) => Container(
        //                 padding: const EdgeInsets.all(0),
        //                 child: Center(
        //                   child: Image.asset(
        //                     e,
        //                     fit: BoxFit.fill,
        //                   ),
        //                 ),
        //               ))
        //           .toList(),
        //     ),
        //     SliverList(
        //       delegate: SliverChildListDelegate([
        //         const SizedBox(
        //           height: 10,
        //         ),
        //         Container(
        //           height: 200,
        //           child: filterList.length == 0
        //               ? Center(
        //                   child: TextView(
        //                     text:
        //                         'No slots are available for ${Utils.getReadableDate(_selectedDate)}',
        //                     style: AppTextTheme.textTheme14Light,
        //                   ),
        //                 )
        //               : Row(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Expanded(
        //                       child: Container(
        //                         child: ListView(
        //                           primary: false,
        //                           shrinkWrap: true,
        //                           children: morning.map((e) {
        //                             return GestureDetector(
        //                               onTap: () {
        //                                 if (e.isAvailable == 'true') {
        //                                   _selectedTime =Utils.getReadableTime(e.slotStart);
        //                                   _selectedTimeOfDay = TimeOfDay(hour: e.slotStart.hour, minute:  e.slotStart.minute);
        //                                   _selectedTimeId = e.slotId;
        //                                   setState(() {
        //                                     _selectedData.clear();
        //                                     _selectedData.add(e);
        //                                   });
        //                                 }
        //                               },
        //                               child: GridViewItem(
        //                                   e, _selectedData.contains(e)),
        //                             );
        //                           }).toList(),
        //                         ),
        //                       ),
        //                     ),
        //                     Expanded(
        //                       child: Container(
        //                         child: ListView(
        //                           primary: false,
        //                           shrinkWrap: true,
        //                           children: afternoon.map((e) {
        //                             return GestureDetector(
        //                               onTap: () {
        //                                 if (e.isAvailable == 'true') {
        //                                   _selectedTime = Utils.getReadableTime(e.slotStart);
        //                                   _selectedTimeOfDay = TimeOfDay(hour: e.slotStart.hour, minute:  e.slotStart.minute);
        //                                   _selectedTimeId = e.slotId;
        //                                   setState(() {
        //                                     _selectedData.clear();
        //                                     _selectedData.add(e);
        //                                   });
        //                                 }
        //                               },
        //                               child: GridViewItem(
        //                                   e, _selectedData.contains(e)),
        //                             );
        //                           }).toList(),
        //                         ),
        //                       ),
        //                     ),
        //                     Expanded(
        //                       child: Container(
        //                         child: ListView(
        //                           primary: false,
        //                           shrinkWrap: true,
        //                           children: evening.map((e) {
        //                             return GestureDetector(
        //                               onTap: () {
        //                                 if (e.isAvailable == 'true') {
        //                                   _selectedTime =Utils.getReadableTime(e.slotStart);
        //                                   _selectedTimeOfDay = TimeOfDay(hour: e.slotStart.hour, minute:  e.slotStart.minute);
        //                                   _selectedTimeId = e.slotId;
        //                                   setState(() {
        //                                     _selectedData.clear();
        //                                     _selectedData.add(e);
        //                                   });
        //                                 }
        //                               },
        //                               child: GridViewItem(
        //                                   e, _selectedData.contains(e)),
        //                             );
        //                           }).toList(),
        //                         ),
        //                       ),
        //                     ),
        //                     Expanded(
        //                       child: Container(
        //                         child: ListView(
        //                           primary: false,
        //                           shrinkWrap: true,
        //                           children: night.map((e) {
        //                             return GestureDetector(
        //                               onTap: () {
        //                                 if (e.isAvailable == 'true') {
        //                                   _selectedTime = Utils.getReadableTime(e.slotStart);
        //                                   _selectedTimeOfDay = TimeOfDay(hour: e.slotStart.hour, minute:  e.slotStart.minute);
        //                                   _selectedTimeId = e.slotId;
        //                                   setState(() {
        //                                     _selectedData.clear();
        //                                     _selectedData.add(e);
        //                                   });
        //                                 }
        //                               },
        //                               child: GridViewItem(
        //                                   e, _selectedData.contains(e)),
        //                             );
        //                           }).toList(),
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //         ),
        //         const SizedBox(
        //           height: 20,
        //         ),
        //       ]),
        //     ),
        //     SliverList(
        //     delegate: SliverChildListDelegate(
        //         [
        //           const SizedBox(
        //             height: 10,
        //           ),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           Expanded(
        //             child: Center(
        //                 child: TextView(
        //               text: 'Date:${Utils.getReadableDate(_selectedDate)}',
        //               style: AppTextTheme.textTheme14Bold,
        //             )),
        //           ),
        //           Expanded(
        //             child: Center(
        //                 child: TextView(
        //               text: 'Time:$_selectedTime',
        //               style: AppTextTheme.textTheme14Bold,
        //             )),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(
        //         height: 20,
        //       ),
        //     ]),
        //   ),
        // ]),
        body: ListView(
          controller: _controller,
          children: [
            Container(
              width: double.infinity,
              color: ColorTheme.lightGreenOpacity,
              //padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                              onSelected: (id) {
                                setState(() {
                                  _loadUserData(id);
                                });
                              },
                            );
                          });
                    },
                  ),
                  TextView(
                    text: 'Speciality: ${widget.model.specialization}',
                    color: Colors.black54,
                    style: AppTextTheme.textTheme14Light,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextView(
                    text: 'Doctor : ${widget?.doctor?.name}',
                    color: Colors.black54,
                    style: AppTextTheme.textTheme14Light,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (!widget.isFast)
                    TextView(
                      text: 'Select Date',
                      color: ColorTheme.darkGreen,
                      style: AppTextTheme.textTheme14Bold,
                    ),
                ],
              ),
            ),
            if (!widget.isFast)
              AbsorbPointer(
                absorbing: widget.isFast,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 24,
                    ),
                    Image.asset(
                      AppAssets.book_appointment,
                      width: 30,
                      height: 30,
                    ),
                    _getMonths(),
                  ],
                ),
              ),
            if (!widget.isFast)
              ConstrainedBox(
                child: _getCalendarView(),
                constraints: BoxConstraints(maxHeight: 350, minHeight: 330),
              ),
            if (!widget.isFast)
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    child: AppButton(
                      color: ColorTheme.buttonColor,
                      buttonTextColor: ColorTheme.white,
                      onClick: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookAppointment(
                                  isFastAppointment: true,
                                )));
                      },
                      style: TextStyle(
                        fontSize: AppTextTheme.textSize12,
                        fontWeight: FontWeight.bold,
                      ),
                      text: 'Want Early Appointment?',
                    ),
                  )
                ],
              ),
            if (widget.isFast)
              Container(
                  width: double.infinity,
                  height: 100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.getRegularText(
                              'Select Date', 14, ColorTheme.darkGreen),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: Utils.getShadow(),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                child: DropdownButton(
                                  value: name,
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        name = value;
                                        _selectedDate = _timeList
                                            .firstWhere((element) =>
                                                element.name == value)
                                            .dateTime;
                                        _genearte();
                                      },
                                    );
                                  },
                                  underline: Container(),
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  items: _timeList
                                      .map<DropdownMenuItem>(
                                          (e) => DropdownMenuItem(
                                                child: AppText.getBoldText(
                                                    e.name,
                                                    14,
                                                    ColorTheme.darkGreen),
                                                value: e.name,
                                              ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: TextView(
                text: 'Select Time',
                color: ColorTheme.darkGreen,
                style: AppTextTheme.textTheme14Bold,
              ),
            ),
            Container(
              height: 100,
              child: GridView.count(
                crossAxisCount: 4,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  AppAssets.morning,
                  AppAssets.afternoon,
                  AppAssets.evening,
                  AppAssets.night,
                ]
                    .map((e) => Container(
                          padding: const EdgeInsets.all(0),
                          child: Center(
                            child: Image.asset(
                              e,
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 200,
              child: filterList.length == 0
                  ? Center(
                      child: TextView(
                        text:
                            'No slots are available for ${Utils.getReadableDate(_selectedDate ?? DateTime.now())}',
                        style: AppTextTheme.textTheme14Light,
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              children: morning.map((e) {
                                return GestureDetector(
                                  onTap: () {
                                    if (e.isAvailable == 'true') {
                                      _selectedTime =
                                          Utils.getReadableTime(e.slotStart);
                                      _selectedTimeOfDay = TimeOfDay(
                                          hour: e.slotStart.hour,
                                          minute: e.slotStart.minute);
                                      _selectedTimeId = e.slotId;
                                      setState(() {
                                        _selectedData.clear();
                                        _selectedData.add(e);
                                      });
                                    }
                                  },
                                  child: GridViewItem(
                                      e, _selectedData.contains(e)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              children: afternoon.map((e) {
                                return GestureDetector(
                                  onTap: () {
                                    if (e.isAvailable == 'true') {
                                      _selectedTime =
                                          Utils.getReadableTime(e.slotStart);
                                      _selectedTimeOfDay = TimeOfDay(
                                          hour: e.slotStart.hour,
                                          minute: e.slotStart.minute);
                                      _selectedTimeId = e.slotId;
                                      setState(() {
                                        _selectedData.clear();
                                        _selectedData.add(e);
                                      });
                                    }
                                  },
                                  child: GridViewItem(
                                      e, _selectedData.contains(e)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              children: evening.map((e) {
                                return GestureDetector(
                                  onTap: () {
                                    if (e.isAvailable == 'true') {
                                      _selectedTime =
                                          Utils.getReadableTime(e.slotStart);
                                      _selectedTimeOfDay = TimeOfDay(
                                          hour: e.slotStart.hour,
                                          minute: e.slotStart.minute);
                                      _selectedTimeId = e.slotId;
                                      setState(() {
                                        _selectedData.clear();
                                        _selectedData.add(e);
                                      });
                                    }
                                  },
                                  child: GridViewItem(
                                      e, _selectedData.contains(e)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              children: night.map((e) {
                                return GestureDetector(
                                  onTap: () {
                                    if (e.isAvailable == 'true') {
                                      _selectedTime =
                                          Utils.getReadableTime(e.slotStart);
                                      _selectedTimeOfDay = TimeOfDay(
                                          hour: e.slotStart.hour,
                                          minute: e.slotStart.minute);
                                      _selectedTimeId = e.slotId;
                                      setState(() {
                                        _selectedData.clear();
                                        _selectedData.add(e);
                                      });
                                    }
                                  },
                                  child: GridViewItem(
                                      e, _selectedData.contains(e)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                      child: TextView(
                    text:
                        'Date:${Utils.getReadableDate(_selectedDate ?? DateTime.now())}',
                    style: AppTextTheme.textTheme14Bold,
                  )),
                ),
                Expanded(
                  child: Center(
                      child: TextView(
                    text: 'Time:$_selectedTime',
                    style: AppTextTheme.textTheme14Bold,
                  )),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ));
  }

  _loadData(String requestedPatient) async {
    // SelectedUser user = PreferenceManager.selectedUser;
    //final pid = PreferenceManager.getUserId();
    _loadUserData(requestedPatient);

    DateTime data = DateTime.now();
    for (int i = 0; i < 12; i++) {
      time.add(data.add(Duration(days: i * 30)));
    }

    if (!widget.isFast)
      _getAvailableTime();
    else
      _genearte();

    setState(() {});
  }

  _loadUserData(String userId) async {
    pid = userId ?? PreferenceManager.getUserId();
    Datum user = await AppDatabase.db.getUser(pid);
    if (user != null) {
      username = user.fullName;
      gender = user.sex.toUpperCase();
      var date = user.dob;
      age = Utils.getYears(date: date);
    }
  }

  String getAddress() {
    final addressService = AddressService.instance;
    final data = addressService.place;
    if (data != null) {
      return data.administrativeArea + '-' + data.locality;
    }
    return 'Loading..';
  }

  _getMonths() {
    return DropdownButton(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 30,
      ),
      underline: Container(),
      value: _value,
      items: time.map((e) {
        return DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
            child: Text(
              DateFormat.yMMM().format(e),
              style: AppTextTheme.textTheme14Bold,
            ),
          ),
          value: time.indexOf(e),
        );
      }).toList(),
      onChanged: (value) {
        _value = value;
        var date = time[value];
        if (value == 0) {
          _currentDate = DateTime.now();
          _selectedDate = DateTime.now();
        } else {
          _currentDate = DateTime(date.year, date.month, 1);
          _selectedDate = _currentDate;

          ///_selectedDate was getting null.
          ///issue date
        }
        filter();
        setState(() {});
      },
    );
  }

  //get calendar view
  _getCalendarView() {
    return Container(
      key: UniqueKey(),
      child: CalendarCarousel<Event>(
        pageScrollPhysics: NeverScrollableScrollPhysics(),
        onDayPressed: (DateTime date, List<Event> events) {
          _selectedDate = date;

          for (int i = 0; i < time.length; i++) {
            var element = time[i];
            var month = DateFormat('yyyy-MM-dd').format(element).split('-')[1];
            var month1 =
                DateFormat('yyyy-MM-dd').format(_selectedDate).split('-')[1];
            if (month == month1) {
              _value = time.indexOf(element);
              break;
            }
          }

          if (!widget.isFast)
            filter();
          else {
            _genearte();
          }
          _controller.animateTo(100.0 * 9,
              duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
          setState(() {});
        },
        selectedDateTime: _selectedDate,
        selectedDayTextStyle: TextStyle(color: Colors.white),
        selectedDayButtonColor: ColorTheme.darkGreen,
        weekdayTextStyle: TextStyle(
          fontSize: 14,
          color: ColorTheme.darkGreen.withOpacity(0.8),
          fontWeight: FontWeight.bold,
        ),
        weekendTextStyle: TextStyle(
          fontSize: 14,
          color: ColorTheme.darkGreen.withOpacity(0.8),
          fontWeight: FontWeight.bold,
        ),
        weekFormat: false,
        isScrollable: true,
        customGridViewPhysics: NeverScrollableScrollPhysics(),
        dayPadding: 4.0,
        showHeader: false,
        weekDayFormat: WeekdayFormat.standaloneShort,
        daysHaveCircularBorder: false,
        minSelectedDate:
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day),
        todayButtonColor: Colors.transparent,
        todayBorderColor: Colors.transparent,
        todayTextStyle: TextStyle(
          color: ColorTheme.darkGreen,
          fontWeight: FontWeight.bold,
        ),
        maxSelectedDate: DateTime(_currentDate.year, _currentDate.month + 1, 0),
        daysTextStyle: TextStyle(
          color: ColorTheme.darkGreen,
          fontWeight: FontWeight.bold,
        ),
        dayButtonColor: Colors.transparent,
      ),
    );
  }

  _getAvailableTime() async {
    //EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    Map<String, String> body = {
      "doctor_id": widget.model.docId,
      "consult_type_id": widget.model.appointmentType
    };
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.getDoctorSchedule,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          ResponseModel model = ResponseModel.fromJson(json.decode(response));
          if (model.success == 'true') {
            AvailableTime time = AvailableTime.fromJson(json.decode(response));
            selectTimeList.clear();
            selectTimeList.addAll(time.slotTime);
            filter();
            setState(() {});
          } else {
            Utils.showToast(
                message: 'Failed to load available time slots: ${model.error}',
                isError: true);
          }
        } else {
          Utils.showToast(
              message: 'Failed to load available time slots', isError: true);
        }
      },
      onError: (error) {
        //EasyLoading.dismiss();
        Loader.hide();
        Utils.showToast(
            message: 'Failed to load available time slots: $error',
            isError: true);
      },
    );
  }

  void filter() {
    filterList.clear();
    morning.clear();
    afternoon.clear();
    evening.clear();
    night.clear();
    if (_selectedDate != null)
      selectTimeList.forEach((element) {
        if (element.slotStart.day == _selectedDate.day &&
            element.slotStart.month == _selectedDate.month &&
            element.slotStart.year == _selectedDate.year) {
          SlotTime data = element;

          if (data.slotStart.isBefore(DateTime.now())) {
            data.isAvailable = 'false';
          }

          if (data.slotStart.hour >= 9 && data.slotStart.hour < 12) {
            morning.add(data);
          } else if (data.slotStart.hour >= 12 && data.slotStart.hour <= 15) {
            afternoon.add(data);
          } else if (data.slotStart.hour > 15 && data.slotStart.hour <= 18) {
            evening.add(data);
          } else if (data.slotStart.hour > 18 && data.slotStart.hour <= 21) {
            night.add(data);
          }

          filterList.add(data);
        }
      });

    if (widget.model.amount == '0') _genearte();

    setState(() {});
  }

  _genearte() async {
    filterList.clear();
    morning.clear();
    afternoon.clear();
    evening.clear();
    night.clear();
    var now = DateTime.now();
    var slotDate = DateTime(
        _selectedDate != null ? _selectedDate.year : now.year,
        _selectedDate != null ? _selectedDate.month : now.month,
        _selectedDate != null ? _selectedDate.day : now.day,
        8,
        0,
        0,
        0);
    List<SlotTime> slot = List<SlotTime>.generate(44, (index) {
      return SlotTime(
          slotId: index,
          slotInMinutes: 15,
          isAvailable: 'true',
          slotStart: slotDate.add(Duration(minutes: 15 * index)));
    });

    slot.forEach((element) {
      SlotTime data = element;

      if (data.slotStart.isBefore(DateTime.now())) {
        data.isAvailable = 'false';
      }

      if (data.slotStart.hour >= 9 && data.slotStart.hour < 12) {
        morning.add(data);
      } else if (data.slotStart.hour >= 12 && data.slotStart.hour <= 15) {
        afternoon.add(data);
      } else if (data.slotStart.hour > 15 && data.slotStart.hour <= 18) {
        evening.add(data);
      } else if (data.slotStart.hour > 18 && data.slotStart.hour <= 21) {
        night.add(data);
      }

      filterList.add(data);
    });

    setState(() {});
  }

  _showPicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      confirmText: 'Done',
      cancelText: 'Cancel',
    ).then((value) {
      if (value != null) {
        _selectedTime = Utils.getReadableTimeFromTimeOfDay(value);
        _selectedTimeOfDay = value;
        setState(() {});
      }
    });
  }

  _requestFastAppointment() async {
    Map<String, dynamic> body = {
      "patid": pid,
      "doc_id": widget.doctor.doctorId,
      "appointment_date": DateFormat('yyyy-MM-dd').format(_selectedDate) +
          ' ${_selectedTimeOfDay.hour}:${_selectedTimeOfDay.minute}:00',
      "appointment_type": "${widget.model.appointmentType}"
    };
    Loader.showProgress();
    final response = await appointmentRepo.requestFastAppointment(body);
    Loader.hide();
    if (response != null) {
      if (response.success == 'true') {
        _success(response);
      } else {
        Utils.showToast(
            message: 'Failed to request appointment: ${response.error}',
            isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to request appointment', isError: true);
    }
  }

  _requestAppointment() async {
    Map<String, dynamic> body = {
      "patid": pid,
      "doc_id": widget.doctor.doctorId,
      "appointment_date": DateFormat('yyyy-MM-dd').format(_selectedDate) +
          ' ${_selectedTimeOfDay.hour}:${_selectedTimeOfDay.minute}:00',
      "appointment_type": "${widget.model.appointmentType}"
    };
    Loader.showProgress();
    final response = await appointmentRepo.requestAppointment(body);
    Loader.hide();

    if (response != null) {
      if (response.success == 'true') {
        _success(response);
      } else {
        Utils.showToast(
            message: 'Failed to request appointment: ${response.error}',
            isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to request appointment', isError: true);
    }
  }

  _success(AppointmentModel data) {
    Utils.showToast(message: 'Appointment requested.');

    if (data.appointment != null && data.appointment.length > 0) {
      Appointment model = data.appointment[0];
      PreferenceManager.setappointment_id = model.appointmentId;
      PreferenceManager.setAppointment = model;

      Future.delayed(
          Duration(milliseconds: 200), _showSkipSheet(data.appointment[0]));
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //     '/home', (Route<dynamic> route) => false);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyAppointmentScreen()),
            (route) => false);
      });
    }
  }

  _showSkipSheet(appoint) {
    print("Inside show skip sheet make_payment_screen");
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return SkipChatSheet(
          onAction: (action) {
            if (action == ActionType.skip) {
              Utils.showAppointmentSuccessDialog(
                context,
                appoint,
                () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //     '/home', (Route<dynamic> route) => false);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAppointmentScreen()),
                        (route) => false);
                  });
                },
              );
            } else {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => SymptomScreen(
                    widget.doctor,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class TimeModel {
  String name;
  DateTime dateTime;

  TimeModel(this.name, this.dateTime);
}
