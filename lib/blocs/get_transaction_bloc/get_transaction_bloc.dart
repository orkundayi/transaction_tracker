import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_transaction_event.dart';
part 'get_transaction_state.dart';

class GetTransactionBloc extends Bloc<GetTransactionEvent, GetTransactionState> {
  final TransactionRepository transactionRepository;
  GetTransactionBloc(this.transactionRepository) : super(GetTransactionInitial()) {
    on<GetTransactionEvent>((event, emit) {
      emit(GetTransactionInProgress());
      try {
        transactionRepository.fetchTransactionsForUser();
        emit(GetTransactionSuccess(event.transactions));
      } catch (e) {
        emit(GetTransactionFailure(e));
      }
    });
  }
}
