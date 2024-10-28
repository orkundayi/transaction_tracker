import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/create_user_account/create_user_account_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/get_user_accounts/get_user_accounts_bloc.dart';

class CreateAccountScreen extends StatefulWidget {
  final CurrencyRates currencyRates;
  const CreateAccountScreen({super.key, required this.currencyRates});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late GetUserAccountsBloc getUserAccountsBloc;
  late CreateUserAccountBloc createUserAccountBloc;
  GetUserAccountsState state = GetUserAccountsInitial();

  @override
  void initState() {
    getUserAccountsBloc = context.read<GetUserAccountsBloc>();
    createUserAccountBloc = context.read<CreateUserAccountBloc>();
    getUserAccounts();
    super.initState();
  }

  void getUserAccounts() {
    getUserAccountsBloc.add(FetchUserAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Ekle'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: BlocListener<GetUserAccountsBloc, GetUserAccountsState>(
          listener: (context, state) {
            if (state is AccountsFetchSuccess) {
              for (var accounts in state.accounts) {
                debugPrint(accounts.name);
                widget.currencyRates.currencies.removeWhere((element) => element.kod == accounts.code);
              }
              widget.currencyRates.currencies.sort((a, b) => a.kod == 'TR'
                  ? -1
                  : b.kod == 'TR'
                      ? 1
                      : 0);
              this.state = state;
              setState(() {});
            } else if (state is AccountFetchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Veriler yüklenirken hata oluştu: ${state.error}'),
                ),
              );
              this.state = state;
              setState(() {});
            }
          },
          child: state is AccountsFetchSuccess
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.currencyRates.currencies.length,
                        itemBuilder: (context, index) {
                          final currency = widget.currencyRates.currencies[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.account_balance_wallet),
                              title: Text(currency.kod ?? ""),
                              subtitle: Text(currency.currencyName ?? ""),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                try {
                                  createUserAccountBloc.add(
                                    CreateUserAccount(
                                      AccountModel(
                                        code: currency.kod ?? "",
                                        name: currency.currencyName ?? "",
                                        balance: 0.0,
                                      ),
                                    ),
                                  );
                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  Navigator.of(context).pop(false);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : state is AccountFetchError
                  ? const Center(
                      child: SizedBox(
                        child: Center(
                          child: Text('Veriler yüklenirken hata oluştu:'),
                        ),
                      ),
                    )
                  : const Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
        ),
      ),
    );
  }
}
