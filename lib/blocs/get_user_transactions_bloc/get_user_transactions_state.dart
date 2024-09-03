part of 'get_user_transactions_bloc.dart';

@immutable
sealed class FetchTransactionState {}

final class FetchTransactionInitial extends FetchTransactionState {}

final class TransactionFetchingInProgress extends FetchTransactionState {}

final class TransactionFetchSuccess extends FetchTransactionState {
  final List<TransactionModel> transactions;

  TransactionFetchSuccess(this.transactions);
}

final class TransactionFetchError extends FetchTransactionState {
  final Object error;

  TransactionFetchError(this.error);
}
