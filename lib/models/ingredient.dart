import 'package:uuid/uuid.dart';

class Ingredient {
  final String id;
  final String name;
  final double weight; // in grams
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double caloriesPer100g;

  Ingredient({
    String? id,
    required this.name,
    required this.weight,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.caloriesPer100g,
  }) : id = id ?? const Uuid().v4();

  // Macro totals for this ingredient instance
  double get protein => (weight / 100) * proteinPer100g;
  double get carbs   => (weight / 100) * carbsPer100g;
  double get fat     => (weight / 100) * fatPer100g;
  double get calories => (weight / 100) * caloriesPer100g;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'caloriesPer100g': caloriesPer100g,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    final double p = map['proteinPer100g']?.toDouble() ?? 0.0;
    final double c = map['carbsPer100g']?.toDouble() ?? 0.0;
    final double f = map['fatPer100g']?.toDouble() ?? 0.0;
    final double? kcal = map['caloriesPer100g'] != null
        ? (map['caloriesPer100g'] as num).toDouble()
        : null;
    return Ingredient(
      id: map['id'],
      name: map['name'],
      weight: map['weight']?.toDouble() ?? 0.0,
      proteinPer100g: p,
      carbsPer100g: c,
      fatPer100g: f,
      caloriesPer100g: kcal ?? (p * 4 + c * 4 + f * 9),
    );
  }

  Ingredient copyWith({
    String? id,
    String? name,
    double? weight,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? caloriesPer100g,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
    );
  }
}
