import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;

class IncomeWidget extends StatefulWidget {
  final Function(DateTime? paymentDate) onDataChanged;
  final CategoryType categoryType;
  const IncomeWidget({super.key, required this.onDataChanged, required this.categoryType});

  @override
  State<IncomeWidget> createState() => _IncomeWidgetState();
}

class _IncomeWidgetState extends State<IncomeWidget> {
  DateTime? paymentDate;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 7,
      ),
      width: MediaQuery.of(context).size.width * 0.95,
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
      child: TextFormField(
        onTap: () async {
          final firstDateOfTheMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
          final lastDateOfTheMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: widget.categoryType == CategoryType.otherIncome ? DateTime(DateTime.now().year) : firstDateOfTheMonth,
            lastDate: widget.categoryType == CategoryType.otherIncome ? DateTime(DateTime.now().year + 100) : lastDateOfTheMonth,
          );
          if (date != null) {
            setState(() {
              paymentDate = date;
              widget.onDataChanged(paymentDate);
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
              'Gelir Tarihi: ${widget.categoryType == CategoryType.otherIncome ? paymentDate != null ? intl.DateFormat("d MMMM", "tr_TR").format(paymentDate!) : 'Seçin' : paymentDate != null ? 'Ayın ${intl.DateFormat('d', 'tr_TR').format(paymentDate!)}' : 'Seçin'}',
          hintTextDirection: TextDirection.ltr,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
