import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:widgets/src/payment_selector/expense.dart';
import 'package:widgets/src/payment_selector/income.dart';

enum PaymentSelectionState {
  expense,
  income,
  transfer,
}

class PaymentSelectorWidget extends StatefulWidget {
  final CategoryType categoryType;
  final ValueNotifier<PaymentSelectionState> pageStateNotifier;
  final Function(bool isInstallment, DateTime? paymentDate, DateTime? installmentDate, String installmentCount)
      onDataChangedForExpense;
  final Function(DateTime? paymentDate) onDataChangedForIncome;

  const PaymentSelectorWidget(
      {super.key,
      required this.pageStateNotifier,
      required this.onDataChangedForExpense,
      required this.onDataChangedForIncome,
      required this.categoryType});

  @override
  State<PaymentSelectorWidget> createState() => _PaymentSelectorWidgetState();
}

class _PaymentSelectorWidgetState extends State<PaymentSelectorWidget> {
  bool isInstallment = false;
  double _opacity = 1.0;
  PaymentSelectionState _currentState = PaymentSelectionState.expense;

  @override
  void initState() {
    super.initState();
    widget.pageStateNotifier.addListener(_handlePageStateChange);
  }

  void _handlePageStateChange() {
    setState(() {
      _opacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentState = widget.pageStateNotifier.value;
      });

      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    widget.pageStateNotifier.removeListener(_handlePageStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: _buildPageContent(_currentState),
    );
  }

  Widget _buildPageContent(PaymentSelectionState state) {
    switch (state) {
      case PaymentSelectionState.expense:
        return ExpenseWidget(
          onDataChanged: (isInstallment, paymentDate, installmentDate, installmentCount) {
            widget.onDataChangedForExpense(isInstallment, paymentDate, installmentDate, installmentCount);
          },
        );
      case PaymentSelectionState.income:
        return IncomeWidget(
          categoryType: widget.categoryType,
          onDataChanged: (paymentDate) {
            widget.onDataChangedForIncome(paymentDate);
          },
        );
      case PaymentSelectionState.transfer:
      default:
        return const SizedBox();
    }
  }
}
