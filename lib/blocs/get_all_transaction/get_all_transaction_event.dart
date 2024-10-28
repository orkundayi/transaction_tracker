part of 'get_all_transaction_bloc.dart';

@immutable
sealed class GetAllTransactionEvent {
  const GetAllTransactionEvent();
}

class FetchAllTransactions extends GetAllTransactionEvent {}
