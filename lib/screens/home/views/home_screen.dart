import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/update_user_account/update_user_account_bloc.dart';
import 'package:flutter_application/screens/add_transaction/views/add_transaction.dart';
import 'package:flutter_application/screens/home/views/main_screen.dart';
import 'package:flutter_application/screens/stats/stats_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/create_transaction_bloc/create_transaction_bloc.dart';
import '../../../blocs/get_all_transaction_bloc/get_all_transaction_bloc.dart';
import '../../../blocs/get_user_transactions_bloc/get_user_transactions_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  initState() {
    super.initState();
    final transactionsBloc = context.read<GetUserTransactionsBloc>();
    transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const <Widget>[
          MainScreen(),
          StatsScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            currentIndex: index,
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 3,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.home,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.graph_circle,
                ),
                label: 'Transactions',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: InkWell(
        onTap: () async {
          await Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => CreateTransactionBloc(FirebaseTransactionRepository()),
                  ),
                  BlocProvider(
                    create: (context) => UpdateUserAccountBloc(FirebaseAccountRepository()),
                  ),
                ],
                child: const AddTransactionPage(),
              ),
            ),
          )
              .then((_) {
            if (context.mounted) {
              final transactionsBloc = context.read<GetUserTransactionsBloc>();
              transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
              context.read<GetAllTransactionBloc>().add(FetchAllTransactions());
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor,
          ),
          padding: const EdgeInsets.all(15),
          child: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
