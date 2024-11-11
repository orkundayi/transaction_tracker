import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../firebase_repository.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final transactionCollection = FirebaseFirestore.instance.collection('transactions');
  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final transactionId = transactionCollection.doc().id;
      transaction.id = transactionId;
      transaction.userId = getCurrenUser()?.uid ?? 'testUser';
      await transactionCollection.doc(transactionId).set(transaction.toMap());
    } catch (e) {
      log('Transaction addition failed: $e');
    }
  }

  @override
  Future<void> removeTransaction(TransactionModel transaction) async {
    try {
      transaction.userId = getCurrenUser()?.uid ?? 'testUser';
      await transactionCollection.doc(transaction.id).delete();
    } catch (e) {
      log('Transaction deletion failed: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      transaction.userId = getCurrenUser()?.uid ?? 'testUser';
      await transactionCollection.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      log('Transaction update failed: $e');
    }
  }

  @override
  Future<List<TransactionModel>> fetchTransactionsForUser(TransactionType type,
      {DateTime? firstDate, DateTime? lastDate}) {
    return transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? 'testUser')
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
  Future<List<TransactionModel>> fetchLastTransactionsForUser(TransactionType type,
      {DateTime? firstDate, DateTime? lastDate, AccountModel? account}) {
    Query query = transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? 'testUser')
        .where('type', isEqualTo: type.name);

    if (account != null) {
      query = query.where('accountCode', isEqualTo: account.code);
    }

    if (firstDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDate));
    }
    if (lastDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDate));
    }

    return query.orderBy('date', descending: true).limit(5).get().then((snapshot) async {
      debugPrint('snapshot.docs: ${snapshot.docs}');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<List<TransactionModel>> fetchTransactionsForThisMonth() {
    final todayLocal = DateTime.now().toLocal();
    final firstDateOfThisMonth = DateTime(todayLocal.year, todayLocal.month, 1);
    final lastDateOfThisMonth = DateTime(todayLocal.year, todayLocal.month + 1, 0, 23, 59, 59);
    return transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? 'testUser')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDateOfThisMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDateOfThisMonth))
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

  User? getCurrenUser() {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Future<TransactionModel?> fetchTransaction(String transactionId) {
    return transactionCollection.doc(transactionId).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return TransactionModel.fromMap(data);
        } else {
          return null;
        }
      } else {
        return null;
      }
    });
  }
}
