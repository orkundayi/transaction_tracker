import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_user_transactions_event.dart';
part 'get_user_transactions_state.dart';

class GetUserTransactionsBloc extends Bloc<GetTransactionEvent, FetchTransactionState> {
  TransactionMode _transactionMode = TransactionMode.last;
  TransactionType _transactionType = TransactionType.expense;
  DateTime _transactionDateFirst = DateTime.now();
  DateTime _transactionDateLast = DateTime.now();

  TransactionMode get transactionMode => _transactionMode;
  TransactionType get transactionType => _transactionType;
  DateTime get transactionDateFirst => _transactionDateFirst;
  DateTime get transactionDateLast => _transactionDateLast;

  final TransactionRepository transactionRepository;

  setTransactionMode(TransactionMode mode) {
    _transactionMode = mode;
  }

  setTransactionType(TransactionType type) {
    _transactionType = type;
  }

  setTransactionDates(DateTime firstDate, DateTime lastDate) {
    _transactionDateFirst = firstDate;
    _transactionDateLast = lastDate;
  }

  GetUserTransactionsBloc(this.transactionRepository) : super(FetchTransactionInitial()) {
    on<FetchTotalTransaction>((event, emit) async {
      emit(FetchingInProgress());
      try {
        final transactions = await transactionRepository.fetchTransactionsForThisMonth();
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchAllTransactions>((event, emit) async {
      emit(FetchingInProgress());
      _transactionMode = TransactionMode.all;
      _transactionType = event.type ?? _transactionType;
      try {
        final transactions = await transactionRepository.fetchTransactionsForUser(_transactionType);
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchLastTransactions>((event, emit) async {
      emit(FetchingInProgress());
      _transactionMode = TransactionMode.last;
      _transactionType = event.type ?? _transactionType;
      try {
        final transactions = await transactionRepository.fetchLastTransactionsForUser(_transactionType);
        emit(FetchingSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchTransactions>((event, emit) async {
      emit(FetchingInProgress());
      _transactionMode = event.mode ?? _transactionMode;
      _transactionType = event.type ?? _transactionType;
      try {
        switch (_transactionMode) {
          case TransactionMode.all:
            final transactions = await transactionRepository.fetchTransactionsForUser(_transactionType, firstDate: event.dateRange?.start, lastDate: event.dateRange?.end);
            emit(FetchingSuccess(transactions));
            break;
          case TransactionMode.last:
            final transactions = await transactionRepository.fetchLastTransactionsForUser(_transactionType, firstDate: event.dateRange?.start, lastDate: event.dateRange?.end);
            emit(FetchingSuccess(transactions));
          default:
        }
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });
  }
}
