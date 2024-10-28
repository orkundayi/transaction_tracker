import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';

import '../user_account/user_account_cubit.dart';

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
  final UserAccountCubit userAccountCubit;

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

  GetUserTransactionsBloc(this.transactionRepository, this.userAccountCubit) : super(FetchTransactionInitial()) {
    on<FetchUserTransactions>((event, emit) async {
      emit(TransactionFetchingInProgress());
      _transactionMode = TransactionMode.all;
      _transactionType = event.type ?? _transactionType;
      try {
        final transactions = await transactionRepository.fetchTransactionsForUser(_transactionType);
        emit(TransactionFetchSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchLastTransactions>((event, emit) async {
      emit(TransactionFetchingInProgress());
      _transactionMode = TransactionMode.last;
      _transactionType = event.type ?? _transactionType;
      try {
        final transactions = await transactionRepository.fetchLastTransactionsForUser(_transactionType,
            account: userAccountCubit.currentAccount ?? userAccountCubit.previousAccount);
        emit(TransactionFetchSuccess(transactions));
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });

    on<FetchTransactions>((event, emit) async {
      emit(TransactionFetchingInProgress());
      _transactionMode = event.mode ?? _transactionMode;
      _transactionType = event.type ?? _transactionType;
      try {
        switch (_transactionMode) {
          case TransactionMode.all:
            final transactions = await transactionRepository.fetchTransactionsForUser(_transactionType,
                firstDate: event.dateRange?.start, lastDate: event.dateRange?.end);
            emit(TransactionFetchSuccess(transactions));
            break;
          case TransactionMode.last:
            final transactions = await transactionRepository.fetchLastTransactionsForUser(_transactionType,
                firstDate: event.dateRange?.start, lastDate: event.dateRange?.end);
            emit(TransactionFetchSuccess(transactions));
          default:
        }
      } catch (e) {
        emit(TransactionFetchError(e));
      }
    });
  }
}
