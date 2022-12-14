// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    this.patid,
    this.appointmentId,
    this.speciliazationId,
    this.symptomId,
    this.questionId,
    this.answerId,
    this.answerText,
    this.attchment,
    this.questionText,
    this.attType,
  });

  int patid;
  int appointmentId;
  int speciliazationId;
  int symptomId;
  int questionId;
  String answerId;
  String answerText;
  String questionText;
  String attType;
  String attchment=null;

  set setPatientId(int id){
    patid=id;
  }

  set setAppointmentId(int id){
    appointmentId = id;
  }

  set setSpecializationId(int id){
    speciliazationId = id;
  }

  set setAttachment(String data){
    attchment=data;
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    patid: json["patid"],
    appointmentId: json["appointment_id"],
    speciliazationId: json["speciliazation_id"],
    symptomId: json["symptom_id"],
    questionId: json["question_id"],
    answerId: json["answer_id"],
    answerText: json["answer_text"],

    attchment: json["attchment"],
  );

  Map<String, String> toJson() => {
    "patid": patid.toString(),
    "appointment_id": appointmentId.toString(),
    "speciliazation_id": speciliazationId.toString(),
    "symptom_id": symptomId.toString(),
    "question_id": questionId.toString(),
    "answer_id": answerId,
    "answer_text": answerText,
    "attchment": attchment,
  };


}
