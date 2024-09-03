import 'package:firebase_repository/src/models/account.dart';

abstract class AccountRepository {
  Future<void> createTurkishAccountForUser();
  Future<void> createSpesificAccountForUser(AccountModel account);

  Future<void> changeBalanceForUserAccount(AccountModel account);

  Future<List<AccountModel>> fetchUserAccounts();
}
