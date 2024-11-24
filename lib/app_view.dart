import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_application/blocs/user_account/user_account_cubit.dart';
import 'package:flutter_application/screens/home/views/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/get_all_transaction/get_all_transaction_bloc.dart';
import 'blocs/get_user_accounts/get_user_accounts_bloc.dart';
import 'blocs/get_user_transactions/get_user_transactions_bloc.dart';

class MyAppView extends StatefulWidget {
  const MyAppView({super.key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  late AdminHelperCubit adminHelperCubit;
  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
        BlocProvider.value(value: adminHelperCubit),
      ],
      child: const HomeScreen(),
    );
  }
}
