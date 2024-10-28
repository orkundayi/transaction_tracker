import 'dart:developer';

import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:widgets/widgets.dart';

import '../../../blocs/create_transaction/create_transaction_bloc.dart';
import '../../../blocs/get_user_accounts/get_user_accounts_bloc.dart';
import '../../../blocs/update_user_account/update_user_account_bloc.dart';
import 'user_account_selector/user_account_selector.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddPaymentSelectionState();
}

class _AddPaymentSelectionState extends State<AddTransactionPage> {
  final GlobalKey<CategorySelectorWidgetState> categoryKey = GlobalKey<CategorySelectorWidgetState>();
  final ValueListenable<bool> _isExchangeRateEnabled = ValueNotifier<bool>(false);
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _exchangeRateController = TextEditingController();
  final ValueNotifier<PaymentSelectionState> _pageStateNotifier =
      ValueNotifier<PaymentSelectionState>(PaymentSelectionState.expense);
  TransactionModel transaction = TransactionModel.empty();
  CurrencyRates? currencyRates;

  String _currentIcon = '₺';
  String _currentCurrencyCode = 'TR';

  bool isInstallment = false;
  DateTime? installmentDate;
  int? installmentCount;
  DateTime? paymentDate;

  AccountModel? selectedAccount;
  AccountModel? selectedTransferAccount;

  CategoryType? categoryType = CategoryType.otherExpense;
  final TextEditingController _categoryController = TextEditingController(text: 'Kategori Seçin');

  @override
  void initState() {
    getCurrencyRates();
    super.initState();
  }

  Future<void> getCurrencyRates() async {
    http.Response response = await getCurrencies();
    if (response.statusCode == 200) {
      currencyRates = parseCurrencyFromResponse(response.body);
    } else {
      log('Failed to load currency rates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kayıt Ekle',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                                      color: _pageStateNotifier.value == PaymentSelectionState.income
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.black,
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
                                      color: _pageStateNotifier.value == PaymentSelectionState.transfer
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.black,
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
                                    if (_pageStateNotifier.value != PaymentSelectionState.expense) {
                                      setState(() {
                                        _categoryController.text = 'Kategori Seçin';
                                        categoryType = CategoryType.otherExpense;
                                        categoryKey.currentState?.clearDataAccordingToPaymentSelectionState();
                                        selectedTransferAccount = null;
                                        if (_pageStateNotifier.value == PaymentSelectionState.transfer &&
                                            _currentCurrencyCode.isNotEmpty &&
                                            selectedAccount != null) {
                                          compareCurrencyCodesAndCalculateExchangeRate();
                                        }
                                      });
                                    }
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
                                    if (_pageStateNotifier.value != PaymentSelectionState.income) {
                                      setState(() {
                                        _categoryController.text = 'Kategori Seçin';
                                        categoryType = CategoryType.otherIncome;
                                        categoryKey.currentState?.clearDataAccordingToPaymentSelectionState();
                                        selectedTransferAccount = null;
                                        if (_pageStateNotifier.value == PaymentSelectionState.transfer &&
                                            _currentCurrencyCode.isNotEmpty &&
                                            selectedAccount != null) {
                                          compareCurrencyCodesAndCalculateExchangeRate();
                                        }
                                      });
                                    }
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
                                    _exchangeRateController.text = '';
                                    selectedAccount = null;
                                    selectedTransferAccount = null;
                                    selectedAccount != null
                                        ? _currentCurrencyCode = selectedAccount!.code
                                        : _currentCurrencyCode = 'TR';
                                    _currentIcon = selectedAccount != null
                                        ? getCurrencySymbolFromCurrencyCode(
                                            selectedAccount!.code,
                                          )
                                        : '₺';
                                    if (_currentCurrencyCode.isNotEmpty && selectedAccount != null) {
                                      compareCurrencyCodesAndCalculateExchangeRate(
                                          transferAccount: selectedTransferAccount);
                                    }
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
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isExchangeRateEnabled,
                      builder: (context, isEnabled, child) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Kur Değiştir'),
                                  content: const Text('Kur değerini değiştirmek istediğinize emin misiniz?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('İptal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        (_isExchangeRateEnabled as ValueNotifier<bool>).value =
                                            !(_isExchangeRateEnabled).value;
                                      },
                                      child: const Text('Evet'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: AbsorbPointer(
                            absorbing: !isEnabled,
                            child: Opacity(
                              opacity: isEnabled ? 1.0 : 0.5,
                              child: exchangeRateTextFormField(),
                            ),
                          ),
                        );
                      },
                    ),
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  showDragHandle: true,
                  enableDrag: false,
                  builder: (context) {
                    return BlocProvider(
                      create: (context) => GetUserAccountsBloc(FirebaseAccountRepository()),
                      child: const UserAccountSelector(),
                    );
                  },
                );
                if (account != null && account.code == selectedTransferAccount?.code) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Hesap Seçme Hatası'),
                          content: const Text('Seçilen hesap, Transfer hesabı ile aynı olamaz.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Tamam'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return;
                }
                if (account != null) {
                  setState(() {
                    selectedAccount = account;
                    if (_pageStateNotifier.value != PaymentSelectionState.transfer && _currentCurrencyCode.isNotEmpty) {
                      compareCurrencyCodesAndCalculateExchangeRate();
                    }
                    if (_pageStateNotifier.value == PaymentSelectionState.transfer) {
                      _currentCurrencyCode = selectedAccount!.code;
                      _currentIcon = getCurrencySymbolFromCurrencyCode(selectedAccount!.code);
                      if (_currentCurrencyCode.isNotEmpty && selectedTransferAccount != null) {
                        compareCurrencyCodesAndCalculateExchangeRate(transferAccount: selectedTransferAccount);
                      }
                    }
                  });
                }
              },
              onTransferAccountSelected: () async {
                final AccountModel? account = await showModalBottomSheet(
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
                    return BlocProvider(
                      create: (context) => GetUserAccountsBloc(FirebaseAccountRepository()),
                      child: const UserAccountSelector(),
                    );
                  },
                );
                if (account != null) {
                  if (selectedAccount != null && selectedAccount!.code == account.code) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Hesap Seçme Hatası'),
                            content: const Text('Transfer hesabı, seçilen hesap ile aynı olamaz.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Tamam'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return;
                  }
                  setState(() {
                    selectedTransferAccount = account;
                    if (_currentCurrencyCode.isNotEmpty && selectedAccount != null) {
                      compareCurrencyCodesAndCalculateExchangeRate(transferAccount: selectedTransferAccount);
                    }
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
                      paymentSelectionState: _pageStateNotifier.value,
                      onDataChanged: (categoryName, categoryType) {
                        this.categoryType = categoryType;
                        _categoryController.text = categoryName;
                        log('********** Data Changed **********');
                        log('Category Name: $categoryName');
                        log('Category Type: $categoryType');
                      },
                      categoryKey: categoryKey,
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
            const SizedBox(height: 10),
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
            late bool complete;
            try {
              transaction.amount = double.parse(_currencyController.text);
              transaction.currencyCode = _currentCurrencyCode;
              transaction.category = CategoryModel.empty(CategoryType.otherExpense);
              transaction.category!.name =
                  _categoryController.text == 'Kategori Seçin' ? 'Diğer' : _categoryController.text;
              transaction.category!.type = categoryType;
              await transactionCalculate(transaction);
              complete = await transactionExchangeRateCheck(transaction);
              if (!complete) {
                return;
              }
              if (context.mounted) {
                context.read<CreateTransactionBloc>().add(CreateTransaction(transaction: transaction));
              }
              if (context.mounted) {
                context.read<UpdateUserAccountBloc>().add(UpdateUserAccountEvent(transaction: transaction));
              }
            } catch (e) {
              log(e.toString());
            } finally {
              if (context.mounted && complete) {
                Navigator.pop(context, true);
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
    if (currencyRates == null) {
      await getCurrencyRates();
      return;
    }
    currencyRates!.currencies.sort((a, b) => a.orderNo.compareTo(b.orderNo));
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
          return CurrencySelector(allCurrencies: currencyRates!.currencies);
        },
      );
      if (result != null) {
        setState(() {
          _currentCurrencyCode = result['currencyCode'];
          _currentIcon = result['currencySymbol'];
          if (selectedAccount != null) {
            compareCurrencyCodesAndCalculateExchangeRate();
          }
        });
      }
    }
  }

  Future<http.Response> getCurrencies() async {
    final response = await http.get(Uri.parse('https://www.tcmb.gov.tr/kurlar/today.xml'));
    return response;
  }

  Widget currencyTextFormField() {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Stack(
        children: [
          TextFormField(
            cursorColor: Theme.of(context).colorScheme.primary,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
            controller: _currencyController,
            onChanged: (value) {
              checkIfValueIsNumeric(value);
              setState(() {});
            },
            keyboardType: TextInputType.number,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              prefixIcon: GestureDetector(
                onTap: _pageStateNotifier.value != PaymentSelectionState.transfer ? _toggleCurrency : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
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
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _pageStateNotifier.value == PaymentSelectionState.transfer ? 0.5 : 1,
                          child: Text(
                            _currentIcon.length < 2 ? '$_currentIcon ' : _currentIcon,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
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
          Positioned(
            right: 20,
            top: 20,
            bottom: 20,
            child: IgnorePointer(
              ignoring: true,
              child: Text(
                _currencyController.text.isNotEmpty
                    ? '${getCalculatedAmount()?.toStringAsFixed(2) ?? ''} ${_pageStateNotifier.value == PaymentSelectionState.transfer ? selectedTransferAccount?.code ?? '' : selectedAccount?.code ?? ''}'
                    : '',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget exchangeRateTextFormField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: TextFormField(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        controller: _exchangeRateController,
        onChanged: (value) {
          checkIfValueIsNumeric(value);
        },
        keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: ' Kur Değeri',
          hintStyle: const TextStyle(
            color: Colors.black,
          ),
          hintTextDirection: TextDirection.ltr,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          prefixIcon: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => (_isExchangeRateEnabled as ValueNotifier<bool>).value = !(_isExchangeRateEnabled).value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  height: 36,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getContainerColor(),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      FontAwesomeIcons.arrowRightArrowLeft,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
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
        await transactionCalculateForExpense(transaction);

        break;
      case PaymentSelectionState.income:
        await transactionCalculateForIncome(transaction);

        break;
      case PaymentSelectionState.transfer:
        transaction.type = TransactionType.transfer;
        transaction.currencyCode = _currentCurrencyCode;
        transaction.toCurrencyCode = selectedTransferAccount!.code;
        transaction.accountCode = transaction.toCurrencyCode;
        transaction.date = DateTime.now().toLocal();
        transaction.currencyRate =
            double.tryParse(_exchangeRateController.text) == 0.0 ? 1.0 : double.parse(_exchangeRateController.text);
        transaction.amount = double.parse(_currencyController.text);
        transaction.calculatedAmount = double.parse(_currencyController.text) * transaction.currencyRate!;
        break;
      default:
    }
  }

  // Expense
  Future<void> transactionCalculateForExpense(TransactionModel transaction) async {
    if (isInstallment) {
      if (installmentCount != null && installmentDate != null) {
        transaction.installments = await createInstallments();
      }
    } else {
      transaction.date = paymentDate!;
      transaction.currencyRate =
          double.tryParse(_exchangeRateController.text) == 0.0 ? 1.0 : double.parse(_exchangeRateController.text);
      transaction.calculatedAmount = double.parse(_currencyController.text) * transaction.currencyRate!;
    }
    transaction.type = TransactionType.expense;
    transaction.currencyCode = _currentCurrencyCode;
    transaction.toCurrencyCode = selectedAccount!.code;
    transaction.accountCode = transaction.toCurrencyCode;
  }

  Future<List<InstallmentModel>?> createInstallments() async {
    CurrencyModel currency = CurrencyModel.empty();
    CurrencyModel toCurrency = CurrencyModel.empty();
    currency.currencyCode = _currentCurrencyCode;
    currency.kod = _currentCurrencyCode;
    toCurrency.currencyCode = selectedAccount!.code;
    toCurrency.kod = selectedAccount!.code;
    if (installmentCount != null && installmentDate != null) {
      var amount = double.parse(_currencyController.text) / installmentCount!;
      double exchangeRate =
          double.tryParse(_exchangeRateController.text) == 0.0 ? 1.0 : double.parse(_exchangeRateController.text);
      List<InstallmentModel> installments = [];
      for (int i = 0; i < installmentCount!; i++) {
        installments.add(
          InstallmentModel(
            installmentNumber: i + 1,
            amount: amount,
            dueDate: DateTime(
              installmentDate!.year,
              installmentDate!.month + i,
              installmentDate!.day,
            ),
            currencyRate: double.parse(_exchangeRateController.text),
            calculatedAmount: amount * exchangeRate,
            currency: currency,
            toCurrency: toCurrency,
          ),
        );
      }
      return installments;
    }
    return null;
  }

  // Income
  Future<void> transactionCalculateForIncome(TransactionModel transaction) async {
    double exchangeRate =
        double.tryParse(_exchangeRateController.text) == 0.0 ? 1.0 : double.parse(_exchangeRateController.text);
    transaction.date = paymentDate!;
    transaction.type = TransactionType.income;
    transaction.currencyRate = exchangeRate;
    transaction.calculatedAmount = double.parse(_currencyController.text) * exchangeRate;
    transaction.currencyCode = _currentCurrencyCode;
    transaction.toCurrencyCode = selectedAccount!.code;
    transaction.accountCode = transaction.toCurrencyCode;
  }

  void _toggleCurrency() async {
    await getCurrencyList();
  }

  Future<void> compareCurrencyCodesAndCalculateExchangeRate({AccountModel? transferAccount}) async {
    var currentCurrency = _currentCurrencyCode;
    var toCurrency = transferAccount?.code ?? selectedAccount!.code;

    if (currencyRates == null) {
      await getCurrencyRates();
      return;
    }
    List<CurrencyModel> currencyList = currencyRates!.currencies;
    CurrencyModel currentCurrencyModel = currencyList.firstWhere((element) => element.currencyCode == currentCurrency);
    CurrencyModel toCurrencyModel = currencyList.firstWhere((element) => element.currencyCode == toCurrency);
    calculateExchangeRate(currentCurrencyModel.forexSelling, toCurrencyModel.forexSelling);
  }

  void calculateExchangeRate(double? forexSelling, double? toForexSelling) {
    if (forexSelling != null && toForexSelling != null) {
      double exchangeRate = forexSelling / toForexSelling;
      _exchangeRateController.text = exchangeRate.toString();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Kur Bilgisi Bulunurken Hata'),
            content: const Text('Kur değerini girmeniz gerekmektedir.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  (_isExchangeRateEnabled as ValueNotifier<bool>).value = true;
                  Navigator.of(context).pop();
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  double? getCalculatedAmount() {
    if (_currencyController.text.isEmpty || _exchangeRateController.text.isEmpty) {
      return null;
    }
    return double.parse(_currencyController.text) * double.parse(_exchangeRateController.text);
  }

  Future<bool> transactionExchangeRateCheck(TransactionModel transaction) async {
    switch (_pageStateNotifier.value) {
      case PaymentSelectionState.transfer:
        var correctedValue = calculateCurrencyExchange(
            transaction.amount, transaction.currencyRate!, transaction.currencyCode, transaction.toCurrencyCode);
        transaction.amount -= correctedValue['remainingRefund'];
        transaction.calculatedAmount = double.parse(correctedValue['totalConverted'].toString());
        bool completed = true;
        if (correctedValue['remainingRefund'] != 0.0) {
          completed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Bilgilendirme'),
                      content: Text(
                          'Hesabınıza: ${transaction.calculatedAmount?.toStringAsFixed(2)} ${transaction.toCurrencyCode} yatırılacaktır. ${correctedValue['remainingRefund']} ${transaction.currencyCode} iade olacaktır.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Tamam'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('İptal'),
                        ),
                      ],
                    );
                  }) ??
              false;
        }
        return completed;
      default:
        if (transaction.currencyCode != transaction.toCurrencyCode) {
          var correctedValue = calculateCurrencyExchange(
              transaction.amount, transaction.currencyRate!, transaction.currencyCode, transaction.toCurrencyCode);
          transaction.calculatedAmount = double.parse(correctedValue['totalConverted'].toString());
          bool completed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Bilgilendirme'),
                    content: Text(
                        'Hesaplanan Tutar: ${transaction.calculatedAmount?.toStringAsFixed(2)} ${transaction.toCurrencyCode}'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Tamam'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('İptal'),
                      ),
                    ],
                  );
                },
              ) ??
              false;
          return completed;
        }
        return true;
    }
  }
}

Map<String, dynamic> calculateCurrencyExchange(
    double amount, double exchangeRate, String fromCurrency, String toCurrency) {
  double totalTargetCurrency = amount * exchangeRate;

  int wholeTargetCurrency = totalTargetCurrency.floor();

  double remainingTargetCurrency = totalTargetCurrency - wholeTargetCurrency;
  double remainingFromCurrency = (remainingTargetCurrency / exchangeRate).floor().toDouble();

  return {
    'fromCurrency': fromCurrency,
    'toCurrency': toCurrency,
    'totalConverted': wholeTargetCurrency,
    'remainingRefund': remainingFromCurrency
  };
}
