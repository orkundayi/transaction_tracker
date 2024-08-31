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

class FetchAllTransactions extends GetTransactionEvent {
  final TransactionType? type;
  const FetchAllTransactions(this.type);
}

class FetchLastTransactions extends GetTransactionEvent {
  final TransactionType? type;
  const FetchLastTransactions(this.type);
}

class FetchTotalTransaction extends GetTransactionEvent {}
