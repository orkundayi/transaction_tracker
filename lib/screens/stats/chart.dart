import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(mainBarData()),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: getBottomTiles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 64,
            getTitlesWidget: getLeftTiles,
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.white,
          tooltipBorder: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
      ),
      barGroups: getBarGroups(),
    );
  }

  Widget getBottomTiles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    Widget title = Text(
      getIntPlusOneToString(value),
      style: style,
    );

    return SideTitleWidget(space: 16, meta: meta, child: title);
  }

  String getIntPlusOneToString(double value) {
    final fixedValue = value.toInt();
    if (fixedValue < 0) {
      return '';
    }
    final String text = (fixedValue + 1).toString();
    if (text.length == 1) {
      return '0$text';
    }
    return text;
  }

  Widget getLeftTiles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    Widget title = Text(
      getMoneyReferanceForTurkiye(value),
      style: style,
    );

    return SideTitleWidget(space: 16, meta: meta, child: title);
  }

  String getMoneyReferanceForTurkiye(double value) {
    final fixedValue = value.toInt();
    if (fixedValue < 0) {
      return '';
    }
    final String text = '$fixedValue₺';
    return text;
  }

  List<BarChartGroupData> getBarGroups() => List.generate(
        9,
        (index) {
          switch (index) {
            case 0:
              return makeGroupData(0, 500);
            case 1:
              return makeGroupData(1, 1000);
            case 2:
              return makeGroupData(2, 2000);
            case 3:
              return makeGroupData(3, 550);
            case 4:
              return makeGroupData(4, 400);
            case 5:
              return makeGroupData(5, 150);
            case 6:
              return makeGroupData(6, 220);
            case 7:
              return makeGroupData(7, 3000);
            case 8:
              return makeGroupData(8, 1250);
            default:
              return throw Error();
          }
        },
      );

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 12,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(120),
              Theme.of(context).colorScheme.secondary.withAlpha(120),
              Theme.of(context).colorScheme.tertiary.withAlpha(120),
            ],
            transform: const GradientRotation(pi / 40),
          ),
        ),
      ],
    );
  }
}
