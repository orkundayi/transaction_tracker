import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/app.dart';
import 'package:flutter_application/firebase_options.dart';
import 'package:flutter_application/simple_bloc_observer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaction_repository/transaction_repository.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
