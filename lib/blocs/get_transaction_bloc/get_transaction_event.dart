part of 'get_transaction_bloc.dart';

@immutable
sealed class GetTransactionEvent {
  final List<TransactionModel> transactions;

  const GetTransactionEvent({required this.transactions});
}
