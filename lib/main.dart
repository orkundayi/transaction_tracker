import 'package:bloc/bloc.dart';
import 'package:flutter_application/simple_bloc_observer.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/app.dart';
import 'package:flutter_application/firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
