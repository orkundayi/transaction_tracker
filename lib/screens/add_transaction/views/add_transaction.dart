import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionPageState _transactionPageState = TransactionPageState.expense;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<CreateTransactionBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kayıt Ekle'),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getContainerColor(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _getContainerColor(),
                            ),
                          ),
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: _getAlignment(),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: Center(
                                    child: Text(
                                      'Gider',
                                      style: TextStyle(
                                        color: _transactionPageState == TransactionPageState.expense ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: Center(
                                    child: Text(
                                      'Gelir',
                                      style: TextStyle(
                                        color: _transactionPageState == TransactionPageState.income ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: Center(
                                    child: Text(
                                      'Transfer',
                                      style: TextStyle(
                                        color: _transactionPageState == TransactionPageState.transfer ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _transactionPageState = TransactionPageState.expense;
                                    });
                                  },
                                  child: const SizedBox(height: 36),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _transactionPageState = TransactionPageState.income;
                                    });
                                  },
                                  child: const SizedBox(height: 36),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _transactionPageState = TransactionPageState.transfer;
                                    });
                                  },
                                  child: const SizedBox(height: 36),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Transaction Type: $_transactionPageState',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the alignment for the moving container
  Alignment _getAlignment() {
    switch (_transactionPageState) {
      case TransactionPageState.expense:
        return Alignment.topLeft;
      case TransactionPageState.income:
        return Alignment.topCenter;
      case TransactionPageState.transfer:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  // Helper method to get the background color based on the current state
  Color _getContainerColor() {
    switch (_transactionPageState) {
      case TransactionPageState.expense:
        return Colors.redAccent.withOpacity(0.2);
      case TransactionPageState.income:
        return Colors.greenAccent.withOpacity(0.2);
      case TransactionPageState.transfer:
        return Colors.purpleAccent.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}

enum TransactionPageState {
  expense,
  income,
  transfer,
}
