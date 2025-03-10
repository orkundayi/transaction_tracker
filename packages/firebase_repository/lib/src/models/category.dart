import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryModel {
  String name;
  CategoryType? type;
  FaIcon? categoryIcon;
  String? description;

  CategoryModel({
    required this.name,
    required this.type,
    required this.categoryIcon,
    this.description,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      name: map['name'],
      type: CategoryType.values[map['type']],
      categoryIcon: getCategoryIcon(CategoryType.values[map['type']]),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap(CategoryModel? category) {
    return {
      'name': name,
      'type': type?.index,
      'description': description,
    };
  }

  factory CategoryModel.empty(CategoryType type) {
    return CategoryModel(
      name: '',
      type: type,
      categoryIcon: getCategoryIcon(type),
    );
  }
  // Tüm CategoryType enum değerlerini döndüren bir fonksiyon
  static List<CategoryType> get allCategoryTypes => CategoryType.values.toList();

  // Belirli CategoryType'ları içeren bir liste döndüren fonksiyon
  static List<CategoryType> get incomeCategoryTypes => [
        CategoryType.salary,
        CategoryType.passive,
        CategoryType.otherIncome,
      ];

  // Belirli CategoryType'ları içermeyenleri döndüren fonksiyon
  static List<CategoryType> get expenseCategoryTypes =>
      CategoryType.values.where((type) => !incomeCategoryTypes.contains(type)).toList();

  // Belirli CategoryType'ların sayısını döndüren fonksiyon
  static int get incomeCategoryTypeCount => incomeCategoryTypes.length;

  // Belirli CategoryType'ların sayısını döndüren fonksiyon
  static int get expenseCategoryTypeCount => expenseCategoryTypes.length;
}

enum CategoryType {
  // Expenses
  electronics, //elektronik
  education, //eğitim
  entertainment, //eğlence
  food, //yemek
  health, //sağlık
  transportation, //ulaşım
  otherExpense, //diğer
  // Incomes
  salary, //maaş
  passive, //pasif
  otherIncome, //diğer
}

getCategoryName(CategoryType? type) {
  switch (type) {
    case CategoryType.electronics:
      return 'Elektronik';
    case CategoryType.education:
      return 'Eğitim';
    case CategoryType.entertainment:
      return 'Eğlence';
    case CategoryType.food:
      return 'Yemek';
    case CategoryType.health:
      return 'Sağlık';
    case CategoryType.transportation:
      return 'Ulaşım';
    case CategoryType.salary:
      return 'Maaş';
    case CategoryType.passive:
      return 'Pasif Gelir';
    case CategoryType.otherExpense:
    case CategoryType.otherIncome:
    default:
      return 'Diğer';
  }
}

getCategoryIcon(CategoryType? type) {
  double size = 16;
  switch (type) {
    case CategoryType.electronics:
      return FaIcon(FontAwesomeIcons.mobileScreenButton, size: size);
    case CategoryType.education:
      return FaIcon(FontAwesomeIcons.graduationCap, size: size);
    case CategoryType.entertainment:
      return FaIcon(FontAwesomeIcons.gamepad, size: size);
    case CategoryType.food:
      return FaIcon(FontAwesomeIcons.burger, size: size);
    case CategoryType.health:
      return FaIcon(FontAwesomeIcons.heartPulse, size: size);
    case CategoryType.transportation:
      return FaIcon(FontAwesomeIcons.bus, size: size);
    case CategoryType.salary:
    case CategoryType.passive:
      return FaIcon(FontAwesomeIcons.wallet, size: size);
    case CategoryType.otherExpense:
    case CategoryType.otherIncome:
    default:
      return FaIcon(FontAwesomeIcons.bars, size: size);
  }
}
