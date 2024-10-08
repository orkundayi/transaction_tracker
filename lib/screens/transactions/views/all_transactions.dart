import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              backgroundColor: Colors.white,
              floating: false,
              pinned: true,
              title: Text(
                'Tüm İşlemler',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildExpenseIncomeDropdown(context),
                    const SizedBox(width: 10),
                    _buildDateFilter(context),
                  ],
                ),
              ),
            ),
            BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
              builder: (context, state) {
                if (state is TransactionFetchingInProgress) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is TransactionFetchSuccess) {
                  final transactions = state.transactions;
                  if (transactions.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildTransactionList(transactions);
                } else if (state is TransactionFetchError) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Veriler yüklenirken hata oluştu.')),
                    ),
                  );
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = transactions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction.type == TransactionType.income ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: getCategoryIcon(transaction.category?.type),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      transaction.category?.name ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${getCurrencySymbolFromCurrencyCode(transaction.currencyCode)} ${transaction.amount}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(transaction.date),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'İşlem bulunamadı.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseIncomeDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
      ),
      child: DropdownButton(
        value: context.watch<GetUserTransactionsBloc>().transactionType,
        items: [
          _buildDropdownItem(context, 'Giderler ', TransactionType.expense),
          _buildDropdownItem(context, 'Gelirler ', TransactionType.income),
        ],
        onChanged: (value) {
          if (value != null) {
            transactionsBloc.setTransactionType(value);
            transactionsBloc.add(FetchUserTransactions(value));
          }
        },
        underline: Container(),
        icon: Icon(
          FontAwesomeIcons.chevronDown,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
      ),
    );
  }

  DropdownMenuItem<TransactionType> _buildDropdownItem(BuildContext context, String label, TransactionType type) {
    return DropdownMenuItem(
      value: type,
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(0),
            lastDate: DateTime.now().toLocal(),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
            });
            transactionsBloc.add(FetchTransactions(
              transactionsBloc.transactionType,
              transactionsBloc.transactionMode,
              DateTimeRange(
                start: DateTime(_selectedDate.year, _selectedDate.month, 0, 0),
                end: DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 0),
              ),
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM yyyy').format(_selectedDate),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
