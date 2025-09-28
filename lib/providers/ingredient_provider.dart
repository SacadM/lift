import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';

class IngredientProvider with ChangeNotifier {
  final List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  IngredientProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('ingredients') ?? [];
    _ingredients
      ..clear()
      ..addAll(raw.map((e) => Ingredient.fromMap(json.decode(e))));
    // Ensure a default Water ingredient exists (0 kcal, 0 macros)
    final hasWater = _ingredients.any((e) => e.name.trim().toLowerCase() == 'water');
    if (!hasWater) {
      _ingredients.add(Ingredient(
        name: 'Water',
        weight: 100,
        proteinPer100g: 0,
        carbsPer100g: 0,
        fatPer100g: 0,
        caloriesPer100g: 0,
      ));
      await _save();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'ingredients',
      _ingredients.map((e) => json.encode(e.toMap())).toList(),
    );
  }

  Future<void> add(Ingredient i) async {
    _ingredients.add(i);
    await _save();
    notifyListeners();
  }

  Future<void> update(Ingredient i) async {
    final idx = _ingredients.indexWhere((e) => e.id == i.id);
    if (idx != -1) _ingredients[idx] = i;
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _ingredients.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  // Get ingredient (or null if it doesn’t exist)
  Ingredient? getById(String id) {
    try {
      return _ingredients.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
