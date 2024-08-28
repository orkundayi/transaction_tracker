import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/transactions/views/all_transactions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';

import '../../../blocs/get_user_transactions_bloc/get_user_transactions_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late GetUserTransactionsBloc transactionsBloc;

  @override
  void initState() {
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    transactionsBloc.setTransactionMode(TransactionMode.last);
    transactionsBloc.setTransactionType(TransactionType.expense);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                FittedBox(
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
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
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.settings),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
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
                          'Total Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          '\$ 1,000,000',
                          style: TextStyle(
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
                                const Column(
                                  children: [
                                    Text(
                                      'Income',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '500,000',
                                      style: TextStyle(
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
                                const Column(
                                  children: [
                                    Text(
                                      'Expenses',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '500,000',
                                      style: TextStyle(
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
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                FontAwesomeIcons.caretDown,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
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
                                  value: GetUserTransactionsBloc(FirebaseTransactionRepository()),
                                  child: const AllTransactions(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                    BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
                      builder: (context, state) {
                        if (state is FetchingInProgress) {
                          return const SizedBox(
                            height: 120,
                            width: 120,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is FetchingSuccess) {
                          final transactions = state.transactions;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: transaction.type == TransactionType.income ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
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
                                            '${getCurrencySymbolFromCurrencyCode(transaction.currencyCode)} ${transaction.amount}',
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
                            padding: EdgeInsets.only(top: 32.0, left: 8, right: 8),
                            child: Center(child: Text('Veri yok.')),
                          );
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
