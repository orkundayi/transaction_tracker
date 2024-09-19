part of 'update_user_account_bloc.dart';

@immutable
sealed class UpdateUserAccount {
  final TransactionModel transaction;

  const UpdateUserAccount({required this.transaction});
}

class UpdateUserAccountEvent extends UpdateUserAccount {
  const UpdateUserAccountEvent({required super.transaction});
}
