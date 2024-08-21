import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryModel {
  String id;
  String name;
  CategoryType? type;
  FaIcon? categoryIcon;
  String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryIcon,
    this.description,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values[map['type']],
      categoryIcon: getCategoryIcon(CategoryType.values[map['type']]),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap(CategoryModel? category) {
    return {
      'id': id,
      'name': name,
      'type': type?.index,
      'categoryIcon': categoryIcon,
      'description': description,
    };
  }
}

enum CategoryType {
  electronics, //elektronik
  education, //eğitim
  entertainment, //eylence
  food, //yemek
  health, //sağlık
  transportation, //ulaşım
  other //diğer
}

getCategoryName(CategoryType? type) {
  switch (type) {
    case CategoryType.electronics:
      return 'Elektronik';
    case CategoryType.education:
      return 'Eğitim';
    case CategoryType.entertainment:
      return 'Eylence';
    case CategoryType.food:
      return 'Yemek';
    case CategoryType.health:
      return 'Sağlık';
    case CategoryType.transportation:
      return 'Ulaşım';
    case CategoryType.other:
    default:
      return 'Diğer';
  }
}

getCategoryIcon(CategoryType? type) {
  switch (type) {
    case CategoryType.electronics:
      return const FaIcon(FontAwesomeIcons.mobileScreenButton);
    case CategoryType.education:
      return const FaIcon(FontAwesomeIcons.graduationCap);
    case CategoryType.entertainment:
      return const FaIcon(FontAwesomeIcons.gamepad);
    case CategoryType.food:
      return const FaIcon(FontAwesomeIcons.burger);
    case CategoryType.health:
      return const FaIcon(FontAwesomeIcons.heartPulse);
    case CategoryType.transportation:
      return const FaIcon(FontAwesomeIcons.bus);
    case CategoryType.other:
    default:
      return const FaIcon(FontAwesomeIcons.bars);
  }
}
