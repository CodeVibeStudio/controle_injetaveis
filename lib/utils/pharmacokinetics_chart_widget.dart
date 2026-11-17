import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'pharmacokinetics_engine.dart';

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
    // Recalcula se a lista de injeções mudar
    if (oldWidget.injections != widget.injections) {
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
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('Nenhum dado para simular.')),
          );
        }

        final data = snapshot.data!;
        double maxRelease = 0;
        final spots = data.map((d) {
          if (d.releaseMg > maxRelease) maxRelease = d.releaseMg;
          return FlSpot(d.day.toDouble(), d.releaseMg);
        }).toList();

        return AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            padding: const EdgeInsets.only(right: 18, top: 24, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: widget.simulationDays.toDouble(),
                minY: 0,
                // Dá uma margem visual de 20% no topo do gráfico
                maxY: maxRelease * 1.2,
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
                    color: const Color(0xFF1E3A8A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                          const Color(0xFF1E3A8A).withValues(alpha: 0.0),
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
