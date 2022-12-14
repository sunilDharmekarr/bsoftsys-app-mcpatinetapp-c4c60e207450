import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/appointment_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class BookAppointmentSuccessDialog extends StatelessWidget {
  final Function onClick;
  final Appointment appointment;
  BookAppointmentSuccessDialog({this.onClick, this.appointment});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Your appointment has been registered successfully.',
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _getView('Appointment ID:', '${appointment?.appointmentId}'),
            _getView('Appointment Date:',
                '${Utils.getReadableDate(appointment?.appointmentDate)}'),
            _getView('Appointment Time:',
                '${Utils.getReadableAppointmentTime(appointment?.appointmentDate)}'),
            _getView('Appointment Type:', '${appointment?.appointmentType}'),
            _getView(
                'Appointment Status:', '${appointment?.appointmentStatus}'),
            _getView('Doctor:', '${appointment?.doctorName}'),
            _getView('Specialization:', '${appointment?.specializationName}'),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                child: TextView(
                  text: "Ok",
                  style: AppTextTheme.textTheme12Regular,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  primary: ColorTheme.buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onClick();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _getView(String label, String data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            textScaleFactor: 1.0,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          Flexible(
            child: Text(
              data,
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
