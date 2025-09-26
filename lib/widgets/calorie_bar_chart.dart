import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CalorieBarChart extends StatelessWidget {
  final Map<String, int> dailyCalories;
  final DateTime selectedDate;
  final Function(DateTime)? onDaySelected;

  const CalorieBarChart({
    Key? key,
    required this.dailyCalories,
    required this.selectedDate,
    this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the start of the week (Sunday)
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    
    // Create a list of days in the week
    final List<DateTime> daysOfWeek = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
    
    // Find the maximum calorie value for scaling
    int maxCalories = 2000; // Default minimum scale
    dailyCalories.forEach((date, calories) {
      if (calories > maxCalories) {
        maxCalories = calories;
      }
    });
    
    // Round up max calories to nearest 500 for nice scale
    maxCalories = ((maxCalories ~/ 500) + 1) * 500;
    
    return Column(
      children: [
        // Draw the chart
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: daysOfWeek.map((day) {
              // Format the date string key to match what's in dailyCalories
              final dateStr = '${day.year}-${day.month}-${day.day}';
              final calories = dailyCalories[dateStr] ?? 0;
              
              // Calculate the bar height as a percentage of the maximum
              final double heightPercent = calories / maxCalories;
              
              // Check if this is today
              final bool isToday = day.year == DateTime.now().year &&
                                  day.month == DateTime.now().month &&
                                  day.day == DateTime.now().day;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (onDaySelected != null) {
                        onDaySelected!(day);
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          calories.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? CupertinoColors.activeBlue 
                                  : CupertinoColors.systemBlue.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Set minimum height to 2 for visibility even when calories are 0
                            height: calories > 0 
                                ? heightPercent * double.infinity 
                                : 2,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('EEE').format(day)}\n${DateFormat('dd/MM').format(day)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}