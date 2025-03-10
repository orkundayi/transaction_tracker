import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/app_view.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_intent/receive_intent.dart';
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
    startIntent();
    super.initState();
  }

  Future<void> startIntent() async {
    ReceiveIntent.receivedIntentStream.listen(
      (Intent? intent) async {
        if (intent != null && intent.extra != null) {
          final Map<String, dynamic> extra = intent.extra!;
          if (extra['openAdminMode'] == true && extra['password'] == const String.fromEnvironment('ADMIN_PASSWORD')) {
            adminHelperCubit.setIsAdmin(true);
          }
          if (extra['returnResponse'] == true) {
            var androidIntent = AndroidIntent(
              action: 'p2p.action.listener',
              type: 'application/json',
              flags: [0x10000000],
              package: 'com.orkun.flutter_intent_rest',
              arguments: {
                'adminMode': adminHelperCubit.isAdmin,
              },
            );
            await androidIntent.launch();
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print('e');
        }
      },
    );
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
