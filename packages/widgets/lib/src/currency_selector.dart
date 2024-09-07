import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';

class CurrencySelector extends StatefulWidget {
  final List<CurrencyModel> allCurrencies;
  const CurrencySelector({super.key, required this.allCurrencies});

  @override
  CurrencySelectorState createState() => CurrencySelectorState();
}

class CurrencySelectorState extends State<CurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyModel> _filteredCurrencies = [];

  void _filterCurrencies(String query) {
    final filtered = widget.allCurrencies.where((currency) {
      final currencyName = currency.name?.toLowerCase() ?? '';
      final input = query.toLowerCase();

      return currencyName.contains(input);
    }).toList();

    setState(() {
      _filteredCurrencies = filtered;
    });
  }

  @override
  void initState() {
    _filteredCurrencies = widget.allCurrencies;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Add Currency',
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
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Type currency name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
              onChanged: _filterCurrencies,
            ),
          ),
          // Para birimi listesi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                CurrencyModel currency = _filteredCurrencies[index];
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
                        Navigator.of(context).pop({
                          'currencyCode': currency.currencyCode ?? '',
                          'currencySymbol': getCurrencySymbolFromCurrencyCode(
                            currency.currencyCode ?? '',
                          ),
                        });
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
  }
}
