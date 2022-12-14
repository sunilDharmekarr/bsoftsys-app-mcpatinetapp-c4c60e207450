// To parse this JSON data, do
//
//     final appointmentModel = appointmentModelFromJson(jsonString);

import 'dart:convert';

AppointmentModel appointmentModelFromJson(String str) => AppointmentModel.fromJson(json.decode(str));

String appointmentModelToJson(AppointmentModel data) => json.encode(data.toJson());

class AppointmentModel {
  AppointmentModel({
    this.success,
    this.appointment,
    this.error,
  });

  String success;
  List<Appointment> appointment;
  String error;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
    success: json["success"],
    appointment: List<Appointment>.from(json["payload"].map((x) => Appointment.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(appointment.map((x) => x.toJson())),
    "error": error,
  };
}

class Appointment {
    Appointment({
        this.appointmentId,
        this.invoiceNo,
        this.appointmentDate,
        this.appointmentType,
        this.appointmentStatus,
        this.doctorName,
        this.specializationName,
    });

    int appointmentId;
    String invoiceNo;
    DateTime appointmentDate;
    String appointmentType;
    String appointmentStatus;
    String doctorName;
    String specializationName;

    factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        appointmentId: json["appointment_id"],
        invoiceNo: json["invoice_no"],
        appointmentDate: DateTime.parse(json["appointment_date"]),
        appointmentType: json["appointment_type"],
        appointmentStatus: json["appointment_status"],
        doctorName: json["doctor_name"],
        specializationName: json["specialization_name"],
    );

    Map<String, dynamic> toJson() => {
        "appointment_id": appointmentId,
        "invoice_no": invoiceNo,
        "appointment_date": appointmentDate.toIso8601String(),
        "appointment_type": appointmentType,
        "appointment_status": appointmentStatus,
        "doctor_name": doctorName,
        "specialization_name": specializationName,
    };
}
