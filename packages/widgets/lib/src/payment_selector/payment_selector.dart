import 'package:flutter/material.dart';
import 'package:widgets/src/payment_selector/expense.dart';

enum PaymentSelectionState {
  expense,
  income,
  transfer,
}

class PaymentSelector extends StatefulWidget {
  final ValueNotifier<PaymentSelectionState> pageStateNotifier;
  final Function(bool isInstallment, DateTime? paymentDate, DateTime? installmentDate, String installmentCount) onDataChanged;

  const PaymentSelector({super.key, required this.pageStateNotifier, required this.onDataChanged});

  @override
  State<PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<PaymentSelector> {
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
            widget.onDataChanged(isInstallment, paymentDate, installmentDate, installmentCount);
          },
        );
      case PaymentSelectionState.income:
        return const Center(child: Text('Income Page'));
      case PaymentSelectionState.transfer:
        return const Center(child: Text('Transfer Page'));
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }
}
