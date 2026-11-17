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
  static Future<List<DailyPlotData>> calculateSimulation({
    required List<InjectionEvent> events,
    required int totalDays,
  }) async {
    // Isolate.run atira o cálculo pesado para uma thread secundária
    return Isolate.run(() {
      List<DailyPlotData> plotData = [];

      for (int t = 0; t <= totalDays; t++) {
        double dailyRelease = 0.0;

        for (var event in events) {
          // Só calcula se a injeção já tiver ocorrido no dia 't'
          if (t >= event.day) {
            int daysSinceInjection = t - event.day;
            
            // k = ln(2) / meia-vida
            double k = math.ln2 / event.compound.halfLifeDays;
            
            // Dose real = dose em mg * peso do éster (fração de hormônio ativo)
            double baseDose = event.doseMg * event.compound.esterWeight;
            
            // V(t) = Dose Base * e^(-k * t)
            double volumeAtDayStart = baseDose * math.exp(-k * daysSinceInjection);
            
            // Liberação no dia = V(t) * (1 - e^-k)
            double releaseToday = volumeAtDayStart * (1 - math.exp(-k));
            
            // Aplica o Princípio da Superposição (soma de todas as injeções ativas)
            dailyRelease += releaseToday;
          }
        }
        plotData.add(DailyPlotData(day: t, releaseMg: dailyRelease));
      }
      return plotData;
    });
  }
}