part of 'get_user_transactions_bloc.dart';

@immutable
sealed class GetTransactionEvent {
  const GetTransactionEvent();
}

class FetchAllTransactions extends GetTransactionEvent {
  const FetchAllTransactions();
}

class FetchLastTransactions extends GetTransactionEvent {
  const FetchLastTransactions();
}
