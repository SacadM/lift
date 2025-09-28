import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ingredient.dart';
import '../models/meal.dart';
import '../models/meal_ingredient.dart';
import '../models/meal_template.dart';
import '../providers/diet_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/meal_template_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key}) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final _ingredientSearchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Selected meal parts as ingredient references + weights
  final List<MealIngredient> _items = [];

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              color: CupertinoColors.systemGrey6,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => setState(() => _selectedDate = d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── helpers ─────────────────────────
  List<MealTemplate> _mealSuggestions(MealTemplateProvider tProv) {
    final q = _mealNameController.text.trim();
    if (q.isEmpty) return [];
    return tProv.searchByName(q);
  }

  bool _mealNameExists(MealTemplateProvider tProv) {
    final q = _mealNameController.text.trim();
    if (q.isEmpty) return false;
    return tProv.getByNameCaseInsensitive(q) != null;
  }

  void _applyTemplate(MealTemplate tmpl) {
    setState(() {
      _mealNameController.text = tmpl.name;
      _items
        ..clear()
        ..addAll(tmpl.items.map((e) => MealIngredient(
              ingredientId: e.ingredientId,
              weight: e.weight,
            )));
    });
  }

  List<Ingredient> _ingredientSuggestions(IngredientProvider iProv) {
    final q = _ingredientSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return iProv.ingredients
        .where((e) => e.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _promptWeight({
    required String title,
    required void Function(double) onConfirmed,
    double? initial,
  }) async {
    final ctrl = TextEditingController(text: initial == null ? '' : initial.toStringAsFixed(0));
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: ctrl,
              placeholder: 'Weight (g)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              final g = double.tryParse(ctrl.text) ?? 0;
              if (g > 0) {
                onConfirmed(g);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _promptMacrosPer100({
    required Ingredient existing,
    required void Function(double p, double c, double f) onConfirmed,
  }) async {
    final pC = TextEditingController(text: existing.proteinPer100g.toString());
    final cC = TextEditingController(text: existing.carbsPer100g.toString());
    final fC = TextEditingController(text: existing.fatPer100g.toString());
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Adjust macros for ${existing.name} (per 100g)'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: pC,
              placeholder: 'Protein /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: cC,
              placeholder: 'Carbs /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: fC,
              placeholder: 'Fat /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Update'),
            onPressed: () {
              final p = double.tryParse(pC.text) ?? existing.proteinPer100g;
              final c = double.tryParse(cC.text) ?? existing.carbsPer100g;
              final f = double.tryParse(fC.text) ?? existing.fatPer100g;
              onConfirmed(p, c, f);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createNewIngredientFlow(String name) async {
    final pC = TextEditingController();
    final cC = TextEditingController();
    final fC = TextEditingController();
    final wC = TextEditingController();
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Create "$name"'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: wC,
              placeholder: 'Weight to add (g)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            const Text('Macros per 100g', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: pC,
              placeholder: 'Protein /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: cC,
              placeholder: 'Carbs /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: fC,
              placeholder: 'Fat /100g',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Create'),
            onPressed: () async {
              final g = double.tryParse(wC.text) ?? 0;
              final p = double.tryParse(pC.text) ?? 0;
              final c = double.tryParse(cC.text) ?? 0;
              final f = double.tryParse(fC.text) ?? 0;
              if (g > 0) {
                final iProv = context.read<IngredientProvider>();
                final newIng = Ingredient(
                  name: name.trim(),
                  weight: 100, // default reference weight stored; not used in meal calc
                  proteinPer100g: p,
                  carbsPer100g: c,
                  fatPer100g: f,
                );
                await iProv.add(newIng);
                setState(() {
                  _items.add(MealIngredient(ingredientId: newIng.id, weight: g));
                  _ingredientSearchController.clear();
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Ingredient? _getIngredientById(String id) => context.read<IngredientProvider>().getById(id);

  (double p, double c, double f, int kcal) _macrosFor(String ingredientId, double weight) {
    final ing = _getIngredientById(ingredientId);
    if (ing == null) return (0, 0, 0, 0);
    final factor = weight / 100.0;
    final p = ing.proteinPer100g * factor;
    final c = ing.carbsPer100g * factor;
    final f = ing.fatPer100g * factor;
    final kcal = (p * 4 + c * 4 + f * 9).round();
    return (p, c, f, kcal);
  }

  double get _totalProtein => _items.fold(0.0, (sum, it) => sum + _macrosFor(it.ingredientId, it.weight).$1);
  double get _totalCarbs => _items.fold(0.0, (sum, it) => sum + _macrosFor(it.ingredientId, it.weight).$2);
  double get _totalFat => _items.fold(0.0, (sum, it) => sum + _macrosFor(it.ingredientId, it.weight).$3);
  int get _totalKcal => (_totalProtein * 4 + _totalCarbs * 4 + _totalFat * 9).round();

  Future<void> _saveAndAdd() async {
    final name = _mealNameController.text.trim();
    if (name.isEmpty || _items.isEmpty) return;
    final iProv = context.read<IngredientProvider>();
    final dProv = context.read<DietProvider>();
    final tProv = context.read<MealTemplateProvider>();

    // upsert template
    final tmpl = MealTemplate(name: name, items: List.of(_items));
    await tProv.upsertByName(tmpl);

    // build Meal
    final mealIngredients = _items.map((it) {
      final base = iProv.getById(it.ingredientId);
      if (base == null) {
        return Ingredient(
          name: 'Unknown',
          weight: it.weight,
          proteinPer100g: 0,
          carbsPer100g: 0,
          fatPer100g: 0,
        );
      }
      return Ingredient(
        id: base.id,
        name: base.name,
        weight: it.weight,
        proteinPer100g: base.proteinPer100g,
        carbsPer100g: base.carbsPer100g,
        fatPer100g: base.fatPer100g,
      );
    }).toList();

    await dProv.addMeal(Meal(name: name, date: _selectedDate, ingredients: mealIngredients));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _justAdd() async {
    final name = _mealNameController.text.trim();
    if (name.isEmpty || _items.isEmpty) return;
    final iProv = context.read<IngredientProvider>();
    final dProv = context.read<DietProvider>();

    final mealIngredients = _items.map((it) {
      final base = iProv.getById(it.ingredientId);
      if (base == null) {
        return Ingredient(
          name: 'Unknown',
          weight: it.weight,
          proteinPer100g: 0,
          carbsPer100g: 0,
          fatPer100g: 0,
        );
      }
      return Ingredient(
        id: base.id,
        name: base.name,
        weight: it.weight,
        proteinPer100g: base.proteinPer100g,
        carbsPer100g: base.carbsPer100g,
        fatPer100g: base.fatPer100g,
      );
    }).toList();

    await dProv.addMeal(Meal(name: name, date: _selectedDate, ingredients: mealIngredients));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tProv = context.watch<MealTemplateProvider>();
    final iProv = context.watch<IngredientProvider>();

    final mealSugs = _mealSuggestions(tProv);
    final ingSugs = _ingredientSuggestions(iProv);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add Meal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date selector
              CupertinoButton(
                onPressed: _showDatePicker,
                padding: const EdgeInsets.all(12),
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
                    const Icon(CupertinoIcons.calendar),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Meal name search
              CupertinoSearchTextField(
                controller: _mealNameController,
                placeholder: 'Meal name (search or create)',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              if (_mealNameController.text.trim().isNotEmpty && !_mealNameExists(tProv))
                const Text('New meal', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
              if (mealSugs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: mealSugs
                        .map((m) => CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              onPressed: () => _applyTemplate(m),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m.name, overflow: TextOverflow.ellipsis)),
                                  const Icon(CupertinoIcons.arrow_down_right_square),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CupertinoSearchTextField(
                controller: _ingredientSearchController,
                placeholder: 'Search or create ingredient',
                onChanged: (_) => setState(() {}),
              ),
              if (_ingredientSearchController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                if (ingSugs.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: ingSugs
                          .map(
                            (e) => CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              onPressed: () async {
                                await _promptWeight(
                                  title: 'Weight for ${e.name}',
                                  onConfirmed: (g) {
                                    setState(() {
                                      _items.add(MealIngredient(ingredientId: e.id, weight: g));
                                      _ingredientSearchController.clear();
                                    });
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(e.name, overflow: TextOverflow.ellipsis)),
                                  Text('P/F/C ${e.proteinPer100g.toStringAsFixed(1)}/${e.fatPer100g.toStringAsFixed(1)}/${e.carbsPer100g.toStringAsFixed(1)}',
                                      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (ingSugs.isEmpty)
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    onPressed: () => _createNewIngredientFlow(_ingredientSearchController.text.trim()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text('Create "${_ingredientSearchController.text.trim()}"',
                                overflow: TextOverflow.ellipsis)),
                        const Icon(CupertinoIcons.add_circled),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              // Selected ingredient rows
              ..._items.map((it) {
                final base = _getIngredientById(it.ingredientId);
                final name = base?.name ?? 'Unknown';
                final (p, c, f, kcal) = _macrosFor(it.ingredientId, it.weight);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    onPressed: () async {
                      await showCupertinoModalPopup(
                        context: context,
                        builder: (_) => CupertinoActionSheet(
                          title: Text(name),
                          message: Text('${it.weight.toStringAsFixed(0)} g  •  P/F/C ${p.toStringAsFixed(1)}/${f.toStringAsFixed(1)}/${c.toStringAsFixed(1)}'),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _promptWeight(
                                  title: 'Adjust weight',
                                  initial: it.weight,
                                  onConfirmed: (g) {
                                    final idx = _items.indexOf(it);
                                    if (idx != -1) {
                                      setState(() {
                                        _items[idx] = MealIngredient(
                                          ingredientId: it.ingredientId,
                                          weight: g,
                                        );
                                      });
                                    }
                                  },
                                );
                              },
                              child: const Text('Adjust weight'),
                            ),
                            if (base != null)
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _promptMacrosPer100(
                                      existing: base,
                                      onConfirmed: (pp, cc, ff) async {
                                        final iProv = context.read<IngredientProvider>();
                                        await iProv.update(base.copyWith(
                                          proteinPer100g: pp,
                                          carbsPer100g: cc,
                                          fatPer100g: ff,
                                        ));
                                        if (mounted) setState(() {});
                                      });
                                },
                                child: const Text('Adjust macros per 100g'),
                              ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              setState(() => _items.remove(it));
                              Navigator.of(context).pop();
                            },
                            child: const Text('Remove ingredient'),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$name (${it.weight.toStringAsFixed(0)}g) - ${p.toStringAsFixed(1)}/${f.toStringAsFixed(1)}/${c.toStringAsFixed(1)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('$kcal kcal', style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroChip('P', _totalProtein),
                    _macroChip('C', _totalCarbs),
                    _macroChip('F', _totalFat),
                    _macroChip('kcal', _totalKcal.toDouble()),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              // Actions
              CupertinoButton.filled(
                onPressed: _saveAndAdd,
                child: const Text('Save and Add'),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                onPressed: _justAdd,
                child: const Text('Just Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _macroChip(String label, double value) => Column(
      children: [
        Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
      ],
    );
