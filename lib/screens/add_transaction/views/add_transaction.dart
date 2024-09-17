import 'dart:developer';

import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:widgets/widgets.dart';

import '../../../blocs/create_transaction_bloc/create_transaction_bloc.dart';
import '../../../blocs/get_user_accounts_bloc/get_user_accounts_bloc.dart';
import 'user_account_selector/user_account_selector.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddPaymentSelectionState();
}

class _AddPaymentSelectionState extends State<AddTransactionPage> {
  final TextEditingController _currencyController = TextEditingController();

  final ValueNotifier<PaymentSelectionState> _pageStateNotifier = ValueNotifier<PaymentSelectionState>(PaymentSelectionState.expense);

  String _currentIcon = '₺';
  String _currentCurrency = 'TR';

  bool isInstallment = false;
  DateTime? installmentDate;
  int? installmentCount;
  DateTime? paymentDate;

  AccountModel? selectedAccount;
  AccountModel? selectedTransferAccount;

  CategoryType? categoryType = CategoryType.otherExpense;
  final TextEditingController _categoryController = TextEditingController(text: 'Kategori Seçin');

  void _toggleCurrency() async {
    await getCurrencyList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ekle'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(24),
                  bottomEnd: Radius.circular(24),
                ),
                color: _getContainerColor(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: MediaQuery.of(context).size.width,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _getContainerColor(),
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: _getAlignment(),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                                    'Gider',
                                    style: TextStyle(
                                      color: checkIfExpense ? Theme.of(context).colorScheme.primary : Colors.black,
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
                                    'Gelir',
                                    style: TextStyle(
                                      color: _pageStateNotifier.value == PaymentSelectionState.income ? Theme.of(context).colorScheme.primary : Colors.black,
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
                                    'Transfer',
                                    style: TextStyle(
                                      color: _pageStateNotifier.value == PaymentSelectionState.transfer ? Theme.of(context).colorScheme.primary : Colors.black,
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
                                onTap: () {
                                  setState(() {
                                    _pageStateNotifier.value = PaymentSelectionState.expense;
                                  });
                                },
                                child: const SizedBox(height: 36),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _pageStateNotifier.value = PaymentSelectionState.income;
                                  });
                                },
                                child: const SizedBox(height: 36),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _pageStateNotifier.value = PaymentSelectionState.transfer;
                                  });
                                },
                                child: const SizedBox(height: 36),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    currencyTextFormField(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            UserAccountSelectorWidget(
              pageStateNotifier: _pageStateNotifier,
              onAccountSelected: () async {
                final AccountModel? account = await showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return BlocProvider(
                      create: (context) => GetUserAccountsBloc(FirebaseAccountRepository()),
                      child: const UserAccountSelector(),
                    );
                  },
                );
                if (account != null) {
                  setState(() {
                    selectedAccount = account;
                  });
                }
              },
              onTransferAccountSelected: () async {
                final AccountModel? account = await showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return BlocProvider(
                      create: (context) => GetUserAccountsBloc(FirebaseAccountRepository()),
                      child: const UserAccountSelector(),
                    );
                  },
                );
                if (account != null) {
                  setState(() {
                    selectedTransferAccount = account;
                  });
                }
              },
              selectedAccount: selectedAccount,
              selectedTransferAccount: selectedTransferAccount,
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _pageStateNotifier.value != PaymentSelectionState.transfer
                  ? CategorySelectorWidget(
                      onDataChanged: (categoryName, categoryType) {
                        this.categoryType = categoryType;
                        _categoryController.text = categoryName;
                        log('********** Data Changed **********');
                        log('Category Name: $categoryName');
                        log('Category Type: $categoryType');
                      },
                    )
                  : const SizedBox(),
            ),
            const SizedBox(height: 10),
            PaymentSelectorWidget(
              categoryType: categoryType!,
              pageStateNotifier: _pageStateNotifier,
              onDataChangedForExpense: (isInstallment, paymentDate, installmentDate, installmentCount) {
                this.isInstallment = isInstallment;
                this.paymentDate = paymentDate;
                this.installmentDate = installmentDate;
                this.installmentCount = int.tryParse(installmentCount);
                log('********** Data Changed **********');
                log('isInstallment: ${this.isInstallment}');
                log('Payment Date: ${this.paymentDate}');
                log('Installment Date: ${this.installmentDate}');
                log('Installment Count: ${this.installmentCount}');
              },
              onDataChangedForIncome: (paymentDate) {
                this.paymentDate = paymentDate;
                log('********** Payment Date Changed **********');
                log('Payment Date: ${this.paymentDate}');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextButton(
          onPressed: () async {
            try {
              final TransactionModel transaction = TransactionModel.empty();
              transaction.amount = double.parse(_currencyController.text);
              transaction.currencyCode = _currentCurrency;
              transaction.category = CategoryModel.empty(CategoryType.otherExpense);
              transaction.category!.name = _categoryController.text == 'Kategori Seçin' ? 'Diğer' : _categoryController.text;
              transaction.category!.type = categoryType;
              await transactionCalculate(transaction);
              debugPrint(transaction.toString());
              if (context.mounted) {
                context.read<CreateTransactionBloc>().add(CreateTransaction(transaction: transaction));
              }
              if (context.mounted) {}
            } catch (e) {
              log(e.toString());
            } finally {
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
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
            'Kaydet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool get checkIfExpense => _pageStateNotifier.value == PaymentSelectionState.expense;

  Alignment _getAlignment() {
    switch (_pageStateNotifier.value) {
      case PaymentSelectionState.expense:
        return Alignment.topLeft;
      case PaymentSelectionState.income:
        return Alignment.topCenter;
      case PaymentSelectionState.transfer:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  Color _getContainerColor() {
    switch (_pageStateNotifier.value) {
      case PaymentSelectionState.expense:
        return Colors.redAccent.withOpacity(0.2);
      case PaymentSelectionState.income:
        return Colors.greenAccent.withOpacity(0.2);
      case PaymentSelectionState.transfer:
        return const Color.fromARGB(255, 61, 124, 153).withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Future<void> getCurrencyList() async {
    http.Response response = await getCurrencies();

    if (response.statusCode == 200) {
      var currencies = parseCurrencyFromResponse(response.body);
      currencies.currencies.sort((a, b) => a.orderNo.compareTo(b.orderNo));
      if (mounted) {
        final result = await showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          showDragHandle: true,
          enableDrag: false,
          builder: (context) {
            return CurrencySelector(allCurrencies: currencies.currencies);
          },
        );
        if (result != null) {
          setState(() {
            _currentCurrency = result['currencyCode'];
            _currentIcon = result['currencySymbol'];
          });
        }
      }
    }
  }

  Future<http.Response> getCurrencies() async {
    final response = await http.get(Uri.parse('https://www.tcmb.gov.tr/kurlar/today.xml'));
    return response;
  }

  Widget currencyTextFormField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: TextFormField(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        controller: _currencyController,
        onChanged: (value) {
          checkIfValueIsNumeric(value);
        },
        keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: GestureDetector(
            onTap: _toggleCurrency,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      height: 36,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getContainerColor(),
                          width: 2,
                        ),
                        color: _getContainerColor().withOpacity(0.05),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentIcon,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 4,
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          hintText: ' Tutar Giriniz',
          hintStyle: const TextStyle(
            color: Colors.black,
          ),
          hintTextDirection: TextDirection.ltr,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }

  void checkIfValueIsNumeric(String value) {
    if (value.isNotEmpty) {
      try {
        double.parse(value);
      } catch (e) {
        _currencyController.text = value.substring(0, value.length - 1);
      }
    }
  }

  transactionCalculate(TransactionModel transaction) async {
    switch (_pageStateNotifier.value) {
      case PaymentSelectionState.expense:
        if (installmentCount != null && installmentDate != null) {
          await transactionCalculateForExpense(transaction);
        }
        break;
      case PaymentSelectionState.income:
        await transactionCalculateForIncome(transaction);
        break;
      case PaymentSelectionState.transfer:
        // TODO: Handle for transfer case.
        break;
      default:
    }
  }

  // Expense
  Future<void> transactionCalculateForExpense(TransactionModel transaction) async {
    if (isInstallment) {
      transaction.installments = await createInstallments();
    } else {
      transaction.date = paymentDate!;
    }
    transaction.type = TransactionType.expense;
  }

  Future<List<InstallmentModel>?> createInstallments() async {
    CurrencyModel currency = CurrencyModel.empty();
    currency.currencyCode = _currentCurrency;
    currency.kod = _currentCurrency;

    final selectedCurrency = await getCurrencies().then((value) async {
      final currencies = parseCurrencyFromResponse(value.body);
      return currencies.currencies.firstWhere((c) => c.currencyCode == _currentCurrency, orElse: () => currency);
    });

    if (installmentCount != null && installmentDate != null) {
      List<InstallmentModel> installments = [];
      for (int i = 0; i < installmentCount!; i++) {
        installments.add(
          InstallmentModel(
            installmentNumber: i + 1,
            amount: double.parse(_currencyController.text) / installmentCount!,
            dueDate: DateTime(
              installmentDate!.year,
              installmentDate!.month + i,
              installmentDate!.day,
            ),
            calculatedAmount: calculateRelateToCurrency(
              double.parse(_currencyController.text) / installmentCount!,
              selectedCurrency,
            ),
            currency: currency,
          ),
        );
      }
      return installments;
    }
    return null;
  }

  double calculateRelateToCurrency(double amount, CurrencyModel selectedCurrency) {
    if (selectedCurrency.currencyCode != 'TR' && selectedCurrency.forexBuying != null) {
      return amount * selectedCurrency.forexBuying!;
    }
    return 0.0;
  }

  // Income
  Future<void> transactionCalculateForIncome(TransactionModel transaction) async {
    CurrencyModel currency = CurrencyModel.empty();
    currency.currencyCode = _currentCurrency;
    currency.kod = _currentCurrency;
    transaction.date = paymentDate!;
    transaction.type = TransactionType.income;
    final selectedCurrency = await getCurrencies().then((value) async {
      final currencies = parseCurrencyFromResponse(value.body);
      return currencies.currencies.firstWhere((c) => c.currencyCode == _currentCurrency, orElse: () => currency);
    });
    if (selectedCurrency.currencyCode != 'TR' && selectedCurrency.forexBuying != null) {
      transaction.calculatedAmount = transaction.amount * selectedCurrency.forexBuying!;
    }
  }
}
