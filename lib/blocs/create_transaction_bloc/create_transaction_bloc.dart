import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'create_transaction_event.dart';
part 'create_transaction_state.dart';

class CreateTransactionBloc
    extends Bloc<CreateTransactionEvent, CreateTransactionState> {
  final TransactionRepository transactionRepository;
  CreateTransactionBloc(this.transactionRepository)
      : super(CreateTransactionInitial()) {
    on<CreateTransactionEvent>((event, emit) async {
      emit(CreateTransactionLoading());
      try {
        await transactionRepository.createTransaction(event.transaction);
      } catch (e) {
        emit(CreateTransactionFailure(e));
      }
    });
  }
}
