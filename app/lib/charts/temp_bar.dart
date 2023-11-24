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
    if (temperature > 60) {
      colors = <Color>[
        Colors.blue.shade700,
        Colors.yellow.shade300,
      ];
    }
    if (temperature > 67) {
      colors = <Color>[
        Colors.yellow.shade300,
        Colors.yellow.shade700,
      ];
    }
    if (temperature > 75) {
      colors = <Color>[
        Colors.yellow.shade700,
        Colors.red,
      ];
    }
    if (temperature > 80) {
      colors = <Color>[
        Colors.red,
        Colors.red.shade900,
      ];
    }

    return Container(
      width: 20,
      height: 110,
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
                  const TextStyle(color: Color(0xff939393), fontSize: 15),
              margin: 5,
              getTitles: (double value) => temperature.toStringAsFixed(0) + "º",
            ),
            leftTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
      ),
    );
  }
}
