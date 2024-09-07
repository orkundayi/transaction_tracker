import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionPageState _transactionPageState = TransactionPageState.expense;

  final TextEditingController _currencyController = TextEditingController();

  String _currentIcon = '₺';
  String _currentCurrency = 'TR';

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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                                          color: _transactionPageState == TransactionPageState.expense ? Colors.blue : Colors.black,
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
                                          color: _transactionPageState == TransactionPageState.income ? Colors.blue : Colors.black,
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
                                          color: _transactionPageState == TransactionPageState.transfer ? Colors.blue : Colors.black,
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
                                        _transactionPageState = TransactionPageState.expense;
                                      });
                                    },
                                    child: const SizedBox(height: 36),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _transactionPageState = TransactionPageState.income;
                                      });
                                    },
                                    child: const SizedBox(height: 36),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _transactionPageState = TransactionPageState.transfer;
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the alignment for the moving container
  Alignment _getAlignment() {
    switch (_transactionPageState) {
      case TransactionPageState.expense:
        return Alignment.topLeft;
      case TransactionPageState.income:
        return Alignment.topCenter;
      case TransactionPageState.transfer:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  Color _getContainerColor() {
    switch (_transactionPageState) {
      case TransactionPageState.expense:
        return Colors.redAccent.withOpacity(0.2);
      case TransactionPageState.income:
        return Colors.greenAccent.withOpacity(0.2);
      case TransactionPageState.transfer:
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
        showModalBottomSheet(
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
            return FractionallySizedBox(
              heightFactor: 0.95,
              child: Column(
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: const Text(
                      'Para Birimi Seç',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    elevation: 0,
                  ),
                  // Arama çubuğu
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Ara',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                    ),
                  ),
                  // Para birimi listesi
                  Expanded(
                    child: ListView.builder(
                      itemCount: currencies.currencies.length,
                      itemBuilder: (context, index) {
                        var currency = currencies.currencies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Card(
                            elevation: 2, // Hafif gölge efekti
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                currency.name ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                getCurrencySymbolFromCurrencyCode(
                                  currency.currencyCode ?? '',
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                _currentIcon = getCurrencySymbolFromCurrencyCode(
                                  currency.currencyCode ?? '',
                                );
                                _currentCurrency = currency.currencyCode ?? '';
                                debugPrint(
                                  'Currency: $_currentCurrency, Icon: $_currentIcon',
                                );
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  Future<http.Response> getCurrencies() async {
    final response = await http.get(Uri.parse('https://www.tcmb.gov.tr/kurlar/today.xml'));
    return response;
  }

  Widget currencyTextFormField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        controller: _currencyController,
        onChanged: (value) {
          _currencyController.text = value;
        },
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
}

enum TransactionPageState {
  expense,
  income,
  transfer,
}
