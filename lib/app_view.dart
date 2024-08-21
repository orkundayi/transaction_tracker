import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home/views/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: HomeScreen(),
    );
  }
}
