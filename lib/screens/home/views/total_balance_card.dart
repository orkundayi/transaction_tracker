import 'dart:async';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/get_all_transaction_bloc/get_all_transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';

class TotalBalanceCard extends StatefulWidget {
  const TotalBalanceCard({super.key});

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard> {
  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  bool _privateWidgetVisible = false;
  int _currentIndex = 0;

  bool _loadedOnce = false;
  late GetAllTransactionBloc transactionsBloc;
  late Timer _timer;
  double _lastTotalBalance = 0.0;
  double _lastIncome = 0.0;
  double _lastExpense = 0.0;

  @override
  void initState() {
    transactionsBloc = context.read<GetAllTransactionBloc>();
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

  void setVisibleWidget() {
    setState(() {
      _privateWidgetVisible = !_privateWidgetVisible;
    });
  }

  void calculateTotalBalance() {
    transactionsBloc.add(FetchAllTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<GetAllTransactionBloc, GetAllTransactionState>(
          listener: (context, state) {
            checkBalance(context, state);
          },
        ),
      ],
      child: _loadedOnce
          ? GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && !_privateWidgetVisible && _currentIndex == 0) {
                  setVisibleWidget();
                } else if (details.primaryVelocity! < 0 && _privateWidgetVisible && _currentIndex == 0) {
                  setVisibleWidget();
                }
              },
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          height: 184,
                          width: 160,
                          left: _privateWidgetVisible ? 20 : -200,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              height: 184,
                              width: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: theme.colorScheme.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Gizli Widget',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          left: _privateWidgetVisible ? 180 : 0,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 0.85,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              height: 200,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              scrollPhysics: _privateWidgetVisible ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                            ),
                            carouselController: _carouselSliderController,
                            items: [
                              GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  if (details.primaryVelocity! > 0 && !_privateWidgetVisible && _currentIndex == 0) {
                                    setVisibleWidget();
                                  } else if (details.primaryVelocity! < 0 && _privateWidgetVisible && _currentIndex == 0) {
                                    setVisibleWidget();
                                  } else if (details.primaryVelocity! < 0 && !_privateWidgetVisible && _currentIndex == 0) {
                                    _carouselSliderController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                                  }
                                },
                                child: const StarterCard(),
                              ),
                              TotalBalance(theme: theme, totalBalance: _lastTotalBalance, income: _lastIncome, expense: _lastExpense),
                              TotalBalance(theme: theme, totalBalance: _lastTotalBalance, income: _lastIncome, expense: _lastExpense),
                              TotalBalance(theme: theme, totalBalance: _lastTotalBalance, income: _lastIncome, expense: _lastExpense),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: _privateWidgetVisible ? 186 : 6 - (_currentIndex * 400),
                    top: 90,
                    bottom: 110,
                    child: const Icon(
                      CupertinoIcons.pause,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(
              height: 120,
              width: 120,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  void checkBalance(BuildContext context, GetAllTransactionState state) {
    if (state is FetchingSuccess) {
      final transactions = state.transactions;
      final incomes = transactions.where((t) => t.type == TransactionType.income).toList();
      final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
      _lastIncome = incomes.fold(
          0, (value, transaction) => value + ((transaction.calculatedAmount != null && transaction.calculatedAmount != 0.0) ? transaction.calculatedAmount! : transaction.amount));
      _lastExpense = expenses.fold(0, (value, transaction) => value + checkIfExpenseHasInstallments(transaction));
      _lastIncome = double.parse(_lastIncome.toStringAsFixed(2));
      _lastExpense = double.parse(_lastExpense.toStringAsFixed(2));
      _lastTotalBalance = _lastIncome - _lastExpense;
      setState(() {
        _loadedOnce = true;
      });
    } else if (state is TransactionFetchError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
      );
    }
  }

  double checkIfExpenseHasInstallments(TransactionModel transaction) {
    if (transaction.installments != null) {
      return findInstallMentForThisMonth(transaction);
    } else {
      return (transaction.calculatedAmount != null && transaction.calculatedAmount != 0.0) ? transaction.calculatedAmount! : transaction.amount;
    }
  }

  double findInstallMentForThisMonth(TransactionModel transaction) {
    final now = DateTime.now().toLocal();
    final currentMonth = now.month;
    final currentYear = now.year;
    final installment = transaction.installments!.firstWhere((i) => i.dueDate.month == currentMonth && i.dueDate.year == currentYear, orElse: () => InstallmentModel.empty());
    return installment.calculatedAmount != 0.0 ? installment.calculatedAmount : installment.amount;
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
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ],
              transform: const GradientRotation(math.pi / 4),
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
      ),
    );
  }
}

class StarterCard extends StatelessWidget {
  const StarterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FirebaseTransactionRepository().createTurkishAccountForUser();
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            height: 200,
            width: MediaQuery.of(context).size.width - 40,
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Türk Lirası Hesabı',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 8,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Net Bakiye: ₺594,13',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
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
                        const Column(
                          children: [
                            Text(
                              'Gelirler',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '800,00',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                        const Column(
                          children: [
                            Text(
                              'Giderler',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₺205,87',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
