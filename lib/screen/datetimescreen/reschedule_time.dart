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
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/create_appointment.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/symptom/symptom_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/skip_chat_sheet.dart';
import 'package:mumbaiclinic/view/cell/grid_view_item.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/screen/payment/make_payment_screen.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class RescheduleTimeScreen extends StatefulWidget {
  final Doctor doctor;
  final String type;
  RescheduleTimeScreen(this.doctor, [this.type]);

  @override
  _RescheduleTimeScreenState createState() => _RescheduleTimeScreenState();
}

class _RescheduleTimeScreenState extends State<RescheduleTimeScreen> {
  final appointmentRepo = AppointmentRepository();

  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
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

  String username = '';
  String gender = '';
  String age = '';
  int _value = 0;
  String _selectedTime = '';
  int _selectedTimeId = 0;
  TimeOfDay _selectedTimeOfDay;
  @override
  void initState() {
    super.initState();
    loadData();
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
                width: 10,
              )
            ],
          ),
        ],
      ),
      persistentFooterButtons: [
        GestureDetector(
          onTap: () {
            if (_selectedTime.isNotEmpty) {
              final data = DateFormat('yyyy-MM-dd').format(_selectedDate) +
                  ' ${_selectedTimeOfDay.hour}:${_selectedTimeOfDay.minute}:00';
              Navigator.of(context).pop(data);
            } else {
              Utils.showToast(
                  message: 'Select appointment time', isError: true);
            }
          },
          child: Container(
            height: 40,
            width: 120,
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
                  text: 'Done',
                  color: Colors.white,
                  style: AppTextTheme.textTheme14Bold,
                ),
              ),
            ),
          ),
        ),
      ],
      body: CustomScrollView(slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                width: double.infinity,
                color: ColorTheme.lightGreenOpacity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(
                      child: TextView(
                        text: 'Patient: Mr.$username($gender/$age)',
                        color: Colors.black87,
                        style: AppTextTheme.textThemeNameLabel,
                      ),
                    ),
                    TextView(
                      text: 'Speciality: ${widget.doctor.specializationName}',
                      color: Colors.black54,
                      style: AppTextTheme.textTheme14Light,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextView(
                      text: 'Select Date',
                      color: ColorTheme.darkGreen,
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ],
                ),
              ),
              Row(
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
              ConstrainedBox(
                child: _getCalendarView(),
                constraints: BoxConstraints(maxHeight: 350, minHeight: 330),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: TextView(
                  text: 'Select Time',
                  color: ColorTheme.darkGreen,
                  style: AppTextTheme.textTheme14Bold,
                ),
              ),
            ],
          ),
        ),
        SliverGrid.count(
          crossAxisCount: 4,
          childAspectRatio: 3,
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
                        fit: BoxFit.fill,
                      ),
                    ),
                  ))
              .toList(),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Row(
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
                            child: GridViewItem(e, _selectedData.contains(e)),
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
                          print(e.slotStart);
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
                            child: GridViewItem(e, _selectedData.contains(e)),
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
                            child: GridViewItem(e, _selectedData.contains(e)),
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
                            child: GridViewItem(e, _selectedData.contains(e)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),

        /*  if(filterList.length==0)
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: EdgeInsets.all(14),
                child:  GestureDetector(
                  onTap: ()=>_showDatePicker(),
                  child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: ColorTheme.lightGreenOpacity,
                      ),
                      child: AppText.getRegularText('Select Date Time', 14 , ColorTheme.darkGreen)
                  ),
                ),
              ),
            ),*/

        SliverList(
          delegate: SliverChildListDelegate([
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                      child: TextView(
                    text: 'Date:${Utils.getReadableDate(_selectedDate)}',
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
          ]),
        ),
      ]),
    );
  }

  loadData() async {
    // SelectedUser user = PreferenceManager.selectedUser;
    final pid = PreferenceManager.getUserId();
    Datum user = await AppDatabase.db.getUser(pid);

    username = user.fullName;
    gender = user.sex.toUpperCase();
    var date = user.dob;
    age = Utils.getYears(date: date);

    DateTime data = DateTime.now();
    for (int i = 0; i < 12; i++) {
      time.add(data.add(Duration(days: i * 30)));
    }
    _getAvailableTime();
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

          filter();

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
      "doctor_id": widget.doctor.doctorId.toString(),
      "consult_type_id": widget.type,
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
            if (selectTimeList.length > 0)
              filter();
            else
              _genearte();
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
            message: 'Failed to load available time slot: $error',
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
    selectTimeList.forEach((element) {
      if (element.slotStart.day == _selectedDate.day) {
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

    if (filterList.length == 0) _genearte();

    setState(() {});
  }

  _genearte() async {
    filterList.clear();
    morning.clear();
    afternoon.clear();
    evening.clear();
    night.clear();
    var now = DateTime.now();
    var slotDate =
        DateTime(now.year, _selectedDate.month, _selectedDate.day, 8, 0, 0, 0);
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
}

class TimeModel {
  String name;
  DateTime dateTime;

  TimeModel(this.name, this.dateTime);
}
