// To parse this JSON data, do
//
//     final urlsModel = urlsModelFromJson(jsonString);

import 'dart:convert';

UrlsModel urlsModelFromJson(String str) => UrlsModel.fromJson(json.decode(str));


class UrlsModel {
  UrlsModel({
    this.success,
    this.urls,
    this.error,
  });

  String success;
  Url urls;
  String error;


  factory UrlsModel.fromJson(Map<String, dynamic> json){
    List<Url> url = [];
    Url urlData;
    if(json.containsKey('payload')){
      url = List<Url>.from(json["payload"].map((x) => Url.fromJson(x)));
    }

    if(url.length>0){
      urlData = url.first;
    }

    return UrlsModel(
      success: json["success"],
      urls: urlData,
      error: json["error"],
    );
  }
}

class Url {
  Url({
    this.aboutusUrl,
    this.privacypolicyUrl,
    this.termsandconditionUrl,
    this.vipconciergeUrl,
    this.homecareUrl,
    this.plansurgeryUrl,
    this.immunizationUrl
  });

  String aboutusUrl;
  String privacypolicyUrl;
  String termsandconditionUrl;
  String vipconciergeUrl;
  String homecareUrl;
  String plansurgeryUrl;
  String immunizationUrl;

  factory Url.fromJson(Map<String, dynamic> json) => Url(
    aboutusUrl: json["aboutus_url"],
    privacypolicyUrl: json["privacypolicy_url"],
    termsandconditionUrl: json["termsandcondition_url"],
    vipconciergeUrl: json["vipconcierge_url"],
    homecareUrl: json["homecare_url"],
    plansurgeryUrl: json["plansurgery_url"],
    immunizationUrl: json['immunization_url'],
  );

}
