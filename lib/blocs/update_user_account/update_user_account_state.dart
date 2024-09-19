part of 'update_user_account_bloc.dart';

@immutable
sealed class UpdateUserAccountState {}

final class UpdateUserAccountInitial extends UpdateUserAccountState {}

final class UpdateUserAccountLoading extends UpdateUserAccountState {}

final class UpdateUserAccountSuccess extends UpdateUserAccountState {}

final class UpdateUserAccountError extends UpdateUserAccountState {
  final dynamic error;

  UpdateUserAccountError(this.error);
}
