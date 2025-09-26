import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class MacroPieChart extends StatelessWidget {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;

  const MacroPieChart({
    Key? key,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure percentages are valid
    final validProtein = proteinPercentage.isNaN ? 0.0 : proteinPercentage;
    final validCarbs = carbsPercentage.isNaN ? 0.0 : carbsPercentage;
    final validFat = fatPercentage.isNaN ? 0.0 : fatPercentage;
    
    // Use actual values, even if they're all zero
    final protein = validProtein;
    final carbs = validCarbs;
    final fat = validFat;

    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: PieChartPainter(
              protein: protein,
              carbs: carbs,
              fat: fat,
            ),
            child: const SizedBox(
              height: 180,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Protein', CupertinoColors.activeBlue, '${protein.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            _buildLegendItem('Carbs', CupertinoColors.activeGreen, '${carbs.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            _buildLegendItem('Fat', CupertinoColors.systemOrange, '${fat.toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;

  PieChartPainter({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Define colors
    final proteinColor = CupertinoColors.activeBlue;
    final carbsColor = CupertinoColors.activeGreen;
    final fatColor = CupertinoColors.systemOrange;
    
    // Calculate angles
    final total = protein + carbs + fat;
    final proteinAngle = 2 * math.pi * (protein / total);
    final carbsAngle = 2 * math.pi * (carbs / total);
    final fatAngle = 2 * math.pi * (fat / total);
    
    double startAngle = -math.pi / 2; // Start from the top (12 o'clock)
    
    // Check if we have any data
    final bool hasData = protein > 0 || carbs > 0 || fat > 0;
    
    if (hasData) {
      // Draw protein slice
      final proteinPaint = Paint()
        ..color = proteinColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        proteinAngle,
        true,
        proteinPaint,
      );
      
      // Draw carbs slice
      startAngle += proteinAngle;
      final carbsPaint = Paint()
        ..color = carbsColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        carbsAngle,
        true,
        carbsPaint,
      );
      
      // Draw fat slice
      startAngle += carbsAngle;
      final fatPaint = Paint()
        ..color = fatColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fatAngle,
        true,
        fatPaint,
      );
    } else {
      // Draw empty chart with gray color when no data
      final emptyPaint = Paint()
        ..color = CupertinoColors.systemGrey5
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, emptyPaint);
    }
    
    // Draw a small white circle in the center for a donut effect
    final centerPaint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is PieChartPainter) {
      return oldDelegate.protein != protein ||
             oldDelegate.carbs != carbs ||
             oldDelegate.fat != fat;
    }
    return true;
  }
}