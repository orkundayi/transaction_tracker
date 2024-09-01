import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_all_transaction_event.dart';
part 'get_all_transaction_state.dart';

class GetAllTransactionBloc extends Bloc<FetchAllTransactions, GetAllTransactionState> {
  final TransactionRepository transactionRepository;

  GetAllTransactionBloc(this.transactionRepository) : super(GetAllTransactionInitial()) {
    on<FetchAllTransactions>((event, emit) async {
      emit(FetchingInProgress());
      try {
        final transactions = await transactionRepository.fetchTransactionsForThisMonth();
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });
  }
}
