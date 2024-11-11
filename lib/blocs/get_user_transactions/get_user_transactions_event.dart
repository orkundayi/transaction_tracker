part of 'get_user_transactions_bloc.dart';

@immutable
sealed class GetTransactionEvent {
  const GetTransactionEvent();
}

class FetchTransactions extends GetTransactionEvent {
  final TransactionType? type;
  final TransactionMode? mode;
  final DateTimeRange? dateRange;
  const FetchTransactions(this.type, this.mode, this.dateRange);
}

class FetchUserTransactions extends GetTransactionEvent {
  final TransactionType? type;
  const FetchUserTransactions(this.type);
}

class FetchLastTransactions extends GetTransactionEvent {
  final TransactionType? type;
  const FetchLastTransactions(this.type);
}

class FetchSingleTransaction extends GetTransactionEvent {
  final String transactionId;
  const FetchSingleTransaction(this.transactionId);
}
