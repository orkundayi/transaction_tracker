part of 'get_all_transaction_bloc.dart';

@immutable
sealed class GetAllTransactionState {}

final class GetAllTransactionInitial extends GetAllTransactionState {}

final class FetchingInProgress extends GetAllTransactionState {}

final class FetchingSuccess extends GetAllTransactionState {
  final List<TransactionModel> transactions;

  FetchingSuccess(this.transactions);
}

final class AllTransactionFetchError extends GetAllTransactionState {
  final Object error;

  AllTransactionFetchError(this.error);
}
