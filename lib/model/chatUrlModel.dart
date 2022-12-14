// To parse this JSON data, do
//
//     final chatUrlModel = chatUrlModelFromJson(jsonString);

import 'dart:convert';

ChatUrlModel chatUrlModelFromJson(String str) => ChatUrlModel.fromJson(json.decode(str));

String chatUrlModelToJson(ChatUrlModel data) => json.encode(data.toJson());

class ChatUrlModel {
    ChatUrlModel({
        this.success,
        this.payload,
        this.error,
    });

    String success;
    List<Payload> payload;
    String error;

    factory ChatUrlModel.fromJson(Map<String, dynamic> json) => ChatUrlModel(
        success: json["success"],
        payload: List<Payload>.from(json["payload"].map((x) => Payload.fromJson(x))),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(payload.map((x) => x.toJson())),
        "error": error,
    };
}

class Payload {
    Payload({
        this.appointmentId,
        this.chatUrl,
    });

    int appointmentId;
    String chatUrl;

    factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        appointmentId: json["appointment_id"],
        chatUrl: json["chat_url"],
    );

    Map<String, dynamic> toJson() => {
        "appointment_id": appointmentId,
        "chat_url": chatUrl,
    };
}
