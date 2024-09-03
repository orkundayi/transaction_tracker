import 'package:cloud_firestore/cloud_firestore.dart';

import 'currency.dart';

class InstallmentModel {
  int installmentNumber;
  double amount;
  double calculatedAmount;
  DateTime dueDate;
  CurrencyModel currency;

  InstallmentModel({
    required this.installmentNumber,
    required this.amount,
    this.calculatedAmount = 0.0,
    required this.dueDate,
    required this.currency,
  });

  factory InstallmentModel.empty() {
    return InstallmentModel(
      installmentNumber: 0,
      amount: 0.0,
      calculatedAmount: 0.0,
      dueDate: DateTime.now().toLocal(),
      currency: CurrencyModel.empty(),
    );
  }

  factory InstallmentModel.fromMap(Map<String, dynamic> json) {
    return InstallmentModel(
      installmentNumber: json['installmentNumber'] as int,
      amount: json['amount'] as double,
      calculatedAmount: json['calculatedAmount'] as double,
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      currency: CurrencyModel.fromMap(json['currency'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'installmentNumber': installmentNumber,
      'amount': amount,
      'calculatedAmount': calculatedAmount,
      'dueDate': dueDate,
      'currency': currency.toMap(),
    };
  }
}
