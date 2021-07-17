import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class CommonLineChart extends StatelessWidget {
  final double minY;
  final double maxY;
  final List<FlSpot> data;
  String? title;

  CommonLineChart(
      {required this.data, required this.minY, required this.maxY, this.title});

  @override
  Widget build(BuildContext context) {
    final double rangeY = maxY - minY;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 36.0,
              top: 24,
            ),
            child: Text(
              title ?? 'Line Chart',
              style: TextStyle(
                  color: Color(
                    0xffffffff,
                  ),
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(
          height: 22,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: data.first.x,
              maxX: data.last.x,
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
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  dotData: FlDotData(
                    show: false,
                  ),
                  colors: [Colors.redAccent.withOpacity(0), Colors.redAccent],
                  colorStops: [0.1, 1.0],
                  barWidth: 4,
                  isCurved: false,
                )
              ],
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
            swapAnimationCurve: Curves.linear, // Optional
          ),
        ),
      ],
    );
  }
}
