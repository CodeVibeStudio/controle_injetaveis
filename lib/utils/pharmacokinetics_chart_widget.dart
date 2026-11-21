import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'pharmacokinetics_engine.dart';
import '../theme/app_theme.dart';

class PharmacokineticsChartWidget extends StatefulWidget {
  final List<InjectionEvent> injections;
  final int simulationDays;

  const PharmacokineticsChartWidget({
    super.key,
    required this.injections,
    this.simulationDays = 90,
  });

  @override
  State<PharmacokineticsChartWidget> createState() =>
      _PharmacokineticsChartWidgetState();
}

class _PharmacokineticsChartWidgetState
    extends State<PharmacokineticsChartWidget> {
  late Future<List<DailyPlotData>> _simulationFuture;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void didUpdateWidget(covariant PharmacokineticsChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.injections != widget.injections ||
        oldWidget.simulationDays != widget.simulationDays) {
      _recalculate();
    }
  }

  void _recalculate() {
    _simulationFuture = PharmacokineticsEngine.calculateSimulation(
      events: widget.injections,
      totalDays: widget.simulationDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyPlotData>>(
      future: _simulationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Erro na simulação: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Nenhum dado para simular.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        double maxRelease = 0;
        final spots = data.map((d) {
          if (d.releaseMg > maxRelease) maxRelease = d.releaseMg;
          return FlSpot(d.day.toDouble(), d.releaseMg);
        }).toList();

        final double safeMaxY = maxRelease > 0 ? maxRelease * 1.2 : 10.0;
        final double safeMaxX = widget.simulationDays > 0
            ? widget.simulationDays.toDouble()
            : 30.0;

        return AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            padding: const EdgeInsets.only(right: 18, top: 24, bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: safeMaxX,
                minY: 0,
                maxY: safeMaxY,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 15,
                      getTitlesWidget: (value, meta) => Text(
                        'Dia ${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueGrey.shade900,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'Dia ${spot.x.toInt()}\n${spot.y.toStringAsFixed(2)} mg',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
