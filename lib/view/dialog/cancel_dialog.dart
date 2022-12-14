import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/myappointment_model.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class CancelDialog extends StatefulWidget {
  final Appointment appointment;
  final Function(bool success) onSuccess;
  CancelDialog(this.appointment, this.onSuccess);

  @override
  _CancelDialogState createState() => _CancelDialogState();
}

class _CancelDialogState extends State<CancelDialog> {
  final _reasonController = TextEditingController();
  final _appointmentRepo = AppointmentRepository();

  bool chbx = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: AppText.getBoldText('Cancel appointment'.toUpperCase(),
                      16, ColorTheme.darkGreen)),
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
              Container(
                height: 60,
                child: Row(
                  children: [
                    Checkbox(
                        value: chbx,
                        onChanged: (val) {
                          setState(() {
                            chbx = val;
                          });
                        }),
                    Expanded(
                        child: AppText.getRegularText(
                            'I want appointment fees to be refund in my wallet.',
                            12,
                            ColorTheme.darkGreen))
                  ],
                ),
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
                    else {
                      setState(() {
                        error = null;
                      });

                      Utils.showAlertDialog(
                          context: context,
                          message:
                              'Are you sure you want to cancel this appointment ?',
                          onOK: () => _cancelApt(),
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

  Future<void> _cancelApt() async {
    Loader.showProgress();
    Map<String, dynamic> body = {
      "patid": widget.appointment.patid,
      "appointment_id": widget.appointment.appointmentId,
      "cancel_reason": "${_reasonController.text}",
      "add_money_to_wallet": "${chbx ? '1' : "0"}"
    };
    final response = await _appointmentRepo.cancelAppointment(body);
    Loader.hide();
    if (response == null) {
      Utils.showSingleButtonAlertDialog(
          context: context,
          message:
              'Appointment cancelled successfully.\n\nRefund Comments: $response\n',
          onClick: () {
            Navigator.of(context).pop();
            widget.onSuccess?.call(true);
          });
    } else {
      Utils.showToast(message: 'Failed to cancel appointment', isError: true);
      widget.onSuccess?.call(false);
    }
  }
}
