import 'dart:async';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/get_all_transaction_bloc/get_all_transaction_bloc.dart';
import 'package:flutter_application/blocs/get_user_accounts_bloc/get_user_accounts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TotalBalanceCard extends StatefulWidget {
  const TotalBalanceCard({super.key});

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard> {
  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  bool _privateWidgetVisible = false;
  int _currentIndex = 0;

  List<AccountModel> accounts = [];

  bool _loadedOnce = false;
  late GetAllTransactionBloc transactionsBloc;
  late GetUserAccountsBloc getUserAccountsBloc;
  late Timer _timer;
  final double _lastTotalBalance = 0.0;
  final double _lastIncome = 0.0;
  final double _lastExpense = 0.0;

  @override
  void initState() {
    transactionsBloc = context.read<GetAllTransactionBloc>();
    getUserAccountsBloc = context.read<GetUserAccountsBloc>();
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
    getUserAccountsBloc.add(FetchUserAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetUserAccountsBloc, GetUserAccountsState>(
      listener: (context, state) {
        if (state is AccountsFetchSuccess) {
          accounts = state.accounts;
          accounts.sort((a, b) => a.code == 'TR'
              ? -1
              : b.code == 'TR'
                  ? 1
                  : 0);

          setState(() {
            _loadedOnce = true;
          });
        } else if (state is AccountFetchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
          );
        }
      },
      child: _loadedOnce
          ? Container(
              color: Colors.white54,
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider.builder(
                itemCount: accounts.length + 1,
                options: CarouselOptions(
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  height: 180,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  scrollPhysics: _privateWidgetVisible ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                ),
                carouselController: _carouselSliderController,
                itemBuilder: (context, index, realIndex) {
                  if (index == accounts.length) {
                    return const CreateNewAccountCard();
                  }
                  final account = accounts[index];
                  return AccountCard(account: account);
                },
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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        width: MediaQuery.of(context).size.width * 0.7,
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
    );
  }
}

class AccountCard extends StatelessWidget {
  final AccountModel account;
  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 8,
              ),
            ],
          ),
          Text(
            '${account.code} ${account.balance}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateNewAccountCard extends StatefulWidget {
  const CreateNewAccountCard({super.key});

  @override
  State<CreateNewAccountCard> createState() => _CreateNewAccountCardState();
}

class _CreateNewAccountCardState extends State<CreateNewAccountCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            'Yeni Hesap Oluştur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
