enum MeasureUnit { mg, mcg, ui }

enum SyringeSize {
  u30(0.3, 30, 0.5),
  u50(0.5, 50, 1.0),
  u100(1.0, 100, 2.0),
  u300(3.0, 300, 10.0), // Seringa de 3mL
  u500(5.0, 500, 10.0); // Seringa de 5mL

  final double maxMl;
  final int maxUnits;
  final double tickInterval;

  const SyringeSize(this.maxMl, this.maxUnits, this.tickInterval);
}

enum ClinicalWarning {
  exceedsSyringe,
  exceedsVial,
  tooSmall,
  unitMismatch,
  missingData,
}

class CalculatorInput {
  final double? vialAmount;
  final MeasureUnit vialUnit;
  final double? diluentMl;
  final SyringeSize syringeSize;
  final double? dose;
  final MeasureUnit doseUnit;

  CalculatorInput({
    this.vialAmount,
    this.vialUnit = MeasureUnit.mg,
    this.diluentMl,
    this.syringeSize = SyringeSize.u100,
    this.dose,
    this.doseUnit = MeasureUnit.mg,
  });
}

class CalculatorResult {
  final double concentrationPerMl;
  final double volumeMl;
  final double units;
  final double nearestTickUnits;
  final int dosesPerVial;
  final int injectionsNeeded;
  final List<ClinicalWarning> warnings;
  final bool hasError;
  final String? errorMessage;

  CalculatorResult({
    required this.concentrationPerMl,
    required this.volumeMl,
    required this.units,
    required this.nearestTickUnits,
    required this.dosesPerVial,
    required this.injectionsNeeded,
    required this.warnings,
    this.hasError = false,
    this.errorMessage,
  });
}

class DoseCalculator {
  static CalculatorResult calculate(CalculatorInput input) {
    if (input.vialAmount == null ||
        input.diluentMl == null ||
        input.dose == null) {
      return _errorResult(
        ClinicalWarning.missingData,
        "Preencha os valores acima para calcular a dose.",
      );
    }

    if (input.vialAmount! <= 0 || input.diluentMl! <= 0 || input.dose! <= 0) {
      return _errorResult(
        ClinicalWarning.missingData,
        "Os valores digitados devem ser maiores que zero.",
      );
    }

    bool vialIsUi = input.vialUnit == MeasureUnit.ui;
    bool doseIsUi = input.doseUnit == MeasureUnit.ui;
    if (vialIsUi != doseIsUi) {
      return _errorResult(
        ClinicalWarning.unitMismatch,
        "Incompatibilidade clínica: Se o frasco é medido em UI, a dose desejada também tem de ser em UI.",
      );
    }

    double baseVialAmount = input.vialUnit == MeasureUnit.mcg
        ? input.vialAmount! / 1000
        : input.vialAmount!;
    double baseDoseAmount = input.doseUnit == MeasureUnit.mcg
        ? input.dose! / 1000
        : input.dose!;

    List<ClinicalWarning> warnings = [];

    if (baseDoseAmount > baseVialAmount) {
      return _errorResult(
        ClinicalWarning.exceedsVial,
        "A dose excede o conteúdo total do frasco.",
      );
    }

    double concentrationPerMl = baseVialAmount / input.diluentMl!;
    double volumeMl = baseDoseAmount / concentrationPerMl;
    double units = volumeMl * 100;

    int dosesPerVial = (baseVialAmount / baseDoseAmount).floor();
    int injectionsNeeded = (volumeMl / input.syringeSize.maxMl).ceil();

    if (volumeMl > input.syringeSize.maxMl) {
      warnings.add(ClinicalWarning.exceedsSyringe);
    }

    if (units < 2.0) {
      warnings.add(ClinicalWarning.tooSmall);
    }

    double tickInterval = input.syringeSize.tickInterval;
    double nearestTickUnits = (units / tickInterval).round() * tickInterval;

    return CalculatorResult(
      concentrationPerMl: (concentrationPerMl * 100).roundToDouble() / 100,
      volumeMl: (volumeMl * 1000).roundToDouble() / 1000,
      units: (units * 100).roundToDouble() / 100,
      nearestTickUnits: nearestTickUnits,
      dosesPerVial: dosesPerVial,
      injectionsNeeded: injectionsNeeded,
      warnings: warnings,
    );
  }

  static CalculatorResult _errorResult(ClinicalWarning warning, String msg) {
    return CalculatorResult(
      concentrationPerMl: 0,
      volumeMl: 0,
      units: 0,
      nearestTickUnits: 0,
      dosesPerVial: 0,
      injectionsNeeded: 0,
      warnings: [warning],
      hasError: true,
      errorMessage: msg,
    );
  }
}
