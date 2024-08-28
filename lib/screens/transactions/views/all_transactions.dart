import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';

import '../../../blocs/get_user_transactions_bloc/get_user_transactions_bloc.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  late GetUserTransactionsBloc transactionsBloc;

  @override
  void initState() {
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    transactionsBloc.setTransactionType(TransactionType.expense);
    transactionsBloc.setTransactionMode(TransactionMode.all);
    transactionsBloc.add(FetchTransactions(transactionsBloc.transactionType, transactionsBloc.transactionMode));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          transactionsBloc.add(FetchTransactions(transactionsBloc.transactionType, transactionsBloc.transactionMode));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/* 
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
                  DropdownMenuItem(value: TransactionType.income, child: Text('Tüm Gelirler')),
                  DropdownMenuItem(value: TransactionType.expense, child: Text('Tüm Giderler')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    transactionsBloc.setTransactionType(value);
                    transactionsBloc.add(FetchAllTransactions(value));
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
          ],
        ),

 */