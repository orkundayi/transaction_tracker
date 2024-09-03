import 'package:transaction_repository/src/models/account.dart';

class UserModel {
  final String userId;
  List<AccountModel> accounts;

  UserModel({required this.userId, List<AccountModel>? accounts}) : accounts = accounts ?? [];

  factory UserModel.empty() {
    return UserModel(
      userId: '',
      accounts: [],
    );
  }

  static UserModel fromMap(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      accounts: (json['accounts'] as List).map((e) => AccountModel.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'accounts': accounts.map((e) => e.toMap()).toList(),
    };
  }
}
