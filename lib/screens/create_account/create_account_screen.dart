import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/get_user_accounts_bloc/get_user_accounts_bloc.dart';

class CreateAccountScreen extends StatefulWidget {
  final CurrencyRates currencyRates;
  const CreateAccountScreen({super.key, required this.currencyRates});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late GetUserAccountsBloc getUserAccountsBloc;
  List<AccountModel> accounts = [];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesaplarım'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: BlocListener<GetUserAccountsBloc, GetUserAccountsState>(
          listener: (context, state) {
            if (state is AccountsFetchSuccess) {
              accounts = state.accounts;
              accounts.sort((a, b) => a.code == 'TR'
                  ? -1
                  : b.code == 'TR'
                      ? 1
                      : 0);
            } else if (state is AccountFetchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${state.error}')),
              );
            }
          },
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Hesaplarım',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return ListTile(
                        title: Text(account.name),
                        subtitle: Text(account.code),
                        trailing: Text('${account.balance} ${account.code}'),
                      );
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: widget.currencyRates.currencies.length,
                      itemBuilder: (context, index) {
                        final currency = widget.currencyRates.currencies[index];
                        return ListTile(
                          title: Text(currency.kod ?? ""),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
