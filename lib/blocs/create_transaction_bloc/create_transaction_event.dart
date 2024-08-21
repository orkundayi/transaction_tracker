part of 'create_transaction_bloc.dart';

@immutable
sealed class CreateTransactionEvent {
  final TransactionModel transaction;

  const CreateTransactionEvent({required this.transaction});
}

class CreateTransaction extends CreateTransactionEvent {
  const CreateTransaction({required super.transaction});
}
