// To parse this JSON data, do
//
//     final availableTime = availableTimeFromJson(jsonString);

import 'dart:convert';

AvailableTime availableTimeFromJson(String str) => AvailableTime.fromJson(json.decode(str));

String availableTimeToJson(AvailableTime data) => json.encode(data.toJson());

class AvailableTime {
  AvailableTime({
    this.success,
    this.slotTime,
    this.error
  });

  String success;
  List<SlotTime> slotTime;
  String error;

  factory AvailableTime.fromJson(Map<String, dynamic> json) => AvailableTime(
    success: json["success"],
    slotTime: List<SlotTime>.from(json["payload"].map((x) => SlotTime.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(slotTime.map((x) => x.toJson())),
    "error": error
  };
}

class SlotTime {
  SlotTime({
    this.slotId,
    this.dayOfWeek,
    this.doctorId,
    this.slotInMinutes,
    this.consultTypeId,
    this.consultType,
    this.date,
    this.slotStart,
    this.slotEnd,
    this.isAvailable,
  });

  int slotId;
  String dayOfWeek;
  int doctorId;
  int slotInMinutes;
  int consultTypeId;
  String consultType;
  DateTime date;
  DateTime slotStart;
  DateTime slotEnd;
  String isAvailable;

  set available(String data){
    isAvailable = data;
  }

  factory SlotTime.fromJson(Map<String, dynamic> json) => SlotTime(
    slotId: json["slot_id"],
    dayOfWeek: json["day_of_week"],
    doctorId: json["doctor_id"],
    slotInMinutes: json["slot_in_minutes"],
    consultTypeId: json["consult_type_id"],
    consultType: json["consult_type"],
    date: DateTime.parse(json["date"]),
    slotStart: DateTime.parse(json["slot_start"]),
    slotEnd: DateTime.parse(json["slot_end"]),
    isAvailable: json["is_available"],
  );

  Map<String, dynamic> toJson() => {
    "slot_id": slotId,
    "day_of_week": dayOfWeek,
    "doctor_id": doctorId,
    "slot_in_minutes": slotInMinutes,
    "consult_type_id": consultTypeId,
    "consult_type": consultType,
    "date": date.toIso8601String(),
    "slot_start": slotStart.toIso8601String(),
    "slot_end": slotEnd.toIso8601String(),
    "is_available": isAvailable,
  };
}
