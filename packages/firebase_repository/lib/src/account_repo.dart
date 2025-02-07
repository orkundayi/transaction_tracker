import 'package:firebase_repository/src/models/account.dart';
import 'package:firebase_repository/src/models/transaction.dart';

abstract class AccountRepository {
  Future<void> createTurkishAccountForUser();

  Future<void> changeBalanceForUserAccount(AccountModel account);

  Future<List<AccountModel>> fetchUserAccounts();

  Future<void> updateUserAccount(TransactionModel transaction);

  Future<void> createUserAccount(AccountModel account);
}
