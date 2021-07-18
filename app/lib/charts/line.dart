import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'indicator.dart';

class CommonLineChart extends StatelessWidget {
  final double minY;
  final double maxY;
  final List<Map<String, dynamic>> data; // List<FlSpot>
  // final List<Color> colors =

  CommonLineChart({required this.data, required this.minY, required this.maxY});

  @override
  Widget build(BuildContext context) {
    final double rangeY = maxY - minY;

    List<LineChartBarData> lineBarsData = <LineChartBarData>[];
    List<Widget> indicators = <Widget>[];

    data.forEach((trace) {
      if (trace["spots"].isNotEmpty)
        lineBarsData.add(LineChartBarData(
          spots: trace["spots"],
          dotData: FlDotData(
            show: false,
          ),
          colors: [Colors.blueAccent.withOpacity(0), trace["color"]],
          colorStops: [0.1, 1.0],
          barWidth: 4,
          isCurved: false,
        ));

      indicators.add(Indicator(
        color: trace["color"],
        text: trace["title"],
        isSquare: false,
        size: 12,
        textColor: Colors.grey,
      ));
    });

    return Stack(
      children: <Widget>[
        Container(
          width: 200,
          height: 100,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: data[0]["spots"].first.x,
              maxX: data[0]["spots"].last.x,
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: (Colors.grey[900])!,
                  width: 2,
                ),
              ),
              lineTouchData: LineTouchData(enabled: false),
              clipData: FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 10,
                horizontalInterval: rangeY / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[900],
                    strokeWidth: 2,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey[900],
                    strokeWidth: 2,
                  );
                },
              ),
              lineBarsData: lineBarsData,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: false,
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  interval: rangeY / 5,
                  getTextStyles: (value) => const TextStyle(
                    color: Color(0xff67727d),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  reservedSize: 50,
                  margin: 12,
                ),
              ),
            ),
            swapAnimationDuration: Duration(milliseconds: 150), // Optional
            swapAnimationCurve: Curves.linear, // Optiona
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: Row(
            children: indicators,
          ),
        ),
      ],
    );
  }
}
