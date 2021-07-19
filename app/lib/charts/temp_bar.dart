import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureBarChart extends StatelessWidget {
  final double temperature;
  // final List<Color> colors =

  TemperatureBarChart({required this.temperature});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = <Color>[Colors.blueAccent];
    if (temperature > 60) colors.add(Colors.yellowAccent);
    if (temperature > 75) colors.add(Colors.redAccent);

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
                      Colors.grey.shade800,
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
