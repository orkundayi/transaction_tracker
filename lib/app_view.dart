import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/user_account/user_account_cubit.dart';
import 'package:flutter_application/screens/home/views/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/get_all_transaction/get_all_transaction_bloc.dart';
import 'blocs/get_user_accounts/get_user_accounts_bloc.dart';
import 'blocs/get_user_transactions/get_user_transactions_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UserAccountCubit>(
            create: (context) => UserAccountCubit(),
          ),
          BlocProvider(
            create: (context) => GetUserTransactionsBloc(
              FirebaseTransactionRepository(),
              BlocProvider.of<UserAccountCubit>(context),
            ),
          ),
          BlocProvider(
            create: (context) => GetAllTransactionBloc(
              FirebaseTransactionRepository(),
            ),
          ),
          BlocProvider(
            create: (context) => GetUserAccountsBloc(
              FirebaseAccountRepository(),
            ),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}
