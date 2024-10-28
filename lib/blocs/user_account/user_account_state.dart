part of 'user_account_cubit.dart';

@immutable
sealed class UserAccountState {}

final class UserAccountInitial extends UserAccountState {}

final class UserAccountIndexUpdating extends UserAccountState {}

final class UserAccountIndexUpdated extends UserAccountState {}

final class UserAccountIndexUpdateError extends UserAccountState {
  final Object error;

  UserAccountIndexUpdateError(this.error);
}
