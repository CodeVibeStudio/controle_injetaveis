// Ficheiro: lib/utils/clinical_tracker_engine.dart

enum CategoriaMarcador {
  seguranca,
  figadoRins,
  lipidios,
  hormonal,
  metabolico,
  bioimpedancia,
  medidas,
}

enum StatusMarcador { normal, atencao, critico }

class MarcadorDefinicao {
  final String id;
  final String nome;
  final String nomeCurto;
  final String unidade;
  final CategoriaMarcador categoria;

  // Faixas de referência (Masculino / Feminino)
  final double? minMasc;
  final double? maxMasc;
  final double? minFem;
  final double? maxFem;

  // Limites de alerta crítico (requer atenção médica mais urgente)
  final double? criticoAltoMasc;
  final double? criticoAltoFem;
  final double? criticoBaixoMasc;
  final double? criticoBaixoFem;

  final bool apenasMasculino;
  final int idadeMinima;

  const MarcadorDefinicao({
    required this.id,
    required this.nome,
    required this.nomeCurto,
    required this.unidade,
    required this.categoria,
    this.minMasc,
    this.maxMasc,
    this.minFem,
    this.maxFem,
    this.criticoAltoMasc,
    this.criticoAltoFem,
    this.criticoBaixoMasc,
    this.criticoBaixoFem,
    this.apenasMasculino = false,
    this.idadeMinima = 0,
  });

  double? minRef(bool isFeminino) => isFeminino ? (minFem ?? minMasc) : minMasc;
  double? maxRef(bool isFeminino) => isFeminino ? (maxFem ?? maxMasc) : maxMasc;

  String faixaTexto(bool isFeminino) {
    final min = minRef(isFeminino);
    final max = maxRef(isFeminino);
    if (min != null && max != null) return '$min – $max $unidade';
    if (min != null) return '≥ $min $unidade';
    if (max != null) return '≤ $max $unidade';
    return 'Acompanhamento';
  }
}

class AvaliacaoMarcador {
  final MarcadorDefinicao marcador;
  final double valor;
  final StatusMarcador status;
  final String direcao; // 'normal', 'alto', 'baixo'
  final String mensagem;

  const AvaliacaoMarcador({
    required this.marcador,
    required this.valor,
    required this.status,
    required this.direcao,
    required this.mensagem,
  });
}

class ClinicalTrackerEngine {
  static const List<MarcadorDefinicao> todosMarcadores = [
    // 1. SEGURANÇA CRÍTICA
    MarcadorDefinicao(
      id: 'hematocrito',
      nome: 'Hematócrito',
      nomeCurto: 'Hematócrito',
      unidade: '%',
      categoria: CategoriaMarcador.seguranca,
      minMasc: 40,
      maxMasc: 50,
      minFem: 36,
      maxFem: 46,
      criticoAltoMasc: 54,
      criticoAltoFem: 50,
    ),
    MarcadorDefinicao(
      id: 'hemoglobina',
      nome: 'Hemoglobina',
      nomeCurto: 'Hemoglobina',
      unidade: 'g/dL',
      categoria: CategoriaMarcador.seguranca,
      minMasc: 13.5,
      maxMasc: 17.5,
      minFem: 12.0,
      maxFem: 15.5,
      criticoAltoMasc: 18.5,
      criticoAltoFem: 16.5,
    ),
    MarcadorDefinicao(
      id: 'pa_sistolica',
      nome: 'Pressão Arterial Sistólica',
      nomeCurto: 'PA Sistólica',
      unidade: 'mmHg',
      categoria: CategoriaMarcador.seguranca,
      minMasc: 90,
      maxMasc: 129,
      criticoAltoMasc: 140,
      criticoAltoFem: 140,
    ),
    MarcadorDefinicao(
      id: 'pa_diastolica',
      nome: 'Pressão Arterial Diastólica',
      nomeCurto: 'PA Diastólica',
      unidade: 'mmHg',
      categoria: CategoriaMarcador.seguranca,
      minMasc: 60,
      maxMasc: 84,
      criticoAltoMasc: 90,
      criticoAltoFem: 90,
    ),

    // 2. FÍGADO & RINS
    MarcadorDefinicao(
      id: 'tgo',
      nome: 'TGO (AST)',
      nomeCurto: 'TGO (AST)',
      unidade: 'U/L',
      categoria: CategoriaMarcador.figadoRins,
      maxMasc: 40,
      maxFem: 35,
      criticoAltoMasc: 80,
      criticoAltoFem: 70,
    ),
    MarcadorDefinicao(
      id: 'tgp',
      nome: 'TGP (ALT)',
      nomeCurto: 'TGP (ALT)',
      unidade: 'U/L',
      categoria: CategoriaMarcador.figadoRins,
      maxMasc: 41,
      maxFem: 33,
      criticoAltoMasc: 80,
      criticoAltoFem: 65,
    ),
    MarcadorDefinicao(
      id: 'ggt',
      nome: 'Gama-GT',
      nomeCurto: 'Gama-GT',
      unidade: 'U/L',
      categoria: CategoriaMarcador.figadoRins,
      maxMasc: 60,
      maxFem: 40,
      criticoAltoMasc: 100,
      criticoAltoFem: 80,
    ),
    MarcadorDefinicao(
      id: 'creatinina',
      nome: 'Creatinina',
      nomeCurto: 'Creatinina',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.figadoRins,
      minMasc: 0.7,
      maxMasc: 1.3,
      minFem: 0.6,
      maxFem: 1.1,
      criticoAltoMasc: 1.6,
      criticoAltoFem: 1.4,
    ),
    MarcadorDefinicao(
      id: 'cistatina_c',
      nome: 'Cistatina C',
      nomeCurto: 'Cistatina C',
      unidade: 'mg/L',
      categoria: CategoriaMarcador.figadoRins,
      minMasc: 0.5,
      maxMasc: 1.0,
      criticoAltoMasc: 1.25,
      criticoAltoFem: 1.25,
    ),

    // 3. LIPÍDIOS & INFLAMAÇÃO
    MarcadorDefinicao(
      id: 'colesterol_total',
      nome: 'Colesterol Total',
      nomeCurto: 'Colest. Total',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.lipidios,
      maxMasc: 190,
      criticoAltoMasc: 240,
      criticoAltoFem: 240,
    ),
    MarcadorDefinicao(
      id: 'hdl',
      nome: 'Colesterol HDL',
      nomeCurto: 'HDL',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.lipidios,
      minMasc: 40,
      minFem: 50,
      criticoBaixoMasc: 30,
      criticoBaixoFem: 35,
    ),
    MarcadorDefinicao(
      id: 'ldl',
      nome: 'Colesterol LDL',
      nomeCurto: 'LDL',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.lipidios,
      maxMasc: 130,
      criticoAltoMasc: 160,
      criticoAltoFem: 160,
    ),
    MarcadorDefinicao(
      id: 'triglicerideos',
      nome: 'Triglicerídeos',
      nomeCurto: 'Triglicerídeos',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.lipidios,
      maxMasc: 150,
      criticoAltoMasc: 200,
      criticoAltoFem: 200,
    ),
    MarcadorDefinicao(
      id: 'apob',
      nome: 'Apolipoproteína B (ApoB)',
      nomeCurto: 'ApoB',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.lipidios,
      maxMasc: 90,
      criticoAltoMasc: 120,
      criticoAltoFem: 120,
    ),
    MarcadorDefinicao(
      id: 'pcr_us',
      nome: 'PCR Ultrassensível',
      nomeCurto: 'PCR-us',
      unidade: 'mg/L',
      categoria: CategoriaMarcador.lipidios,
      maxMasc: 3.0,
      criticoAltoMasc: 5.0,
      criticoAltoFem: 5.0,
    ),

    // 4. HORMONAL
    MarcadorDefinicao(
      id: 'testosterona_total',
      nome: 'Testosterona Total',
      nomeCurto: 'Testo Total',
      unidade: 'ng/dL',
      categoria: CategoriaMarcador.hormonal,
      minMasc: 300,
      maxMasc: 900,
      minFem: 15,
      maxFem: 70,
      criticoAltoMasc: 1500,
      criticoAltoFem: 120,
    ),
    MarcadorDefinicao(
      id: 'estradiol',
      nome: 'Estradiol (E2)',
      nomeCurto: 'Estradiol',
      unidade: 'pg/mL',
      categoria: CategoriaMarcador.hormonal,
      minMasc: 15,
      maxMasc: 45,
      minFem: 30,
      maxFem: 300,
      criticoAltoMasc: 75,
      criticoAltoFem: 450,
    ),
    MarcadorDefinicao(
      id: 'shbg',
      nome: 'SHBG',
      nomeCurto: 'SHBG',
      unidade: 'nmol/L',
      categoria: CategoriaMarcador.hormonal,
      minMasc: 15,
      maxMasc: 55,
      minFem: 25,
      maxFem: 120,
    ),
    MarcadorDefinicao(
      id: 'prolactina',
      nome: 'Prolactina',
      nomeCurto: 'Prolactina',
      unidade: 'ng/mL',
      categoria: CategoriaMarcador.hormonal,
      maxMasc: 15,
      maxFem: 25,
      criticoAltoMasc: 25,
      criticoAltoFem: 40,
    ),
    MarcadorDefinicao(
      id: 'tsh',
      nome: 'TSH',
      nomeCurto: 'TSH',
      unidade: 'mUI/L',
      categoria: CategoriaMarcador.hormonal,
      minMasc: 0.4,
      maxMasc: 4.5,
      criticoAltoMasc: 6.0,
      criticoAltoFem: 6.0,
    ),
    MarcadorDefinicao(
      id: 'psa_total',
      nome: 'PSA Total',
      nomeCurto: 'PSA Total',
      unidade: 'ng/mL',
      categoria: CategoriaMarcador.hormonal,
      maxMasc: 4.0,
      criticoAltoMasc: 4.0,
      apenasMasculino: true,
      idadeMinima: 40,
    ),

    // 5. METABÓLICO
    MarcadorDefinicao(
      id: 'glicemia',
      nome: 'Glicemia em Jejum',
      nomeCurto: 'Glicemia',
      unidade: 'mg/dL',
      categoria: CategoriaMarcador.metabolico,
      minMasc: 70,
      maxMasc: 99,
      criticoAltoMasc: 126,
      criticoAltoFem: 126,
    ),
    MarcadorDefinicao(
      id: 'insulina',
      nome: 'Insulina Basal',
      nomeCurto: 'Insulina',
      unidade: 'µU/mL',
      categoria: CategoriaMarcador.metabolico,
      minMasc: 2.0,
      maxMasc: 12.0,
      criticoAltoMasc: 20.0,
      criticoAltoFem: 20.0,
    ),
    MarcadorDefinicao(
      id: 'hba1c',
      nome: 'Hemoglobina Glicada (HbA1c)',
      nomeCurto: 'HbA1c',
      unidade: '%',
      categoria: CategoriaMarcador.metabolico,
      maxMasc: 5.6,
      criticoAltoMasc: 6.5,
      criticoAltoFem: 6.5,
    ),
    MarcadorDefinicao(
      id: 'igf1',
      nome: 'IGF-1 (Somatomedina C)',
      nomeCurto: 'IGF-1',
      unidade: 'ng/mL',
      categoria: CategoriaMarcador.metabolico,
      minMasc: 80,
      maxMasc: 250,
      criticoAltoMasc: 350,
      criticoAltoFem: 350,
    ),

    // 6. CORPO & BIOIMPEDÂNCIA
    MarcadorDefinicao(
      id: 'peso_kg',
      nome: 'Peso Corporal',
      nomeCurto: 'Peso',
      unidade: 'kg',
      categoria: CategoriaMarcador.bioimpedancia,
    ),
    MarcadorDefinicao(
      id: 'massa_magra_kg',
      nome: 'Massa Magra',
      nomeCurto: 'Massa Magra',
      unidade: 'kg',
      categoria: CategoriaMarcador.bioimpedancia,
    ),
    MarcadorDefinicao(
      id: 'bf_percent',
      nome: 'Gordura Corporal (BF)',
      nomeCurto: 'BF %',
      unidade: '%',
      categoria: CategoriaMarcador.bioimpedancia,
      minMasc: 8,
      maxMasc: 20,
      minFem: 16,
      maxFem: 28,
      criticoAltoMasc: 28,
      criticoAltoFem: 35,
    ),
    MarcadorDefinicao(
      id: 'gordura_visceral',
      nome: 'Gordura Visceral',
      nomeCurto: 'Gord. Visceral',
      unidade: 'nível',
      categoria: CategoriaMarcador.bioimpedancia,
      maxMasc: 9,
      criticoAltoMasc: 13,
      criticoAltoFem: 13,
    ),

    // 7. MEDIDAS CORPORAIS
    MarcadorDefinicao(
      id: 'cintura_cm',
      nome: 'Cintura / Abdômen',
      nomeCurto: 'Cintura',
      unidade: 'cm',
      categoria: CategoriaMarcador.medidas,
      maxMasc: 94,
      maxFem: 80,
      criticoAltoMasc: 102,
      criticoAltoFem: 88,
    ),
    MarcadorDefinicao(
      id: 'torax_cm',
      nome: 'Tórax',
      nomeCurto: 'Tórax',
      unidade: 'cm',
      categoria: CategoriaMarcador.medidas,
    ),
    MarcadorDefinicao(
      id: 'braco_cm',
      nome: 'Braço',
      nomeCurto: 'Braço',
      unidade: 'cm',
      categoria: CategoriaMarcador.medidas,
    ),
    MarcadorDefinicao(
      id: 'coxa_cm',
      nome: 'Coxa',
      nomeCurto: 'Coxa',
      unidade: 'cm',
      categoria: CategoriaMarcador.medidas,
    ),
  ];

  /// Retorna marcadores aplicáveis ao perfil do usuário
  static List<MarcadorDefinicao> obterMarcadores({
    required bool isFeminino,
    required int idade,
    CategoriaMarcador? categoria,
  }) {
    return todosMarcadores.where((m) {
      if (m.apenasMasculino && isFeminino) return false;
      if (idade < m.idadeMinima) return false;
      if (categoria != null && m.categoria != categoria) return false;
      return true;
    }).toList();
  }

  /// Avalia um valor individual contra a faixa de referência
  static AvaliacaoMarcador avaliar(
    MarcadorDefinicao m,
    double valor, {
    required bool isFeminino,
  }) {
    final min = m.minRef(isFeminino);
    final max = m.maxRef(isFeminino);
    final critAlto = isFeminino ? (m.criticoAltoFem ?? m.criticoAltoMasc) : m.criticoAltoMasc;
    final critBaixo = isFeminino ? (m.criticoBaixoFem ?? m.criticoBaixoMasc) : m.criticoBaixoMasc;

    if (critAlto != null && valor >= critAlto) {
      return AvaliacaoMarcador(
        marcador: m,
        valor: valor,
        status: StatusMarcador.critico,
        direcao: 'alto',
        mensagem: '${m.nome} elevado ($valor ${m.unidade}). Leve este resultado para avaliação médica.',
      );
    }

    if (critBaixo != null && valor <= critBaixo) {
      return AvaliacaoMarcador(
        marcador: m,
        valor: valor,
        status: StatusMarcador.critico,
        direcao: 'baixo',
        mensagem: '${m.nome} muito baixo ($valor ${m.unidade}). Leve este resultado para avaliação médica.',
      );
    }

    if (max != null && valor > max) {
      return AvaliacaoMarcador(
        marcador: m,
        valor: valor,
        status: StatusMarcador.atencao,
        direcao: 'alto',
        mensagem: '${m.nome} acima da referência ($valor ${m.unidade}). Acompanhe com seu médico.',
      );
    }

    if (min != null && valor < min) {
      return AvaliacaoMarcador(
        marcador: m,
        valor: valor,
        status: StatusMarcador.atencao,
        direcao: 'baixo',
        mensagem: '${m.nome} abaixo da referência ($valor ${m.unidade}). Acompanhe com seu médico.',
      );
    }

    return AvaliacaoMarcador(
      marcador: m,
      valor: valor,
      status: StatusMarcador.normal,
      direcao: 'normal',
      mensagem: 'Dentro da faixa de referência.',
    );
  }

  /// Retorna apenas os alertas (Atenção ou Crítico) de um exame salvo
  static List<AvaliacaoMarcador> gerarAlertas(
    Map<String, dynamic> resultados, {
    required bool isFeminino,
    required int idade,
  }) {
    final List<AvaliacaoMarcador> alertas = [];
    final marcadores = obterMarcadores(isFeminino: isFeminino, idade: idade);

    for (final m in marcadores) {
      final raw = resultados[m.id];
      if (raw == null) continue;
      final valor = double.tryParse(raw.toString().replaceAll(',', '.'));
      if (valor == null) continue;

      final aval = avaliar(m, valor, isFeminino: isFeminino);
      if (aval.status != StatusMarcador.normal) {
        alertas.add(aval);
      }
    }

    // Ordena colocando os críticos primeiro
    alertas.sort((a, b) => b.status.index.compareTo(a.status.index));
    return alertas;
  }

  static String nomeCategoria(CategoriaMarcador cat) {
    switch (cat) {
      case CategoriaMarcador.seguranca:
        return 'Segurança & Sangue';
      case CategoriaMarcador.figadoRins:
        return 'Fígado & Rins';
      case CategoriaMarcador.lipidios:
        return 'Lipídios & Inflamação';
      case CategoriaMarcador.hormonal:
        return 'Hormonal';
      case CategoriaMarcador.metabolico:
        return 'Metabólico';
      case CategoriaMarcador.bioimpedancia:
        return 'Corpo & Bioimpedância';
      case CategoriaMarcador.medidas:
        return 'Medidas Corporais';
    }
  }
}