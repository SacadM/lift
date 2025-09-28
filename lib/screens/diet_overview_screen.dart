import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diet_provider.dart';
import '../widgets/calorie_bar_chart.dart';
import '../widgets/macro_pie_chart.dart';
import 'add_meal_screen.dart';

class DietOverviewScreen extends StatefulWidget {
  const DietOverviewScreen({Key? key}) : super(key: key);

  @override
  State<DietOverviewScreen> createState() => _DietOverviewScreenState();
}

class _DietOverviewScreenState extends State<DietOverviewScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);
    final dailyCalories = dietProvider.weeklyCalories(_selectedDate);
    final macros = dietProvider.macrosForDate(_selectedDate);
    final mealsToday = dietProvider.mealsForDate(_selectedDate);

    final totalCaloriesToday = dailyCalories['${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'] ?? 0;

    final totalMacros = macros.protein + macros.carbs + macros.fat;
    double pPerc = totalMacros == 0 ? 0 : (macros.protein / totalMacros) * 100;
    double cPerc = totalMacros == 0 ? 0 : (macros.carbs / totalMacros) * 100;
    double fPerc = totalMacros == 0 ? 0 : (macros.fat / totalMacros) * 100;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Diet', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const AddMealScreen()));
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calorie chart
            SizedBox(
              height: 220,
              child: CalorieBarChart(
                dailyCalories: dailyCalories,
                selectedDate: _selectedDate,
                onDaySelected: (day) => setState(() => _selectedDate = day),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${DateFormat('EEEE, MMM d').format(_selectedDate)}  •  $totalCaloriesToday kcal',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Water: ${dietProvider.waterMlForDate(_selectedDate)} ml',
                style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
              ),
            ),
            const SizedBox(height: 24),
            // Macro pie chart
            MacroPieChart(
              proteinPercentage: pPerc,
              carbsPercentage: cPerc,
              fatPercentage: fPerc,
            ),
            const SizedBox(height: 24),
            const Text('Meals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (mealsToday.isEmpty)
              const Center(
                child: Text('No meals logged for this day', style: TextStyle(color: CupertinoColors.systemGrey)),
              )
            else
              ...mealsToday.map((meal) => _buildMealTile(meal)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTile(meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${meal.calories.toStringAsFixed(0)} kcal', style: const TextStyle(color: CupertinoColors.systemGrey)),
            const SizedBox(height: 4),
            Text('P: ${meal.totalProtein.toStringAsFixed(1)}g   C: ${meal.totalCarbs.toStringAsFixed(1)}g   F: ${meal.totalFat.toStringAsFixed(1)}g',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
