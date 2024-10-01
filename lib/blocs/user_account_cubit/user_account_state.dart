part of 'user_account_cubit.dart';

@immutable
sealed class UserAccountState {}

final class UserAccountInitial extends UserAccountState {}

final class UserAccountIndexUpdated extends UserAccountState {
  final int index;
  final AccountModel? account;

  UserAccountIndexUpdated(this.index, this.account);
}
