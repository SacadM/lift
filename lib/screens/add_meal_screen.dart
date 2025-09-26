import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ingredient.dart';
import '../models/meal.dart';
import '../providers/diet_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key}) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<_IngredientFormData> _ingredients = [];

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

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(_IngredientFormData());
    });
  }

  void _saveMeal() {
    if (!_formKey.currentState!.validate() || _ingredients.isEmpty) return;
    final dietProvider = Provider.of<DietProvider>(context, listen: false);

    final ingredients = _ingredients.map((data) => data.toIngredient()).toList();
    final meal = Meal(
      name: _mealNameController.text.trim(),
      date: _selectedDate,
      ingredients: ingredients,
    );

    dietProvider.addMeal(meal);

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Meal added successfully'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),
              // Meal name
              CupertinoTextFormFieldRow(
                controller: _mealNameController,
                placeholder: 'Meal name (e.g. Breakfast)',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter meal name' : null,
              ),
              const SizedBox(height: 24),
              const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // Ingredient rows
              ..._ingredients.map((data) => _IngredientRow(data: data, onRemove: () {
                    setState(() => _ingredients.remove(data));
                  })),
              CupertinoButton.filled(
                onPressed: _addIngredientRow,
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: const Text('Save Meal'),
                onPressed: _saveMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientFormData {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  Ingredient toIngredient() {
    return Ingredient(
      name: nameController.text.trim(),
      weight: double.tryParse(weightController.text) ?? 0,
      proteinPer100g: double.tryParse(proteinController.text) ?? 0,
      carbsPer100g: double.tryParse(carbsController.text) ?? 0,
      fatPer100g: double.tryParse(fatController.text) ?? 0,
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final _IngredientFormData data;
  final VoidCallback onRemove;
  const _IngredientRow({Key? key, required this.data, required this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: data.nameController,
                placeholder: 'Ingredient',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              onPressed: onRemove,
              child: const Icon(CupertinoIcons.delete_simple, size: 20, color: CupertinoColors.destructiveRed),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _numberField(controller: data.weightController, placeholder: 'g'),
            const SizedBox(width: 6),
            _numberField(controller: data.proteinController, placeholder: 'P/100g'),
            const SizedBox(width: 6),
            _numberField(controller: data.carbsController, placeholder: 'C/100g'),
            const SizedBox(width: 6),
            _numberField(controller: data.fatController, placeholder: 'F/100g'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _numberField({required TextEditingController controller, required String placeholder}) {
    return Expanded(
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}