// To parse this JSON data, do
//
//     final labSlotModel = labSlotModelFromJson(jsonString);

import 'dart:convert';

LabSlotModel labSlotModelFromJson(String str) => LabSlotModel.fromJson(json.decode(str));

String labSlotModelToJson(LabSlotModel data) => json.encode(data.toJson());

class LabSlotModel {
  LabSlotModel({
    this.success,
    this.slots,
    this.error,
  });

  String success;
  List<Slot> slots=[];
  String error;

  factory LabSlotModel.fromJson(Map<String, dynamic> json) => LabSlotModel(
    success: json["success"],
    slots: List<Slot>.from(json["payload"].map((x) => Slot.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
    "error": error,
  };
}

class Slot {
  Slot({
    this.id,
    this.collectionSlot,
  });

  int id;
  String collectionSlot;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json["id"],
    collectionSlot: json["collection_slot"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collection_slot": collectionSlot,
  };
}
