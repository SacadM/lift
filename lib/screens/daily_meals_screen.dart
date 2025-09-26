// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../models/meal.dart';
// import '../providers/meal_provider.dart';
// import '../widgets/macro_pie_chart.dart';
// import 'edit_meal_screen.dart';

// class DailyMealsScreen extends StatelessWidget {
//   final DateTime date;

//   const DailyMealsScreen({
//     Key? key,
//     required this.date,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final mealProvider = Provider.of<MealProvider>(context);
//     final mealsForDate = mealProvider.getMealsForDate(date);
//     final macros = mealProvider.getMacroPercentagesForDate(date);
//     final totalCalories = mealProvider.getTotalCaloriesForDate(date);
//     final totalMacros = mealProvider.getTotalMacrosForDate(date);

//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: Text(DateFormat('EEEE, MMMM d').format(date)),
//         previousPageTitle: 'Summary',
//       ),
//       child: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(16.0),
//           children: [
//             // Daily summary card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: CupertinoColors.systemBackground,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: CupertinoColors.systemGrey4.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Calories: $totalCalories',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildMacroSummary('Protein', totalMacros['protein'] ?? 0, 'g', CupertinoColors.activeBlue.withOpacity(0.9)),
//                       _buildMacroSummary('Carbs', totalMacros['carbs'] ?? 0, 'g', CupertinoColors.activeGreen.withOpacity(0.9)),
//                       _buildMacroSummary('Fat', totalMacros['fat'] ?? 0, 'g', CupertinoColors.systemOrange.withOpacity(0.9)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Macro Distribution',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     height: 180,
//                     child: MacroPieChart(
//                       proteinPercentage: macros['protein'] ?? 0,
//                       carbsPercentage: macros['carbs'] ?? 0,
//                       fatPercentage: macros['fat'] ?? 0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Meals list
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Meals',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${mealsForDate.length} entries',
//                   style: const TextStyle(
//                     color: CupertinoColors.systemGrey,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             if (mealsForDate.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 30.0),
//                 child: Center(
//                   child: Text(
//                     'No meals recorded for this day',
//                     style: TextStyle(
//                       color: CupertinoColors.systemGrey,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: mealsForDate.length,
//                 itemBuilder: (context, index) {
//                   final meal = mealsForDate[index];
//                   return _buildMealItem(context, meal, mealProvider);
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMacroSummary(String label, double value, String unit, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             color: CupertinoColors.systemGrey,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           '${value.toStringAsFixed(1)}',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           unit,
//           style: const TextStyle(
//             fontSize: 14,
//             color: CupertinoColors.systemGrey,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMealItem(BuildContext context, Meal meal, MealProvider mealProvider) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: CupertinoColors.systemBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: CupertinoColors.systemGrey4.withOpacity(0.12),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: CupertinoContextMenu(
//         actions: [
//           CupertinoContextMenuAction(
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Edit'),
//                 Icon(CupertinoIcons.pencil),
//               ],
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//               _navigateToEditMeal(context, meal);
//             },
//           ),
//           CupertinoContextMenuAction(
//             isDestructiveAction: true,
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Delete'),
//                 Icon(CupertinoIcons.delete),
//               ],
//             ),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await _confirmDeletion(context, meal, mealProvider);
//             },
//           ),
//         ],
//         child: CupertinoButton(
//           padding: EdgeInsets.zero,
//           onPressed: () => _navigateToEditMeal(context, meal),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: CupertinoColors.activeBlue.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Center(
//                               child: Icon(
//                                 CupertinoIcons.square_list,
//                                 color: CupertinoColors.activeBlue,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               meal.name,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: CupertinoColors.label,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: CupertinoColors.activeBlue.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '${meal.calories} cal',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: CupertinoColors.activeBlue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildMacroCircle('P', meal.protein, CupertinoColors.activeBlue),
//                     _buildMacroCircle('C', meal.carbs, CupertinoColors.activeGreen),
//                     _buildMacroCircle('F', meal.fat, CupertinoColors.systemOrange),
//                   ],
//                 ),
//                 if (meal.ingredients.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Ingredients:',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: CupertinoColors.systemGrey,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     meal.ingredients.join(', '),
//                     style: const TextStyle(
//                       color: CupertinoColors.systemGrey,
//                       fontSize: 14,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildMacroCircle(String label, double value, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               value.toStringAsFixed(1),
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             color: color,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToEditMeal(BuildContext context, Meal meal) {
//     Navigator.of(context).push(
//       CupertinoPageRoute(
//         builder: (context) => EditMealScreen(meal: meal),
//       ),
//     );
//   }

//   Future<void> _confirmDeletion(BuildContext context, Meal meal, MealProvider mealProvider) async {
//     return showCupertinoDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: Text('Delete "${meal.name}"?'),
//           content: const Text('This action cannot be undone.'),
//           actions: [
//             CupertinoDialogAction(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             CupertinoDialogAction(
//               isDestructiveAction: true,
//               child: const Text('Delete'),
//               onPressed: () {
//                 mealProvider.deleteMeal(meal.id);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }