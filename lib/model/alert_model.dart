// To parse this JSON data, do
//
//     final alertModel = alertModelFromJson(jsonString);

import 'dart:convert';

AlertModel alertModelFromJson(String str) => AlertModel.fromJson(json.decode(str));

String alertModelToJson(AlertModel data) => json.encode(data.toJson());

class AlertModel {
    AlertModel({
        this.success,
        this.alert,
        this.error,
    });

    String success;
    List<Alert> alert;
    String error;

    factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        success: json["success"],
        alert: List<Alert>.from(json["payload"].map((x) => Alert.fromJson(x))),
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(alert.map((x) => x.toJson())),
        "error": error,
    };
}

class Alert {
    Alert({
        this.alertId,
        this.patId,
        this.alertDate,
        this.alertDetails,
        this.isRead,
    });

    dynamic alertId;
    int patId;
    DateTime alertDate;
    String alertDetails;
    bool isRead;

    set read(bool data )=>isRead=data;

    factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        alertId: json["alert_id"],
        patId: json["pat_id"],
        alertDate: DateTime.parse(json["alert_date"]),
        alertDetails: json["alert_details"],
        isRead: json["is_read"],
    );

    Map<String, dynamic> toJson() => {
        "alert_id": alertId,
        "pat_id": patId,
        "alert_date": alertDate.toIso8601String(),
        "alert_details": alertDetails,
        "is_read": isRead,
    };
}
