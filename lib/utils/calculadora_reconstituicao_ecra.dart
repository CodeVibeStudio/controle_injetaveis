// Ficheiro: utils/calculadora_reconstituicao_ecra.dart
import 'pharmacokinetics_engine.dart';
import 'pharmacokinetics_chart_widget.dart';

import 'package:flutter/material.dart';

import 'dose_calculator.dart';
import 'syringe_widget.dart';
import '../i18n/translations.g.dart';

class CalculadoraReconstituicaoEcra extends StatefulWidget {
  const CalculadoraReconstituicaoEcra({super.key});

  @override
  State<CalculadoraReconstituicaoEcra> createState() =>
      _CalculadoraReconstituicaoEcraState();
}

class _CalculadoraReconstituicaoEcraState
    extends State<CalculadoraReconstituicaoEcra> {
  final volumeCtrl = TextEditingController();
  final concentracaoCtrl = TextEditingController();
  final doseSemanalCtrl = TextEditingController();
  final intervaloCtrl = TextEditingController();

  String unidadeSelecionada = 'mg';
  SyringeSize? seringaSelecionada;

  double calcVolumeMl = 0.0;
  double calcDoseUi = 0.0;
  double doseMgFinal = 0.0;
  int rendimentoDoses = 0;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    volumeCtrl.addListener(_recalcular);
    concentracaoCtrl.addListener(_recalcular);
    doseSemanalCtrl.addListener(_recalcular);
    intervaloCtrl.addListener(_recalcular);
  }

  @override
  void dispose() {
    volumeCtrl.dispose();
    concentracaoCtrl.dispose();
    doseSemanalCtrl.dispose();
    intervaloCtrl.dispose();
    super.dispose();
  }

  void _limparTudo() {
    volumeCtrl.clear();
    concentracaoCtrl.clear();
    doseSemanalCtrl.clear();
    intervaloCtrl.clear();
    setState(() {
      unidadeSelecionada = 'mg';
      seringaSelecionada = null;
      calcVolumeMl = 0.0;
      calcDoseUi = 0.0;
      doseMgFinal = 0.0;
      rendimentoDoses = 0;
      hasError = false;
    });
  }

  void _recalcular() {
    if (doseSemanalCtrl.text.isEmpty ||
        concentracaoCtrl.text.isEmpty ||
        intervaloCtrl.text.isEmpty ||
        volumeCtrl.text.isEmpty) {
      setState(() {
        calcVolumeMl = 0.0;
        calcDoseUi = 0.0;
        hasError = false;
      });
      return;
    }

    try {
      double doseSemanal = double.parse(
        doseSemanalCtrl.text.replaceAll(',', '.'),
      );
      double concentracao = double.parse(
        concentracaoCtrl.text.replaceAll(',', '.'),
      );
      double volFrasco = double.parse(volumeCtrl.text.replaceAll(',', '.'));
      int intervalo = int.parse(intervaloCtrl.text.replaceAll(',', '.'));

      if (concentracao > 0) {
        double fator = (intervalo == 3)
            ? (doseSemanal / 2)
            : ((doseSemanal / 7) * intervalo);

        double doseCalcMg = fator;
        if (unidadeSelecionada == 'mL') {
          doseCalcMg = fator * concentracao;
        } else if (unidadeSelecionada == 'mcg') {
          doseCalcMg = fator / 1000;
        }

        double volMl = doseCalcMg / concentracao;
        double doseUi = volMl * 100;

        setState(() {
          calcVolumeMl = (volMl * 1000).roundToDouble() / 1000;
          calcDoseUi = (doseUi * 100).roundToDouble() / 100;
          doseMgFinal = doseCalcMg;
          rendimentoDoses = ((volFrasco * concentracao) / doseCalcMg).floor();

          if (seringaSelecionada == null ||
              calcVolumeMl > seringaSelecionada!.maxMl) {
            if (calcVolumeMl <= 0.3) {
              seringaSelecionada = SyringeSize.u30;
            } else if (calcVolumeMl <= 0.5)
              seringaSelecionada = SyringeSize.u50;
            else if (calcVolumeMl <= 1.0)
              seringaSelecionada = SyringeSize.u100;
            else if (calcVolumeMl <= 3.0)
              seringaSelecionada = SyringeSize.u300;
            else
              seringaSelecionada = SyringeSize.u500;
          }
        });
      }
    } catch (e) {}
  }

  Future<void> _abrirCalculadoraDiluicao() async {
    final querUsar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.science, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text(
              t.calculadora.diluicao_titulo,
              style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 18),
            ),
          ],
        ),
        content: Text(t.calculadora.diluicao_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.geral.nao),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
            ),
            child: Text(
              t.geral.sim,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (querUsar != true) return;

    final mgCtrl = TextEditingController();
    final passo1 = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.calculadora.passo1, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: mgCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: t.calculadora.passo1_label,
            hintText: t.calculadora.passo1_hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.geral.nao),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, mgCtrl.text),
            child: Text(t.geral.ok),
          ),
        ],
      ),
    );
    if (passo1 == null || passo1.isEmpty) return;

    final mlCtrl = TextEditingController();
    final passo2 = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.calculadora.passo2, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: mlCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: t.calculadora.passo2_label,
            hintText: t.calculadora.passo2_hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.geral.nao),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, mlCtrl.text),
            child: Text(t.geral.ok),
          ),
        ],
      ),
    );
    if (passo2 == null || passo2.isEmpty) return;

    try {
      double mg = double.parse(passo1.replaceAll(',', '.'));
      double ml = double.parse(passo2.replaceAll(',', '.'));
      double resultado = mg / ml;

      String strRes = resultado == resultado.truncateToDouble()
          ? resultado.toStringAsFixed(0)
          : resultado.toStringAsFixed(2);

      setState(() {
        volumeCtrl.text = ml.toString();
        concentracaoCtrl.text = strRes;
        _recalcular();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.calculadora.msg_sucesso),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.calculadora.msg_invalido),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<SyringeSize>> syringeOptions = [
      const DropdownMenuItem(
        value: SyringeSize.u30,
        child: Text('30 UI (0.3 mL)'),
      ),
      const DropdownMenuItem(
        value: SyringeSize.u50,
        child: Text('50 UI (0.5 mL)'),
      ),
      const DropdownMenuItem(
        value: SyringeSize.u100,
        child: Text('100 UI (1 mL)'),
      ),
      const DropdownMenuItem(value: SyringeSize.u300, child: Text('3 mL')),
      const DropdownMenuItem(value: SyringeSize.u500, child: Text('5 mL')),
    ];

    String strDoseFinal = unidadeSelecionada == 'mcg'
        ? '${(doseMgFinal * 1000).toStringAsFixed(1).replaceAll('.0', '')} mcg'
        : '${doseMgFinal.toStringAsFixed(2).replaceAll('.00', '')} $unidadeSelecionada';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.calculadora.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.calculadora.limpar,
            onPressed: _limparTudo,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              t.calculadora.aviso,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: volumeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: t.calculadora.volume,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: concentracaoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onTap: () {
                      if (concentracaoCtrl.text.isEmpty) {
                        _abrirCalculadoraDiluicao();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: t.calculadora.concentracao,
                      hintText: 'mg/mL',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calculate, color: Colors.blue),
                        tooltip: t.calculadora.assistente,
                        onPressed: _abrirCalculadoraDiluicao,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: doseSemanalCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: t.calculadora.dose_semanal,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: intervaloCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t.calculadora.intervalo,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    initialValue: unidadeSelecionada,
                    decoration: InputDecoration(
                      labelText: t.calculadora.unidade,
                      border: const OutlineInputBorder(),
                    ),
                    items: ['mg', 'mcg', 'UI', 'mL']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => unidadeSelecionada = val);
                        _recalcular();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: DropdownButtonFormField<SyringeSize>(
                    initialValue: seringaSelecionada,
                    decoration: InputDecoration(
                      labelText: t.calculadora.seringa,
                      border: const OutlineInputBorder(),
                    ),
                    items: syringeOptions,
                    onChanged: (val) {
                      if (val != null) {
                        if (calcVolumeMl > val.maxMl) {
                          setState(() {});
                        } else {
                          setState(() => seringaSelecionada = val);
                          _recalcular();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      t.calculadora.resultados,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: calcVolumeMl == 0 || seringaSelecionada == null
                        ? Column(
                            children: [
                              Text(
                                t.calculadora.selecoes_vazias,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const SyringeVisualizer(
                                syringeSize: SyringeSize.u100,
                                filledUnits: 0,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_para_dose),
                                    TextSpan(
                                      text: strDoseFinal,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: t.calculadora.res_aspire),
                                    TextSpan(
                                      text:
                                          '${calcVolumeMl.toStringAsFixed(2).replaceAll('.', ',')}${t.calculadora.res_ou}${calcDoseUi.toStringAsFixed(1).replaceAll('.0', '')}${t.calculadora.res_unidades}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              SyringeVisualizer(
                                syringeSize: seringaSelecionada!,
                                filledUnits: calcDoseUi,
                              ),

                              const SizedBox(height: 16),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_conc),
                                    TextSpan(
                                      text:
                                          '${concentracaoCtrl.text.replaceAll('.', ',')} mg/mL.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_contem),
                                    TextSpan(
                                      text:
                                          '$rendimentoDoses${t.calculadora.res_doses}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${t.calculadora.res_de}$strDoseFinal${t.calculadora.res_cada}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 16),

            Text(
              t.calculadora.simulador_titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            Text(
              t.calculadora.simulador_desc,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const PharmacokineticsChartWidget(
              injections: [
                InjectionEvent(
                  day: 0,
                  doseMg: 250,
                  compound: Compound(
                    name: 'Enantato',
                    esterWeight: 0.70,
                    halfLifeDays: 4.5,
                  ),
                ),
                InjectionEvent(
                  day: 7,
                  doseMg: 250,
                  compound: Compound(
                    name: 'Enantato',
                    esterWeight: 0.70,
                    halfLifeDays: 4.5,
                  ),
                ),
              ],
              simulationDays: 30,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
