import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/myappointment_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/datetimescreen/reschedule_time.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class ResechedulAppointment extends StatefulWidget {
  final Appointment appointment;
  final Function(bool success) onSuccess;
  ResechedulAppointment(this.appointment, this.onSuccess);

  @override
  _ResechedulAppointmentState createState() => _ResechedulAppointmentState();
}

class _ResechedulAppointmentState extends State<ResechedulAppointment> {
  final _reasonController = TextEditingController();
  final _appointmentRepo = AppointmentRepository();
  bool chbx = false;
  String error = '';
  String dateTime = 'Select Date Time';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: AppText.getBoldText(
                      'Reschedule Appointment'.toUpperCase(),
                      16,
                      ColorTheme.darkGreen)),
              SizedBox(
                height: 16,
              ),
              AppText.getRegularText(
                  'Appointment ID : ${widget.appointment.appointmentId}',
                  12,
                  Colors.black),
              SizedBox(
                height: 10,
              ),
              AppText.getRegularText(
                  'Appointment Date : ${Utils.getReadableDateTime(widget.appointment.appointmentDate)}',
                  12,
                  Colors.black),
              SizedBox(
                height: 10,
              ),
              AppText.getRegularText(
                  'Doctor : ${widget.appointment.doctor}', 12, Colors.black),
              SizedBox(
                height: 10,
              ),
              AppText.getRegularText('Reason :', 12, Colors.black),
              SizedBox(
                height: 4,
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.lightGreenOpacity,
                ),
                child: TextField(
                  controller: _reasonController,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  maxLength: 140,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorTheme.darkGreen,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    errorText: error,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              AppText.getRegularText('Select Datetime :', 12, Colors.black),
              SizedBox(
                height: 4,
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => RescheduleTimeScreen(
                        Doctor(
                          doctorId: widget.appointment.doctorId,
                          specializationName:
                              widget.appointment.doctorSpecialization,
                        ),
                        _getConsultTypeInt(widget.appointment.appointmentType)
                            .toString(),
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      dateTime = result;
                    });
                  }
                },
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorTheme.lightGreenOpacity,
                    ),
                    child: AppText.getRegularText(
                        '$dateTime', 14, ColorTheme.darkGreen)),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: AppButton(
                  color: ColorTheme.buttonColor,
                  buttonTextColor: ColorTheme.white,
                  onClick: () {
                    if (_reasonController.text.toString().trim().isEmpty)
                      setState(() {
                        error = 'Reason is required';
                      });
                    else if (dateTime == 'Select Date Time')
                      Utils.showToast(message: 'Please select new date time');
                    else {
                      setState(() {
                        error = null;
                      });
                      Utils.showAlertDialog(
                          context: context,
                          message:
                              'Are you sure you want to reschedule this appointment ?',
                          onOK: () => _rescheduleApt(),
                          actionNme: 'Yes',
                          nagetive: 'No');
                    }
                  },
                  style: TextStyle(
                    fontSize: AppTextTheme.textSize12,
                    fontWeight: FontWeight.bold,
                  ),
                  text: 'Submit',
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getConsultTypeInt(String type) {
    switch (type) {
      case 'Video Consult':
        return 1;
      case 'Clinic Consult':
        return 2;
        break;
      case 'Home Visit':
        return 3;
        break;
    }
  }

  Future<void> _rescheduleApt() async {
    Loader.showProgress();
    Map<String, dynamic> body = {
      "patid": widget.appointment.patid,
      "appointment_id": widget.appointment.appointmentId,
      "reschedule_reason": "${_reasonController.text}",
      "new_appointment_date": "$dateTime"
    };
    final response = await _appointmentRepo.rescheduleAppointment(body);
    Loader.hide();
    if (response == null) {
      Utils.showSingleButtonAlertDialog(
          context: context,
          message: 'Appointment rescheduled successfully.',
          onClick: () {
            Navigator.of(context).pop();
            widget.onSuccess?.call(true);
          });
    } else {
      Utils.showSingleButtonAlertDialog(
        context: context,
        message: response,
      );
      widget.onSuccess?.call(false);
    }
  }
}
