import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpenseWidget extends StatefulWidget {
  final Function(bool isInstallment, DateTime? paymentDate, DateTime? installmentDate, String installmentCount) onDataChanged;
  const ExpenseWidget({super.key, required this.onDataChanged});

  @override
  State<ExpenseWidget> createState() => _ExpenseWidgetState();
}

class _ExpenseWidgetState extends State<ExpenseWidget> {
  bool isInstallment = false;
  bool showInstallmentForContainer = false;
  double _opacity = 1.0;
  bool showInstallmentForCard = false;
  DateTime? paymentDate;
  DateTime? installmentDate;
  final TextEditingController installmentCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    installmentCountController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    installmentCountController.removeListener(_onDataChanged);
    super.dispose();
  }

  void _handleOpacity(bool value) async {
    if (value) {
      setState(() {
        _opacity = 0.0;
      });

      await Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          showInstallmentForContainer = isInstallment;
        });
      });

      await Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          showInstallmentForCard = isInstallment;
        });
      });
    } else {
      setState(() {
        _opacity = 0.0;
      });

      await Future.delayed(const Duration(milliseconds: 300), () {
        showInstallmentForCard = isInstallment;
      });

      await Future.delayed(const Duration(milliseconds: 50), () {
        showInstallmentForContainer = isInstallment;
      });
    }

    setState(() {
      _opacity = 1.0;
    });
  }

  void _onDataChanged() {
    widget.onDataChanged(
      isInstallment,
      paymentDate,
      installmentDate,
      installmentCountController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * 0.95,
      height: showInstallmentForContainer ? 200 : 136,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      _onDataChanged();
                      _handleOpacity(value);
                    });
                  },
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 300),
            child: showInstallmentForCard
                ? Column(
                    key: const ValueKey("installment"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: TextFormField(
                          controller: installmentCountController,
                          onChanged: (value) {
                            installmentCountController.text = value;
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
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
                                _onDataChanged();
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            hintText: 'Taksit Ödeme Günü: ${installmentDate?.toLocal().toString().split(' ')[0] ?? 'Seçin'}',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey("noInstallment"), // unique key for widget
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
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
                                _onDataChanged();
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            hintText: 'Ödeme Tarihi: ${paymentDate?.toLocal().toString().split(' ')[0] ?? 'Seçin'}',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
