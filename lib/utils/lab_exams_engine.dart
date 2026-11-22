// Ficheiro: lib/utils/lab_exams_engine.dart

enum SexoBiologico { masculino, feminino }

enum PerfilPonderal {
  baixoPeso,
  pesoAdequado,
  sobrepesoOuObesidade,
  pesoElevadoMassaMuscular,
}

enum CategoriaSubstancia {
  esterLongo,
  esterCurtoOuOral,
  incretinas,
  peptideosCobre,
  eixoGh,
}

enum SecaoExame {
  laboratoriais,
  especificosProtocolo,
  perfilPonderal,
  cardiologicos,
  imagemRastreamento,
}

class ExameSugerido {
  final String id;
  final String nome;
  final SecaoExame secao;
  final String primeiroExame;
  final String periodicidade;
  final int validadeDias;
  final List<String> tagsDestaque;

  const ExameSugerido({
    required this.id,
    required this.nome,
    required this.secao,
    required this.primeiroExame,
    required this.periodicidade,
    this.validadeDias = 90,
    this.tagsDestaque = const [],
  });

  ExameSugerido copyWith({
    String? primeiroExame,
    String? periodicidade,
    List<String>? tagsDestaque,
  }) {
    return ExameSugerido(
      id: id,
      nome: nome,
      secao: secao,
      primeiroExame: primeiroExame ?? this.primeiroExame,
      periodicidade: periodicidade ?? this.periodicidade,
      tagsDestaque: tagsDestaque ?? this.tagsDestaque,
    );
  }
}

class PerfilClinicoInput {
  final SexoBiologico sexo;
  final int idade;
  final double? pesoKg;
  final double? alturaCm;
  final bool altaMassaMuscular;
  final List<String> nomesMedicamentosAtivos;

  const PerfilClinicoInput({
    required this.sexo,
    required this.idade,
    this.pesoKg,
    this.alturaCm,
    this.altaMassaMuscular = false,
    this.nomesMedicamentosAtivos = const [],
  });

  double? get imc {
    if (pesoKg == null || alturaCm == null || alturaCm! <= 0) return null;
    final alturaM = alturaCm! / 100.0;
    return pesoKg! / (alturaM * alturaM);
  }

  PerfilPonderal get perfilPonderal {
    if (altaMassaMuscular && (pesoKg ?? 0) >= 85) {
      return PerfilPonderal.pesoElevadoMassaMuscular;
    }
    final valorImc = imc;
    if (valorImc != null) {
      if (valorImc < 18.5) return PerfilPonderal.baixoPeso;
      if (valorImc < 25.0) return PerfilPonderal.pesoAdequado;
      return PerfilPonderal.sobrepesoOuObesidade;
    }
    // Fallback por peso corporal caso altura não esteja cadastrada
    if (pesoKg != null) {
      if (pesoKg! < 50) return PerfilPonderal.baixoPeso;
      if (pesoKg! >= 95) return PerfilPonderal.sobrepesoOuObesidade;
    }
    return PerfilPonderal.pesoAdequado;
  }
}

class LabExamsEngine {
  /// Classifica automaticamente os medicamentos ativos do Supabase nas 5 categorias clínicas
  static Set<CategoriaSubstancia> detectarCategorias(List<String> nomes) {
    final Set<CategoriaSubstancia> cats = {};
    for (final raw in nomes) {
      final n = raw.toLowerCase();
      if (n.contains('enantato') ||
          n.contains('cipionato') ||
          n.contains('deca') ||
          n.contains('decanoato') ||
          n.contains('undecilenato') ||
          n.contains('boldenona') ||
          n.contains('primobolan') ||
          n.contains('metenolona')) {
        cats.add(CategoriaSubstancia.esterLongo);
      }
      if (n.contains('propionato') ||
          n.contains('acetato') ||
          n.contains('fenilpropionato') ||
          n.contains('npp') ||
          n.contains('oxandrolona') ||
          n.contains('anavar') ||
          n.contains('dianabol') ||
          n.contains('stanozolol') ||
          n.contains('hemogenin') ||
          n.contains('proviron')) {
        cats.add(CategoriaSubstancia.esterCurtoOuOral);
      }
      if (n.contains('semaglutida') ||
          n.contains('ozempic') ||
          n.contains('wegovy') ||
          n.contains('tirzepatida') ||
          n.contains('mounjaro') ||
          n.contains('zepbound') ||
          n.contains('retatrutida') ||
          n.contains('liraglutida')) {
        cats.add(CategoriaSubstancia.incretinas);
      }
      if (n.contains('ghk-cu') || n.contains('ghk cu') || n.contains('cobre')) {
        cats.add(CategoriaSubstancia.peptideosCobre);
      }
      if (n.contains('hgh') ||
          n.contains('somatropina') ||
          n.contains('gh ') ||
          n.contains('cjc-1295') ||
          n.contains('ipamorelin') ||
          n.contains('tesamorelin') ||
          n.contains('tesamorelina') ||
          n.contains('mk-677') ||
          n.contains('sermorelin')) {
        cats.add(CategoriaSubstancia.eixoGh);
      }
    }
    return cats;
  }

  /// Gera o mapa de exames agrupados por seção, já deduplicados e com tags de destaque
  static Map<SecaoExame, List<ExameSugerido>> gerarRecomendacoes(
    PerfilClinicoInput input,
  ) {
    final categorias = detectarCategorias(input.nomesMedicamentosAtivos);
    final perfil = input.perfilPonderal;
    final Map<String, ExameSugerido> mapaUnico = {};

    // Helper de adição com deduplicação inteligente
    void addOrTag({
      required String id,
      required String nome,
      required SecaoExame secao,
      required String primeiroExame,
      required String periodicidade,
      String? tag,
    }) {
      if (mapaUnico.containsKey(id)) {
        if (tag != null && !mapaUnico[id]!.tagsDestaque.contains(tag)) {
          mapaUnico[id] = mapaUnico[id]!.copyWith(
            tagsDestaque: [...mapaUnico[id]!.tagsDestaque, tag],
          );
        }
      } else {
        mapaUnico[id] = ExameSugerido(
          id: id,
          nome: nome,
          secao: secao,
          primeiroExame: primeiroExame,
          periodicidade: periodicidade,
          tagsDestaque: tag != null ? [tag] : [],
        );
      }
    }

    final bool temEsterLongo = categorias.contains(
      CategoriaSubstancia.esterLongo,
    );
    final String prazoBaseLab = temEsterLongo
        ? '6 a 8 semanas'
        : '4 a 6 semanas';
    const String periodBaseLab = '3 a 6 meses';

    // =========================================================================
    // A. BASE COMUM (Ambos os sexos — Todas as faixas etárias)
    // =========================================================================
    final baseLab = <String, String>{
      'hemograma': 'Hemograma completo',
      'glicemia_insulina': 'Glicemia em jejum, Insulina basal e Índice HOMA-IR',
      'hba1c': 'Hemoglobina Glicada (HbA1c)',
      'lipidograma': 'Colesterol Total, HDL, LDL, VLDL e Triglicerídeos',
      'apob_lpa': 'Apolipoproteína B (ApoB) e Lipoproteína(a) [Lp(a)]',
      'hepatico':
          'TGO (AST), TGP (ALT), Gama-GT, Fosfatase Alcalina e Bilirrubinas',
      'renal': 'Ureia, Creatinina, TFGe, Urina tipo 1 (EAS) e Relação Albumina/Creatinina',
      'cistatina_c': 'Cistatina C',
      'eletrolitos': 'Eletrólitos (Sódio, Potássio, Magnésio e Cálcio total)',
      'inflamatorios': 'PCR ultrassensível (PCR-us), Ferritina, Homocisteína, Ácido Úrico e CPK',
      'hormonios_base': 'Testosterona Total/Livre, SHBG, Albumina, Estradiol (E2), Prolactina, LH, FSH, DHT, TSH e T4 Livre',
    };

    baseLab.forEach((id, nome) {
      addOrTag(
        id: id,
        nome: nome,
        secao: SecaoExame.laboratoriais,
        primeiroExame: prazoBaseLab,
        periodicidade: periodBaseLab,
      );
    });

    addOrTag(
      id: 'vitaminas',
      nome: 'Vitaminas (25-OH Vitamina D, Vitamina B12 e Ácido Fólico)',
      secao: SecaoExame.laboratoriais,
      primeiroExame: '3 meses',
      periodicidade: '6 a 12 meses',
    );

    // Cardiológicos e Imagem (Base)
    addOrTag(
      id: 'pa_mapa',
      nome: 'Pressão Arterial (Aferição domiciliar / MAPA 24h)',
      secao: SecaoExame.cardiologicos,
      primeiroExame: '1 a 2 semanas',
      periodicidade: 'Quinzenal/Mensal (MAPA 6-12 meses)',
    );
    addOrTag(
      id: 'cardio_base',
      nome: 'ECG de repouso, Ecocardiograma transtorácico e Teste Ergométrico',
      secao: SecaoExame.cardiologicos,
      primeiroExame: 'Basal ou 6 a 12 meses',
      periodicidade: 'Anual (ou semestral se alterado)',
    );
    addOrTag(
      id: 'usg_abdome',
      nome: 'Ultrassonografia de abdome total',
      secao: SecaoExame.imagemRastreamento,
      primeiroExame: '6 a 12 meses',
      periodicidade: 'Anual',
    );
    addOrTag(
      id: 'bioimpedancia_dexa',
      nome: 'Bioimpedância ou DEXA corporal',
      secao: SecaoExame.imagemRastreamento,
      primeiroExame: '3 meses',
      periodicidade: '3 a 6 meses',
    );

    // =========================================================================
    // B. EXAMES CONDICIONAIS POR CATEGORIA DE SUBSTÂNCIA
    // =========================================================================
    if (categorias.contains(CategoriaSubstancia.incretinas)) {
      addOrTag(
        id: 'amilase_lipase',
        nome: 'Amilase e Lipase (Pâncreas)',
        secao: SecaoExame.especificosProtocolo,
        primeiroExame: '4 a 8 semanas',
        periodicidade: '3 a 6 meses',
        tag: 'Incretinas (GLP-1/GIP)',
      );
      addOrTag(
        id: 'hepatico',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Incretinas',
      );
      addOrTag(
        id: 'eletrolitos',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Incretinas',
      );
      addOrTag(
        id: 'usg_abdome',
        nome: '',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Incretinas',
      );
      addOrTag(
        id: 'bioimpedancia_dexa',
        nome: '',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Monitorar massa magra',
      );
    }

    if (categorias.contains(CategoriaSubstancia.peptideosCobre)) {
      addOrTag(
        id: 'cobre_zinco',
        nome: 'Cobre sérico, Ceruloplasmina e Zinco sérico',
        secao: SecaoExame.especificosProtocolo,
        primeiroExame: '4 a 8 semanas',
        periodicidade: '3 a 6 meses',
        tag: 'Peptídeo de Cobre (GHK-Cu)',
      );
    }

    if (categorias.contains(CategoriaSubstancia.eixoGh)) {
      addOrTag(
        id: 'igf1',
        nome: 'IGF-1 (Somatomedina C)',
        secao: SecaoExame.especificosProtocolo,
        primeiroExame: '4 a 8 semanas',
        periodicidade: '3 a 6 meses',
        tag: 'Eixo GH / Secretagogos',
      );
    }

    // =========================================================================
    // C. SEXO BIOLÓGICO: MASCULINO (Zero exames ginecológicos/obstétricos)
    // =========================================================================
    if (input.sexo == SexoBiologico.masculino) {
      if (input.idade >= 18 && input.idade <= 39) {
        addOrTag(
          id: 'espermograma',
          nome: 'Espermograma (opcional / fertilidade)',
          secao: SecaoExame.especificosProtocolo,
          primeiroExame: '3 meses',
          periodicidade: '6 a 12 meses',
          tag: 'Masculino 18-39',
        );
      }
      if (input.idade >= 40) {
        addOrTag(
          id: 'psa',
          nome: 'PSA Total e Livre',
          secao: SecaoExame.laboratoriais,
          primeiroExame: '3 meses',
          periodicidade: '6 a 12 meses',
          tag: 'Masculino 40+',
        );
        addOrTag(
          id: 'urologico_prostata',
          nome:
              'Exame urológico (toque retal) e USG de próstata/vias urinárias',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: '12 meses',
          periodicidade: 'Anual',
          tag: 'Masculino 40+',
        );
        addOrTag(
          id: 'escore_calcio',
          nome: 'Escore de Cálcio Coronariano',
          secao: SecaoExame.cardiologicos,
          primeiroExame: 'Basal',
          periodicidade: '3 a 5 anos',
          tag: 'Masculino 40+',
        );
      }
      if (input.idade >= 50) {
        addOrTag(
          id: 'doppler_carotidas',
          nome: 'Doppler de carótidas e vertebrais',
          secao: SecaoExame.cardiologicos,
          primeiroExame: 'Basal',
          periodicidade: '1 a 2 anos',
          tag: '50+ anos',
        );
        addOrTag(
          id: 'dexa_ossea',
          nome: 'Densitometria óssea (DEXA)',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: '2 anos',
          tag: '50+ anos',
        );
        addOrTag(
          id: 'colonoscopia',
          nome: 'Colonoscopia (ou pesquisa de sangue oculto nas fezes)',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: '5 a 10 anos (ou sangue oculto anual)',
          tag: '50+ anos',
        );
      }
    }

    // =========================================================================
    // D. SEXO BIOLÓGICO: FEMININO (Zero PSA ou exames de próstata)
    // =========================================================================
    if (input.sexo == SexoBiologico.feminino) {
      addOrTag(
        id: 'hormonios_fem',
        nome: 'Progesterona, DHEA-S e Androstenediona',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '6 a 8 semanas',
        periodicidade: '3 a 6 meses',
        tag: 'Feminino',
      );
      addOrTag(
        id: 'beta_hcg',
        nome: 'Beta-hCG (rastreio gestacional)',
        secao: SecaoExame.laboratoriais,
        primeiroExame: 'Basal (antes do início)',
        periodicidade: 'Sempre que houver atraso menstrual',
        tag: 'Segurança Feminina',
      );
      addOrTag(
        id: 'usg_pelvica_mamas',
        nome: 'USG pélvica/transvaginal e USG de mamas',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: '12 meses',
        periodicidade: 'Anual',
        tag: 'Feminino',
      );
      if (input.idade >= 25) {
        addOrTag(
          id: 'papanicolau',
          nome: 'Papanicolau (Preventivo)',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: 'Anual (ou a cada 3 anos após 2 normais)',
          tag: 'Feminino 25+',
        );
      }
      if (input.idade >= 40) {
        addOrTag(
          id: 'mamografia',
          nome: 'Mamografia bilateral',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: 'Anual',
          tag: 'Feminino 40+',
        );
        addOrTag(
          id: 'dexa_ossea',
          nome: 'Densitometria óssea (DEXA)',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: '2 anos',
          tag: 'Feminino 40+',
        );
      }
      if (input.idade >= 50) {
        addOrTag(
          id: 'doppler_carotidas',
          nome: 'Doppler de carótidas e vertebrais',
          secao: SecaoExame.cardiologicos,
          primeiroExame: 'Basal',
          periodicidade: '1 a 2 anos',
          tag: '50+ anos',
        );
        addOrTag(
          id: 'escore_calcio',
          nome: 'Escore de Cálcio Coronariano',
          secao: SecaoExame.cardiologicos,
          primeiroExame: 'Basal',
          periodicidade: '3 a 5 anos',
          tag: '50+ anos',
        );
        addOrTag(
          id: 'colonoscopia',
          nome: 'Colonoscopia (ou pesquisa de sangue oculto nas fezes)',
          secao: SecaoExame.imagemRastreamento,
          primeiroExame: 'Basal',
          periodicidade: '5 a 10 anos (ou sangue oculto anual)',
          tag: '50+ anos',
        );
      }
    }

    // =========================================================================
    // E. EXAMES CONDICIONAIS POR PESO CORPORAL / IMC
    // =========================================================================
    if (perfil == PerfilPonderal.sobrepesoOuObesidade) {
      addOrTag(
        id: 'totg_75g',
        nome: 'Teste Oral de Tolerância à Glicose (TOTG 75g / Curva Glicêmica e Insulínica)',
        secao: SecaoExame.perfilPonderal,
        primeiroExame: 'Basal',
        periodicidade: 'Anual (se houver resistência insulínica)',
        tag: 'Perfil Metabólico',
      );
      addOrTag(
        id: 'fibroscan',
        nome: 'Elastografia Hepática (FibroScan)',
        secao: SecaoExame.perfilPonderal,
        primeiroExame: 'Basal (se esteatose/enzimas alteradas)',
        periodicidade: '1 a 2 anos',
        tag: 'Perfil Metabólico',
      );
      addOrTag(
        id: 'polissonografia',
        nome: 'Polissonografia (rastreio de apneia do sono)',
        secao: SecaoExame.perfilPonderal,
        primeiroExame: 'Basal',
        periodicidade: 'Conforme indicação clínica',
        tag: 'Risco Hematócrito/PA',
      );
      addOrTag(
        id: 'pa_mapa',
        nome: '',
        secao: SecaoExame.cardiologicos,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Peso/IMC',
      );
      addOrTag(
        id: 'apob_lpa',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Peso/IMC',
      );
      addOrTag(
        id: 'inflamatorios',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Peso/IMC',
      );
      addOrTag(
        id: 'renal',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Peso/IMC',
      );
      addOrTag(
        id: 'bioimpedancia_dexa',
        nome: '',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Peso/IMC',
      );
    } else if (perfil == PerfilPonderal.pesoElevadoMassaMuscular) {
      addOrTag(
        id: 'cistatina_c',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Evita falso-positivo da Creatinina',
      );
      addOrTag(
        id: 'bioimpedancia_dexa',
        nome: '',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Alta Massa Muscular',
      );
    } else if (perfil == PerfilPonderal.baixoPeso) {
      addOrTag(
        id: 'proteinas_pre_albumina',
        nome: 'Proteínas Totais e Frações + Pré-albumina',
        secao: SecaoExame.perfilPonderal,
        primeiroExame: 'Basal',
        periodicidade: '3 a 6 meses',
        tag: 'Baixo Peso / IMC < 18,5',
      );
      addOrTag(
        id: 'ferro_transferrina',
        nome: 'Ferro Sérico e Índice de Saturação de Transferrina',
        secao: SecaoExame.perfilPonderal,
        primeiroExame: 'Basal',
        periodicidade: '3 a 6 meses',
        tag: 'Baixo Peso / IMC < 18,5',
      );
      addOrTag(
        id: 'dexa_ossea',
        nome: 'Densitometria óssea (DEXA)',
        secao: SecaoExame.imagemRastreamento,
        primeiroExame: 'Basal',
        periodicidade: '2 anos',
        tag: 'Baixo Peso / IMC < 18,5',
      );
      addOrTag(
        id: 'vitaminas',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Baixo Peso',
      );
      addOrTag(
        id: 'eletrolitos',
        nome: '',
        secao: SecaoExame.laboratoriais,
        primeiroExame: '',
        periodicidade: '',
        tag: 'Prioridade: Baixo Peso',
      );
    }

    // Agrupamento final por seção
    final Map<SecaoExame, List<ExameSugerido>> agrupado = {
      for (final s in SecaoExame.values) s: [],
    };
    for (final exame in mapaUnico.values) {
      agrupado[exame.secao]!.add(exame);
    }
    return agrupado;
  }

  /// Define a validade (em dias) de cada exame para evitar repetições desnecessárias
  static int obterValidadeDias(String id) {
    const validades = {
      'vitaminas': 180,
      'cardio_base': 365,
      'usg_abdome': 365,
      'bioimpedancia_dexa': 180,
      'espermograma': 180,
      'psa': 180,
      'urologico_prostata': 365,
      'escore_calcio': 1095, // 3 anos
      'doppler_carotidas': 365,
      'dexa_ossea': 730, // 2 anos
      'colonoscopia': 1825, // 5 anos
      'usg_pelvica_mamas': 365,
      'papanicolau': 365,
      'mamografia': 365,
      'totg_75g': 365,
      'fibroscan': 365,
      'polissonografia': 730,
    };
    return validades[id] ?? 90; // Padrão: 3 meses (90 dias)
  }

  /// Remove exames que já foram feitos e ainda estão dentro da validade
  static Map<SecaoExame, List<ExameSugerido>> filtrarPendentes(
    Map<SecaoExame, List<ExameSugerido>> recomendacoes,
    Map<String, DateTime> ultimaColetaPorId,
  ) {
    final agora = DateTime.now();
    final Map<SecaoExame, List<ExameSugerido>> resultado = {};

    for (final entry in recomendacoes.entries) {
      resultado[entry.key] = entry.value.where((ex) {
        final ultimaData = ultimaColetaPorId[ex.id];
        if (ultimaData == null) return true; // Nunca feito
        final diasPassados = agora.difference(ultimaData).inDays;
        final validade = obterValidadeDias(ex.id);
        return diasPassados >=
            (validade - 15); // Libera 15 dias antes de vencer
      }).toList();
    }
    return resultado;
  }

  /// Gera texto limpo pronto para copiar/compartilhar com o médico
  static String gerarTextoParaMedico(
    Map<SecaoExame, List<ExameSugerido>> recomendacoes,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('SUGESTÃO DE EXAMES LABORATORIAIS');
    buffer.writeln('Gerado pelo App Controle de Injetáveis\n');

    final titulos = {
      SecaoExame.laboratoriais: '1. EXAMES LABORATORIAIS',
      SecaoExame.especificosProtocolo: '2. ESPECÍFICOS DO PROTOCOLO',
      SecaoExame.perfilPonderal: '3. PERFIL PONDERAL E METABÓLICO',
      SecaoExame.cardiologicos: '4. CARDIOLÓGICOS',
      SecaoExame.imagemRastreamento: '5. IMAGEM E RASTREAMENTO',
    };

    for (final entry in recomendacoes.entries) {
      if (entry.value.isEmpty) continue;
      buffer.writeln(titulos[entry.key]);
      for (final ex in entry.value) {
        buffer.writeln('• ${ex.nome}');
      }
      buffer.writeln('');
    }

    buffer.writeln(
      'Aviso: Lista informativa para discussão médica. Não substitui prescrição ou avaliação profissional.',
    );
    return buffer.toString();
  }
}
