part of 'get_user_accounts_bloc.dart';

@immutable
sealed class GetUserAccountsEvent {}

final class FetchUserAccounts extends GetUserAccountsEvent {}
