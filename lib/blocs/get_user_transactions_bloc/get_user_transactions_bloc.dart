import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_user_transactions_event.dart';
part 'get_user_transactions_state.dart';

class GetUserTransactionsBloc extends Bloc<GetTransactionEvent, FetchTransactionState> {
  final TransactionRepository transactionRepository;
  GetUserTransactionsBloc(this.transactionRepository) : super(FetchTransactionInitial()) {
    on<FetchAllTransactions>((event, emit) async {
      emit(FetchingInProgress());
      try {
        final transactions = await transactionRepository.fetchTransactionsForUser();
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchLastTransactions>((event, emit) async {
      emit(FetchingInProgress());
      try {
        final transactions = await transactionRepository.fetchLastTransactionsForUser();
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });
  }
}
