import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/app_view.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/firebase/auth_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AdminHelperCubit adminHelperCubit;
  AdminHelperState? adminHelperState;
  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: adminHelperCubit,
      child: BlocListener<AdminHelperCubit, AdminHelperState>(
        bloc: adminHelperCubit,
        listener: (context, state) {
          adminHelperState = state;
          setState(() {});
        },
        child: adminHelperState is AdminLoggedIn
            ? const MyAppView()
            : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) => buildTransactionApp(snapshot),
              ),
      ),
    );
  }

  Widget buildTransactionApp(AsyncSnapshot<User?> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const CircularProgressIndicator();
      case ConnectionState.active:
      case ConnectionState.done:
        if (snapshot.hasData) {
          return const MyAppView();
        } else {
          return const AuthScreen();
        }
      case ConnectionState.none:
        return const AuthScreen();
    }
  }
}
