import 'package:firebase_repository/firebase_repository.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> removeTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> fetchTransactionsForUser(TransactionType type, {DateTime? firstDate, DateTime? lastDate});
  Future<List<TransactionModel>> fetchLastTransactionsForUser(TransactionType type, {DateTime? firstDate, DateTime? lastDate, AccountModel? account});
  Future<List<TransactionModel>> fetchTransactionsForThisMonth();
}
