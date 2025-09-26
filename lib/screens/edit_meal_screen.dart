// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../models/meal.dart';
// import '../models/meal_ingredient.dart';
// import '../models/ingredient.dart';
// import '../providers/meal_provider.dart';
// import '../providers/ingredient_provider.dart';

// class EditMealScreen extends StatefulWidget {
//   final Meal meal;
//   const EditMealScreen({Key? key, required this.meal}) : super(key: key);

//   @override
//   State<EditMealScreen> createState() => _EditMealScreenState();
// }

// class _EditMealScreenState extends State<EditMealScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _name = TextEditingController();
//   DateTime _selectedDate = DateTime.now();

//   late List<MealIngredient> _parts;
//   double _p = 0, _c = 0, _f = 0;
//   int _cal = 0;

//   @override
//   void initState() {
//     super.initState();
//     _name.text = widget.meal.name;
//     _selectedDate = widget.meal.date;
//     _parts = List<MealIngredient>.from(widget.meal.ingredients);
//     _p = widget.meal.protein;
//     _c = widget.meal.carbs;
//     _f = widget.meal.fat;
//     _cal = widget.meal.calories;
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     super.dispose();
//   }

//   // ───────────────── helpers ─────────────────
//   void _recalc() {
//     final iProv = context.read<IngredientProvider>();
//     double p = 0, c = 0, f = 0;
//     int cal = 0;
//     for (final part in _parts) {
//       final ing = iProv.getById(part.ingredientId);
//       if (ing == null) continue;
//       final fct = part.weight / 100.0;
//       p   += ing.protein * fct;
//       c   += ing.carbs   * fct;
//       f   += ing.fat     * fct;
//       cal += (ing.calories * fct).round();
//     }
//     setState(() {
//       _p = p; _c = c; _f = f; _cal = cal;
//     });
//   }

//   // ───────────────── UI ─────────────────
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: const Text('Edit Meal'),
//         previousPageTitle: DateFormat('MMM d').format(widget.meal.date),
//       ),
//       child: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // name
//               CupertinoTextField(controller: _name, placeholder: 'Meal name'),
//               const SizedBox(height: 20),

//               // ingredient list
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Ingredients',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   CupertinoButton(
//                     padding: EdgeInsets.zero,
//                     child: const Icon(CupertinoIcons.add_circled),
//                     onPressed: _openPicker,
//                   ),
//                 ],
//               ),
//               ..._parts.map(_tile),
//               const SizedBox(height: 20),

//               // totals
//               if (_parts.isNotEmpty) _totals(),

//               const SizedBox(height: 32),
//               CupertinoButton.filled(
//                 onPressed: _save,
//                 child: const Text('Update Meal'),
//               ),
//               const SizedBox(height: 16),
//               CupertinoButton(
//                 onPressed: _confirmDelete,
//                 child: const Text('Delete Meal',
//                     style: TextStyle(color: CupertinoColors.destructiveRed)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _tile(MealIngredient m) {
//     final ing = context.read<IngredientProvider>().getById(m.ingredientId);
//     if (ing == null) return const SizedBox.shrink();
//     return Dismissible(
//       key: ValueKey('${m.ingredientId}_${m.weight}'),
//       background: Container(color: CupertinoColors.systemRed),
//       onDismissed: (_) {
//         setState(() => _parts.remove(m));
//         _recalc();
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Row(
//           children: [
//             Expanded(child: Text(ing.name)),
//             Text('${m.weight.toStringAsFixed(0)} g'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _totals() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Calculated Macros',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _chip('Protein', _p),
//               _chip('Carbs', _c),
//               _chip('Fat', _f),
//               _chip('Cal', _cal.toDouble()),
//             ],
//           ),
//         ],
//       );

//   Widget _chip(String lbl, double v) => Column(
//         children: [
//           Text(v.toStringAsFixed(1),
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(lbl,
//               style: const TextStyle(
//                   fontSize: 12, color: CupertinoColors.systemGrey)),
//         ],
//       );

//   // picker
//   void _openPicker() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (_) => _IngredientPicker(onPicked: (ing, g) {
//         setState(() => _parts.add(
//             MealIngredient(ingredientId: ing.id, weight: g))); // add part
//         _recalc();
//       }),
//     );
//   }

//   // save
//   void _save() {
//     if (_formKey.currentState!.validate() && _parts.isNotEmpty) {
//       final updated = Meal(
//         id: widget.meal.id,
//         name: _name.text.trim(),
//         date: _selectedDate,
//         ingredients: _parts,
//         protein: _p,
//         carbs: _c,
//         fat: _f,
//         calories: _cal,
//       );
//       context.read<MealProvider>().updateMeal(updated);
//       Navigator.of(context).pop();
//     }
//   }

//   // delete
//   void _confirmDelete() {
//     showCupertinoDialog(
//       context: context,
//       builder: (_) => CupertinoAlertDialog(
//         title: Text('Delete "${widget.meal.name}"?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           CupertinoDialogAction(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop()),
//           CupertinoDialogAction(
//             isDestructiveAction: true,
//             child: const Text('Delete'),
//             onPressed: () {
//               context.read<MealProvider>().deleteMeal(widget.meal.id);
//               Navigator.of(context)
//                 ..pop()
//                 ..pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ───────────────── modal ingredient picker ─────────────────
// class _IngredientPicker extends StatefulWidget {
//   final void Function(Ingredient ing, double weight) onPicked;
//   const _IngredientPicker({required this.onPicked});

//   @override
//   State<_IngredientPicker> createState() => _IngredientPickerState();
// }

// class _IngredientPickerState extends State<_IngredientPicker> {
//   Ingredient? _sel;
//   final _w = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final list = context.watch<IngredientProvider>().ingredients;
//     return Container(
//       height: 420,
//       color: CupertinoColors.systemBackground,
//       child: Column(
//         children: [
//           const SizedBox(height: 12),
//           const Text('Select ingredient',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(
//             child: CupertinoPicker(
//               itemExtent: 32,
//               onSelectedItemChanged: (i) => setState(() => _sel = list[i]),
//               children: list.map((e) => Text(e.name)).toList(),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: CupertinoTextField(
//               controller: _w,
//               placeholder: 'Weight in g',
//               keyboardType:
//                   const TextInputType.numberWithOptions(decimal: true),
//             ),
//           ),
//           const SizedBox(height: 12),
//           CupertinoButton.filled(
//             onPressed: () {
//               final g = double.tryParse(_w.text) ?? 0;
//               if (_sel != null && g > 0) {
//                 widget.onPicked(_sel!, g);
//                 Navigator.of(context).pop();
//               }
//             },
//             child: const Text('Add'),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }