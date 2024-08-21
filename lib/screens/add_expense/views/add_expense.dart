import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_repository/transaction_repository.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  String _currentIcon = '₺';
  String _currentCurrency = 'TR';

  bool isInstallment = false;
  int? installmentCount;
  DateTime? installmentDate;
  DateTime? paymentDate;

  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'Kategori Seçin');
  final TextEditingController _installmentCountController =
      TextEditingController();

  void _toggleCurrency() async {
    await getCurrencyList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gider Ekle'),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  currencyTextFormField(),
                  const SizedBox(height: 16),
                  categoryTextFormField(),
                  const SizedBox(height: 16),
                  paymentInfo(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: kToolbarHeight,
                    child: TextButton(
                      onPressed: () async {
                        final TransactionModel transaction =
                            TransactionModel.empty();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getCurrencyList() async {
    final response =
        await http.get(Uri.parse('https://www.tcmb.gov.tr/kurlar/today.xml'));

    if (response.statusCode == 200) {
      var currencies = await parseCurrencyFromResponse(response.body);
      currencies.currencies.sort((a, b) => a.orderNo.compareTo(b.orderNo));
      if (mounted) {
        showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Para Birimi Seçin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currencies.currencies.length,
                      itemBuilder: (context, index) {
                        var currency = currencies.currencies[index];
                        return ListTile(
                          title: Text(
                            currency.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            getCurrencySymbolFromCurrencyCode(
                                currency.currencyCode),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            _currentIcon = getCurrencySymbolFromCurrencyCode(
                              currency.currencyCode,
                            );
                            _currentCurrency = currency.currencyCode;
                            debugPrint(
                              'Currency: $_currentCurrency, Icon: $_currentIcon',
                            );
                            setState(() {});
                            Navigator.of(context).pop();
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
              ),
            );
          },
        );
      }
    }
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    height: 40,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 4,
                    right: 6,
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

  Widget categoryTextFormField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        controller: _categoryController,
        onTap: () async {
          showModalBottomSheet(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 0.8,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Kategori Seçin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: CategoryType.values.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          CategoryType categoryType =
                              CategoryType.values[index];
                          return ListTile(
                            title: Text(
                              getCategoryName(categoryType),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: getCategoryIcon(categoryType),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onTap: () {
                              _categoryController.text =
                                  getCategoryName(categoryType);
                              setState(() {});
                              Navigator.of(context).pop();
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
                ),
              );
            },
          );
        },
        textAlignVertical: TextAlignVertical.center,
        readOnly: true,
        decoration: InputDecoration(
          fillColor: Colors.white,
          hintText: _categoryController.text,
          filled: true,
          prefixIcon: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              height: 40,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                  Icons.category,
                  size: 20,
                ),
              ),
            ),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
    );
  }

  Widget paymentInfo() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                FontAwesomeIcons.creditCard,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Taksit mevcut mu?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isInstallment,
                      onChanged: (value) {
                        setState(() {
                          isInstallment = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (isInstallment) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                  child: TextFormField(
                    controller: _installmentCountController,
                    onChanged: (value) {
                      _installmentCountController.text = value;
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      filled: true,
                      prefixIcon: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.circleQuestion,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 4,
                              right: 6,
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
                      hintText: 'Taksit Sayısı',
                      hintTextDirection: TextDirection.ltr,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(DateTime.now().year + 100),
                      );
                      if (date != null) {
                        setState(() {
                          installmentDate = date;
                        });
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      filled: true,
                      prefixIcon: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.calendarDay,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 4,
                              right: 6,
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
                      hintText:
                          'Taksit Ödeme Günü: ${installmentDate?.toLocal().toString().split(' ')[0] ?? 'Seçin'}',
                      hintTextDirection: TextDirection.ltr,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (!isInstallment) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                  child: TextFormField(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(DateTime.now().year + 100),
                      );
                      if (date != null) {
                        setState(() {
                          paymentDate = date;
                        });
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      filled: true,
                      prefixIcon: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.calendarDay,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 4,
                              right: 6,
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
                      hintText:
                          'Ödeme Tarihi: ${paymentDate?.toLocal().toString().split(' ')[0] ?? 'Seçin'}',
                      hintTextDirection: TextDirection.ltr,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ]
            ],
          ),
        ),
        const Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              FontAwesomeIcons.calendarDay,
              size: 80,
            ),
          ),
        ),
      ],
    );
  }
}
