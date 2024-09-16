import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/get_user_accounts_bloc/get_user_accounts_bloc.dart';

class UserAccountSelector extends StatefulWidget {
  const UserAccountSelector({super.key});

  @override
  State<UserAccountSelector> createState() => _UserAccountSelectorState();
}

class _UserAccountSelectorState extends State<UserAccountSelector> {
  late GetUserAccountsBloc getUserAccountsBloc;
  List<AccountModel> accounts = [];

  bool _loadedOnce = false;
  @override
  void initState() {
    getUserAccountsBloc = context.read<GetUserAccountsBloc>();
    getUserAccounts();
    super.initState();
  }

  void getUserAccounts() {
    getUserAccountsBloc.add(FetchUserAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetUserAccountsBloc, GetUserAccountsState>(
      listener: (context, state) {
        if (state is AccountsFetchSuccess) {
          accounts = state.accounts;
          accounts.sort((a, b) => a.code == 'TR'
              ? -1
              : b.code == 'TR'
                  ? 1
                  : 0);

          setState(() {
            _loadedOnce = true;
          });
        } else if (state is AccountFetchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
          );
        }
      },
      child: FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 1,
        child: _loadedOnce
            ? Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Hesap Seçin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        var account = accounts[index];
                        return ListTile(
                          title: Text(
                            account.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            account.code,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(account);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: kToolbarHeight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadowColor: Colors.black,
                          elevation: 1,
                        ),
                        child: const Text(
                          'Vazgeç',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(
                height: 120,
                width: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}
