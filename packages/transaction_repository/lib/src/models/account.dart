class AccountModel {
  final String code;
  final String name;
  final double balance;

  AccountModel({
    required this.code,
    required this.name,
    required this.balance,
  });

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
      balance: json['balance'] as double,
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
