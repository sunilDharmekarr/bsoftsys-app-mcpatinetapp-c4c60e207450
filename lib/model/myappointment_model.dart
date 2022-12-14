// To parse this JSON data, do
//
//     final myappointmentModel = myappointmentModelFromJson(jsonString);

import 'dart:convert';

MyappointmentModel myappointmentModelFromJson(String str) =>
    MyappointmentModel.fromJson(json.decode(str));

String myappointmentModelToJson(MyappointmentModel data) =>
    json.encode(data.toJson());

class MyappointmentModel {
  MyappointmentModel({
    this.success,
    this.appointments,
    this.error,
  });

  String success;
  List<Appointment> appointments;
  String error;

  factory MyappointmentModel.fromJson(Map<String, dynamic> json) =>
      MyappointmentModel(
        success: json["success"],
        appointments: List<Appointment>.from(
            json["payload"].map((x) => Appointment.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(appointments.map((x) => x.toJson())),
        "error": error,
      };
}

class Appointment {
  Appointment({
    this.patid,
    this.appointmentId,
    this.appointmentDate,
    this.appointmentType,
    this.doctorId,
    this.doctor,
    this.doctorSpecialization,
    this.chiefComplaint,
    this.statusId,
    this.status,
    this.invoiceNo,
    this.connectUrl,
    this.connectPassword,
    this.followUpAptAvailable,
    this.isPaid,
    this.chatUrl,
    this.amount,
    this.discount,
    this.paid,
    this.amountPayable,
  });

  int patid;
  int appointmentId;
  DateTime appointmentDate;
  String appointmentType;
  int doctorId;
  String doctor;
  String doctorSpecialization;
  String chiefComplaint;
  int statusId;
  String status;
  String invoiceNo;
  String connectUrl;
  String connectPassword;
  int followUpAptAvailable;
  int isPaid;
  String chatUrl;
  double amount;
  double discount;
  double paid;
  double amountPayable;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        patid: json["patid"],
        appointmentId: json["appointment_id"],
        appointmentDate: DateTime.parse(json["appointment_date"]),
        appointmentType: json["appointment_type"],
        doctorId: json["doctor_id"],
        doctor: json["doctor"],
        doctorSpecialization: json["doctor_specialization"],
        chiefComplaint: json["chief_complaint"],
        statusId: json["status_id"],
        status: json["status"],
        invoiceNo: json["invoice_no"],
        connectUrl: json["connect_url"],
        connectPassword: json["connect_password"],
        followUpAptAvailable: json["FollowUpAptAvailable"],
        isPaid: json["is_paid"],
        chatUrl: json["chat_url"],
        amount: json["Amount"],
        discount: json["Discount"],
        paid: json["Paid"],
        amountPayable: json["amount_payable"],
      );

  Map<String, dynamic> toJson() => {
        "patid": patid,
        "appointment_id": appointmentId,
        "appointment_date": appointmentDate.toIso8601String(),
        "appointment_type": appointmentType,
        "doctor_id": doctorId,
        "doctor": doctor,
        "doctor_specialization": doctorSpecialization,
        "chief_complaint": chiefComplaint,
        "status_id": statusId,
        "status": status,
        "invoice_no": invoiceNo,
        "connect_url": connectUrl,
        "connect_password": connectPassword,
        "FollowUpAptAvailable": followUpAptAvailable,
        "is_paid": isPaid,
        "chat_url": chatUrl,
        "Amount": amount,
        "Discount": discount,
        "Paid": paid,
        "amount_payable": amountPayable,
      };
}
