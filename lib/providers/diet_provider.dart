import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class DietProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<Meal> get meals => _meals;

  DietProvider() {
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList('meals') ?? [];
      _meals = mealsJson
          .map((mJson) => Meal.fromMap(json.decode(mJson)))
          .toList();
      // sort by date
      _meals.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading meals: $e');
    }
  }

  Future<void> _saveMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = _meals.map((m) => json.encode(m.toMap())).toList();
      await prefs.setStringList('meals', mealsJson);
    } catch (e) {
      debugPrint('Error saving meals: $e');
    }
  }

  Future<void> addMeal(Meal meal) async {
    _meals.add(meal);
    _meals.sort((a, b) => b.date.compareTo(a.date));
    await _saveMeals();
    notifyListeners();
  }

  Future<void> updateMeal(Meal meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
      _meals.sort((a, b) => b.date.compareTo(a.date));
      await _saveMeals();
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    await _saveMeals();
    notifyListeners();
  }

  // Meals for a particular day
  List<Meal> mealsForDate(DateTime date) {
    return _meals.where((m) => _isSameDay(m.date, date)).toList();
  }

  // Daily calories map for a given week (Sunday‑Saturday). Key formatted yyyy-m-d
  Map<String, int> weeklyCalories(DateTime referenceDate) {
    final startOfWeek = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    Map<String, int> map = {};
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final key = _dateKey(day);
      map[key] = 0;
    }
    for (final meal in _meals) {
      if (meal.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          meal.date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        final key = _dateKey(meal.date);
        map[key] = (map[key] ?? 0) + meal.calories.round();
      }
    }
    return map;
  }

  // Macros for a single day
  ({double protein, double carbs, double fat}) macrosForDate(DateTime date) {
    final mealsToday = mealsForDate(date);
    double p = 0, c = 0, f = 0;
    for (final meal in mealsToday) {
      p += meal.totalProtein;
      c += meal.totalCarbs;
      f += meal.totalFat;
    }
    return (protein: p, carbs: c, fat: f);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}