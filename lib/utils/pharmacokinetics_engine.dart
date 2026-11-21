import 'dart:isolate';
import 'dart:math' as math;

// 1. ESTRUTURA DE MODELOS
class Compound {
  final String name;
  final double esterWeight; // Ex: 0.70 para Enantato
  final double halfLifeDays;

  const Compound({
    required this.name,
    required this.esterWeight,
    required this.halfLifeDays,
  });
}

class InjectionEvent {
  final int day;
  final double doseMg;
  final Compound compound;

  const InjectionEvent({
    required this.day,
    required this.doseMg,
    required this.compound,
  });
}

class DailyPlotData {
  final int day;
  final double releaseMg;

  const DailyPlotData({required this.day, required this.releaseMg});
}

// 2. LÓGICA MATEMÁTICA (Executada em Isolate para não travar a UI)
class PharmacokineticsEngine {
  static List<DailyPlotData> _runMath(
    List<InjectionEvent> events,
    int totalDays,
  ) {
    final List<DailyPlotData> plotData = [];

    for (int t = 0; t <= totalDays; t++) {
      double dailyRelease = 0.0;

      for (var event in events) {
        if (t >= event.day && event.compound.halfLifeDays > 0) {
          final int daysSinceInjection = t - event.day;
          final double k = math.ln2 / event.compound.halfLifeDays;
          final double baseDose = event.doseMg * event.compound.esterWeight;
          final double volumeAtDayStart =
              baseDose * math.exp(-k * daysSinceInjection);
          final double releaseToday = volumeAtDayStart * (1 - math.exp(-k));
          dailyRelease += releaseToday;
        }
      }
      plotData.add(DailyPlotData(day: t, releaseMg: dailyRelease));
    }
    return plotData;
  }

  static Future<List<DailyPlotData>> calculateSimulation({
    required List<InjectionEvent> events,
    required int totalDays,
  }) async {
    try {
      return await Isolate.run(() => _runMath(events, totalDays));
    } catch (_) {
      return _runMath(events, totalDays);
    }
  }
}
