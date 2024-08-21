import 'category.dart';
import 'installment.dart';

class TransactionModel {
  final String userId;
  String id;
  String? title;
  TransactionType type;
  double amount;
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
      date: DateTime.now(),
      currencyCode: '',
    );
  }

  static TransactionModel fromMap(Map<String, dynamic> json) {
    return TransactionModel(
      userId: json['userId'] as String? ?? '',
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: json['amount'] as double,
      date: json['date'] as DateTime,
      currencyCode: json['currencyCode'] as String,
      category: json['category'] != null
          ? CategoryModel.fromMap(json['category'] as Map<String, Object>)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'date': date,
      'currencyCode': currencyCode,
      'category': category?.toMap(category),
      'note': note,
    };
  }
}

enum TransactionType {
  income,
  expense,
}
