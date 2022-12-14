import 'dart:convert';

AddressModel addressModelFromJson(String data) =>
    AddressModel.fromJson(json.decode(data));

String addressModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
  AddressModel({
    this.success,
    this.addresses,
    this.error,
  });

  String success;
  List<AddressDatum> addresses;
  String error;

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        success: json["success"],
        addresses: List<AddressDatum>.from(
            json["payload"].map((x) => AddressDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(addresses.map((x) => x.toJson())),
        "error": error,
      };
}

class AddressDatum {
  AddressDatum({
    this.id,
    this.patient,
    this.typeId,
    this.type,
    this.address1,
    this.address2,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.pinCode,
  });

  int id;
  int patient;
  int typeId;
  String type;
  String address1;
  String address2;
  String landmark;
  String city;
  String state;
  String country;
  String pinCode;

  factory AddressDatum.fromJson(Map<String, dynamic> json) => AddressDatum(
        id: json["address_id"],
        patient: json["patid"],
        typeId: json["address_type_id"],
        type: json["address_type"],
        address1: json["address_1"],
        address2: json["area"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pinCode: json["pincode"],
        landmark: json["Landmark"],
      );

  Map<String, dynamic> toJson() => {
        "address_id": id,
        "patid": patient,
        "address_type_id": typeId,
        "address_type": type,
        "address_1": address1,
        "area": address2,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pinCode,
        "Landmark": landmark,
      };
}

AddressTypeModel addressTypeModelFromJson(String data) =>
    AddressTypeModel.fromJson(json.decode(data));

String addressTypeModelToJson(AddressTypeModel data) =>
    json.encode(data.toJson());

class AddressTypeModel {
  AddressTypeModel({
    this.success,
    this.addressTypes,
    this.error,
  });

  String success;
  List<AddressTypeDatum> addressTypes;
  String error;

  factory AddressTypeModel.fromJson(Map<String, dynamic> json) =>
      AddressTypeModel(
        success: json["success"],
        addressTypes: List<AddressTypeDatum>.from(
            json["payload"].map((x) => AddressTypeDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(addressTypes.map((x) => x.toJson())),
        "error": error,
      };

  String getName(int id) {
    if (id == 0)
      return 'Default';
    else if (addressTypes.any((element) => element.id == id)) {
      return addressTypes.firstWhere((element) => element.id == id).name;
    }
    return "---";
  }
}

class AddressTypeDatum {
  AddressTypeDatum({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory AddressTypeDatum.fromJson(Map<String, dynamic> json) =>
      AddressTypeDatum(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
