import 'package:uuid/uuid.dart';
import 'meal_ingredient.dart';

class MealTemplate {
  final String id;
  final String name;
  final List<MealIngredient> items;

  MealTemplate({
    String? id,
    required this.name,
    required this.items,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'items': items.map((e) => e.toMap()).toList(),
      };

  factory MealTemplate.fromMap(Map<String, dynamic> map) => MealTemplate(
        id: map['id'],
        name: map['name'],
        items: (map['items'] as List<dynamic>)
            .map((e) => MealIngredient.fromMap(e))
            .toList(),
      );
}

