import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login/login_view.dart';
import 'register/register_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  late AdminHelperCubit adminHelperCubit;
  final PageController _pageController = PageController();
  bool _isLogin = true;

  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    super.initState();
  }

  void _toggleView() {
    setState(() {
      _isLogin = !_isLogin;
      _pageController.animateToPage(
        _isLogin ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Hane Cüzdan'),
        actions: [],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              LoginView(),
              RegisterView(),
            ],
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            left: 20.0,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                overlayColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              ),
              onPressed: _toggleView,
              onLongPress: () async {
                var adminResult = await showDialog<bool?>(
                      context: context,
                      builder: (BuildContext context) {
                        String password = '';
                        return AlertDialog(
                          title: const Text('Admin Password'),
                          content: TextField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged: (value) {
                              password = value;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Enter admin password',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (password == 'knifeofnight') {
                                  Navigator.of(context).pop(true);
                                } else {
                                  Navigator.of(context).pop(false);
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
                if (adminResult == true) {
                  adminHelperCubit.setIsAdmin(true);
                }
              },
              child: Text(
                _isLogin ? 'Register ->' : '<- Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
