import 'dart:async';

import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_application/blocs/get_all_transaction/get_all_transaction_bloc.dart';
import 'package:flutter_application/blocs/user_account/user_account_cubit.dart';
import 'package:flutter_application/screens/transactions/views/all_transactions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../blocs/get_user_accounts/get_user_accounts_bloc.dart';
import '../../../blocs/get_user_transactions/get_user_transactions_bloc.dart';
import 'total_balance_card.dart';
import 'transaction_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AdminHelperCubit adminHelperCubit;
  late GetUserTransactionsBloc transactionsBloc;
  late GetAllTransactionBloc allTransactionsBloc;
  late GetUserAccountsBloc userAccountBloc;
  late UserAccountCubit userAccountCubit;
  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    allTransactionsBloc = context.read<GetAllTransactionBloc>();
    userAccountBloc = context.read<GetUserAccountsBloc>();
    userAccountCubit = context.read<UserAccountCubit>();
    transactionsBloc.setTransactionMode(TransactionMode.last);
    transactionsBloc.setTransactionType(TransactionType.expense);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
          allTransactionsBloc.add(FetchAllTransactions());
          userAccountBloc.add(FetchUserAccounts());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: screenWidth,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.person_fill,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hoşgeldin!',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Orkun Dayı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            adminHelperCubit.setIsAdmin(false);
                          },
                          icon: const Icon(CupertinoIcons.settings),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: transactionsBloc),
                  BlocProvider.value(value: allTransactionsBloc),
                  BlocProvider.value(value: userAccountBloc),
                  BlocProvider.value(value: userAccountCubit),
                ],
                child: TotalBalanceCard(
                  onAccountChanged: () async {
                    Timer(const Duration(milliseconds: 500), () {
                      transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
                    });
                  },
                  onAccountCreated: () {
                    Timer(const Duration(milliseconds: 500), () {
                      userAccountBloc.add(FetchUserAccounts());
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: DropdownButton(
                            value: context.watch<GetUserTransactionsBloc>().transactionType,
                            items: const [
                              DropdownMenuItem(value: TransactionType.income, child: Text('Son Gelirler')),
                              DropdownMenuItem(value: TransactionType.expense, child: Text('Son Giderler')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                transactionsBloc.setTransactionType(value);
                                transactionsBloc.add(FetchLastTransactions(value));
                              }
                            },
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            dropdownColor: Colors.white,
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                FontAwesomeIcons.caretDown,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            underline: Container(
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: GetUserTransactionsBloc(
                                    FirebaseTransactionRepository(),
                                    userAccountCubit,
                                  ),
                                  child: const AllTransactions(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Hepsini Gör',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
                      builder: (context, state) {
                        if (state is TransactionFetchingInProgress) {
                          return const SizedBox(
                            height: 120,
                            width: 120,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is TransactionFetchSuccess) {
                          final transactions = state.transactions;

                          return transactions.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 32.0, left: 8, right: 8, bottom: 32),
                                  child: Center(
                                    child: Text(
                                      'İşlem Bulunamadı',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: index != transactions.length - 1 ? 8 : 0),
                                      child: InkWell(
                                        onTap: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => BlocProvider.value(
                                                value: transactionsBloc,
                                                child: TransactionDetailScreen(transactionId: transaction.id),
                                              ),
                                            ),
                                          );
                                          transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey.withAlpha(80)),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: transaction.type == TransactionType.income
                                                      ? Colors.green.withAlpha(80)
                                                      : Colors.red.withAlpha(80),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: getCategoryIcon(transaction.category?.type),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                transaction.category?.name ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              Column(
                                                children: [
                                                  Text(
                                                    '${getCurrencySymbolFromCurrencyCode(transaction.toCurrencyCode)} ${transaction.amount}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('dd MMM yyyy').format(transaction.date),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                        } else if (state is TransactionFetchError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 32.0, left: 8, right: 8),
                            child: Center(child: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.only(top: 32.0, left: 8, right: 8, bottom: 32),
                            child: Center(
                              child: Text(
                                'İşlem Bulunamadı',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
