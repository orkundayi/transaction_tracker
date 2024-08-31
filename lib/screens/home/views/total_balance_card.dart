import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';

import '../../../blocs/get_user_transactions_bloc/get_user_transactions_bloc.dart';

class TotalBalanceCard extends StatefulWidget {
  const TotalBalanceCard({super.key});

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard> {
  bool _loadedOnce = false;
  late GetUserTransactionsBloc transactionsBloc;
  late Timer _timer;
  double _lastTotalBalance = 0.0;
  double _lastIncome = 0.0;
  double _lastExpense = 0.0;

  @override
  void initState() {
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    calculateTotalBalance();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      calculateTotalBalance();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  calculateTotalBalance() {
    transactionsBloc.add(FetchTotalTransaction());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
      builder: (context, state) {
        if (state is FetchingInProgress) {
          if (!_loadedOnce) {
            return const SizedBox(
              height: 120,
              width: 120,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return TotalBalance(theme: theme, totalBalance: _lastTotalBalance, income: _lastIncome, expense: _lastExpense);
        } else if (state is FetchingSuccess) {
          _loadedOnce = true;
          late double totalBalance;
          late double income;
          late double expense;
          final transactions = state.transactions;

          if (transactions.isEmpty) {
            totalBalance = 0.0;
            income = 0.0;
            expense = 0.0;
          } else {
            final incomes = transactions.where((t) => t.type == TransactionType.income).toList();
            final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
            income = incomes.fold(0, (value, transaction) => value + transaction.amount);
            expense = expenses.fold(0, (value, transaction) => value + checkIfExpenseHasInstallments(transaction));
            totalBalance = income - expense;
          }
          _lastTotalBalance = totalBalance;
          _lastIncome = income;
          _lastExpense = expense;
          return TotalBalance(theme: theme, totalBalance: totalBalance, income: income, expense: expense);
        } else if (state is TransactionFetchError) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 8, right: 8),
            child: Center(child: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(top: 32.0, left: 8, right: 8),
            child: Center(child: Text('Veri yok.')),
          );
        }
      },
    );
  }

  double checkIfExpenseHasInstallments(TransactionModel transaction) {
    if (transaction.installments != null) {
      return findInstallMentForThisMonth(transaction);
    } else {
      return transaction.amount;
    }
  }

  double findInstallMentForThisMonth(TransactionModel transaction) {
    final now = DateTime.now().toLocal();
    final currentMonth = now.month;
    final currentYear = now.year;
    return transaction.installments!.firstWhere((i) => i.dueDate.month == currentMonth && i.dueDate.year == currentYear, orElse: () => InstallmentModel.empty()).amount;
  }
}

class TotalBalance extends StatelessWidget {
  const TotalBalance({
    super.key,
    required this.theme,
    required this.totalBalance,
    required this.income,
    required this.expense,
  });

  final ThemeData theme;
  final double totalBalance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
            transform: const GradientRotation(pi / 4),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Toplam Bakiye',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '₺ $totalBalance',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_down,
                        color: Color(0xff45de52),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        const Text(
                          'Gelirler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$income',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.arrow_up,
                        color: Color(0xfffb5e69),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        const Text(
                          'Giderler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$expense',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
