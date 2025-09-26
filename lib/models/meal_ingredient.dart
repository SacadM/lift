class MealIngredient {
  final String ingredientId;
  final double weight; // grams

  MealIngredient({
    required this.ingredientId,
    required this.weight,
  });

  Map<String, dynamic> toMap() => {
        'ingredientId': ingredientId,
        'weight': weight,
      };

  factory MealIngredient.fromMap(Map<String, dynamic> m) => MealIngredient(
        ingredientId: m['ingredientId'],
        weight: (m['weight'] as num).toDouble(),
      );
}