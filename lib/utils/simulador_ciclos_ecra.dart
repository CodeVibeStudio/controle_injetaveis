// Ficheiro: utils/simulador_ciclos_ecra.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pharmacokinetics_engine.dart';
import 'pharmacokinetics_chart_widget.dart';
import '../i18n/translations.g.dart';
import '../theme/app_theme.dart';

final Map<String, List<Compound>> baseDeDadosCompostos = {
  'Esteroides/Hormônios Anabolizantes': [
    const Compound(
      name: 'Testosterona Enantato',
      esterWeight: 0.70,
      halfLifeDays: 4.5,
    ),
    const Compound(
      name: 'Testosterona Cipionato',
      esterWeight: 0.69,
      halfLifeDays: 5.0,
    ),
    const Compound(
      name: 'Testosterona Propionato',
      esterWeight: 0.80,
      halfLifeDays: 0.8,
    ),
    const Compound(
      name: 'Nandrolona Decanoato (Deca)',
      esterWeight: 0.64,
      halfLifeDays: 7.0,
    ),
    const Compound(
      name: 'Nandrolona Fenilpropionato (NPP)',
      esterWeight: 0.67,
      halfLifeDays: 1.5,
    ),
    const Compound(
      name: 'Boldenona Undecilenato',
      esterWeight: 0.61,
      halfLifeDays: 14.0,
    ),
    const Compound(
      name: 'Drostanolona Propionato (Masteron)',
      esterWeight: 0.80,
      halfLifeDays: 0.8,
    ),
    const Compound(
      name: 'Drostanolona Enantato',
      esterWeight: 0.70,
      halfLifeDays: 4.5,
    ),
    const Compound(
      name: 'Metenolona Enantato (Primobolan)',
      esterWeight: 0.70,
      halfLifeDays: 4.5,
    ),
    const Compound(
      name: 'Trembolona Acetato',
      esterWeight: 0.87,
      halfLifeDays: 1.0,
    ),
    const Compound(
      name: 'Trembolona Enantato',
      esterWeight: 0.70,
      halfLifeDays: 4.5,
    ),
    const Compound(
      name: 'Dianabol (Metandienona)',
      esterWeight: 1.0,
      halfLifeDays: 0.2,
    ),
    const Compound(
      name: 'Anavar (Oxandrolona)',
      esterWeight: 1.0,
      halfLifeDays: 0.4,
    ),
    const Compound(
      name: 'Mesterolona (Proviron)',
      esterWeight: 1.0,
      halfLifeDays: 0.5,
    ),
  ],
  'Peptídeos e Outros': [
    const Compound(name: 'hCG', esterWeight: 1.0, halfLifeDays: 1.5),
    const Compound(
      name: 'HGH (Somatropina)',
      esterWeight: 1.0,
      halfLifeDays: 0.2,
    ),
  ],
};

class CompoundRowState {
  final TextEditingController doseCtrl = TextEditingController();
  String nomeComposto = '';
  Compound? composto;
  int? frequenciaDias;
  int? semanaInicio;
  int? semanaFim;

  void dispose() {
    doseCtrl.dispose();
  }
}

class SimuladorCiclosEcra extends StatefulWidget {
  const SimuladorCiclosEcra({super.key});

  @override
  State<SimuladorCiclosEcra> createState() => _SimuladorCiclosEcraState();
}

class _SimuladorCiclosEcraState extends State<SimuladorCiclosEcra> {
  final supabase = Supabase.instance.client;
  final nomeCicloCtrl = TextEditingController();
  int? duracaoCicloSemanas;
  DateTime dataInicio = DateTime.now();

  List<String> listaSubstancias = [];
  int _resetKey = 0;

  List<CompoundRowState> linhas = [CompoundRowState()];

  bool mostrarGrafico = false;
  List<InjectionEvent> eventosGerados = [];
  int diasTotaisSimulacao = 0;

  @override
  void initState() {
    super.initState();
    _carregarCatalogo();
  }

  Future<void> _carregarCatalogo() async {
    final Set<String> nomes = {};
    for (var lista in baseDeDadosCompostos.values) {
      for (var c in lista) {
        nomes.add(c.name);
      }
    }
    try {
      final resposta = await supabase.rpc('obter_nomes_unicos');
      for (var item in resposta) {
        String nome = item['nome'].toString();
        if (nome.startsWith('Mix') || nome.startsWith('[Arquivado]')) continue;
        if (nome.startsWith('[Oculto] ')) {
          nome = nome.replaceFirst('[Oculto] ', '');
        }
        nomes.add(nome);
      }
    } catch (e) {
      debugPrint('Erro ao carregar catálogo no simulador: $e');
    }
    final listaOrdenada = nomes.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (mounted) {
      setState(() => listaSubstancias = listaOrdenada);
    }
  }

  Compound _resolverComposto(String nome) {
    for (var lista in baseDeDadosCompostos.values) {
      for (var c in lista) {
        if (c.name.toLowerCase() == nome.toLowerCase()) return c;
      }
    }
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
    return Compound(name: nome, esterWeight: 1.0, halfLifeDays: 3.0);
  }

  @override
  void dispose() {
    nomeCicloCtrl.dispose();
    for (var l in linhas) {
      l.dispose();
    }
    super.dispose();
  }

  void _adicionarComposto() {
    setState(() {
      linhas.add(CompoundRowState());
      mostrarGrafico = false;
    });
  }

  void _removerComposto(int index) {
    if (linhas.length > 1) {
      setState(() {
        linhas[index].dispose();
        linhas.removeAt(index);
        mostrarGrafico = false;
      });
    }
  }

  void _reiniciar() {
    for (var l in linhas) {
      l.dispose();
    }
    setState(() {
      nomeCicloCtrl.clear();
      duracaoCicloSemanas = null;
      _resetKey++;
      linhas = [CompoundRowState()];
      mostrarGrafico = false;
    });
  }

  void _gerarTrama() {
    FocusScope.of(context).unfocus();
    final int duracao = duracaoCicloSemanas ?? 12;
    List<InjectionEvent> eventos = [];

    int duracaoTotalDias = (duracao * 7) + 28;

    for (var linha in linhas) {
      double dose =
          double.tryParse(linha.doseCtrl.text.replaceAll(',', '.')) ?? 0.0;
      if (dose <= 0 ||
          linha.nomeComposto.trim().isEmpty ||
          linha.frequenciaDias == null ||
          linha.semanaInicio == null ||
          linha.semanaFim == null) {
        continue;
      }

      final composto = linha.composto ?? _resolverComposto(linha.nomeComposto);
      int diaInicio = (linha.semanaInicio! - 1) * 7;
      int diaFim = (linha.semanaFim! * 7) - 1;

      if (diaFim > (duracao * 7)) {
        diaFim = duracao * 7;
      }

      for (int dia = diaInicio; dia <= diaFim; dia += linha.frequenciaDias!) {
        eventos.add(InjectionEvent(day: dia, doseMg: dose, compound: composto));
      }
    }

    if (eventos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verifique a dose e o intervalo de semanas (início deve ser menor ou igual ao fim).',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      eventosGerados = List<InjectionEvent>.from(eventos);
      diasTotaisSimulacao = duracaoTotalDias;
      mostrarGrafico = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.simulador.titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Text(t.simulador.subtitulo, style: AppTextStyles.pageTitle),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nomeCicloCtrl,
                      decoration: InputDecoration(
                        labelText: t.simulador.nome_ciclo,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: duracaoCicloSemanas,
                            decoration: InputDecoration(
                              labelText: t.simulador.duracao,
                              border: const OutlineInputBorder(),
                            ),
                            items: List.generate(24, (i) => i + 1).map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(t.simulador.semanas(s: s)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  duracaoCicloSemanas = val;
                                  mostrarGrafico = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(t.simulador.composto_title, style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),

            ...List.generate(linhas.length, (index) {
              final linha = linhas[index];
              return Card(
                color: AppColors.surface,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.simulador.composto_n(n: index + 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          if (linhas.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerComposto(index),
                              tooltip: t.simulador.remover,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<String>(
                        key: ValueKey('sim_sub_${_resetKey}_$index'),
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
                          setState(() {
                            linha.nomeComposto = selection;
                            linha.composto = _resolverComposto(selection);
                            mostrarGrafico = false;
                          });
                        },
                        fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                          return TextFormField(
                            controller: ctrl,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: t.simulador.selecione,
                              prefixIcon: const Icon(Icons.search_rounded),
                            ),
                            onChanged: (val) {
                              linha.nomeComposto = val;
                              linha.composto = _resolverComposto(val);
                              mostrarGrafico = false;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: linha.doseCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: t.simulador.dose,
                        ),
                        onChanged: (_) => mostrarGrafico = false,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: linha.frequenciaDias,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: t.simulador.esquema,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(t.simulador.freq_1),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(t.simulador.freq_2),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(t.simulador.freq_3),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text(t.simulador.freq_4),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text(t.simulador.freq_5),
                          ),
                          DropdownMenuItem(
                            value: 7,
                            child: Text(t.simulador.freq_7),
                          ),
                          DropdownMenuItem(
                            value: 14,
                            child: Text(t.simulador.freq_14),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              linha.frequenciaDias = val;
                              mostrarGrafico = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: linha.semanaInicio,
                              decoration: InputDecoration(
                                labelText: t.simulador.de_sem,
                                border: const OutlineInputBorder(),
                              ),
                              items:
                                  List.generate(
                                    duracaoCicloSemanas ?? 24,
                                    (i) => i + 1,
                                  ).map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(t.simulador.semana_n(s: s)),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    linha.semanaInicio = val;
                                    mostrarGrafico = false;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue:
                                  (linha.semanaFim != null &&
                                      duracaoCicloSemanas != null &&
                                      linha.semanaFim! > duracaoCicloSemanas!)
                                  ? duracaoCicloSemanas
                                  : linha.semanaFim,
                              decoration: InputDecoration(
                                labelText: t.simulador.ate_sem,
                                border: const OutlineInputBorder(),
                              ),
                              items:
                                  List.generate(
                                    duracaoCicloSemanas ?? 24,
                                    (i) => i + 1,
                                  ).map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(t.simulador.semana_n(s: s)),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    linha.semanaFim = val;
                                    mostrarGrafico = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _gerarTrama,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      t.simulador.btn_trama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: _adicionarComposto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      t.simulador.btn_adicionar,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _reiniciar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      t.simulador.btn_reiniciar,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (mostrarGrafico) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                t.simulador.grafico_titulo,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),

              PharmacokineticsChartWidget(
                injections: eventosGerados,
                simulationDays: diasTotaisSimulacao,
              ),
              const SizedBox(height: 16),
              Text(
                t.simulador.grafico_nota,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
