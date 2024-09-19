import 'package:firebase_repository/src/models/account_log.dart';

class AccountModel {
  String code;
  String name;
  double balance;
  List<AccountLog> logs;

  AccountModel({
    required this.code,
    required this.name,
    required this.balance,
    List<AccountLog>? logs,
  }) : logs = logs ?? [];

  factory AccountModel.emty() {
    return AccountModel(
      code: '',
      name: '',
      balance: 0.0,
    );
  }

  static AccountModel fromMap(Map<String, dynamic> json) {
    return AccountModel(
      code: json['code'] as String,
      name: json['name'] as String,
      balance: double.tryParse(json['balance'].toString()) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'balance': balance,
    };
  }
}
