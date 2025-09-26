import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';

class WorkoutChart extends StatelessWidget {
  final List<Workout> workouts;
  final bool showWeight; // If false, show estimated 1RM
  
  const WorkoutChart({
    Key? key,
    required this.workouts,
    this.showWeight = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Center(
        child: Text(
          'No workout data to display',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate chart dimensions
        final chartWidth = constraints.maxWidth;
        final chartHeight = constraints.maxHeight - 40; // Reserve space for x-axis labels
        
        // Filter to last 20 workouts if more exist
        final displayWorkouts = workouts.length > 20 
            ? workouts.sublist(workouts.length - 20) 
            : workouts;
            
        // Get max value for scaling
        double maxValue = 0;
        for (var workout in displayWorkouts) {
          final value = showWeight 
              ? workout.weight 
              : workout.estimatedOneRepMax;
          if (value > maxValue) {
            maxValue = value;
          }
        }
        
        // Add 10% padding to max value for better visualization
        maxValue = maxValue * 1.1;
        
        // Calculate bar width based on available space
        final barWidth = chartWidth / displayWorkouts.length - 8;
        
        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: Stack(
                children: [
                  // Horizontal grid lines
                  ..._buildGridLines(chartHeight, maxValue),
                  
                  // Data bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: displayWorkouts.map((workout) {
                      final value = showWeight 
                          ? workout.weight 
                          : workout.estimatedOneRepMax;
                      final barHeight = (value / maxValue) * chartHeight;
                      
                      return _buildBar(
                        barWidth: barWidth,
                        barHeight: barHeight,
                        value: value,
                        date: workout.date,
                        isRM: !showWeight,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // X-axis labels
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: displayWorkouts.map((workout) {
                  return SizedBox(
                    width: barWidth + 8,
                    child: Text(
                      DateFormat('MMM d').format(workout.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
  
  List<Widget> _buildGridLines(double height, double maxValue) {
    // Create 5 grid lines
    const lineCount = 5;
    final List<Widget> lines = [];
    
    for (int i = 0; i < lineCount; i++) {
      final yPos = height - (height / lineCount * i);
      final value = (maxValue / lineCount * i).toStringAsFixed(1);
      
      lines.add(
        Positioned(
          top: yPos,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: CupertinoColors.systemGrey5,
          ),
        ),
      );
      
      lines.add(
        Positioned(
          top: yPos - 10,
          left: 4,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      );
    }
    
    return lines;
  }
  
  Widget _buildBar({
    required double barWidth,
    required double barHeight,
    required double value,
    required DateTime date,
    required bool isRM,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isRM 
                ? CupertinoColors.activeBlue 
                : CupertinoColors.activeOrange,
          ),
        ),
        const SizedBox(height: 2),
        // Data bar
        Container(
          width: barWidth,
          height: barHeight.isNaN || barHeight.isInfinite || barHeight <= 0 
              ? 2 
              : barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isRM
                  ? [
                      CupertinoColors.activeBlue,
                      CupertinoColors.systemBlue.withOpacity(0.7),
                    ]
                  : [
                      CupertinoColors.activeOrange,
                      CupertinoColors.systemOrange.withOpacity(0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}