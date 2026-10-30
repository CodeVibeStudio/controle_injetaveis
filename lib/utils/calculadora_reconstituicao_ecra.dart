// Ficheiro: utils/calculadora_reconstituicao_ecra.dart
import 'package:flutter/material.dart';

import 'dose_calculator.dart';
import 'syringe_widget.dart';

class CalculadoraReconstituicaoEcra extends StatefulWidget {
  const CalculadoraReconstituicaoEcra({Key? key}) : super(key: key);

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
      // O volume total também é necessário para calcular as doses totais
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
            if (calcVolumeMl <= 0.3)
              seringaSelecionada = SyringeSize.u30;
            else if (calcVolumeMl <= 0.5)
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
    } catch (e) {
      // Ignora digitações incompletas silenciosamente
    }
  }

  // (Mantenha a função _abrirCalculadoraDiluicao exatamente igual à versão anterior aqui)
  Future<void> _abrirCalculadoraDiluicao() async {
    final querUsar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.science, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text(
              'Diluição de Peptídeos',
              style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Deseja calcular a reconstituição de um Pó Liofilizado (ex: Peptídeos, GH ou hCG)?\n\nIsto calculará automaticamente a Concentração cruzando a Massa Total do frasco com a quantidade de Água Bacteriostática inserida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
            ),
            child: const Text('Sim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (querUsar != true) return;

    final mgCtrl = TextEditingController();
    final passo1 = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Reconstituição\nPASSO 1 DE 2:',
          style: TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: mgCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Massa Total do Liofilizado (mg ou UI)",
            hintText: "Ex: 5 (para frascos de 5mg)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, mgCtrl.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (passo1 == null || passo1.isEmpty) return;

    final mlCtrl = TextEditingController();
    final passo2 = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Reconstituição\nPASSO 2 DE 2:',
          style: TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: mlCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Água Bacteriostática (mL)",
            hintText: "Quantos mL vai injetar no pó?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, mlCtrl.text),
            child: const Text('OK'),
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
          const SnackBar(
            content: Text('Diluição calculada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valores inválidos.'),
            backgroundColor: Colors.red,
          ),
        );
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
      const DropdownMenuItem(
        value: SyringeSize.u300,
        child: Text('Seringa 3 mL'),
      ),
      const DropdownMenuItem(
        value: SyringeSize.u500,
        child: Text('Seringa 5 mL'),
      ),
    ];

    String strDoseFinal = unidadeSelecionada == 'mcg'
        ? '${(doseMgFinal * 1000).toStringAsFixed(1).replaceAll('.0', '')} mcg'
        : '${doseMgFinal.toStringAsFixed(2).replaceAll('.00', '')} $unidadeSelecionada';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculadora de Injetáveis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar Tudo',
            onPressed: _limparTudo,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              '⚠️ Ferramenta educativa. Confirme doses com um profissional de saúde.',
              style: TextStyle(
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
                    decoration: const InputDecoration(
                      labelText: 'Volume Frasco (mL)',
                      border: OutlineInputBorder(),
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
                      if (concentracaoCtrl.text.isEmpty)
                        _abrirCalculadoraDiluicao();
                    },
                    decoration: InputDecoration(
                      labelText: 'Concentração',
                      hintText: 'mg/mL',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calculate, color: Colors.blue),
                        tooltip: 'Assistente de Reconstituição',
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
                    decoration: const InputDecoration(
                      labelText: 'Dose Semanal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: intervaloCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Intervalo (dias)',
                      border: OutlineInputBorder(),
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
                    value: unidadeSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
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
                    value: seringaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Seringa (UI)',
                      border: OutlineInputBorder(),
                    ),
                    items: syringeOptions,
                    onChanged: (val) {
                      if (val != null) {
                        if (calcVolumeMl > val.maxMl) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Seringa Incompatível',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              content: Text(
                                'O volume calculado é de $calcVolumeMl mL.\n\nNão é possível selecionar uma seringa de ${val.maxMl} mL.',
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Entendido'),
                                ),
                              ],
                            ),
                          );
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

            // 👇 CAIXA DE RESULTADOS UNIFICADA NO ESTILO DO SITE DE REFERÊNCIA
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
                    child: const Text(
                      'Resultados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                              const Text(
                                'Faça as seleções acima para calcular a quantidade de fluido aspirado para a dose desejada.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SyringeVisualizer(
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
                                    const TextSpan(text: 'Para a dose de '),
                                    TextSpan(
                                      text: strDoseFinal,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ', aspire o conteúdo da seringa até: ',
                                    ),
                                    TextSpan(
                                      text:
                                          '${calcVolumeMl.toStringAsFixed(2).replaceAll('.', ',')} mL ou ${calcDoseUi.toStringAsFixed(1).replaceAll('.0', '')} unidades.',
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
                                    const TextSpan(
                                      text: 'Concentração do frasco reconstituído:\n',
                                    ),
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
                                    const TextSpan(text: 'O frasco contém '),
                                    TextSpan(
                                      text: '$rendimentoDoses doses',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' de $strDoseFinal cada.'),
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
          ],
        ),
      ),
    );
  }
}
