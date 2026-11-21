// Ficheiro: utils/calculadora_reconstituicao_ecra.dart
import 'pharmacokinetics_engine.dart';
import 'pharmacokinetics_chart_widget.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dose_calculator.dart';
import 'syringe_widget.dart';
import '../i18n/translations.g.dart';
import '../theme/app_theme.dart';

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

  String? unidadeSelecionada;
  SyringeSize? seringaSelecionada;

  final supabase = Supabase.instance.client;
  List<String> listaSubstancias = [];
  String substanciaSelecionada = '';
  int _autocompleteKey = 0;

  double calcVolumeMl = 0.0;
  double calcDoseUi = 0.0;
  double doseMgFinal = 0.0;
  int rendimentoDoses = 0;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarCatalogo();
    volumeCtrl.addListener(_recalcular);
    concentracaoCtrl.addListener(_recalcular);
    doseSemanalCtrl.addListener(_recalcular);
    intervaloCtrl.addListener(_recalcular);
  }

  Future<void> _carregarCatalogo() async {
    try {
      final resposta = await supabase.rpc('obter_nomes_unicos');
      final Set<String> nomes = {};
      for (var item in resposta) {
        String nome = item['nome'].toString();
        if (nome.startsWith('Mix') || nome.startsWith('[Arquivado]')) continue;
        if (nome.startsWith('[Oculto] ')) {
          nome = nome.replaceFirst('[Oculto] ', '');
        }
        nomes.add(nome);
      }
      final listaOrdenada = nomes.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (mounted) {
        setState(() => listaSubstancias = listaOrdenada);
      }
    } catch (e) {
      debugPrint('Erro ao carregar catálogo na calculadora: $e');
    }
  }

  Compound _obterCompostoParaGrafico(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('cipionato')) {
      return Compound(name: nome, esterWeight: 0.69, halfLifeDays: 5.0);
    } else if (n.contains('propionato')) {
      return Compound(name: nome, esterWeight: 0.80, halfLifeDays: 0.8);
    } else if (n.contains('decanoato') || n.contains('deca')) {
      return Compound(name: nome, esterWeight: 0.64, halfLifeDays: 7.0);
    } else if (n.contains('undecilenato') || n.contains('boldenona')) {
      return Compound(name: nome, esterWeight: 0.61, halfLifeDays: 14.0);
    } else if (n.contains('acetato')) {
      return Compound(name: nome, esterWeight: 0.87, halfLifeDays: 1.0);
    } else if (n.contains('enantato')) {
      return Compound(name: nome, esterWeight: 0.70, halfLifeDays: 4.5);
    } else if (n.contains('tirzepatida') || n.contains('mounjaro')) {
      return Compound(name: nome, esterWeight: 1.0, halfLifeDays: 5.0);
    } else if (n.contains('semaglutida') || n.contains('ozempic')) {
      return Compound(name: nome, esterWeight: 1.0, halfLifeDays: 7.0);
    } else if (n.contains('retatrutida')) {
      return Compound(name: nome, esterWeight: 1.0, halfLifeDays: 6.0);
    }
    return Compound(
      name: nome.isEmpty ? 'Substância' : nome,
      esterWeight: 1.0,
      halfLifeDays: 3.0,
    );
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
      substanciaSelecionada = '';
      _autocompleteKey++;
      unidadeSelecionada = null;
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
        volumeCtrl.text.isEmpty ||
        unidadeSelecionada == null) {
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
            const Icon(Icons.science_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.calculadora.diluicao_titulo,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          t.calculadora.diluicao_desc,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(t.geral.nao),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(t.geral.sim),
                ),
              ),
            ],
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
          ),
        ),
        actions: [
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
          ),
        ),
        actions: [
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
    final allSyringes = [
      (SyringeSize.u30, '30 UI (0.3 mL)'),
      (SyringeSize.u50, '50 UI (0.5 mL)'),
      (SyringeSize.u100, '100 UI (1 mL)'),
      (SyringeSize.u300, '3 mL'),
      (SyringeSize.u500, '5 mL'),
    ];

    final filteredSyringes = calcVolumeMl > 0
        ? allSyringes.where((s) => s.$1.maxMl >= calcVolumeMl).toList()
        : allSyringes;

    final List<DropdownMenuItem<SyringeSize>> syringeOptions =
        (filteredSyringes.isEmpty ? [allSyringes.last] : filteredSyringes)
            .map((s) => DropdownMenuItem(value: s.$1, child: Text(s.$2)))
            .toList();

    final unidadeTexto = unidadeSelecionada ?? 'mg';
    String strDoseFinal = unidadeTexto == 'mcg'
        ? '${(doseMgFinal * 1000).toStringAsFixed(1).replaceAll('.0', '')} mcg'
        : '${doseMgFinal.toStringAsFixed(2).replaceAll('.00', '')} $unidadeTexto';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.calculadora.titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: t.calculadora.limpar,
            onPressed: _limparTudo,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                t.calculadora.aviso,
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            Autocomplete<String>(
              key: ValueKey('calc_sub_$_autocompleteKey'),
              initialValue: TextEditingValue(text: substanciaSelecionada),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return listaSubstancias;
                }
                return listaSubstancias.where(
                  (opt) => opt.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (String selection) {
                setState(() => substanciaSelecionada = selection);
              },
              fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                return TextFormField(
                  controller: ctrl,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Substância (Pesquisar...)',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (val) =>
                      setState(() => substanciaSelecionada = val),
                );
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: volumeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Vol. (mL)',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                      labelText: 'Conc. (mg/mL)',
                      hintText: 'mg/mL',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calculate_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: t.calculadora.assistente,
                        onPressed: _abrirCalculadoraDiluicao,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                    key: ValueKey('unid_$unidadeSelecionada'),
                    initialValue: unidadeSelecionada,
                    decoration: InputDecoration(
                      labelText: t.calculadora.unidade,
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
                    key: ValueKey(
                      'ser_${seringaSelecionada}_${syringeOptions.length}',
                    ),
                    initialValue:
                        syringeOptions.any((o) => o.value == seringaSelecionada)
                        ? seringaSelecionada
                        : null,
                    decoration: InputDecoration(
                      labelText: t.calculadora.seringa,
                    ),
                    items: syringeOptions,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => seringaSelecionada = val);
                        _recalcular();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              color: AppColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.surfaceHighlight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      t.calculadora.resultados,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: calcVolumeMl == 0 || seringaSelecionada == null
                        ? Column(
                            children: [
                              Text(
                                t.calculadora.selecoes_vazias,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
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
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_para_dose),
                                    TextSpan(
                                      text: strDoseFinal,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    TextSpan(text: t.calculadora.res_aspire),
                                    TextSpan(
                                      text:
                                          '${calcVolumeMl.toStringAsFixed(2).replaceAll('.', ',')}${t.calculadora.res_ou}${calcDoseUi.toStringAsFixed(1).replaceAll('.0', '')}${t.calculadora.res_unidades}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
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
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_conc),
                                    TextSpan(
                                      text:
                                          '${concentracaoCtrl.text.replaceAll('.', ',')} mg/mL.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(text: t.calculadora.res_contem),
                                    TextSpan(
                                      text:
                                          '$rendimentoDoses${t.calculadora.res_doses}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
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
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              t.calculadora.simulador_titulo,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 4),
            Text(
              (doseMgFinal > 0 && intervaloCtrl.text.isNotEmpty)
                  ? 'Simulação: $strDoseFinal de ${substanciaSelecionada.isEmpty ? "Substância" : substanciaSelecionada} a cada ${intervaloCtrl.text} dia(s) (35 dias)'
                  : 'Preencha os campos acima para visualizar a curva de liberação.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final int intervalo =
                    int.tryParse(intervaloCtrl.text.replaceAll(',', '.')) ?? 0;
                if (doseMgFinal <= 0 || intervalo <= 0) {
                  return Container(
                    height: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Preencha os campos acima para gerar a curva de liberação.',
                      style: TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final composto = _obterCompostoParaGrafico(
                  substanciaSelecionada,
                );
                final List<InjectionEvent> eventosDinamicos = [];
                for (int dia = 0; dia <= 28; dia += intervalo) {
                  eventosDinamicos.add(
                    InjectionEvent(
                      day: dia,
                      doseMg: doseMgFinal,
                      compound: composto,
                    ),
                  );
                }

                return PharmacokineticsChartWidget(
                  injections: eventosDinamicos,
                  simulationDays: 35,
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
