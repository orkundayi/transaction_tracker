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
  double _opacity = 1.0;
  AuthState _currentState = AuthState.login;
  bool _isStateChanging = false;

  late AdminHelperCubit adminHelperCubit;

  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    super.initState();
  }

  void _changeAuthState() {
    if (_isStateChanging) {
      return;
    }
    setState(() {
      _isStateChanging = true;
      _opacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentState = _currentState == AuthState.login ? AuthState.register : AuthState.login;
        _isStateChanging = false;
        _opacity = 1.0;
      });
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _currentState == AuthState.login ? const LoginView() : const RegisterView(),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            left: 20.0,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  overlayColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                ),
                onPressed: _changeAuthState,
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
                  _currentState == AuthState.register ? 'Register ->' : '<- Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AuthState {
  login,
  register,
}
