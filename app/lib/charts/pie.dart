import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiskPieChart extends StatelessWidget {
  final double percentage;

  DiskPieChart({required this.percentage});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (percentage > 95)
      color = Colors.red;
    else if (percentage > 90)
      color = Colors.orange;
    else
      color = Colors.white;

    return Container(
      width: 25,
      height: 25,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          startDegreeOffset: -90,
          sections: [
            PieChartSectionData(
              value: percentage,
              color: color,
              showTitle: false,
              radius: 10,
            ),
            PieChartSectionData(
              value: 100 - percentage,
              color: Color(0x33ffffff),
              showTitle: false,
              radius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
