// To parse this JSON data, do
//
//     final wallet = walletFromJson(jsonString);

import 'dart:convert';

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  Wallet({
    this.success,
    this.walletBalance,
    this.error,
  });

  String success;
  List<WalletBalance> walletBalance;
  String error;

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    success: json["success"],
    walletBalance: List<WalletBalance>.from(json["payload"].map((x) => WalletBalance.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(walletBalance.map((x) => x.toJson())),
    "error": error,
  };
}

class WalletBalance {
  WalletBalance({
    this.patid,
    this.walletBalance,
  });

  int patid;
  double walletBalance;

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    patid: json["patid"],
    walletBalance: json["wallet_balance"],
  );

  Map<String, dynamic> toJson() => {
    "patid": patid,
    "wallet_balance": walletBalance??0,
  };
}
