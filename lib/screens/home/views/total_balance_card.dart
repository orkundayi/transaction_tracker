import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/get_all_transaction_bloc/get_all_transaction_bloc.dart';
import 'package:flutter_application/blocs/get_user_accounts_bloc/get_user_accounts_bloc.dart';
import 'package:flutter_application/blocs/user_account_cubit/user_account_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create_account/create_account_screen.dart';

class TotalBalanceCard extends StatefulWidget {
  final Function() onAccountChanged;
  const TotalBalanceCard({super.key, required this.onAccountChanged});

  @override
  State<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends State<TotalBalanceCard> {
  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  int _currentIndex = 0;

  List<AccountModel> accounts = [];

  bool _loadedOnce = false;
  late GetAllTransactionBloc transactionsBloc;
  late GetUserAccountsBloc getUserAccountsBloc;
  late UserAccountCubit userAccountCubit;
  late Timer _timer;

  @override
  void initState() {
    transactionsBloc = context.read<GetAllTransactionBloc>();
    getUserAccountsBloc = context.read<GetUserAccountsBloc>();
    userAccountCubit = context.read<UserAccountCubit>();
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
            userAccountCubit.updateIndex(_currentIndex, accounts.length == _currentIndex ? null : accounts[_currentIndex]);
          });
        } else if (state is AccountFetchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
          );
        }
      },
      child: _loadedOnce
          ? SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider.builder(
                itemCount: accounts.length + 1,
                options: CarouselOptions(
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    _currentIndex = index;
                    userAccountCubit.updateIndex(_currentIndex, accounts.length == _currentIndex ? null : accounts[_currentIndex]);
                    if (userAccountCubit.currentAccount != null && userAccountCubit.previousAccount != null) {
                      widget.onAccountChanged();
                    }
                  },
                  height: 180,
                  enableInfiniteScroll: false,
                  initialPage: context.watch<UserAccountCubit>().state is UserAccountIndexUpdated ? (context.watch<UserAccountCubit>().currentIndex) : 0,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
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

class AccountCard extends StatelessWidget {
  final AccountModel account;
  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: getCurrencyFlagFromCurrencyCode(account.code).image,
                radius: 16,
              ),
              const SizedBox(width: 10),
              Text(
                account.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.black54,
            thickness: 1,
          ),
          const SizedBox(height: 10),
          Text(
            '${account.balance.toStringAsFixed(2)} ${getCurrencySymbolFromCurrencyCode(account.code)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
    return GestureDetector(
      onTap: () async {
        // TODO: Action to create a new account
        CurrencyRates? currencyRates = await getCurrencyRates();
        if (currencyRates != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => GetUserAccountsBloc(FirebaseAccountRepository()),
                child: CreateAccountScreen(currencyRates: currencyRates),
              ),
            ),
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bilinmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 50,
              color: Colors.black,
            ),
            SizedBox(height: 10),
            Text(
              'Yeni Hesap Oluştur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
