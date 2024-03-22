import 'package:flutter/material.dart';

class IconLegendVertical extends StatelessWidget {
  final double height;
  final IconData icon;
  final double iconSize;

  final String text;
  final Color textColor;
  final double textSize;
  final FontWeight textWeight;

  const IconLegendVertical({
    required this.text,
    required this.icon,
    this.height = 42,
    this.iconSize = 20,
    this.textColor = const Color(0xFFBFBFBF),
    this.textSize = 14,
    this.textWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: <Widget>[
          Icon(icon, size: iconSize),
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: textWeight,
              color: textColor,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
