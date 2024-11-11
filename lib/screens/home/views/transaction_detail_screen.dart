import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/blocs/get_user_transactions/get_user_transactions_bloc.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    context.read<GetUserTransactionsBloc>().add(FetchSingleTransaction(widget.transactionId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: BlocBuilder<GetUserTransactionsBloc, FetchTransactionState>(
        builder: (context, state) {
          if (state is TransactionFetchingInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SingleTransactionFetchSuccess) {
            final transaction = state.transaction;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${transaction.category?.name ?? ''}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Amount: ${transaction.amount}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Date: ${transaction.date}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement update transaction logic
                    },
                    child: const Text('Update Transaction'),
                  ),
                ],
              ),
            );
          } else if (state is TransactionFetchError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const Center(child: Text('Transaction not found'));
          }
        },
      ),
    );
  }
}
