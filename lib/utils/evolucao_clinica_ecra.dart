// Ficheiro: lib/utils/evolucao_clinica_ecra.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../i18n/translations.g.dart';
import 'clinical_tracker_engine.dart';

class EvolucaoClinicaEcra extends StatefulWidget {
  const EvolucaoClinicaEcra({super.key});

  @override
  State<EvolucaoClinicaEcra> createState() => _EvolucaoClinicaEcraState();
}

class _EvolucaoClinicaEcraState extends State<EvolucaoClinicaEcra>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  bool carregando = true;
  bool isFeminino = false;
  int idade = 30;

  // Registros vindos do Supabase
  List exames = [];
  List medicoes = [];

  // Filtros de visualização
  CategoriaMarcador categoriaTabela = CategoriaMarcador.seguranca;
  String marcadorGraficoId = 'hematocrito';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => carregando = false);
      return;
    }

    try {
      final perfil = await supabase
          .from('perfis')
          .select('genero, data_nascimento')
          .eq('id', userId)
          .maybeSingle();

      if (perfil != null) {
        isFeminino = perfil['genero'] == 'Feminino';
        if (perfil['data_nascimento'] != null) {
          final nasc = DateTime.tryParse(perfil['data_nascimento'].toString());
          if (nasc != null) idade = DateTime.now().year - nasc.year;
        }
      }

      final respExames = await supabase
          .from('historico_exames')
          .select()
          .eq('user_id', userId)
          .order('data_exame', ascending: false);

      final respMedicoes = await supabase
          .from('medicoes_corporais')
          .select()
          .eq('user_id', userId)
          .order('data_medicao', ascending: false);

      if (mounted) {
        setState(() {
          exames = List.from(respExames);
          medicoes = List.from(respMedicoes);
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar evolução clínica: $e');
    }

    if (mounted) setState(() => carregando = false);
  }

  String _formatarDataCurta(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return iso;
    return '${p[2]}/${p[1]}/${p[0].substring(2)}';
  }

  Color _corStatus(StatusMarcador status) {
    switch (status) {
      case StatusMarcador.normal:
        return AppColors.success;
      case StatusMarcador.atencao:
        return AppColors.warning;
      case StatusMarcador.critico:
        return AppColors.error;
    }
  }

  // =========================================================================
  // MODAL DE REGISTRO (EXAME LABORATORIAL OU BIOIMPEDÂNCIA/MEDIDAS)
  // =========================================================================
  Future<void> _deletarRegistro(String tabela, dynamic id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Excluir Registro',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este registro clínico? Esta ação não pode ser desfeita.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await supabase.from(tabela).delete().eq('id', id);
      if (mounted) {
        _carregarDados();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro excluído com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // =========================================================================
  // MODAL DE REGISTRO (EXAME LABORATORIAL OU BIOIMPEDÂNCIA/MEDIDAS)
  // =========================================================================
  Future<void> _abrirModalRegistro({
    bool iniciarEmCorpo = false,
    Map? registroEditado,
  }) async {
    final bool modoEdicao = registroEditado != null;
    bool modoCorpo = iniciarEmCorpo;
    DateTime dataSelecionada = DateTime.now();
    final Map<String, TextEditingController> ctrls = {
      for (final m in ClinicalTrackerEngine.todosMarcadores)
        m.id: TextEditingController(),
    };
    final obsCtrl = TextEditingController();
    bool salvando = false;

    if (modoEdicao) {
      final dataRaw = modoCorpo
          ? registroEditado['data_medicao']
          : registroEditado['data_exame'];
      if (dataRaw != null) {
        dataSelecionada =
            DateTime.tryParse(dataRaw.toString()) ?? DateTime.now();
      }
      obsCtrl.text = (registroEditado['observacoes'] ?? '').toString();

      if (modoCorpo) {
        for (final m in ClinicalTrackerEngine.todosMarcadores) {
          final v = registroEditado[m.id];
          if (v != null) ctrls[m.id]?.text = v.toString();
        }
      } else if (registroEditado['resultados'] is Map) {
        final res = registroEditado['resultados'] as Map;
        res.forEach((k, v) {
          if (v != null && ctrls.containsKey(k.toString())) {
            ctrls[k.toString()]!.text = v.toString();
          }
        });
      }
    }

    final marcadoresLab =
        ClinicalTrackerEngine.obterMarcadores(
              isFeminino: isFeminino,
              idade: idade,
            )
            .where(
              (m) =>
                  m.categoria != CategoriaMarcador.bioimpedancia &&
                  m.categoria != CategoriaMarcador.medidas,
            )
            .toList();

    final marcadoresCorpo =
        ClinicalTrackerEngine.obterMarcadores(
              isFeminino: isFeminino,
              idade: idade,
            )
            .where(
              (m) =>
                  m.categoria == CategoriaMarcador.bioimpedancia ||
                  m.categoria == CategoriaMarcador.medidas,
            )
            .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final listaAtual = modoCorpo ? marcadoresCorpo : marcadoresLab;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add_chart_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              modoEdicao
                                  ? 'Editar Registro Clínico'
                                  : 'Novo Registro Clínico',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Seletor Laboratorial vs Corpo (bloqueado na edição)
                      if (!modoEdicao)
                        Container(
                          height: 44,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceInner,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setStateModal(() => modoCorpo = false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !modoCorpo
                                          ? AppColors.navPillActive
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Exame de Sangue',
                                      style: TextStyle(
                                        color: !modoCorpo
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setStateModal(() => modoCorpo = true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: modoCorpo
                                          ? AppColors.navPillActive
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Bioimpedância / Medidas',
                                      style: TextStyle(
                                        color: modoCorpo
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Data da Coleta / Medição
                      InkWell(
                        onTap: () async {
                          final escolhida = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.primaryDarkText,
                                  surface: AppColors.surface,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (escolhida != null) {
                            setStateModal(() => dataSelecionada = escolhida);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data do Registro',
                            isDense: true,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Preencha apenas os marcadores presentes no seu laudo:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Campos agrupados
                      Expanded(
                        child: ListView(
                          children: [
                            ...listaAtual.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TextField(
                                  controller: ctrls[m.id],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: '${m.nome} (${m.unidade})',
                                    helperText:
                                        'Ref: ${m.faixaTexto(isFeminino)}',
                                    helperStyle: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              );
                            }),
                            TextField(
                              controller: obsCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Observações (opcional)',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      salvando
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final userId = supabase.auth.currentUser?.id;
                                if (userId == null) return;
                                final dataIso = dataSelecionada
                                    .toIso8601String()
                                    .split('T')[0];

                                setStateModal(() => salvando = true);
                                try {
                                  if (modoCorpo) {
                                    double? parseNum(String id) {
                                      final t = ctrls[id]!.text.trim();
                                      if (t.isEmpty) return null;
                                      return double.tryParse(
                                        t.replaceAll(',', '.'),
                                      );
                                    }

                                    final payload = {
                                      'user_id': userId,
                                      'data_medicao': dataIso,
                                      'peso_kg': parseNum('peso_kg'),
                                      'massa_magra_kg': parseNum(
                                        'massa_magra_kg',
                                      ),
                                      'bf_percent': parseNum('bf_percent'),
                                      'gordura_visceral': parseNum(
                                        'gordura_visceral',
                                      ),
                                      'cintura_cm': parseNum('cintura_cm'),
                                      'torax_cm': parseNum('torax_cm'),
                                      'braco_cm': parseNum('braco_cm'),
                                      'coxa_cm': parseNum('coxa_cm'),
                                      'observacoes': obsCtrl.text.trim(),
                                    };

                                    final temAlgum = payload.entries.any(
                                      (e) =>
                                          e.key != 'user_id' &&
                                          e.key != 'data_medicao' &&
                                          e.key != 'observacoes' &&
                                          e.value != null,
                                    );

                                    if (!temAlgum) {
                                      setStateModal(() => salvando = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Preencha pelo menos uma medida.',
                                          ),
                                          backgroundColor: AppColors.warning,
                                        ),
                                      );
                                      return;
                                    }

                                    if (modoEdicao) {
                                      await supabase
                                          .from('medicoes_corporais')
                                          .update(payload)
                                          .eq('id', registroEditado['id']);
                                    } else {
                                      await supabase
                                          .from('medicoes_corporais')
                                          .insert(payload);
                                    }
                                  } else {
                                    final Map<String, double> resultados = {};
                                    for (final m in marcadoresLab) {
                                      final txt = ctrls[m.id]!.text.trim();
                                      if (txt.isEmpty) continue;
                                      final v = double.tryParse(
                                        txt.replaceAll(',', '.'),
                                      );
                                      if (v != null) resultados[m.id] = v;
                                    }

                                    if (resultados.isEmpty) {
                                      setStateModal(() => salvando = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Preencha pelo menos um resultado.',
                                          ),
                                          backgroundColor: AppColors.warning,
                                        ),
                                      );
                                      return;
                                    }

                                    // Captura foto automática das substâncias ativas
                                    final meds = await supabase
                                        .from('medicamentos')
                                        .select('nome');
                                    final ativos = meds
                                        .map((e) => e['nome'].toString())
                                        .where(
                                          (n) =>
                                              !n.startsWith('[Arquivado]') &&
                                              !n.startsWith('[Oculto]'),
                                        )
                                        .toList();

                                    final dadosExame = {
                                      'user_id': userId,
                                      'data_exame': dataIso,
                                      'categoria_alvo': 'Laudo Registrado',
                                      'resultados': resultados,
                                      'protocolo_ativo': ativos,
                                      'exames_realizados': resultados.keys
                                          .toList(),
                                      'observacoes': obsCtrl.text.trim(),
                                    };
                                    if (modoEdicao) {
                                      await supabase
                                          .from('historico_exames')
                                          .update(dadosExame)
                                          .eq('id', registroEditado['id']);
                                    } else {
                                      await supabase
                                          .from('historico_exames')
                                          .insert(dadosExame);
                                    }
                                  }

                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    _carregarDados();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registro salvo com sucesso!',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setStateModal(() => salvando = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro ao salvar: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('SALVAR REGISTRO'),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    for (final c in ctrls.values) {
      c.dispose();
    }
    obsCtrl.dispose();
  }

  // =========================================================================
  // ABA 1: ALERTAS & ÚLTIMO CHECK-UP
  // =========================================================================
  Widget _buildAbaAlertas() {
    final examesComResultado = exames.where((e) {
      final r = e['resultados'];
      return r is Map && r.isNotEmpty;
    }).toList();

    final ultimoExame = examesComResultado.isNotEmpty
        ? examesComResultado.first
        : null;
    final ultimaMedicao = medicoes.isNotEmpty ? medicoes.first : null;

    final List<AvaliacaoMarcador> alertas = ultimoExame != null
        ? ClinicalTrackerEngine.gerarAlertas(
            Map<String, dynamic>.from(ultimoExame['resultados']),
            isFeminino: isFeminino,
            idade: idade,
          )
        : [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Card de Alertas
        if (ultimoExame == null)
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.biotech_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum resultado registrado ainda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Toque no botão abaixo para registrar seu primeiro exame de sangue ou bioimpedância e acompanhar sua evolução.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Card(
            color: alertas.isEmpty
                ? AppColors.surface
                : (alertas.any((a) => a.status == StatusMarcador.critico)
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.warningBg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: alertas.isEmpty
                    ? AppColors.success.withValues(alpha: 0.5)
                    : (alertas.any((a) => a.status == StatusMarcador.critico)
                          ? AppColors.error.withValues(alpha: 0.6)
                          : AppColors.warning.withValues(alpha: 0.5)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        alertas.isEmpty
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        color: alertas.isEmpty
                            ? AppColors.success
                            : (alertas.any(
                                    (a) => a.status == StatusMarcador.critico,
                                  )
                                  ? AppColors.error
                                  : AppColors.warning),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          alertas.isEmpty
                              ? 'Último Exame: Tudo na Faixa'
                              : '${alertas.length} Marcador(es) para Avaliação Médica',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data: ${_formatarDataCurta(ultimoExame['data_exame'].toString())}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (ultimoExame['protocolo_ativo'] is List &&
                      (ultimoExame['protocolo_ativo'] as List).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Protocolo na data: ${(ultimoExame['protocolo_ativo'] as List).join(', ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (alertas.isNotEmpty) ...[
                    const Divider(height: 20),
                    ...alertas.map((a) {
                      final cor = _corStatus(a.status);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              a.direcao == 'alto'
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: cor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${a.marcador.nome}: ${a.valor} ${a.marcador.unidade}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: cor,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    'Ref: ${a.marcador.faixaTexto(isFeminino)} — Leve ao seu médico.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Resumo rápido de Bioimpedância
        if (ultimaMedicao != null)
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.monitor_weight_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Última Bioimpedância',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatarDataCurta(
                          ultimaMedicao['data_medicao'].toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (ultimaMedicao['peso_kg'] != null)
                        _chipMetrica('Peso', '${ultimaMedicao['peso_kg']} kg'),
                      if (ultimaMedicao['massa_magra_kg'] != null)
                        _chipMetrica(
                          'Massa Magra',
                          '${ultimaMedicao['massa_magra_kg']} kg',
                        ),
                      if (ultimaMedicao['bf_percent'] != null)
                        _chipMetrica('BF', '${ultimaMedicao['bf_percent']}%'),
                      if (ultimaMedicao['cintura_cm'] != null)
                        _chipMetrica(
                          'Cintura',
                          '${ultimaMedicao['cintura_cm']} cm',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        if (examesComResultado.isNotEmpty || medicoes.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Histórico de Registros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...examesComResultado.map((ex) {
            final qtd = (ex['resultados'] as Map).length;
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.biotech_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Exame • ${_formatarDataCurta(ex['data_exame'].toString())}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '$qtd marcador(es) registrado(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      onPressed: () => _abrirModalRegistro(
                        iniciarEmCorpo: false,
                        registroEditado: ex,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () =>
                          _deletarRegistro('historico_exames', ex['id']),
                    ),
                  ],
                ),
              ),
            );
          }),
          ...medicoes.map((med) {
            final pesoStr = med['peso_kg'] != null
                ? ' • ${med['peso_kg']} kg'
                : '';
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.monitor_weight_rounded,
                  color: AppColors.success,
                ),
                title: Text(
                  'Corpo • ${_formatarDataCurta(med['data_medicao'].toString())}$pesoStr',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  med['bf_percent'] != null
                      ? 'BF: ${med['bf_percent']}%'
                      : 'Medidas corporais',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      onPressed: () => _abrirModalRegistro(
                        iniciarEmCorpo: true,
                        registroEditado: med,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () =>
                          _deletarRegistro('medicoes_corporais', med['id']),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _chipMetrica(String label, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ABA 2: TABELA COMPARATIVA COM SEMÁFORO COLORIDO
  // =========================================================================
  Widget _buildAbaTabela() {
    final bool ehCorpo =
        categoriaTabela == CategoriaMarcador.bioimpedancia ||
        categoriaTabela == CategoriaMarcador.medidas;

    final registros = ehCorpo
        ? medicoes
        : exames
              .where(
                (e) =>
                    e['resultados'] is Map &&
                    (e['resultados'] as Map).isNotEmpty,
              )
              .toList();

    final marcadores = ClinicalTrackerEngine.obterMarcadores(
      isFeminino: isFeminino,
      idade: idade,
      categoria: categoriaTabela,
    );

    return Column(
      children: [
        // Chips de filtro por categoria
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: CategoriaMarcador.values.map((cat) {
              final sel = cat == categoriaTabela;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    ClinicalTrackerEngine.nomeCategoria(cat),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sel
                          ? AppColors.primaryDarkText
                          : AppColors.textSecondary,
                    ),
                  ),
                  selected: sel,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onSelected: (_) => setState(() => categoriaTabela = cat),
                ),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: registros.isEmpty
              ? const Center(
                  child: Text(
                    'Sem registros nesta categoria.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.surfaceHighlight,
                      ),
                      dataRowColor: WidgetStateProperty.all(AppColors.surface),
                      border: TableBorder.all(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Marcador',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...registros.take(6).map((r) {
                          final dataStr = ehCorpo
                              ? r['data_medicao'].toString()
                              : r['data_exame'].toString();
                          return DataColumn(
                            label: Text(
                              _formatarDataCurta(dataStr),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }),
                      ],
                      rows: marcadores.map((m) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.nomeCurto,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    m.faixaTexto(isFeminino),
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...registros.take(6).map((r) {
                              final raw = ehCorpo
                                  ? r[m.id]
                                  : (r['resultados'] as Map)[m.id];
                              if (raw == null) {
                                return const DataCell(
                                  Text(
                                    '—',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                );
                              }
                              final val = double.tryParse(raw.toString());
                              if (val == null) {
                                return const DataCell(Text('—'));
                              }
                              final aval = ClinicalTrackerEngine.avaliar(
                                m,
                                val,
                                isFeminino: isFeminino,
                              );
                              final cor = _corStatus(aval.status);
                              return DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: cor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    '$val',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: cor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // =========================================================================
  // ABA 3: GRÁFICOS DE EVOLUÇÃO (fl_chart com faixa verde de referência)
  // =========================================================================
  Widget _buildAbaGraficos() {
    final todos = ClinicalTrackerEngine.obterMarcadores(
      isFeminino: isFeminino,
      idade: idade,
    );
    final marcador = todos.firstWhere(
      (m) => m.id == marcadorGraficoId,
      orElse: () => todos.first,
    );

    final bool ehCorpo =
        marcador.categoria == CategoriaMarcador.bioimpedancia ||
        marcador.categoria == CategoriaMarcador.medidas;

    final List<(String data, double valor)> pontos = [];
    final fonte = ehCorpo ? medicoes.reversed : exames.reversed;

    for (final reg in fonte) {
      final raw = ehCorpo
          ? reg[marcador.id]
          : (reg['resultados'] is Map ? reg['resultados'][marcador.id] : null);
      if (raw == null) continue;
      final val = double.tryParse(raw.toString());
      if (val == null) continue;
      final dt = ehCorpo
          ? reg['data_medicao'].toString()
          : reg['data_exame'].toString();
      pontos.add((_formatarDataCurta(dt), val));
    }

    final spots = List.generate(
      pontos.length,
      (i) => FlSpot(i.toDouble(), pontos[i].$2),
    );

    final minRef = marcador.minRef(isFeminino);
    final maxRef = marcador.maxRef(isFeminino);

    double minY = 0;
    double maxY = 100;
    if (pontos.isNotEmpty) {
      final valores = pontos.map((p) => p.$2).toList();
      if (minRef != null) valores.add(minRef);
      if (maxRef != null) valores.add(maxRef);
      final menor = valores.reduce((a, b) => a < b ? a : b);
      final maior = valores.reduce((a, b) => a > b ? a : b);
      final margem = (maior - menor).abs() < 1 ? 5.0 : (maior - menor) * 0.2;
      minY = (menor - margem).clamp(0, double.infinity);
      maxY = maior + margem;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        DropdownButtonFormField<String>(
          initialValue: marcador.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Escolha o Marcador para Visualizar',
            prefixIcon: Icon(Icons.show_chart_rounded),
          ),
          items: todos.map((m) {
            return DropdownMenuItem(
              value: m.id,
              child: Text('${m.nome} (${m.unidade})'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => marcadorGraficoId = val);
          },
        ),
        const SizedBox(height: 16),

        if (pontos.isEmpty)
          Container(
            height: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Nenhum dado registrado para este marcador.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          Container(
            height: 300,
            padding: const EdgeInsets.fromLTRB(12, 24, 20, 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: pontos.length > 1 ? (pontos.length - 1).toDouble() : 1,
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                rangeAnnotations: (minRef != null || maxRef != null)
                    ? RangeAnnotations(
                        horizontalRangeAnnotations: [
                          HorizontalRangeAnnotation(
                            y1: minRef ?? minY,
                            y2: maxRef ?? maxY,
                            color: AppColors.success.withValues(alpha: 0.12),
                          ),
                        ],
                      )
                    : const RangeAnnotations(),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= pontos.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            pontos[idx].$1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.30),
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
        const SizedBox(height: 12),
        Text(
          'Faixa de referência (${isFeminino ? "Feminino" : "Masculino"}): ${marcador.faixaTexto(isFeminino)}. A área verde no fundo indica a zona esperada.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _gerarRelatorioMedico() {
    final buf = StringBuffer();
    buf.writeln('RELATÓRIO DE EVOLUÇÃO CLÍNICA');
    buf.writeln('App Controle de Injetáveis');
    buf.writeln(
      'Perfil: ${isFeminino ? "Feminino" : "Masculino"} | $idade anos\n',
    );

    final mapaMarcadores = {
      for (final m in ClinicalTrackerEngine.todosMarcadores) m.id: m,
    };

    final examesComResultado = exames
        .where(
          (e) => e['resultados'] is Map && (e['resultados'] as Map).isNotEmpty,
        )
        .toList();

    // 1. Alertas do último exame
    if (examesComResultado.isNotEmpty) {
      final ultimo = examesComResultado.first;
      final resMap = Map<String, dynamic>.from(ultimo['resultados']);
      final alertas = ClinicalTrackerEngine.gerarAlertas(
        resMap,
        isFeminino: isFeminino,
        idade: idade,
      );

      if (alertas.isNotEmpty) {
        buf.writeln(
          '⚠️ PONTOS DE ATENÇÃO (${_formatarDataCurta(ultimo['data_exame'].toString())}):',
        );
        for (final a in alertas) {
          final nivel = a.status == StatusMarcador.critico
              ? 'CRÍTICO'
              : 'ATENÇÃO';
          buf.writeln(
            '• [$nivel] ${a.marcador.nome}: ${a.valor} ${a.marcador.unidade} (Ref: ${a.marcador.faixaTexto(isFeminino)})',
          );
        }
        buf.writeln('');
      }
    }

    // 2. Histórico dos últimos 3 exames
    if (examesComResultado.isNotEmpty) {
      buf.writeln('🧪 ÚLTIMOS EXAMES LABORATORIAIS:');
      for (final e in examesComResultado.take(3)) {
        buf.writeln('Data: ${_formatarDataCurta(e['data_exame'].toString())}');
        if (e['protocolo_ativo'] is List &&
            (e['protocolo_ativo'] as List).isNotEmpty) {
          buf.writeln(
            'Protocolo ativo: ${(e['protocolo_ativo'] as List).join(', ')}',
          );
        }
        (e['resultados'] as Map).forEach((k, v) {
          final def = mapaMarcadores[k.toString()];
          if (def != null) {
            buf.writeln('• ${def.nome}: $v ${def.unidade}');
          } else {
            buf.writeln('• $k: $v');
          }
        });
        if (e['observacoes'] != null &&
            e['observacoes'].toString().trim().isNotEmpty) {
          buf.writeln('Obs: ${e['observacoes']}');
        }
        buf.writeln('');
      }
    }

    // 3. Última bioimpedância e medidas
    if (medicoes.isNotEmpty) {
      final m = medicoes.first;
      buf.writeln(
        '📏 ÚLTIMA BIOIMPEDÂNCIA / MEDIDAS (${_formatarDataCurta(m['data_medicao'].toString())}):',
      );
      if (m['peso_kg'] != null) buf.writeln('• Peso: ${m['peso_kg']} kg');
      if (m['massa_magra_kg'] != null) {
        buf.writeln('• Massa Magra: ${m['massa_magra_kg']} kg');
      }
      if (m['bf_percent'] != null) buf.writeln('• BF: ${m['bf_percent']}%');
      if (m['gordura_visceral'] != null) {
        buf.writeln('• Gordura Visceral: ${m['gordura_visceral']}');
      }
      if (m['cintura_cm'] != null) {
        buf.writeln('• Cintura: ${m['cintura_cm']} cm');
      }
      if (m['torax_cm'] != null) buf.writeln('• Tórax: ${m['torax_cm']} cm');
      if (m['braco_cm'] != null) buf.writeln('• Braço: ${m['braco_cm']} cm');
      if (m['coxa_cm'] != null) buf.writeln('• Coxa: ${m['coxa_cm']} cm');
      buf.writeln('');
    }

    buf.writeln(
      'Aviso: Relatório gerado para apoio à consulta médica. Não substitui avaliação profissional.',
    );
    return buf.toString();
  }

  Future<void> _enviarRelatorioEmail() async {
    final emailUsuario = supabase.auth.currentUser?.email ?? '';
    final corpo = _gerarRelatorioMedico();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailUsuario,
      query:
          'subject=${Uri.encodeComponent("Relatório de Evolução Clínica - Controle de Injetáveis")}&body=${Uri.encodeComponent(corpo)}',
    );
    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o aplicativo de e-mail.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.evolucao.titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: t.evolucao.tooltip_email,
            onPressed: _enviarRelatorioEmail,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: t.evolucao.tooltip_copiar,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _gerarRelatorioMedico()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.evolucao.msg_copiado),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: t.evolucao.aba_alertas),
            Tab(text: t.evolucao.aba_tabela),
            Tab(text: t.evolucao.aba_graficos),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalRegistro(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryDarkText,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          t.evolucao.btn_registrar,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAbaAlertas(),
                _buildAbaTabela(),
                _buildAbaGraficos(),
              ],
            ),
    );
  }
}
