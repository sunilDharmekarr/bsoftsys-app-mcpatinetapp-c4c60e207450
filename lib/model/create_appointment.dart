// To parse this JSON data, do
//
//     final createAppointment = createAppointmentFromJson(jsonString);

import 'dart:convert';

CreateAppointment createAppointmentFromJson(String str) => CreateAppointment.fromJson(json.decode(str));

String createAppointmentToJson(CreateAppointment data) => json.encode(data.toJson());

class CreateAppointment {
  CreateAppointment({
    this.patid,
    this.docId,
    this.slotId,
    this.appointmentDate,
    this.appointmentType,
    this.promoCode,
    this.amount,
    this.discount,
    this.paidAmount,
    this.paymentId,
    this.specialization,
  });

  String patid;
  String docId;
  int slotId;
  String appointmentDate;
  String appointmentType;
  String promoCode;
  String amount;
  String discount;
  String paidAmount;
  String paymentId;
  String specialization;

  factory CreateAppointment.fromJson(Map<String, dynamic> json) => CreateAppointment(
    patid: json["patid"],
    docId: json["doc_id"],
    slotId: json["slot_id"],
    appointmentDate: json["appointment_date"],
    appointmentType: json["appointment_type"],
    promoCode: json["promo_code"],
    amount: json["amount"],
    discount: json["discount"],
    paidAmount: json["paid_amount"],
    paymentId: json["payment_id"],
  );

  Map<String, dynamic> toJson() => {
    "patid": patid,
    "doc_id": docId,
    "slot_id": slotId,
    "appointment_date": appointmentDate,
    "appointment_type": appointmentType,
    "promo_code": promoCode,
    "amount": amount,
    "discount": discount,
    "paid_amount": paidAmount,
    "payment_id": paymentId,
  };
}
