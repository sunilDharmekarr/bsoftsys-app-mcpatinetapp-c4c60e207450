import 'dart:convert';

UrlToShare urlToShareFromJson(String str) => UrlToShare.fromJson(json.decode(str));

String urlToShareToJson(UrlToShare data) => json.encode(data.toJson());

class UrlToShare {
  UrlToShare({
    this.success,
    this.payload,
    this.error,
  });

  String success;
  String payload;
  String error;

  factory UrlToShare.fromJson(Map<String, dynamic> json) => UrlToShare(
    success: json["success"],
    payload: json["payload"],
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": payload,
    "error": error,
  };
}
