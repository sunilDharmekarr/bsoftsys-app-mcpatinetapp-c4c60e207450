// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  RegisterModel({
    this.success,
    this.data,
    this.error,
  });

  String success;
  List<Datum> data;
  String error;

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        success: json["success"],
        data: List<Datum>.from(json["payload"].map((x) => Datum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(data.map((x) => x.toJson())),
        "error": error,
      };
}

class Datum {
  Datum({
    this.id,
    this.patid,
    this.firstName,
    this.middleName,
    this.lastName,
    this.sex,
    this.dob,
    this.mobile,
    this.emergencyContact,
    this.email,
    this.address1,
    this.address2,
    this.country,
    this.state,
    this.city,
    this.pincode,
    this.familyDoctor,
    this.fullName,
    this.profile_pic,
    this.fhead,
    this.relationId,
    this.height,
    this.weight,
    this.bgId,
    this.displayMessage,
  });

  int id;
  int patid;
  String firstName;
  String middleName;
  String lastName;
  String sex;
  String dob;
  String mobile;
  String emergencyContact;
  String email;
  String familyDoctor;
  String fullName;
  String profile_pic;
  bool fhead;
  dynamic height;
  dynamic weight;
  dynamic bgId;
  dynamic relationId;
  String address1;
  String address2;
  String country;
  String state;
  String city;
  String pincode;
  //Only for displaying msg during registration
  String displayMessage;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        patid: json["patid"],
        fullName: json.containsKey("full_name") ? json['full_name'] : '',
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        sex: json["sex"],
        dob: json["dob"],
        mobile: json["mobile"],
        emergencyContact: json["emergency_contact"],
        email: json["email"],
        address1: json["address1"],
        address2: json["address2"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        pincode: json["pincode"],
        familyDoctor: json["family_doctor"],
        profile_pic: json.containsKey('profile_pic') ? json['profile_pic'] : '',
        fhead: json.containsKey('fhead')
            ? (json['fhead'] == "0" ? false : true)
            : false,
        displayMessage:
            json.containsKey("display_msg") ? json['display_msg'] : '',
      );

  factory Datum.fromDatabaseJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        patid: json["patid"],
        fullName: json.containsKey("full_name") ? json['full_name'] : '',
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        sex: json["sex"],
        dob: json["dob"],
        mobile: json["mobile"],
        email: json["email"],
        profile_pic: json.containsKey('profile_pic') ? json['profile_pic'] : '',
        fhead: json.containsKey('fhead')
            ? (json['fhead'] == "0" ? false : true)
            : false,
        relationId: json['relation_id'],
        bgId: json['bg_id'],
        height: json['height'],
        weight: json['weight'],
        address1: json["address1"],
        address2: json["address2"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        pincode: json["pincode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patid": patid,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "sex": sex,
        "dob": dob,
        "mobile": mobile,
        "emergency_contact": emergencyContact,
        "email": email,
        "family_doctor": familyDoctor,
        "profile_pic": profile_pic,
        "address1": address1,
        "address2": address2,
        "country": country,
        "state": state,
        "city": city,
        "pincode": pincode,
      };

  Map<String, dynamic> toDatabase() => {
        "patid": patid,
        "full_name": '$firstName $middleName $lastName',
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "dob": dob.toString(),
        "mobile": mobile,
        "email": email,
        "sex": sex,
        "profile_pic": profile_pic,
        "fhead": "0",
        "relation_id": relationId ?? 0,
        "bg_id": bgId ?? 0,
        "weight": weight ?? "0",
        "height": height ?? "0",
        "address1": address1,
        "address2": address2,
        "country": country,
        "state": state,
        "city": city,
        "pincode": pincode,
      };
}
