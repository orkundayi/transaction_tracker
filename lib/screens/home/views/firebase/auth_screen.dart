import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/admin_helper/admin_helper_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  AuthState _currentState = AuthState.login;

  late AdminHelperCubit adminHelperCubit;
  @override
  void initState() {
    adminHelperCubit = context.read<AdminHelperCubit>();
    super.initState();
  }

  void _changeAuthState(AuthState state) {
    if (_currentState == state) {
      return;
    }
    setState(() {
      _currentState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Hane Cüzdan'),
        actions: [],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool bigScreen = constraints.maxHeight > 500;
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: bigScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 360,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _authBody(context),
                            ],
                          ),
                        ),
                      ),
                      if (bigScreen)
                        SizedBox(
                          height: 120,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            //TODO: Do Login Or Register Process
          },
          onLongPress: () async {
            var adminResult = await showDialog<bool?>(
                  context: context,
                  builder: (BuildContext context) {
                    String password = '';
                    return AlertDialog(
                      title: const Text('Admin Şifresi'),
                      content: TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Admin Şifresini Gir',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (password == '1234') {
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
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 56,
            decoration: BoxDecoration(
              color: themeData.colorScheme.onPrimary,
              border: Border.all(
                color: themeData.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('Devam Et')),
          ),
        ),
      ),
    );
  }

  _getContainerColor(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    switch (_currentState) {
      case AuthState.login:
        return themeData.colorScheme.primary;
      case AuthState.register:
        return themeData.colorScheme.secondary;
    }
  }

  Alignment _getAlignment() {
    switch (_currentState) {
      case AuthState.login:
        return Alignment.topLeft;
      case AuthState.register:
        return Alignment.topRight;
    }
  }

  _authBody(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getContainerColor(context),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: _getAlignment(),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getContainerColor(context),
                ),
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: _currentState == AuthState.login
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        color: _currentState == AuthState.register
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _changeAuthState(AuthState.login),
                  child: const SizedBox(height: 36),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _changeAuthState(AuthState.register),
                  child: const SizedBox(height: 36),
                ),
              ),
            ],
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
