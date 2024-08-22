import 'currency.dart';

class InstallmentModel {
  int installmentNumber;
  double amount;
  DateTime dueDate;
  CurrencyModel currency;

  InstallmentModel({
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.currency,
  });

  factory InstallmentModel.empty() {
    return InstallmentModel(
      installmentNumber: 0,
      amount: 0.0,
      dueDate: DateTime.now(),
      currency: CurrencyModel.empty(),
    );
  }

  factory InstallmentModel.fromMap(Map<String, dynamic> json) {
    return InstallmentModel(
      installmentNumber: json['installmentNumber'] as int,
      amount: json['amount'] as double,
      dueDate: json['dueDate'] as DateTime,
      currency: CurrencyModel.fromMap(json['currency'] as Map<String, Object>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': dueDate,
      'currency': currency.toMap(),
    };
  }
}
