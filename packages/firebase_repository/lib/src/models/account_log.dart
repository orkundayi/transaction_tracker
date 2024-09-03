class AccountLog {
  final double oldAmount;
  final double newAmount;
  final DateTime date;

  AccountLog({
    required this.oldAmount,
    required this.newAmount,
    required this.date,
  });

  static AccountLog fromMap(Map<String, dynamic> json) {
    return AccountLog(
      oldAmount: json['oldAmount'] as double,
      newAmount: json['newAmount'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'oldAmount': oldAmount,
      'newAmount': newAmount,
      'date': date.toIso8601String(),
    };
  }
}
