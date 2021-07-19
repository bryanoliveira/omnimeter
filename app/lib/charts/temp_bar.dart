import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureBarChart extends StatelessWidget {
  final double temperature;
  // final List<Color> colors =

  TemperatureBarChart({required this.temperature});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = <Color>[
      Colors.blue.shade200,
      Colors.blue.shade700,
    ];
    if (temperature > 60) colors.add(Colors.yellow.shade300);
    if (temperature > 67) colors.add(Colors.yellow.shade700);
    if (temperature > 75) colors.add(Colors.red);
    if (temperature > 80) colors.add(Colors.red.shade900);

    return Container(
      width: 20,
      height: 100,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  y: temperature,
                  colors: colors,
                  width: 15,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    y: 100,
                    colors: [
                      Colors.grey.shade900,
                    ],
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value) =>
                  const TextStyle(color: Color(0xff939393), fontSize: 18),
              margin: 0,
              getTitles: (double value) =>
                  temperature.toStringAsFixed(0) + " ºC",
            ),
          ),
        ),
      ),
    );
  }
}
