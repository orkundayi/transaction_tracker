import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  DateTime _selectedDate = DateTime.now().toLocal();
  @override
  void initState() {
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    transactionsBloc.setTransactionType(TransactionType.expense);
    transactionsBloc.setTransactionMode(TransactionMode.all);
    transactionsBloc.add(FetchTransactions(
      transactionsBloc.transactionType,
      transactionsBloc.transactionMode,
      DateTimeRange(
        start: DateTime(_selectedDate.year, _selectedDate.month, 0, 0),
        end: DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 0),
      ),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          transactionsBloc.add(FetchTransactions(
            transactionsBloc.transactionType,
            transactionsBloc.transactionMode,
            DateTimeRange(
              start: DateTime(_selectedDate.year, _selectedDate.month, 0, 0),
              end: DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 0),
            ),
          ));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tüm İşlemler',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Column(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 24,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              _buildExpenseIncomeDropdown(context),
                              const SizedBox(width: 10),
                              _buildDateFilter(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
              builder: (context, state) {
                if (state is FetchingInProgress) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else if (state is FetchingSuccess) {
                  final transactions = state.transactions;
                  if (transactions.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32.0, left: 8, right: 8),
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
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                      childCount: transactions.length,
                    ),
                  );
                } else if (state is TransactionFetchError) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32.0, left: 8, right: 8),
                      child: Center(child: Text('Veriler yüklenirken hata oluştu')),
                    ),
                  );
                } else {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32.0, left: 8, right: 8),
                      child: Center(child: Text('Veri yok.')),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseIncomeDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton(
        value: context.watch<GetUserTransactionsBloc>().transactionType,
        items: [
          DropdownMenuItem(
              value: TransactionType.expense,
              child: Text(
                'Giderler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
          DropdownMenuItem(
              value: TransactionType.income,
              child: Text(
                'Gelirler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ],
        onChanged: (value) {
          if (value != null) {
            transactionsBloc.setTransactionType(value);
            transactionsBloc.add(FetchUserTransactions(value));
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
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            barrierDismissible: true,
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(0),
            lastDate: DateTime.now().toLocal(),
            initialDatePickerMode: DatePickerMode.year,
            selectableDayPredicate: (DateTime date) {
              return date.isBefore(DateTime.now().toLocal());
            },
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
            });
            transactionsBloc.add(
              FetchTransactions(
                transactionsBloc.transactionType,
                transactionsBloc.transactionMode,
                DateTimeRange(
                  start: DateTime(_selectedDate.year, _selectedDate.month, 0, 0),
                  end: DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 0),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.calendarDays,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
