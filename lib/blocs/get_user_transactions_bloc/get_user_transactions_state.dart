part of 'get_user_transactions_bloc.dart';

@immutable
sealed class FetchTransactionState {}

final class FetchTransactionInitial extends FetchTransactionState {}

final class FetchingInProgress extends FetchTransactionState {}

final class FetchingSuccess extends FetchTransactionState {
  final List<TransactionModel> transactions;

  FetchingSuccess(this.transactions);
}

final class TransactionFetchError extends FetchTransactionState {
  final Object error;

  TransactionFetchError(this.error);
}
