import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/update_user_account/update_user_account_bloc.dart';
import 'package:flutter_application/screens/add_transaction/views/add_transaction.dart';
import 'package:flutter_application/screens/home/views/main_screen.dart';
import 'package:flutter_application/screens/stats/stats_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/create_transaction/create_transaction_bloc.dart';
import '../../../blocs/get_all_transaction/get_all_transaction_bloc.dart';
import '../../../blocs/get_user_accounts/get_user_accounts_bloc.dart';
import '../../../blocs/get_user_transactions/get_user_transactions_bloc.dart';
import '../../../blocs/user_account/user_account_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GetUserAccountsBloc accountsBloc;
  late GetUserTransactionsBloc transactionsBloc;
  late GetAllTransactionBloc allTransactionsBloc;
  late UserAccountCubit userAccountCubit;
  @override
  initState() {
    super.initState();
    transactionsBloc = context.read<GetUserTransactionsBloc>();
    accountsBloc = context.read<GetUserAccountsBloc>();
    allTransactionsBloc = context.read<GetAllTransactionBloc>();
    userAccountCubit = context.read<UserAccountCubit>();
    transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: <Widget>[
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: allTransactionsBloc),
              BlocProvider.value(value: transactionsBloc),
              BlocProvider.value(value: accountsBloc),
              BlocProvider.value(value: accountsBloc),
              BlocProvider.value(value: userAccountCubit),
            ],
            child: const MainScreen(),
          ),
          const StatsScreen(),
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
      floatingActionButton: GestureDetector(
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
              Future.delayed(const Duration(milliseconds: 500), () {
                transactionsBloc.add(FetchLastTransactions(transactionsBloc.transactionType));
                accountsBloc.add(FetchUserAccounts());
                allTransactionsBloc.add(FetchAllTransactions());
              });
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
