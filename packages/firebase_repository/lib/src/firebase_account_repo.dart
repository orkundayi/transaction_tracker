import 'dart:async';

import 'package:collection/collection.dart';

import '../firebase_repository.dart';

class FirebaseAccountRepository implements AccountRepository {
  final userAccountCollection = FirebaseFirestore.instance.collection('userAccounts');

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
  Future<List<AccountModel>> fetchUserAccounts() async {
    final userAccount = await userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').get();
    if (userAccount.exists) {
      UserModel user = UserModel.fromMap(userAccount.data()!);
      return user.accounts;
    } else {
      return [];
    }
  }

  @override
  Future<void> changeBalanceForUserAccount(AccountModel account) async {
    final userAccount = await userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').get();
    if (userAccount.exists) {
      UserModel user = UserModel.fromMap(userAccount.data()!);
      final oldBalance = user.accounts.firstWhereOrNull((element) => element.code == account.code)?.balance;
      final selectedAccount = user.accounts.firstWhereOrNull((element) => element.code == account.code);
      selectedAccount?.balance += account.balance;
      selectedAccount?.logs.add(AccountLog(
        date: DateTime.now().toLocal(),
        oldAmount: oldBalance ?? 0.0,
        newAmount: account.balance,
      ));
      return userAccountCollection.doc(getCurrenUser()?.uid ?? 'testUser').set(user.toMap());
    }
  }

  bool checkIfAccountAlreadyExists(UserModel user, AccountModel account) => user.accounts.firstWhereOrNull((element) => element.code == account.code) != null;
}
