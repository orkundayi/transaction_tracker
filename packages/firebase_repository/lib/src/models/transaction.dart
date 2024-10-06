import '../../firebase_repository.dart';

class TransactionModel {
  String userId;
  String id;
  String? title;
  String? accountCode;
  TransactionType type;
  double amount;
  double? currencyRate;
  double? calculatedAmount;
  DateTime date;
  List<InstallmentModel>? installments;
  String currencyCode;
  String toCurrencyCode;
  CategoryModel? category;
  String? note;

  TransactionModel({
    required this.userId,
    this.id = '',
    this.title,
    this.accountCode,
    required this.type,
    required this.amount,
    this.currencyRate = 0.0,
    this.calculatedAmount = 0.0,
    required this.date,
    required this.currencyCode,
    this.toCurrencyCode = '',
    this.category,
    this.installments,
    this.note,
  });

  factory TransactionModel.empty() {
    return TransactionModel(
      userId: '',
      type: TransactionType.expense,
      amount: 0.0,
      currencyRate: 0.0,
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
      type: getTransactionType(json['type']),
      accountCode: json['accountCode'],
      amount: json['amount'],
      currencyRate: json['currencyRate'],
      calculatedAmount: json['calculatedAmount'],
      date: (json['date'] as Timestamp).toDate(),
      installments: json['installments'] != null ? (json['installments'] as List).map((e) => InstallmentModel.fromMap(e)).toList() : null,
      currencyCode: json['currencyCode'],
      toCurrencyCode: json['toCurrencyCode'],
      category: json['category'] != null ? CategoryModel.fromMap(json['category']) : null,
      note: json['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'accountCode': accountCode,
      'type': type.name,
      'amount': amount,
      'currencyRate': currencyRate,
      'calculatedAmount': calculatedAmount,
      'date': date,
      'currencyCode': currencyCode,
      'toCurrencyCode': toCurrencyCode,
      'category': category?.toMap(category),
      'note': note,
      'installments': installments?.map((e) => e.toMap()).toList(),
    };
  }
}

enum TransactionType {
  income,
  expense,
  transfer,
}

String getTransactionTypeName(TransactionType type) {
  return type.name;
}

TransactionType getTransactionType(String name) {
  switch (name) {
    case 'Gelir':
      return TransactionType.income;
    case 'Gider':
      return TransactionType.expense;
    case 'Transfer':
      return TransactionType.transfer;
    default:
      return TransactionType.expense;
  }
}

enum TransactionMode {
  all,
  last,
}
