import 'dart:developer';

import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:widgets/widgets.dart';

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
  DateTime? paymentDate;

  void _toggleCurrency() async {
    await getCurrencyList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<CreateTransactionBloc>(),
      child: Scaffold(
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
                                        color: checkIfExpense ? Colors.blue : Colors.black,
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
                                        color: _pageStateNotifier.value == PaymentSelectionState.income ? Colors.blue : Colors.black,
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
                                        color: _pageStateNotifier.value == PaymentSelectionState.transfer ? Colors.blue : Colors.black,
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
              PaymentSelector(pageStateNotifier: _pageStateNotifier)
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
                /* final TransactionModel transaction = TransactionModel.empty();
                transaction.amount = double.parse(_currencyController.text);
                transaction.currencyCode = _currentCurrency;
                transaction.category = CategoryModel.empty(CategoryType.otherExpense);
                transaction.category!.name = _categoryController.text;
                transaction.category!.type = categoryType;
                await transactionCalculate(transaction);
                debugPrint(transaction.toString());
                if (context.mounted) {
                  context.read<CreateTransactionBloc>().add(CreateTransaction(transaction: transaction));
                } */
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
              'Gider Ekle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
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
                  AnimatedContainer(
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
          hintText: 'Tutar',
          hintTextDirection: TextDirection.ltr,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(24)),
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
}
