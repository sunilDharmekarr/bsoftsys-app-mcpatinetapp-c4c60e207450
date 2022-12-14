// To parse this JSON data, do
//
//     final transactionModel = transactionModelFromJson(jsonString);

import 'dart:convert';

TransactionModel transactionModelFromJson(String str) => TransactionModel.fromJson(json.decode(str));

String transactionModelToJson(TransactionModel data) => json.encode(data.toJson());

class TransactionModel {
  TransactionModel({
    this.success,
    this.transaction,
    this.error,
  });

  final String success;
   List<Transaction> transaction=[];
  final String error;

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    success: json["success"],
    transaction: List<Transaction>.from(json["payload"].map((x) => Transaction.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(transaction.map((x) => x.toJson())),
    "error": error,
  };
}

class Transaction {
  Transaction({
    this.patid,
    this.transactionDate,
    this.remarks,
    this.credit,
    this.debit,
    this.closingBalance,
    this.invoiceNo,
  });

  int patid;
  DateTime transactionDate;
  String remarks;
  double credit;
  double debit;
  int closingBalance;
  dynamic invoiceNo;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    patid: json["patid"],
    transactionDate: DateTime.parse(json["transaction_date"]),
    remarks: json["remarks"],
    credit: json["credit"],
    debit: json["debit"],
    closingBalance: json["closing_balance"],
    invoiceNo:json.containsKey('invoice_no')?  json["invoice_no"]:'',
  );

  Map<String, dynamic> toJson() => {
    "patid": patid,
    "transaction_date": transactionDate.toIso8601String(),
    "remarks": remarks,
    "credit": credit,
    "debit": debit,
    "closing_balance": closingBalance,
    "invoice_no":invoiceNo,
  };
}
