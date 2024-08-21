import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaction_repository/src/models/transaction.dart';
import 'package:transaction_repository/src/transaction_repo.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final transactionCollection =
      FirebaseFirestore.instance.collection('transactions');
  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final transactionId = transactionCollection.doc().id;
      transaction.id = transactionId;
      await transactionCollection.doc(transactionId).set(transaction.toMap());
    } catch (e) {
      log('Transaction addition failed: $e');
    }
  }

  @override
  Future<void> removeTransaction(TransactionModel transaction) async {
    try {
      await transactionCollection.doc(transaction.id).delete();
    } catch (e) {
      log('Transaction deletion failed: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await transactionCollection
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      log('Transaction update failed: $e');
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactionsForUser(String userId) {
    return transactionCollection
        .where('userId', isEqualTo: userId)
        .get()
        .then((snapshot) async {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    });
  }
}
