import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:widgets/src/payment_selector/payment_selector.dart';

class CategorySelectorWidget extends StatefulWidget {
  final PaymentSelectionState paymentSelectionState;
  final GlobalKey<CategorySelectorWidgetState> categoryKey;
  final Function(String category, CategoryType? categoryType) onDataChanged;

  const CategorySelectorWidget({required this.onDataChanged, required this.paymentSelectionState, required this.categoryKey}) : super(key: categoryKey);

  void clearData() {
    categoryKey.currentState?.clearDataAccordingToPaymentSelectionState();
  }

  @override
  State<CategorySelectorWidget> createState() => CategorySelectorWidgetState();
}

class CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  CategoryType? categoryType = CategoryType.otherExpense;
  final TextEditingController _categoryController = TextEditingController(text: 'Kategori Seçin');

  void clearDataAccordingToPaymentSelectionState() {
    if (widget.paymentSelectionState == PaymentSelectionState.expense) {
      categoryType = CategoryType.otherExpense;
    } else {
      categoryType = CategoryType.otherIncome;
    }
    _categoryController.text = 'Kategori Seçin';
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: TextFormField(
        controller: _categoryController,
        onTap: () async {
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
                widthFactor: 1,
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
                        itemCount: widget.paymentSelectionState == PaymentSelectionState.expense ? CategoryModel.expenseCategoryTypeCount : CategoryModel.incomeCategoryTypeCount,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemBuilder: (context, index) {
                          CategoryType categoryType =
                              widget.paymentSelectionState == PaymentSelectionState.expense ? CategoryModel.expenseCategoryTypes[index] : CategoryModel.incomeCategoryTypes[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ListTile(
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
                                _categoryController.text = getCategoryName(categoryType);
                                this.categoryType = categoryType;
                                widget.onDataChanged(_categoryController.text, this.categoryType);
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: kToolbarHeight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 3,
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
}
