import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'create_transaction_event.dart';
part 'create_transaction_state.dart';

class CreateTransactionBloc extends Bloc<CreateTransactionEvent, CreateTransactionState> {
  final TransactionRepository transactionRepository;

  CreateTransactionBloc(this.transactionRepository) : super(CreateTransactionInitial()) {
    on<CreateTransactionEvent>((event, emit) async {
      emit(CreateTransactionInProgress());
      try {
        await transactionRepository.createTransaction(event.transaction);
        emit(CreateTransactionSuccess(event.transaction));
      } catch (e) {
        emit(CreateTransactionFailure(e));
      }
    });
  }
}
