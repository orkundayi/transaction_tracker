part of 'create_user_account_bloc.dart';

@immutable
sealed class CreateUserAccountEvent {}

final class CreateUserAccount extends CreateUserAccountEvent {
  final AccountModel account;

  CreateUserAccount(this.account);
}
