import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home/views/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';

import 'blocs/get_transaction_bloc/get_transaction_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: BlocProvider(
        create: (context) => GetTransactionBloc(FirebaseTransactionRepository()),
        child: const HomeScreen(),
      ),
    );
  }
}
