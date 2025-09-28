import 'package:uuid/uuid.dart';
import 'ingredient.dart';

class Meal {
  final String id;
  final String name;
  final DateTime date;
  final List<Ingredient> ingredients;

  Meal({
    String? id,
    required this.name,
    required this.date,
    required this.ingredients,
  }) : id = id ?? const Uuid().v4();

  double get totalProtein => ingredients.fold(0, (p, i) => p + i.protein);
  double get totalCarbs   => ingredients.fold(0, (p, i) => p + i.carbs);
  double get totalFat     => ingredients.fold(0, (p, i) => p + i.fat);
  double get calories     => ingredients.fold(0, (p, i) => p + i.calories);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.millisecondsSinceEpoch,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      ingredients: (map['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromMap(e))
          .toList(),
    );
  }
}
