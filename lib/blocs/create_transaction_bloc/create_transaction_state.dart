part of 'create_transaction_bloc.dart';

@immutable
sealed class CreateTransactionState {}

final class CreateTransactionInitial extends CreateTransactionState {}

final class CreateTransactionLoading extends CreateTransactionState {}

final class CreateTransactionSuccess extends CreateTransactionState {
  final TransactionModel transaction;

  CreateTransactionSuccess(this.transaction);
}

final class CreateTransactionFailure extends CreateTransactionState {
  final Object error;

  CreateTransactionFailure(this.error);
}
