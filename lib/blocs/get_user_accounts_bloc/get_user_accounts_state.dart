part of 'get_user_accounts_bloc.dart';

@immutable
sealed class GetUserAccountsState {}

final class GetUserAccountsInitial extends GetUserAccountsState {}

final class FetchingInProgress extends GetUserAccountsState {}

final class AccountsFetchSuccess extends GetUserAccountsState {
  final List<AccountModel> accounts;

  AccountsFetchSuccess(this.accounts);
}

final class AccountFetchError extends GetUserAccountsState {
  final Object error;

  AccountFetchError(this.error);
}
