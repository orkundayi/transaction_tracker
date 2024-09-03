import '../../firebase_repository.dart';

class TransactionModel {
  String userId;
  String id;
  String? title;
  TransactionType type;
  double amount;
  double? calculatedAmount;
  DateTime date;
  List<InstallmentModel>? installments;
  String currencyCode;
  CategoryModel? category;
  String? note;

  TransactionModel({
    required this.userId,
    this.id = '',
    this.title,
    required this.type,
    required this.amount,
    this.calculatedAmount = 0.0,
    required this.date,
    required this.currencyCode,
    this.category,
    this.installments,
    this.note,
  });

  factory TransactionModel.empty() {
    return TransactionModel(
      userId: '',
      type: TransactionType.expense,
      amount: 0.0,
      calculatedAmount: 0.0,
      date: DateTime.now(),
      currencyCode: '',
    );
  }

  static TransactionModel fromMap(Map<String, dynamic> json) {
    return TransactionModel(
      userId: json['userId'] as String? ?? '',
      id: json['id'],
      title: json['title'],
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: json['amount'],
      calculatedAmount: json['calculatedAmount'],
      date: (json['date'] as Timestamp).toDate(),
      currencyCode: json['currencyCode'],
      category: json['category'] != null ? CategoryModel.fromMap(json['category']) : null,
      note: json['note'],
      installments: json['installments'] != null ? (json['installments'] as List).map((e) => InstallmentModel.fromMap(e)).toList() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'calculatedAmount': calculatedAmount,
      'date': date,
      'currencyCode': currencyCode,
      'category': category?.toMap(category),
      'note': note,
      'installments': installments?.map((e) => e.toMap()).toList(),
    };
  }
}

enum TransactionType {
  income,
  expense,
}

String getTransactionTypeName(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Gelir';
    case TransactionType.expense:
      return 'Gider';
    default:
      return '';
  }
}

enum TransactionMode {
  all,
  last,
}
