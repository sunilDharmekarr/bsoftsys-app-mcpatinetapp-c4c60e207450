// To parse this JSON data, do
//
//     final videoCallTokenModel = videoCallTokenModelFromJson(jsonString);

import 'dart:convert';

VideoCallTokenModel videoCallTokenModelFromJson(String str) => VideoCallTokenModel.fromJson(json.decode(str));

String videoCallTokenModelToJson(VideoCallTokenModel data) => json.encode(data.toJson());

class VideoCallTokenModel {
    VideoCallTokenModel({
        this.success,
        this.payload,
        this.error,
    });

    String success;
    Payload payload;
    String error;

    factory VideoCallTokenModel.fromJson(Map<String, dynamic> json) => VideoCallTokenModel(
        success: json["success"],
        payload: Payload.fromJson(json["payload"]),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "payload": payload.toJson(),
        "error": error,
    };
}

class Payload {
    Payload({
        this.key,
    });

    String key;

    factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        key: json["key"],
    );

    Map<String, dynamic> toJson() => {
        "key": key,
    };
}

