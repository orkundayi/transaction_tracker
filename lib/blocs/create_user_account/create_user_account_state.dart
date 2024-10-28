part of 'create_user_account_bloc.dart';

@immutable
sealed class CreateUserAccountState {}

final class CreateUserAccountInitial extends CreateUserAccountState {}

final class CreateUserAccountInProgress extends CreateUserAccountState {}

final class CreateUserAccountSuccess extends CreateUserAccountState {}

final class CreateUserAccountError extends CreateUserAccountState {
  final Object error;

  CreateUserAccountError(this.error);
}
