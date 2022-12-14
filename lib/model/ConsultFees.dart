// To parse this JSON data, do
//
//     final consultFees = consultFeesFromJson(jsonString);

import 'dart:convert';

ConsultFees consultFeesFromJson(String str) => ConsultFees.fromJson(json.decode(str));


class ConsultFees {
  ConsultFees({
    this.success,
    this.fee,
    this.error,
  });

  String success;
  List<Fee> fee=[];
  String error;

  factory ConsultFees.fromJson(Map<String, dynamic> json) => ConsultFees(
    success: json["success"],
    fee: List<Fee>.from(json["payload"].map((x) => Fee.fromJson(x))),
    error: json["error"],
  );

}

class Fee {
  Fee({
    this.id,
    this.consultType,
    this.firstConsultationFee,
    this.followupConsultationFee,
    this.doctorId,
    this.doctorName,
  });

  dynamic id;
  String consultType;
  dynamic firstConsultationFee;
  dynamic followupConsultationFee;
  dynamic doctorId;
  String doctorName;

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
    id: json["id"],
    consultType: json["consult_type"],
    firstConsultationFee:json.containsKey('first_consultation_fee')?
    double.parse(json["first_consultation_fee"].toString()).toStringAsFixed(0):
    double.parse(json["fast_appointment_fee"].toString()).toStringAsFixed(0),
    followupConsultationFee:json.containsKey('followup_consultation_fee')?
    double.parse(json["followup_consultation_fee"].toString()).toStringAsFixed(0):'',
    doctorId: json["doctor_id"],
    doctorName: json["doctor_name"],
  );

}
