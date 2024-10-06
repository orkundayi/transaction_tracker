import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:widgets/widgets.dart';

class UserAccountSelectorWidget extends StatefulWidget {
  final AccountModel? selectedAccount;
  final AccountModel? selectedTransferAccount;
  final VoidCallback? onAccountSelected;
  final VoidCallback? onTransferAccountSelected;
  final ValueNotifier<PaymentSelectionState> pageStateNotifier;
  const UserAccountSelectorWidget(
      {super.key, this.selectedAccount, this.onAccountSelected, this.selectedTransferAccount, this.onTransferAccountSelected, required this.pageStateNotifier});

  @override
  State<UserAccountSelectorWidget> createState() => _UserAccountSelectorWidgetState();
}

class _UserAccountSelectorWidgetState extends State<UserAccountSelectorWidget> {
  PaymentSelectionState _currentState = PaymentSelectionState.expense;
  double _opacity = 0.0;
  bool _showTransferAccount = false;

  @override
  void initState() {
    super.initState();
    widget.pageStateNotifier.addListener(_handlePageStateChange);
  }

  void _handlePageStateChange() async {
    switch (widget.pageStateNotifier.value) {
      case PaymentSelectionState.transfer:
        setState(() {
          _opacity = 0.0;
          _currentState = widget.pageStateNotifier.value;
        });
        await Future.delayed(const Duration(milliseconds: 310), () {
          setState(() {
            _showTransferAccount = true;
          });
        });
        await Future.delayed(const Duration(milliseconds: 310), () {
          setState(() {
            _opacity = 1.0;
          });
        });

        break;
      default:
        setState(() {
          _opacity = 0.0;
        });
        await Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _currentState = widget.pageStateNotifier.value;
          });
        });
        setState(() {
          _showTransferAccount = false;
        });
    }
  }

  @override
  void dispose() {
    widget.pageStateNotifier.removeListener(_handlePageStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _currentState == PaymentSelectionState.transfer ? 132 : 70,
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
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              widget.onAccountSelected?.call();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1.25,
                  height: 54,
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
                                  FontAwesomeIcons.moneyBillWave,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Hesap',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            widget.selectedAccount?.code ?? 'Hesap Seçin',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showTransferAccount)
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () async {
                  widget.onTransferAccountSelected?.call();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 1.25,
                      height: 54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
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
                                    FontAwesomeIcons.moneyBillWave,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Aktarılacak Hesap',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                widget.selectedTransferAccount?.code ?? 'Hesap Seçin',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
