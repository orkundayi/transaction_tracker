import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:transaction_repository/transaction_repository.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final transactionCollection = FirebaseFirestore.instance.collection('transactions');
  final userAccountCollection = FirebaseFirestore.instance.collection('userAccounts');
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

  @override
  Future<List<TransactionModel>> fetchTransactionsForThisMonth() {
    final todayLocal = DateTime.now().toLocal();
    final firstDateOfThisMonth = DateTime(todayLocal.year, todayLocal.month, 1);
    final lastDateOfThisMonth = DateTime(todayLocal.year, todayLocal.month + 1, 0, 23, 59, 59);
    return transactionCollection
        .where('userId', isEqualTo: getCurrenUser()?.uid ?? '')
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

  // Account operations
  @override
  Future<void> createTurkishAccountForUser() async {
    final userAccount = await userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').get();
    if (!userAccount.exists) {
      UserModel user = UserModel(userId: getCurrenUser()?.uid ?? 'testUser');
      user.accounts.add(AccountModel(code: 'TR', name: 'Türk Lirası Hesabı', balance: 0.0));
      return userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').set(user.toMap());
    }
  }

  @override
  Future<void> createSpesificAccountForUser(AccountModel account) async {
    final userAccount = await userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').get();
    if (userAccount.exists) {
      UserModel user = UserModel.fromMap(userAccount.data()!);
      if (checkIfAccountAlreadyExists(user, account)) {
        return;
      }
      user.accounts.add(account);
      return userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').set(user.toMap());
    }
  }

  @override
  Future<List<AccountModel>> fetchAccountsForUser() async {
    final userAccount = await userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').get();
    if (userAccount.exists) {
      UserModel user = UserModel.fromMap(userAccount.data()!);
      return user.accounts;
    } else {
      return [];
    }
  }

  bool checkIfAccountAlreadyExists(UserModel user, AccountModel account) => user.accounts.firstWhereOrNull((element) => element.code == account.code) != null;
}
