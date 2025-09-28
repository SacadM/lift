import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_template.dart';
import '../models/meal_ingredient.dart';

class MealTemplateProvider with ChangeNotifier {
  final List<MealTemplate> _templates = [];
  List<MealTemplate> get templates => List.unmodifiable(_templates);

  MealTemplateProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('meal_templates') ?? [];
      _templates
        ..clear()
        ..addAll(raw.map((e) => MealTemplate.fromMap(json.decode(e))));
      // Ensure a default 'Water' template exists if a Water ingredient is present.
      final hasWaterTemplate = _templates.any((t) => t.name.trim().toLowerCase() == 'water');
      if (!hasWaterTemplate) {
        final ingRaw = prefs.getStringList('ingredients') ?? [];
        String? waterId;
        for (final s in ingRaw) {
          try {
            final m = json.decode(s) as Map<String, dynamic>;
            final name = (m['name'] as String?)?.trim().toLowerCase();
            if (name == 'water') {
              waterId = m['id'] as String?;
              break;
            }
          } catch (_) {}
        }
        if (waterId != null) {
          _templates.add(MealTemplate(
            name: 'Water',
            items: [MealIngredient(ingredientId: waterId, weight: 250)], // default 250ml
          ));
          await _save();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading templates: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'meal_templates',
        _templates.map((e) => json.encode(e.toMap())).toList(),
      );
    } catch (e) {
      debugPrint('Error saving templates: $e');
    }
  }

  MealTemplate? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  MealTemplate? getByNameCaseInsensitive(String name) {
    final n = name.trim().toLowerCase();
    try {
      return _templates.firstWhere((t) => t.name.trim().toLowerCase() == n);
    } catch (_) {
      return null;
    }
  }

  List<MealTemplate> searchByName(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _templates
        .where((t) => t.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> add(MealTemplate t) async {
    _templates.add(t);
    await _save();
    notifyListeners();
  }

  Future<void> update(MealTemplate t) async {
    final idx = _templates.indexWhere((x) => x.id == t.id);
    if (idx != -1) {
      _templates[idx] = t;
      await _save();
      notifyListeners();
    }
  }

  Future<void> upsertByName(MealTemplate t) async {
    final existing = getByNameCaseInsensitive(t.name);
    if (existing == null) {
      await add(t);
    } else {
      final updated = MealTemplate(id: existing.id, name: t.name, items: t.items);
      await update(updated);
    }
  }
}
