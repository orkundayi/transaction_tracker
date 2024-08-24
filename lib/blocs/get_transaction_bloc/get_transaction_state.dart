part of 'get_transaction_bloc.dart';

@immutable
sealed class GetTransactionState {}

final class GetTransactionInitial extends GetTransactionState {}

final class GetTransactionInProgress extends GetTransactionState {}

final class GetTransactionSuccess extends GetTransactionState {
  final List<TransactionModel> transactions;

  GetTransactionSuccess(this.transactions);
}

final class GetTransactionFailure extends GetTransactionState {
  final Object error;

  GetTransactionFailure(this.error);
}
