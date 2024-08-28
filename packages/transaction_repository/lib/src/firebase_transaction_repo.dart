import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:transaction_repository/src/models/transaction.dart';
import 'package:transaction_repository/src/transaction_repo.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final transactionCollection = FirebaseFirestore.instance.collection('transactions');
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
      await transactionCollection.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      log('Transaction update failed: $e');
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactionsForUser(TransactionType type, {DateTime? firstDate, DateTime? lastDate}) {
    return transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? '')
        .where('type', isEqualTo: type.name)
        .where('date', isGreaterThanOrEqualTo: firstDate != null ? Timestamp.fromDate(firstDate) : null)
        .where('date', isLessThanOrEqualTo: lastDate != null ? Timestamp.fromDate(lastDate) : null)
        .orderBy(
          'date',
          descending: true,
        )
        .get()
        .then((snapshot) async {
      debugPrint('snapshot.docs: ${snapshot.docs}');
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<List<TransactionModel>> fetchLastTransactionsForUser(TransactionType type, {DateTime? firstDate, DateTime? lastDate}) {
    return transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? '')
        .where('type', isEqualTo: type.name)
        .where('date', isGreaterThanOrEqualTo: firstDate != null ? Timestamp.fromDate(firstDate) : null)
        .where('date', isLessThanOrEqualTo: lastDate != null ? Timestamp.fromDate(lastDate) : null)
        .orderBy(
          'date',
          descending: true,
        )
        .limit(5)
        .get()
        .then((snapshot) async {
      debugPrint('snapshot.docs: ${snapshot.docs}');
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
    });
  }

  User? getCurrenUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
