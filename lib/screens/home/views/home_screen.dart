import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:flutter_application/screens/add_expense/views/add_expense.dart';
import 'package:flutter_application/screens/home/views/main_screen.dart';
import 'package:flutter_application/screens/stats/stats_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:transaction_repository/transaction_repository.dart';

import '../../../blocs/get_user_transactions_bloc/get_user_transactions_bloc.dart';
import '../../add_income/views/add_income.dart';

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
      body: BlocProvider.value(
        value: BlocProvider.of<GetUserTransactionsBloc>(context),
        child: IndexedStack(
          index: index,
          children: const <Widget>[
            MainScreen(),
            StatsScreen(),
          ],
        ),
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        children: [
          SpeedDialChild(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(CupertinoIcons.money_dollar_circle),
            label: 'Gider Ekle',
            backgroundColor: theme.scaffoldBackgroundColor,
            labelBackgroundColor: theme.scaffoldBackgroundColor,
            onTap: () async {
              await Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => CreateTransactionBloc(
                      FirebaseTransactionRepository(),
                    ),
                    child: const AddExpense(),
                  ),
                ),
              )
                  .then((_) {
                final transactionsBloc = context.read<GetUserTransactionsBloc>();
                transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
                transactionsBloc.add(FetchTotalTransaction());
              });
            },
          ),
          SpeedDialChild(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(CupertinoIcons.money_dollar_circle_fill),
            label: 'Gelir Ekle',
            backgroundColor: theme.scaffoldBackgroundColor,
            labelBackgroundColor: theme.scaffoldBackgroundColor,
            onTap: () async {
              await Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => CreateTransactionBloc(
                      FirebaseTransactionRepository(),
                    ),
                    child: const AddIncome(),
                  ),
                ),
              )
                  .then((_) {
                final transactionsBloc = context.read<GetUserTransactionsBloc>();
                transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
                transactionsBloc.add(FetchTotalTransaction());
              });
            },
          ),
        ],
      ),
    );
  }
}
