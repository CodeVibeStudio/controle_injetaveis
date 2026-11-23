///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsPt = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$notificacoes$pt notificacoes = Translations$notificacoes$pt.internal(_root);
	late final Translations$erros$pt erros = Translations$erros$pt.internal(_root);
	late final Translations$login$pt login = Translations$login$pt.internal(_root);
	late final Translations$perfil$pt perfil = Translations$perfil$pt.internal(_root);
	late final Translations$guia$pt guia = Translations$guia$pt.internal(_root);
	late final Translations$dashboard$pt dashboard = Translations$dashboard$pt.internal(_root);
	late final Translations$setup$pt setup = Translations$setup$pt.internal(_root);
	late final Translations$formulario$pt formulario = Translations$formulario$pt.internal(_root);
	late final Translations$cronograma$pt cronograma = Translations$cronograma$pt.internal(_root);
	late final Translations$guia_conteudo$pt guia_conteudo = Translations$guia_conteudo$pt.internal(_root);
	late final Translations$biometria$pt biometria = Translations$biometria$pt.internal(_root);
	late final Translations$visualizador$pt visualizador = Translations$visualizador$pt.internal(_root);
	late final Translations$geral$pt geral = Translations$geral$pt.internal(_root);
	late final Translations$calculadora$pt calculadora = Translations$calculadora$pt.internal(_root);
	late final Translations$simulador$pt simulador = Translations$simulador$pt.internal(_root);
	late final Translations$dashboard_alertas$pt dashboard_alertas = Translations$dashboard_alertas$pt.internal(_root);
	late final Translations$regioes$pt regioes = Translations$regioes$pt.internal(_root);
	late final Translations$formulario_extras$pt formulario_extras = Translations$formulario_extras$pt.internal(_root);
	late final Translations$exames$pt exames = Translations$exames$pt.internal(_root);
	late final Translations$complementos$pt complementos = Translations$complementos$pt.internal(_root);
	late final Translations$navegacao$pt navegacao = Translations$navegacao$pt.internal(_root);
	late final Translations$evolucao$pt evolucao = Translations$evolucao$pt.internal(_root);
	late final Translations$cronograma_modal$pt cronograma_modal = Translations$cronograma_modal$pt.internal(_root);
}

// Path: notificacoes
class Translations$notificacoes$pt {
	Translations$notificacoes$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Dia de Injeção! 💉'
	String get titulo_injecao => 'Dia de Injeção! 💉';

	/// pt: 'Hoje é dia de aplicar ${medicamento} (${local}).'
	String corpo_injecao({required Object medicamento, required Object local}) => 'Hoje é dia de aplicar ${medicamento} (${local}).';
}

// Path: erros
class Translations$erros$pt {
	Translations$erros$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Verifique a sua ligação à internet e tente novamente.'
	String get sem_internet => 'Verifique a sua ligação à internet e tente novamente.';

	/// pt: 'Falha ao iniciar o aplicativo'
	String get falha_app => 'Falha ao iniciar o aplicativo';
}

// Path: login
class Translations$login$pt {
	Translations$login$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Controle de Injetáveis'
	String get titulo => 'Controle de Injetáveis';

	/// pt: 'Email'
	String get email => 'Email';

	/// pt: 'Palavra-passe'
	String get senha => 'Palavra-passe';

	/// pt: 'ENTRAR'
	String get entrar => 'ENTRAR';

	/// pt: 'CRIAR NOVA CONTA'
	String get criar_conta => 'CRIAR NOVA CONTA';

	/// pt: 'Esqueci minha senha'
	String get esqueci_senha => 'Esqueci minha senha';
}

// Path: perfil
class Translations$perfil$pt {
	Translations$perfil$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Meu Perfil'
	String get titulo => 'Meu Perfil';

	/// pt: 'Idioma / Language'
	String get idioma => 'Idioma / Language';

	/// pt: 'Dados Biológicos'
	String get dados_biologicos => 'Dados Biológicos';

	/// pt: 'Estas informações são essenciais para que o aplicativo cruze a sua idade, sexo biológico e peso, gerando painéis de exames clínicos precisos e totalmente seguros.'
	String get descricao_biologicos => 'Estas informações são essenciais para que o aplicativo cruze a sua idade, sexo biológico e peso, gerando painéis de exames clínicos precisos e totalmente seguros.';

	/// pt: 'Nome Completo'
	String get nome => 'Nome Completo';

	/// pt: 'Peso (kg)'
	String get peso => 'Peso (kg)';

	/// pt: 'Sexo Biológico'
	String get sexo => 'Sexo Biológico';

	/// pt: 'Data de Nascimento (DD/MM/AAAA)'
	String get data_nascimento => 'Data de Nascimento (DD/MM/AAAA)';

	/// pt: 'SALVAR PERFIL'
	String get btn_salvar => 'SALVAR PERFIL';

	/// pt: 'Perfil salvo com sucesso!'
	String get msg_sucesso => 'Perfil salvo com sucesso!';

	/// pt: 'Erro ao salvar: '
	String get msg_erro => 'Erro ao salvar: ';

	/// pt: 'Por favor, selecione o sexo biológico.'
	String get erro_sexo => 'Por favor, selecione o sexo biológico.';

	/// pt: 'Digite uma data de nascimento válida (DD/MM/AAAA).'
	String get erro_data => 'Digite uma data de nascimento válida (DD/MM/AAAA).';
}

// Path: guia
class Translations$guia$pt {
	Translations$guia$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Guia e Termos de Uso'
	String get titulo => 'Guia e Termos de Uso';

	/// pt: '⬇️ Role a tela até o final para habilitar o aceite.'
	String get aviso_scroll => '⬇️ Role a tela até o final para habilitar o aceite.';

	/// pt: 'Declaro que li as instruções, estou ciente dos riscos médicos e aceito os Termos de Responsabilidade e Isenção.'
	String get texto_aceite => 'Declaro que li as instruções, estou ciente dos riscos médicos e aceito os Termos de Responsabilidade e Isenção.';

	/// pt: 'ESTOU CIENTE E ACEITO'
	String get btn_aceitar => 'ESTOU CIENTE E ACEITO';

	/// pt: 'Termos aceitos e registrados. Uso liberado!'
	String get msg_sucesso => 'Termos aceitos e registrados. Uso liberado!';

	/// pt: 'Erro ao registrar: '
	String get msg_erro => 'Erro ao registrar: ';

	/// pt: 'Sair do App'
	String get tooltip_sair => 'Sair do App';
}

// Path: dashboard
class Translations$dashboard$pt {
	Translations$dashboard$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Tratamento'
	String get titulo => 'Tratamento';

	/// pt: 'Resumo Clínico'
	String get resumo_clinico => 'Resumo Clínico';

	/// pt: 'Próxima Aplicação'
	String get proxima_aplicacao => 'Próxima Aplicação';

	/// pt: 'Última Aplicação'
	String get ultima_aplicacao => 'Última Aplicação';

	/// pt: 'GERIR MEDICAMENTOS'
	String get gerir_medicamentos => 'GERIR MEDICAMENTOS';

	/// pt: 'Nenhuma aplicação futura agendada.'
	String get nenhuma_aplicacao => 'Nenhuma aplicação futura agendada.';

	/// pt: 'Nenhum histórico de aplicações.'
	String get nenhum_historico => 'Nenhum histórico de aplicações.';
}

// Path: setup
class Translations$setup$pt {
	Translations$setup$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Banco de Medicamentos'
	String get titulo => 'Banco de Medicamentos';

	/// pt: 'NOVO'
	String get btn_novo => 'NOVO';

	/// pt: 'Nenhum medicamento configurado.'
	String get nenhum_medicamento => 'Nenhum medicamento configurado.';

	/// pt: 'Simulador de Ciclos'
	String get simulador_titulo => 'Simulador de Ciclos';

	/// pt: 'Planeie os seus protocolos e visualize a libertação no sangue.'
	String get simulador_subtitulo => 'Planeie os seus protocolos e visualize a libertação no sangue.';
}

// Path: formulario
class Translations$formulario$pt {
	Translations$formulario$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Novo Medicamento'
	String get titulo_novo => 'Novo Medicamento';

	/// pt: 'Editar Medicamento'
	String get titulo_editar => 'Editar Medicamento';

	/// pt: 'ATUALIZAR MEDICAMENTO'
	String get btn_atualizar => 'ATUALIZAR MEDICAMENTO';

	/// pt: 'GUARDAR MEDICAMENTO'
	String get btn_guardar => 'GUARDAR MEDICAMENTO';

	/// pt: 'ENCERRAR TRATAMENTO (ARQUIVAR)'
	String get btn_arquivar => 'ENCERRAR TRATAMENTO (ARQUIVAR)';

	/// pt: 'Mix Selecionado'
	String get campo_mix => 'Mix Selecionado';

	/// pt: 'Medicamento (Digitar)'
	String get campo_medicamento => 'Medicamento (Digitar)';

	/// pt: 'Catálogo (Pesquisar...)'
	String get campo_catalogo => 'Catálogo (Pesquisar...)';

	/// pt: 'NOVO'
	String get btn_novo_catalogo => 'NOVO';

	/// pt: 'CATÁLOGO'
	String get btn_abrir_catalogo => 'CATÁLOGO';

	/// pt: 'CRIAR MIX'
	String get btn_criar_mix => 'CRIAR MIX';

	/// pt: 'MODO MIX ATIVADO'
	String get modo_mix_titulo => 'MODO MIX ATIVADO';

	/// pt: 'Pode alterar o Intervalo, Seringa e Locais livremente. Para alterar as DOSES base, clique em DESMEMBRAR MIX.'
	String get modo_mix_editar => 'Pode alterar o Intervalo, Seringa e Locais livremente. Para alterar as DOSES base, clique em DESMEMBRAR MIX.';

	/// pt: 'O Intervalo, Seringa e Região foram importados automaticamente.'
	String get modo_mix_novo => 'O Intervalo, Seringa e Região foram importados automaticamente.';

	/// pt: 'Intervalo (dias)'
	String get campo_intervalo => 'Intervalo (dias)';

	/// pt: 'Qtd. Frascos'
	String get qtd_curto => 'Qtd. Frascos';

	/// pt: 'Vol. (mL)'
	String get vol_curto => 'Vol. (mL)';

	/// pt: 'Conc. (mg/mL)'
	String get conc_curto => 'Conc. (mg/mL)';

	/// pt: 'Dose Semanal'
	String get campo_dose_semanal => 'Dose Semanal';

	/// pt: 'Unidade'
	String get campo_unidade => 'Unidade';

	/// pt: 'Dose Calculada por Aplicação:'
	String get resultado_dose => 'Dose Calculada por Aplicação:';

	/// pt: 'Aguardando valores...'
	String get resultado_vazio => 'Aguardando valores...';

	/// pt: 'Seringa (UI)'
	String get campo_seringa => 'Seringa (UI)';

	/// pt: 'Locais do Rodízio'
	String get campo_locais => 'Locais do Rodízio';

	/// pt: 'Data de Início'
	String get campo_data => 'Data de Início';

	/// pt: 'Hora da Aplicação'
	String get campo_hora => 'Hora da Aplicação';

	/// pt: 'Intervalo (Dias)'
	String get freq_intervalo => 'Intervalo (Dias)';

	/// pt: 'Dias da Semana'
	String get freq_dias_semana => 'Dias da Semana';

	Map<String, String> get dias_semana => {
		'1': 'Seg',
		'2': 'Ter',
		'3': 'Qua',
		'4': 'Qui',
		'5': 'Sex',
		'6': 'Sáb',
		'7': 'Dom',
	};
}

// Path: cronograma
class Translations$cronograma$pt {
	Translations$cronograma$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Cronograma: ${nome}'
	String titulo({required Object nome}) => 'Cronograma: ${nome}';

	/// pt: 'GERAR NOVO CICLO'
	String get btn_gerar_novo => 'GERAR NOVO CICLO';

	/// pt: 'Nenhum cronograma gerado ainda.'
	String get nenhum_gerado => 'Nenhum cronograma gerado ainda.';

	/// pt: 'GERAR CRONOGRAMA'
	String get btn_gerar => 'GERAR CRONOGRAMA';

	/// pt: 'Seringa: ${seringa} UI | Intervalo: ${intervalo} dias'
	String info_seringa({required Object seringa, required Object intervalo}) => 'Seringa: ${seringa} UI | Intervalo: ${intervalo} dias';
}

// Path: guia_conteudo
class Translations$guia_conteudo$pt {
	Translations$guia_conteudo$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: '⚖️ TERMOS DE RESPONSABILIDADE E PRIVACIDADE'
	String get termos_titulo => '⚖️ TERMOS DE RESPONSABILIDADE E PRIVACIDADE';

	/// pt: 'Ao utilizar o Controle de Injetáveis, o usuário declara estar plenamente ciente de que: 1. O usuário assume TOTAL e exclusiva responsabilidade pelas doses, misturas (Mix), saldos de frasco e protocolos gerados. 2. A CodeVibe Studio NÃO se responsabiliza por erros de preenchimento ou cálculos equivocados gerados por dados incorretos. 3. O "Painel de Exames", a "Evolução Clínica" (alertas, semáforo e gráficos) e o "Simulador de Ciclos" são estimativas informativas e matemáticas. NÃO têm valor de diagnóstico, prescrição ou aconselhamento médico. 4. Privacidade (LGPD): Seus dados de saúde são armazenados de forma privada com isolamento individual de acesso e nunca são vendidos ou compartilhados com terceiros. Você pode editar ou excluir seus registros a qualquer momento. 5. O usuário isenta os criadores de qualquer complicação clínica decorrente do uso desta ferramenta organizacional.'
	String get termos_texto => 'Ao utilizar o Controle de Injetáveis, o usuário declara estar plenamente ciente de que:\n\n1. O usuário assume TOTAL e exclusiva responsabilidade pelas doses, misturas (Mix), saldos de frasco e protocolos gerados.\n2. A CodeVibe Studio NÃO se responsabiliza por erros de preenchimento ou cálculos equivocados gerados por dados incorretos.\n3. O "Painel de Exames", a "Evolução Clínica" (alertas, semáforo e gráficos) e o "Simulador de Ciclos" são estimativas informativas e matemáticas. NÃO têm valor de diagnóstico, prescrição ou aconselhamento médico.\n4. Privacidade (LGPD): Seus dados de saúde são armazenados de forma privada com isolamento individual de acesso e nunca são vendidos ou compartilhados com terceiros. Você pode editar ou excluir seus registros a qualquer momento.\n5. O usuário isenta os criadores de qualquer complicação clínica decorrente do uso desta ferramenta organizacional.';

	/// pt: '🚨 AVISO MÉDICO IMPORTANTE'
	String get aviso_titulo => '🚨 AVISO MÉDICO IMPORTANTE';

	/// pt: 'Este aplicativo é exclusivamente uma ferramenta de apoio logístico e matemático. ELE NÃO SUBSTITUI A ORIENTAÇÃO MÉDICA. • O aplicativo não receita, não prescreve e não recomenda tratamentos. • Diante de qualquer marcador alterado na Evolução Clínica, leve o relatório ao seu médico para avaliação. • Em caso de dor extrema, febre, vermelhidão intensa, inchaço, falta de ar ou qualquer mal-estar após uma aplicação, PROCURE UMA EMERGÊNCIA HOSPITALAR IMEDIATAMENTE ou contate o seu médico. • Nunca inicie, titule ou altere dosagens sem o conhecimento e autorização do seu profissional de saúde.'
	String get aviso_texto => 'Este aplicativo é exclusivamente uma ferramenta de apoio logístico e matemático. ELE NÃO SUBSTITUI A ORIENTAÇÃO MÉDICA.\n\n• O aplicativo não receita, não prescreve e não recomenda tratamentos.\n• Diante de qualquer marcador alterado na Evolução Clínica, leve o relatório ao seu médico para avaliação.\n• Em caso de dor extrema, febre, vermelhidão intensa, inchaço, falta de ar ou qualquer mal-estar após uma aplicação, PROCURE UMA EMERGÊNCIA HOSPITALAR IMEDIATAMENTE ou contate o seu médico.\n• Nunca inicie, titule ou altere dosagens sem o conhecimento e autorização do seu profissional de saúde.';

	/// pt: '🧼 HIGIENE E ASSEPSIA'
	String get higiene_titulo => '🧼 HIGIENE E ASSEPSIA';

	/// pt: 'A falta de higiene pode causar infecções graves e abcessos. Siga rigorosamente: • Lave as mãos com água e sabão antes de tocar nos materiais. • Limpe a borracha do bujão com algodão e Álcool 70%. • Faça a assepsia da pele com Álcool 70% e deixe secar naturalmente antes de perfurar. • Utilize APENAS seringas e agulhas estéreis, de uso único (descartáveis). • Descarte o material perfurocortante em recipiente rígido adequado (Descarpack).'
	String get higiene_texto => 'A falta de higiene pode causar infecções graves e abcessos. Siga rigorosamente:\n\n• Lave as mãos com água e sabão antes de tocar nos materiais.\n• Limpe a borracha do bujão com algodão e Álcool 70%.\n• Faça a assepsia da pele com Álcool 70% e deixe secar naturalmente antes de perfurar.\n• Utilize APENAS seringas e agulhas estéreis, de uso único (descartáveis).\n• Descarte o material perfurocortante em recipiente rígido adequado (Descarpack).';

	/// pt: '📱 COMO USAR O APLICATIVO'
	String get como_usar_titulo => '📱 COMO USAR O APLICATIVO';

	/// pt: '• Início (Resumo Clínico): Prioridade dinâmica que destaca sua Próxima e Última Aplicação no topo, subindo alertas de exame apenas quando exigirem ação. • Banco de Medicamentos e Cronograma Inteligente: Cadastre seus frascos, locais de rodízio e gere ciclos por Frasco inteiro, Semanas, Meses ou Injeções. Ao gerar um novo ciclo, o app desconta automaticamente o volume já aplicado, permitindo continuar no frasco atual (ideal para titulação de dose) ou iniciar um frasco novo. • Evolução Clínica: Registre exames de sangue e bioimpedância/medidas. Acompanhe alertas de marcadores fora da faixa, tabela comparativa com semáforo colorido, gráficos com faixa de referência e envie relatórios limpos por e-mail ou cópia para o seu médico. • Calculadoras e Simulador de Ciclos: Use o Assistente de Reconstituição, a Seringa Virtual e o Simulador Farmacocinético para visualizar curvas teóricas de liberação. • Mix Seguro: Agrupe compostos compatíveis na mesma seringa com soma automática de volumes.'
	String get como_usar_texto => '• Início (Resumo Clínico): Prioridade dinâmica que destaca sua Próxima e Última Aplicação no topo, subindo alertas de exame apenas quando exigirem ação.\n\n• Banco de Medicamentos e Cronograma Inteligente: Cadastre seus frascos, locais de rodízio e gere ciclos por Frasco inteiro, Semanas, Meses ou Injeções. Ao gerar um novo ciclo, o app desconta automaticamente o volume já aplicado, permitindo continuar no frasco atual (ideal para titulação de dose) ou iniciar um frasco novo.\n\n• Evolução Clínica: Registre exames de sangue e bioimpedância/medidas. Acompanhe alertas de marcadores fora da faixa, tabela comparativa com semáforo colorido, gráficos com faixa de referência e envie relatórios limpos por e-mail ou cópia para o seu médico.\n\n• Calculadoras e Simulador de Ciclos: Use o Assistente de Reconstituição, a Seringa Virtual e o Simulador Farmacocinético para visualizar curvas teóricas de liberação.\n\n• Mix Seguro: Agrupe compostos compatíveis na mesma seringa com soma automática de volumes.';

	/// pt: '🧬 CÉREBRO ANALÍTICO E EXAMES'
	String get cerebro_titulo => '🧬 CÉREBRO ANALÍTICO E EXAMES';

	/// pt: 'O aplicativo possui um Motor Preditivo de segurança: • Perfil Biométrico: Cruza sexo biológico, idade, peso e protocolo ativo para sugerir exames relevantes para discussão médica, com envio direto por e-mail ou cópia. • Controle de Repetição: Ao confirmar a coleta, o histórico salva os exames realizados e oculta automaticamente o que ainda está dentro da validade. • Protocolo Pré-Exame: Antes da coleta agendada, o sistema libera um Checklist Clínico (Jejum, Pausa nos Treinos/CPK, Repouso Pélvico, etc.) para evitar falsos positivos. • Janela de Biomarcadores: A primeira janela ideal é sugerida 45 dias após o início do protocolo, com revisões sugeridas a cada 90 dias.'
	String get cerebro_texto => 'O aplicativo possui um Motor Preditivo de segurança:\n\n• Perfil Biométrico: Cruza sexo biológico, idade, peso e protocolo ativo para sugerir exames relevantes para discussão médica, com envio direto por e-mail ou cópia.\n\n• Controle de Repetição: Ao confirmar a coleta, o histórico salva os exames realizados e oculta automaticamente o que ainda está dentro da validade.\n\n• Protocolo Pré-Exame: Antes da coleta agendada, o sistema libera um Checklist Clínico (Jejum, Pausa nos Treinos/CPK, Repouso Pélvico, etc.) para evitar falsos positivos.\n\n• Janela de Biomarcadores: A primeira janela ideal é sugerida 45 dias após o início do protocolo, com revisões sugeridas a cada 90 dias.';

	/// pt: '🔔 MOTOR DE NOTIFICAÇÕES NATIVAS'
	String get notificacoes_titulo => '🔔 MOTOR DE NOTIFICAÇÕES NATIVAS';

	/// pt: 'Para garantir o máximo desempenho e poupar a bateria, o nosso motor adota arquitetura silenciosa: • Fila Anti-Spam: Aparelhos recentes limitam alarmes por aplicativo. Por isso, o app agenda automaticamente as próximas 60 aplicações e renova a fila conforme você marca as doses concluídas. • Dica para Android: Para evitar atrasos ou bloqueios do sistema, mantenha em Configurações → Aplicativos → Controle de Injetáveis a Bateria como "Irrestrito" e "Alarmes e lembretes" permitidos.'
	String get notificacoes_texto => 'Para garantir o máximo desempenho e poupar a bateria, o nosso motor adota arquitetura silenciosa:\n\n• Fila Anti-Spam: Aparelhos recentes limitam alarmes por aplicativo. Por isso, o app agenda automaticamente as próximas 60 aplicações e renova a fila conforme você marca as doses concluídas.\n\n• Dica para Android: Para evitar atrasos ou bloqueios do sistema, mantenha em Configurações → Aplicativos → Controle de Injetáveis a Bateria como "Irrestrito" e "Alarmes e lembretes" permitidos.';

	/// pt: '💉 GUIA DE SERINGAS E AGULHAS'
	String get seringas_titulo => '💉 GUIA DE SERINGAS E AGULHAS';

	/// pt: 'Entenda o material adequado para cada aplicação:'
	String get seringas_subtitulo => 'Entenda o material adequado para cada aplicação:';

	/// pt: 'Visualizar Agulhas e Seringas'
	String get seringas_btn => 'Visualizar Agulhas e Seringas';

	/// pt: '💉 AGULHAS RECOMENDADAS:'
	String get seringas_texto1 => '💉 AGULHAS RECOMENDADAS:';

	/// pt: '• Subcutânea (SC - Gordura): Agulhas curtas e finas, ex: 13x0.45mm ou 13x0.3mm (marrom/cinza). Aplicada em ângulo de 90° ou 45° dependendo do tecido adiposo. • Intramuscular (IM - Músculo): Agulhas longas para alcançar o músculo, ex: 25x0.7mm ou 30x0.7mm (preta/azul) e para volumes maiores 25x0.8mm (verde). Aplicar em ângulo de 90°.'
	String get seringas_texto2 => '• Subcutânea (SC - Gordura): Agulhas curtas e finas, ex: 13x0.45mm ou 13x0.3mm (marrom/cinza). Aplicada em ângulo de 90° ou 45° dependendo do tecido adiposo.\n• Intramuscular (IM - Músculo): Agulhas longas para alcançar o músculo, ex: 25x0.7mm ou 30x0.7mm (preta/azul) e para volumes maiores 25x0.8mm (verde). Aplicar em ângulo de 90°.';

	/// pt: '🧪 SERINGAS E ESCALAS:'
	String get seringas_texto3 => '🧪 SERINGAS E ESCALAS:';

	/// pt: '• Seringas de Insulina (100 UI = 1 mL): Escala detalhada. 10 UI equivalem a 0.1 mL. Ideal para microdoses subcutâneas de alta precisão. • Seringas de 3 mL ou 5 mL: Usadas para aplicações intramusculares que requerem maior volume de diluente ou óleo.'
	String get seringas_texto4 => '• Seringas de Insulina (100 UI = 1 mL): Escala detalhada. 10 UI equivalem a 0.1 mL. Ideal para microdoses subcutâneas de alta precisão.\n• Seringas de 3 mL ou 5 mL: Usadas para aplicações intramusculares que requerem maior volume de diluente ou óleo.';

	/// pt: '🗺️ MAPA DE PONTOS DE APLICAÇÃO'
	String get mapas_titulo => '🗺️ MAPA DE PONTOS DE APLICAÇÃO';

	/// pt: 'ATUALIZAÇÃO CLÍNICA (IM)'
	String get mapas_alerta_titulo => 'ATUALIZAÇÃO CLÍNICA (IM)';

	/// pt: '✅ O Ventro Glúteo é hoje considerado o padrão-ouro e o local mais seguro para injeções intramusculares, por estar totalmente livre de grandes vasos e nervos. ❌ O antigo "Dorso Glúteo" (quadrante superior externo) está a ser abandonado na prática clínica atual. Ele oferece alto risco de lesão do nervo ciático e apresenta mais riscos do que benefícios.'
	String get mapas_alerta_texto => '✅ O Ventro Glúteo é hoje considerado o padrão-ouro e o local mais seguro para injeções intramusculares, por estar totalmente livre de grandes vasos e nervos.\n\n❌ O antigo "Dorso Glúteo" (quadrante superior externo) está a ser abandonado na prática clínica atual. Ele oferece alto risco de lesão do nervo ciático e apresenta mais riscos do que benefícios.';

	/// pt: 'Clique na região para visualizar os locais exatos e fazer o rodízio correto:'
	String get mapas_subtitulo => 'Clique na região para visualizar os locais exatos e fazer o rodízio correto:';

	/// pt: 'Pontos da Barriga (8 Pontos)'
	String get mapas_btn1 => 'Pontos da Barriga (8 Pontos)';

	/// pt: 'Pontos dos Flancos (9 Pontos)'
	String get mapas_btn2 => 'Pontos dos Flancos (9 Pontos)';

	/// pt: 'Pontos dos Glúteos (Ventro Glúteo / Dorso)'
	String get mapas_btn3 => 'Pontos dos Glúteos (Ventro Glúteo / Dorso)';

	/// pt: 'Pontos da Coxa (Vasto Lateral)'
	String get mapas_btn4 => 'Pontos da Coxa (Vasto Lateral)';

	/// pt: 'Pontos do Deltoide (Braço)'
	String get mapas_btn5 => 'Pontos do Deltoide (Braço)';

	/// pt: '📖 DICIONÁRIO MAROMBA E CLÍNICO'
	String get dicionario_titulo => '📖 DICIONÁRIO MAROMBA E CLÍNICO';

	/// pt: 'O dialeto das academias e dos tratamentos, traduzido de forma direta:'
	String get dicionario_subtitulo => 'O dialeto das academias e dos tratamentos, traduzido de forma direta:';

	/// pt: '💪 SOBRE O SHAPE (CORPO)'
	String get dic_cat1 => '💪 SOBRE O SHAPE (CORPO)';

	/// pt: '🏋️ SOBRE O TREINO'
	String get dic_cat2 => '🏋️ SOBRE O TREINO';

	/// pt: '🥦 SOBRE A DIETA'
	String get dic_cat3 => '🥦 SOBRE A DIETA';

	/// pt: '💉 SOBRE OS INJETÁVEIS E "ADITIVOS"'
	String get dic_cat4 => '💉 SOBRE OS INJETÁVEIS E "ADITIVOS"';
}

// Path: biometria
class Translations$biometria$pt {
	Translations$biometria$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Desbloqueie para aceder aos seus dados clínicos'
	String get motivo => 'Desbloqueie para aceder aos seus dados clínicos';

	/// pt: 'Biometria cancelada. Tente novamente ou use a senha do App.'
	String get erro_cancelado => 'Biometria cancelada. Tente novamente ou use a senha do App.';

	/// pt: 'Erro no sensor biométrico.'
	String get erro_sensor => 'Erro no sensor biométrico.';

	/// pt: 'Aplicativo Bloqueado'
	String get titulo => 'Aplicativo Bloqueado';

	/// pt: 'Protegendo o seu histórico clínico...'
	String get subtitulo => 'Protegendo o seu histórico clínico...';

	/// pt: 'USAR BIOMETRIA'
	String get btn_biometria => 'USAR BIOMETRIA';

	/// pt: 'ACESSAR COM SENHA DO APP'
	String get btn_senha => 'ACESSAR COM SENHA DO APP';
}

// Path: visualizador
class Translations$visualizador$pt {
	Translations$visualizador$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Imagem não encontrada.'
	String get erro_imagem => 'Imagem não encontrada.';
}

// Path: geral
class Translations$geral$pt {
	Translations$geral$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Sim'
	String get sim => 'Sim';

	/// pt: 'Não'
	String get nao => 'Não';

	/// pt: 'OK'
	String get ok => 'OK';

	/// pt: 'Cancelar'
	String get cancelar => 'Cancelar';
}

// Path: calculadora
class Translations$calculadora$pt {
	Translations$calculadora$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Calculadora de Injetáveis'
	String get titulo => 'Calculadora de Injetáveis';

	/// pt: 'Limpar Tudo'
	String get limpar => 'Limpar Tudo';

	/// pt: '⚠️ Ferramenta educativa. Confirme doses com um profissional de saúde.'
	String get aviso => '⚠️ Ferramenta educativa. Confirme doses com um profissional de saúde.';

	/// pt: 'Volume Frasco (mL)'
	String get volume => 'Volume Frasco (mL)';

	/// pt: 'Concentração'
	String get concentracao => 'Concentração';

	/// pt: 'Assistente de Reconstituição'
	String get assistente => 'Assistente de Reconstituição';

	/// pt: 'Dose Semanal'
	String get dose_semanal => 'Dose Semanal';

	/// pt: 'Intervalo (dias)'
	String get intervalo => 'Intervalo (dias)';

	/// pt: 'Unidade'
	String get unidade => 'Unidade';

	/// pt: 'Seringa (UI)'
	String get seringa => 'Seringa (UI)';

	/// pt: 'Resultados'
	String get resultados => 'Resultados';

	/// pt: 'Faça as seleções acima para calcular a quantidade de fluido aspirado para a dose desejada.'
	String get selecoes_vazias => 'Faça as seleções acima para calcular a quantidade de fluido aspirado para a dose desejada.';

	/// pt: 'Para a dose de '
	String get res_para_dose => 'Para a dose de ';

	/// pt: ', aspire o conteúdo da seringa até: '
	String get res_aspire => ', aspire o conteúdo da seringa até: ';

	/// pt: ' mL ou '
	String get res_ou => ' mL ou ';

	/// pt: ' unidades.'
	String get res_unidades => ' unidades.';

	/// pt: 'Concentração do frasco reconstituído: '
	String get res_conc => 'Concentração do frasco reconstituído:\n';

	/// pt: 'O frasco contém '
	String get res_contem => 'O frasco contém ';

	/// pt: ' doses'
	String get res_doses => ' doses';

	/// pt: ' de '
	String get res_de => ' de ';

	/// pt: ' cada.'
	String get res_cada => ' cada.';

	/// pt: 'Calculadora de Diluição'
	String get diluicao_titulo => 'Calculadora de Diluição';

	/// pt: 'Deseja calcular a reconstituição ou descobrir a concentração de um frasco? Isto calculará automaticamente a Concentração cruzando a Massa Total da substância com a quantidade de líquido.'
	String get diluicao_desc => 'Deseja calcular a reconstituição ou descobrir a concentração de um frasco?\n\nIsto calculará automaticamente a Concentração cruzando a Massa Total da substância com a quantidade de líquido.';

	/// pt: 'Cálculo PASSO 1 DE 2:'
	String get passo1 => 'Cálculo\nPASSO 1 DE 2:';

	/// pt: 'Total da Substância (mg)'
	String get passo1_label => 'Total da Substância (mg)';

	/// pt: 'Ex: 5 (para frascos de 5mg)'
	String get passo1_hint => 'Ex: 5 (para frascos de 5mg)';

	/// pt: 'Cálculo PASSO 2 DE 2:'
	String get passo2 => 'Cálculo\nPASSO 2 DE 2:';

	/// pt: 'Volume do Líquido (mL)'
	String get passo2_label => 'Volume do Líquido (mL)';

	/// pt: 'Quantos mL totais tem o frasco?'
	String get passo2_hint => 'Quantos mL totais tem o frasco?';

	/// pt: 'Diluição calculada com sucesso!'
	String get msg_sucesso => 'Diluição calculada com sucesso!';

	/// pt: 'Valores inválidos.'
	String get msg_invalido => 'Valores inválidos.';

	/// pt: 'Simulador de Liberação (Farmacocinética)'
	String get simulador_titulo => 'Simulador de Liberação (Farmacocinética)';

	/// pt: 'Teste: 2 injeções de 250mg de Enantato (Dia 0 e Dia 7)'
	String get simulador_desc => 'Teste: 2 injeções de 250mg de Enantato (Dia 0 e Dia 7)';
}

// Path: simulador
class Translations$simulador$pt {
	Translations$simulador$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Simulador de Ciclos'
	String get titulo => 'Simulador de Ciclos';

	/// pt: 'Elabore o seu protocolo'
	String get subtitulo => 'Elabore o seu protocolo';

	/// pt: 'Nome do Ciclo (opcional)'
	String get nome_ciclo => 'Nome do Ciclo (opcional)';

	/// pt: 'Duração'
	String get duracao => 'Duração';

	/// pt: '${s} semanas'
	String semanas({required Object s}) => '${s} semanas';

	/// pt: 'Composto(s)'
	String get composto_title => 'Composto(s)';

	/// pt: 'Composto #${n}'
	String composto_n({required Object n}) => 'Composto #${n}';

	/// pt: 'Remover Composto'
	String get remover => 'Remover Composto';

	/// pt: 'Dose (mg)'
	String get dose => 'Dose (mg)';

	/// pt: 'Categoria'
	String get categoria => 'Categoria';

	/// pt: 'Selecione o composto'
	String get selecione => 'Selecione o composto';

	/// pt: 'Esquema de dosagem (Agendar)'
	String get esquema => 'Esquema de dosagem (Agendar)';

	/// pt: 'Diariamente'
	String get freq_1 => 'Diariamente';

	/// pt: 'Um dia sim, um dia não'
	String get freq_2 => 'Um dia sim, um dia não';

	/// pt: 'A cada 3 dias'
	String get freq_3 => 'A cada 3 dias';

	/// pt: 'A cada 4 dias'
	String get freq_4 => 'A cada 4 dias';

	/// pt: 'A cada 5 dias'
	String get freq_5 => 'A cada 5 dias';

	/// pt: 'A cada 7 dias (1x/sem)'
	String get freq_7 => 'A cada 7 dias (1x/sem)';

	/// pt: 'A cada 14 dias'
	String get freq_14 => 'A cada 14 dias';

	/// pt: 'De (Semana)'
	String get de_sem => 'De (Semana)';

	/// pt: 'Até (Semana)'
	String get ate_sem => 'Até (Semana)';

	/// pt: 'Semana ${s}'
	String semana_n({required Object s}) => 'Semana ${s}';

	/// pt: 'Simular'
	String get btn_trama => 'Simular';

	/// pt: 'Adicionar Composto'
	String get btn_adicionar => 'Adicionar Composto';

	/// pt: 'Reiniciar'
	String get btn_reiniciar => 'Reiniciar';

	/// pt: 'Liberação Diária de Fármaco Ativo (mg)'
	String get grafico_titulo => 'Liberação Diária de Fármaco Ativo (mg)';

	/// pt: 'Nota: A linha representa a miligramagem efetiva libertada no sangue a cada dia, aplicando o princípio da superposição (acúmulo) e o peso do éster.'
	String get grafico_nota => 'Nota: A linha representa a miligramagem efetiva libertada no sangue a cada dia, aplicando o princípio da superposição (acúmulo) e o peso do éster.';
}

// Path: dashboard_alertas
class Translations$dashboard_alertas$pt {
	Translations$dashboard_alertas$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Atenção! Coleta em ${dias} dia(s)'
	String atencao_coleta({required Object dias}) => 'Atenção! Coleta em ${dias} dia(s)';

	/// pt: 'O seu período de proteção biométrica começou. Abra o checklist clínico para não invalidar os resultados.'
	String get texto_protecao => 'O seu período de proteção biométrica começou. Abra o checklist clínico para não invalidar os resultados.';

	/// pt: 'ABRIR CHECKLIST CLÍNICO'
	String get btn_abrir_checklist => 'ABRIR CHECKLIST CLÍNICO';

	/// pt: 'Coleta Agendada'
	String get coleta_agendada => 'Coleta Agendada';

	/// pt: 'Você possui exames agendados para daqui a ${dias} dias (${data}).'
	String texto_exames({required Object dias, required Object data}) => 'Você possui exames agendados para daqui a ${dias} dias (${data}).';

	/// pt: 'VER PAINEL E REAGENDAR'
	String get btn_ver_painel => 'VER PAINEL E REAGENDAR';

	/// pt: 'Mix: '
	String get label_mix => 'Mix: ';

	/// pt: 'Data: '
	String get label_data => 'Data: ';

	/// pt: 'Local: '
	String get label_local => 'Local: ';

	/// pt: 'Dose: '
	String get label_dose => 'Dose: ';
}

// Path: regioes
class Translations$regioes$pt {
	Translations$regioes$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Selecione os Locais'
	String get selecione => 'Selecione os Locais';

	/// pt: 'Nenhum'
	String get nenhum => 'Nenhum';

	/// pt: '${qtd} selecionado(s)'
	String selecionados({required Object qtd}) => '${qtd} selecionado(s)';

	/// pt: 'CONFIRMAR'
	String get confirmar => 'CONFIRMAR';

	/// pt: 'Cancelar'
	String get cancelar => 'Cancelar';

	/// pt: 'Ventro Glúteo (IM)'
	String get ventro_gluteo => 'Ventro Glúteo (IM)';

	/// pt: 'Vasto Lateral (IM)'
	String get vasto_lateral => 'Vasto Lateral (IM)';

	/// pt: 'Deltoide (IM)'
	String get deltoide => 'Deltoide (IM)';

	/// pt: 'Glúteo Superior (IM)'
	String get gluteo_superior => 'Glúteo Superior (IM)';

	/// pt: 'Barriga (SC)'
	String get barriga => 'Barriga (SC)';

	/// pt: 'Flanco (SC)'
	String get flanco => 'Flanco (SC)';

	/// pt: 'Perna Anterior (SC)'
	String get perna_anterior => 'Perna Anterior (SC)';

	/// pt: 'Braço Tríceps (SC)'
	String get braco_triceps => 'Braço Tríceps (SC)';
}

// Path: formulario_extras
class Translations$formulario_extras$pt {
	Translations$formulario_extras$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Preenchimento Seguro'
	String get dialogo_rotulo_titulo => 'Preenchimento Seguro';

	/// pt: 'Deseja usar a Calculadora automática de Rótulo? Isso evita erros na conversão de medicamentos como a Tirzepatida ou Semaglutida.'
	String get dialogo_rotulo_desc => 'Deseja usar a Calculadora automática de Rótulo?\n\nIsso evita erros na conversão de medicamentos como a Tirzepatida ou Semaglutida.';

	/// pt: '30 UI (0.3 mL)'
	String get seringa_30 => '30 UI (0.3 mL)';

	/// pt: '50 UI (0.5 mL)'
	String get seringa_50 => '50 UI (0.5 mL)';

	/// pt: '100 UI (1 mL)'
	String get seringa_100 => '100 UI (1 mL)';

	/// pt: 'Seringa 3 mL'
	String get seringa_3ml => 'Seringa 3 mL';

	/// pt: 'Seringa 5 mL'
	String get seringa_5ml => 'Seringa 5 mL';

	/// pt: 'Assistente'
	String get assistente => 'Assistente';
}

// Path: exames
class Translations$exames$pt {
	Translations$exames$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Protocolo Pré-Exame'
	String get checklist_titulo => 'Protocolo Pré-Exame';

	/// pt: 'Confirme as regras abaixo para evitar falsos positivos nos seus resultados hormonais.'
	String get checklist_subtitulo => 'Confirme as regras abaixo para evitar falsos positivos nos seus resultados hormonais.';

	/// pt: '1. Jejum Estrito (8 a 12h)'
	String get item1_tit => '1. Jejum Estrito (8 a 12h)';

	/// pt: 'Obrigatório para Insulina Basal e Glicemia. Máximo 14h. Beba bastante água, está liberada!'
	String get item1_desc => 'Obrigatório para Insulina Basal e Glicemia. Máximo 14h. Beba bastante água, está liberada!';

	/// pt: '2. Pausa nos Treinos (48h)'
	String get item2_tit => '2. Pausa nos Treinos (48h)';

	/// pt: 'Suspenda a musculação. Microlesões elevam falsamente a CPK (dano muscular), Creatinina e TGO (AST).'
	String get item2_desc => 'Suspenda a musculação. Microlesões elevam falsamente a CPK (dano muscular), Creatinina e TGO (AST).';

	/// pt: '3. Repouso Pélvico (72h)'
	String get item3_tit => '3. Repouso Pélvico (72h)';

	/// pt: 'Sem ejaculação (evita picos falsos de Prolactina e PSA). Não ande de moto, bicicleta ou cavalo.'
	String get item3_desc => 'Sem ejaculação (evita picos falsos de Prolactina e PSA). Não ande de moto, bicicleta ou cavalo.';

	/// pt: '4. Proteção Hepática (72h)'
	String get item4_tit => '4. Proteção Hepática (72h)';

	/// pt: 'Zero álcool para não gerar picos agudos de Gama-GT, Triglicerídeos e inflamação sistêmica (PCR).'
	String get item4_desc => 'Zero álcool para não gerar picos agudos de Gama-GT, Triglicerídeos e inflamação sistêmica (PCR).';

	/// pt: '5. Horário da Coleta'
	String get item5_tit => '5. Horário da Coleta';

	/// pt: 'Coleta estrita entre 07h e 09h da manhã para pegar Testosterona, TSH e Prolactina no pico basal.'
	String get item5_desc => 'Coleta estrita entre 07h e 09h da manhã para pegar Testosterona, TSH e Prolactina no pico basal.';

	/// pt: '6. Fidelidade ao Ciclo'
	String get item6_tit => '6. Fidelidade ao Ciclo';

	/// pt: 'Não pause ou atrase as injeções no app. O exame deve refletir a cinética hormonal real do corpo.'
	String get item6_desc => 'Não pause ou atrase as injeções no app. O exame deve refletir a cinética hormonal real do corpo.';

	/// pt: 'CONFIRMAR CHECKLIST'
	String get btn_confirmar => 'CONFIRMAR CHECKLIST';

	/// pt: 'Sugestão de Laboratório'
	String get painel_titulo => 'Sugestão de Laboratório';

	/// pt: 'Lista personalizada cruzando sexo biológico, idade, peso e protocolo ativo.'
	String get painel_subtitulo => 'Lista personalizada cruzando sexo biológico, idade, peso e protocolo ativo.';

	/// pt: 'AGENDAR DATA DA COLETA'
	String get btn_agendar => 'AGENDAR DATA DA COLETA';

	/// pt: 'JÁ FIZ A COLETA NO LABORATÓRIO'
	String get btn_ja_fiz => 'JÁ FIZ A COLETA NO LABORATÓRIO';

	/// pt: 'COPIAR LISTA PARA O MÉDICO'
	String get btn_copiar_medico => 'COPIAR LISTA PARA O MÉDICO';

	/// pt: 'ENVIAR PARA MEU E-MAIL'
	String get btn_enviar_email => 'ENVIAR PARA MEU E-MAIL';

	/// pt: 'Selecione pelo menos um bloco de exames.'
	String get msg_selecione_bloco => 'Selecione pelo menos um bloco de exames.';

	/// pt: 'Sugestão de Exames - Controle de Injetáveis'
	String get email_assunto => 'Sugestão de Exames - Controle de Injetáveis';

	/// pt: 'Lista copiada! Cole no WhatsApp ou leve na consulta.'
	String get msg_copiado => 'Lista copiada! Cole no WhatsApp ou leve na consulta.';

	/// pt: 'Aviso: Sugestão informativa para discussão médica. Não substitui prescrição profissional; intervalos podem ser ajustados pelo seu médico.'
	String get aviso_clinico => 'Aviso: Sugestão informativa para discussão médica. Não substitui prescrição profissional; intervalos podem ser ajustados pelo seu médico.';

	/// pt: 'Laboratoriais'
	String get sec_laboratoriais => 'Laboratoriais';

	/// pt: 'Específicos do Protocolo'
	String get sec_protocolo => 'Específicos do Protocolo';

	/// pt: 'Perfil Ponderal e Metabólico'
	String get sec_ponderal => 'Perfil Ponderal e Metabólico';

	/// pt: 'Cardiológicos'
	String get sec_cardiologicos => 'Cardiológicos';

	/// pt: 'Imagem e Rastreamento'
	String get sec_imagem => 'Imagem e Rastreamento';

	/// pt: '1º Exame'
	String get primeiro_exame => '1º Exame';

	/// pt: 'Periodicidade'
	String get periodicidade => 'Periodicidade';

	late final Translations$exames$nomes$pt nomes = Translations$exames$nomes$pt.internal(_root);
}

// Path: complementos
class Translations$complementos$pt {
	Translations$complementos$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Intervalo: A cada ${dias} dias'
	String intervalo_cada({required Object dias}) => 'Intervalo: A cada ${dias} dias';

	/// pt: 'Masculino'
	String get masculino => 'Masculino';

	/// pt: 'Feminino'
	String get feminino => 'Feminino';

	/// pt: 'Selecione'
	String get selecione_erro => 'Selecione';

	/// pt: 'Seringa: ${seringa} UI | Intervalo: ${dias} dias'
	String seringa_intervalo({required Object seringa, required Object dias}) => 'Seringa: ${seringa} UI | Intervalo: ${dias} dias';
}

// Path: navegacao
class Translations$navegacao$pt {
	Translations$navegacao$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Início'
	String get inicio => 'Início';

	/// pt: 'Tratamento'
	String get tratamento => 'Tratamento';

	/// pt: 'Ferramentas'
	String get ferramentas => 'Ferramentas';

	/// pt: 'Perfil'
	String get perfil => 'Perfil';
}

// Path: evolucao
class Translations$evolucao$pt {
	Translations$evolucao$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Evolução Clínica'
	String get titulo => 'Evolução Clínica';

	/// pt: 'Histórico de exames, alertas, bioimpedância e gráficos.'
	String get card_subtitulo => 'Histórico de exames, alertas, bioimpedância e gráficos.';

	/// pt: 'Alertas'
	String get aba_alertas => 'Alertas';

	/// pt: 'Tabela'
	String get aba_tabela => 'Tabela';

	/// pt: 'Gráficos'
	String get aba_graficos => 'Gráficos';

	/// pt: 'Registrar'
	String get btn_registrar => 'Registrar';

	/// pt: 'SALVAR REGISTRO'
	String get btn_salvar => 'SALVAR REGISTRO';

	/// pt: 'Novo Registro Clínico'
	String get modal_novo => 'Novo Registro Clínico';

	/// pt: 'Editar Registro Clínico'
	String get modal_editar => 'Editar Registro Clínico';

	/// pt: 'Exame de Sangue'
	String get tipo_sangue => 'Exame de Sangue';

	/// pt: 'Bioimpedância / Medidas'
	String get tipo_corpo => 'Bioimpedância / Medidas';

	/// pt: 'Data do Registro'
	String get data_registro => 'Data do Registro';

	/// pt: 'Preencha apenas os marcadores presentes no seu laudo:'
	String get instrucao_laudo => 'Preencha apenas os marcadores presentes no seu laudo:';

	/// pt: 'Observações (opcional)'
	String get obs_opcional => 'Observações (opcional)';

	/// pt: 'Nenhum resultado registrado ainda'
	String get sem_resultados => 'Nenhum resultado registrado ainda';

	/// pt: 'Toque no botão abaixo para registrar seu primeiro exame de sangue ou bioimpedância e acompanhar sua evolução.'
	String get sem_resultados_desc => 'Toque no botão abaixo para registrar seu primeiro exame de sangue ou bioimpedância e acompanhar sua evolução.';

	/// pt: 'Último Exame: Tudo na Faixa'
	String get tudo_na_faixa => 'Último Exame: Tudo na Faixa';

	/// pt: 'Última Bioimpedância'
	String get ultima_bio => 'Última Bioimpedância';

	/// pt: 'Histórico de Registros'
	String get historico_titulo => 'Histórico de Registros';

	/// pt: 'Sem registros nesta categoria.'
	String get sem_categoria => 'Sem registros nesta categoria.';

	/// pt: 'Escolha o Marcador para Visualizar'
	String get escolha_marcador => 'Escolha o Marcador para Visualizar';

	/// pt: 'Nenhum dado registrado para este marcador.'
	String get sem_dados_marcador => 'Nenhum dado registrado para este marcador.';

	/// pt: 'Enviar relatório para meu e-mail'
	String get tooltip_email => 'Enviar relatório para meu e-mail';

	/// pt: 'Copiar relatório para o médico'
	String get tooltip_copiar => 'Copiar relatório para o médico';

	/// pt: 'Relatório copiado! Cole no WhatsApp ou leve na consulta.'
	String get msg_copiado => 'Relatório copiado! Cole no WhatsApp ou leve na consulta.';

	/// pt: 'Registro salvo com sucesso!'
	String get msg_salvo => 'Registro salvo com sucesso!';

	/// pt: 'Registro excluído com sucesso!'
	String get msg_excluido => 'Registro excluído com sucesso!';

	/// pt: 'Excluir Registro'
	String get excluir_titulo => 'Excluir Registro';

	/// pt: 'Tem certeza que deseja excluir este registro clínico? Esta ação não pode ser desfeita.'
	String get excluir_desc => 'Tem certeza que deseja excluir este registro clínico? Esta ação não pode ser desfeita.';

	/// pt: 'Excluir'
	String get btn_excluir => 'Excluir';
}

// Path: cronograma_modal
class Translations$cronograma_modal$pt {
	Translations$cronograma_modal$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Período do Cronograma'
	String get titulo => 'Período do Cronograma';

	/// pt: 'Frasco atual ($vol mL)'
	String frasco_atual({required Object vol}) => 'Frasco atual (${vol} mL)';

	/// pt: 'Frasco novo ($vol mL)'
	String frasco_novo({required Object vol}) => 'Frasco novo (${vol} mL)';

	/// pt: 'Frasco inteiro'
	String get op_frasco => 'Frasco inteiro';

	/// pt: 'Até acabar o saldo'
	String get op_frasco_sub => 'Até acabar o saldo';

	/// pt: 'Por Semanas'
	String get op_semanas => 'Por Semanas';

	/// pt: 'Ex: 4 ou 8 semanas'
	String get op_semanas_sub => 'Ex: 4 ou 8 semanas';

	/// pt: 'Por Meses'
	String get op_meses => 'Por Meses';

	/// pt: 'Ex: 3 meses'
	String get op_meses_sub => 'Ex: 3 meses';

	/// pt: 'Por Injeções'
	String get op_injecoes => 'Por Injeções';

	/// pt: 'Qtd. exata de doses'
	String get op_injecoes_sub => 'Qtd. exata de doses';

	/// pt: 'Semanas'
	String get lbl_semanas => 'Semanas';

	/// pt: 'Meses'
	String get lbl_meses => 'Meses';

	/// pt: 'Injeções'
	String get lbl_injecoes => 'Injeções';

	/// pt: 'GERAR 1 APLICAÇÃO'
	String get btn_gerar_uma => 'GERAR 1 APLICAÇÃO';

	/// pt: 'GERAR $qtd APLICAÇÕES'
	String btn_gerar_varias({required Object qtd}) => 'GERAR ${qtd} APLICAÇÕES';

	/// pt: 'INFORME A QUANTIDADE'
	String get btn_informe_qtd => 'INFORME A QUANTIDADE';
}

// Path: exames.nomes
class Translations$exames$nomes$pt {
	Translations$exames$nomes$pt.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// pt: 'Hemograma Completo'
	String get hemo => 'Hemograma Completo';

	/// pt: 'Marcadores Inflamatórios (PCR e Ferritina)'
	String get marcadores => 'Marcadores Inflamatórios (PCR e Ferritina)';

	/// pt: 'Perfil Lipídico (Colesterol Total, HDL, LDL, VLDL, Triglicerídeos)'
	String get lipidico => 'Perfil Lipídico (Colesterol Total, HDL, LDL, VLDL, Triglicerídeos)';

	/// pt: 'Função Hepática (TGO, TGP, Gama-GT)'
	String get figado => 'Função Hepática (TGO, TGP, Gama-GT)';

	/// pt: 'Função Renal (Ureia e Creatinina)'
	String get rim => 'Função Renal (Ureia e Creatinina)';

	/// pt: 'Dano Muscular (CPK)'
	String get cpk => 'Dano Muscular (CPK)';

	/// pt: 'Testosterona Total e Livre'
	String get testo => 'Testosterona Total e Livre';

	/// pt: 'Estradiol (E2)'
	String get e2 => 'Estradiol (E2)';

	/// pt: 'SHBG'
	String get shbg => 'SHBG';

	/// pt: 'DHT (Di-hidrotestosterona)'
	String get dht => 'DHT (Di-hidrotestosterona)';

	/// pt: 'Prolactina'
	String get prolactina => 'Prolactina';

	/// pt: 'Tireoide (TSH e T4 Livre)'
	String get tireoide => 'Tireoide (TSH e T4 Livre)';

	/// pt: 'PSA Total e Livre (Próstata)'
	String get psa => 'PSA Total e Livre (Próstata)';

	/// pt: 'Glicemia em Jejum'
	String get glicemia => 'Glicemia em Jejum';

	/// pt: 'Insulina Basal'
	String get insulina => 'Insulina Basal';

	/// pt: 'Hemoglobina Glicada (HbA1c)'
	String get hba1c => 'Hemoglobina Glicada (HbA1c)';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'notificacoes.titulo_injecao' => 'Dia de Injeção! 💉',
			'notificacoes.corpo_injecao' => ({required Object medicamento, required Object local}) => 'Hoje é dia de aplicar ${medicamento} (${local}).',
			'erros.sem_internet' => 'Verifique a sua ligação à internet e tente novamente.',
			'erros.falha_app' => 'Falha ao iniciar o aplicativo',
			'login.titulo' => 'Controle de Injetáveis',
			'login.email' => 'Email',
			'login.senha' => 'Palavra-passe',
			'login.entrar' => 'ENTRAR',
			'login.criar_conta' => 'CRIAR NOVA CONTA',
			'login.esqueci_senha' => 'Esqueci minha senha',
			'perfil.titulo' => 'Meu Perfil',
			'perfil.idioma' => 'Idioma / Language',
			'perfil.dados_biologicos' => 'Dados Biológicos',
			'perfil.descricao_biologicos' => 'Estas informações são essenciais para que o aplicativo cruze a sua idade, sexo biológico e peso, gerando painéis de exames clínicos precisos e totalmente seguros.',
			'perfil.nome' => 'Nome Completo',
			'perfil.peso' => 'Peso (kg)',
			'perfil.sexo' => 'Sexo Biológico',
			'perfil.data_nascimento' => 'Data de Nascimento (DD/MM/AAAA)',
			'perfil.btn_salvar' => 'SALVAR PERFIL',
			'perfil.msg_sucesso' => 'Perfil salvo com sucesso!',
			'perfil.msg_erro' => 'Erro ao salvar: ',
			'perfil.erro_sexo' => 'Por favor, selecione o sexo biológico.',
			'perfil.erro_data' => 'Digite uma data de nascimento válida (DD/MM/AAAA).',
			'guia.titulo' => 'Guia e Termos de Uso',
			'guia.aviso_scroll' => '⬇️ Role a tela até o final para habilitar o aceite.',
			'guia.texto_aceite' => 'Declaro que li as instruções, estou ciente dos riscos médicos e aceito os Termos de Responsabilidade e Isenção.',
			'guia.btn_aceitar' => 'ESTOU CIENTE E ACEITO',
			'guia.msg_sucesso' => 'Termos aceitos e registrados. Uso liberado!',
			'guia.msg_erro' => 'Erro ao registrar: ',
			'guia.tooltip_sair' => 'Sair do App',
			'dashboard.titulo' => 'Tratamento',
			'dashboard.resumo_clinico' => 'Resumo Clínico',
			'dashboard.proxima_aplicacao' => 'Próxima Aplicação',
			'dashboard.ultima_aplicacao' => 'Última Aplicação',
			'dashboard.gerir_medicamentos' => 'GERIR MEDICAMENTOS',
			'dashboard.nenhuma_aplicacao' => 'Nenhuma aplicação futura agendada.',
			'dashboard.nenhum_historico' => 'Nenhum histórico de aplicações.',
			'setup.titulo' => 'Banco de Medicamentos',
			'setup.btn_novo' => 'NOVO',
			'setup.nenhum_medicamento' => 'Nenhum medicamento configurado.',
			'setup.simulador_titulo' => 'Simulador de Ciclos',
			'setup.simulador_subtitulo' => 'Planeie os seus protocolos e visualize a libertação no sangue.',
			'formulario.titulo_novo' => 'Novo Medicamento',
			'formulario.titulo_editar' => 'Editar Medicamento',
			'formulario.btn_atualizar' => 'ATUALIZAR MEDICAMENTO',
			'formulario.btn_guardar' => 'GUARDAR MEDICAMENTO',
			'formulario.btn_arquivar' => 'ENCERRAR TRATAMENTO (ARQUIVAR)',
			'formulario.campo_mix' => 'Mix Selecionado',
			'formulario.campo_medicamento' => 'Medicamento (Digitar)',
			'formulario.campo_catalogo' => 'Catálogo (Pesquisar...)',
			'formulario.btn_novo_catalogo' => 'NOVO',
			'formulario.btn_abrir_catalogo' => 'CATÁLOGO',
			'formulario.btn_criar_mix' => 'CRIAR MIX',
			'formulario.modo_mix_titulo' => 'MODO MIX ATIVADO',
			'formulario.modo_mix_editar' => 'Pode alterar o Intervalo, Seringa e Locais livremente. Para alterar as DOSES base, clique em DESMEMBRAR MIX.',
			'formulario.modo_mix_novo' => 'O Intervalo, Seringa e Região foram importados automaticamente.',
			'formulario.campo_intervalo' => 'Intervalo (dias)',
			'formulario.qtd_curto' => 'Qtd. Frascos',
			'formulario.vol_curto' => 'Vol. (mL)',
			'formulario.conc_curto' => 'Conc. (mg/mL)',
			'formulario.campo_dose_semanal' => 'Dose Semanal',
			'formulario.campo_unidade' => 'Unidade',
			'formulario.resultado_dose' => 'Dose Calculada por Aplicação:',
			'formulario.resultado_vazio' => 'Aguardando valores...',
			'formulario.campo_seringa' => 'Seringa (UI)',
			'formulario.campo_locais' => 'Locais do Rodízio',
			'formulario.campo_data' => 'Data de Início',
			'formulario.campo_hora' => 'Hora da Aplicação',
			'formulario.freq_intervalo' => 'Intervalo (Dias)',
			'formulario.freq_dias_semana' => 'Dias da Semana',
			'formulario.dias_semana."1"' => 'Seg',
			'formulario.dias_semana."2"' => 'Ter',
			'formulario.dias_semana."3"' => 'Qua',
			'formulario.dias_semana."4"' => 'Qui',
			'formulario.dias_semana."5"' => 'Sex',
			'formulario.dias_semana."6"' => 'Sáb',
			'formulario.dias_semana."7"' => 'Dom',
			'cronograma.titulo' => ({required Object nome}) => 'Cronograma: ${nome}',
			'cronograma.btn_gerar_novo' => 'GERAR NOVO CICLO',
			'cronograma.nenhum_gerado' => 'Nenhum cronograma gerado ainda.',
			'cronograma.btn_gerar' => 'GERAR CRONOGRAMA',
			'cronograma.info_seringa' => ({required Object seringa, required Object intervalo}) => 'Seringa: ${seringa} UI | Intervalo: ${intervalo} dias',
			'guia_conteudo.termos_titulo' => '⚖️ TERMOS DE RESPONSABILIDADE E PRIVACIDADE',
			'guia_conteudo.termos_texto' => 'Ao utilizar o Controle de Injetáveis, o usuário declara estar plenamente ciente de que:\n\n1. O usuário assume TOTAL e exclusiva responsabilidade pelas doses, misturas (Mix), saldos de frasco e protocolos gerados.\n2. A CodeVibe Studio NÃO se responsabiliza por erros de preenchimento ou cálculos equivocados gerados por dados incorretos.\n3. O "Painel de Exames", a "Evolução Clínica" (alertas, semáforo e gráficos) e o "Simulador de Ciclos" são estimativas informativas e matemáticas. NÃO têm valor de diagnóstico, prescrição ou aconselhamento médico.\n4. Privacidade (LGPD): Seus dados de saúde são armazenados de forma privada com isolamento individual de acesso e nunca são vendidos ou compartilhados com terceiros. Você pode editar ou excluir seus registros a qualquer momento.\n5. O usuário isenta os criadores de qualquer complicação clínica decorrente do uso desta ferramenta organizacional.',
			'guia_conteudo.aviso_titulo' => '🚨 AVISO MÉDICO IMPORTANTE',
			'guia_conteudo.aviso_texto' => 'Este aplicativo é exclusivamente uma ferramenta de apoio logístico e matemático. ELE NÃO SUBSTITUI A ORIENTAÇÃO MÉDICA.\n\n• O aplicativo não receita, não prescreve e não recomenda tratamentos.\n• Diante de qualquer marcador alterado na Evolução Clínica, leve o relatório ao seu médico para avaliação.\n• Em caso de dor extrema, febre, vermelhidão intensa, inchaço, falta de ar ou qualquer mal-estar após uma aplicação, PROCURE UMA EMERGÊNCIA HOSPITALAR IMEDIATAMENTE ou contate o seu médico.\n• Nunca inicie, titule ou altere dosagens sem o conhecimento e autorização do seu profissional de saúde.',
			'guia_conteudo.higiene_titulo' => '🧼 HIGIENE E ASSEPSIA',
			'guia_conteudo.higiene_texto' => 'A falta de higiene pode causar infecções graves e abcessos. Siga rigorosamente:\n\n• Lave as mãos com água e sabão antes de tocar nos materiais.\n• Limpe a borracha do bujão com algodão e Álcool 70%.\n• Faça a assepsia da pele com Álcool 70% e deixe secar naturalmente antes de perfurar.\n• Utilize APENAS seringas e agulhas estéreis, de uso único (descartáveis).\n• Descarte o material perfurocortante em recipiente rígido adequado (Descarpack).',
			'guia_conteudo.como_usar_titulo' => '📱 COMO USAR O APLICATIVO',
			'guia_conteudo.como_usar_texto' => '• Início (Resumo Clínico): Prioridade dinâmica que destaca sua Próxima e Última Aplicação no topo, subindo alertas de exame apenas quando exigirem ação.\n\n• Banco de Medicamentos e Cronograma Inteligente: Cadastre seus frascos, locais de rodízio e gere ciclos por Frasco inteiro, Semanas, Meses ou Injeções. Ao gerar um novo ciclo, o app desconta automaticamente o volume já aplicado, permitindo continuar no frasco atual (ideal para titulação de dose) ou iniciar um frasco novo.\n\n• Evolução Clínica: Registre exames de sangue e bioimpedância/medidas. Acompanhe alertas de marcadores fora da faixa, tabela comparativa com semáforo colorido, gráficos com faixa de referência e envie relatórios limpos por e-mail ou cópia para o seu médico.\n\n• Calculadoras e Simulador de Ciclos: Use o Assistente de Reconstituição, a Seringa Virtual e o Simulador Farmacocinético para visualizar curvas teóricas de liberação.\n\n• Mix Seguro: Agrupe compostos compatíveis na mesma seringa com soma automática de volumes.',
			'guia_conteudo.cerebro_titulo' => '🧬 CÉREBRO ANALÍTICO E EXAMES',
			'guia_conteudo.cerebro_texto' => 'O aplicativo possui um Motor Preditivo de segurança:\n\n• Perfil Biométrico: Cruza sexo biológico, idade, peso e protocolo ativo para sugerir exames relevantes para discussão médica, com envio direto por e-mail ou cópia.\n\n• Controle de Repetição: Ao confirmar a coleta, o histórico salva os exames realizados e oculta automaticamente o que ainda está dentro da validade.\n\n• Protocolo Pré-Exame: Antes da coleta agendada, o sistema libera um Checklist Clínico (Jejum, Pausa nos Treinos/CPK, Repouso Pélvico, etc.) para evitar falsos positivos.\n\n• Janela de Biomarcadores: A primeira janela ideal é sugerida 45 dias após o início do protocolo, com revisões sugeridas a cada 90 dias.',
			'guia_conteudo.notificacoes_titulo' => '🔔 MOTOR DE NOTIFICAÇÕES NATIVAS',
			'guia_conteudo.notificacoes_texto' => 'Para garantir o máximo desempenho e poupar a bateria, o nosso motor adota arquitetura silenciosa:\n\n• Fila Anti-Spam: Aparelhos recentes limitam alarmes por aplicativo. Por isso, o app agenda automaticamente as próximas 60 aplicações e renova a fila conforme você marca as doses concluídas.\n\n• Dica para Android: Para evitar atrasos ou bloqueios do sistema, mantenha em Configurações → Aplicativos → Controle de Injetáveis a Bateria como "Irrestrito" e "Alarmes e lembretes" permitidos.',
			'guia_conteudo.seringas_titulo' => '💉 GUIA DE SERINGAS E AGULHAS',
			'guia_conteudo.seringas_subtitulo' => 'Entenda o material adequado para cada aplicação:',
			'guia_conteudo.seringas_btn' => 'Visualizar Agulhas e Seringas',
			'guia_conteudo.seringas_texto1' => '💉 AGULHAS RECOMENDADAS:',
			'guia_conteudo.seringas_texto2' => '• Subcutânea (SC - Gordura): Agulhas curtas e finas, ex: 13x0.45mm ou 13x0.3mm (marrom/cinza). Aplicada em ângulo de 90° ou 45° dependendo do tecido adiposo.\n• Intramuscular (IM - Músculo): Agulhas longas para alcançar o músculo, ex: 25x0.7mm ou 30x0.7mm (preta/azul) e para volumes maiores 25x0.8mm (verde). Aplicar em ângulo de 90°.',
			'guia_conteudo.seringas_texto3' => '🧪 SERINGAS E ESCALAS:',
			'guia_conteudo.seringas_texto4' => '• Seringas de Insulina (100 UI = 1 mL): Escala detalhada. 10 UI equivalem a 0.1 mL. Ideal para microdoses subcutâneas de alta precisão.\n• Seringas de 3 mL ou 5 mL: Usadas para aplicações intramusculares que requerem maior volume de diluente ou óleo.',
			'guia_conteudo.mapas_titulo' => '🗺️ MAPA DE PONTOS DE APLICAÇÃO',
			'guia_conteudo.mapas_alerta_titulo' => 'ATUALIZAÇÃO CLÍNICA (IM)',
			'guia_conteudo.mapas_alerta_texto' => '✅ O Ventro Glúteo é hoje considerado o padrão-ouro e o local mais seguro para injeções intramusculares, por estar totalmente livre de grandes vasos e nervos.\n\n❌ O antigo "Dorso Glúteo" (quadrante superior externo) está a ser abandonado na prática clínica atual. Ele oferece alto risco de lesão do nervo ciático e apresenta mais riscos do que benefícios.',
			'guia_conteudo.mapas_subtitulo' => 'Clique na região para visualizar os locais exatos e fazer o rodízio correto:',
			'guia_conteudo.mapas_btn1' => 'Pontos da Barriga (8 Pontos)',
			'guia_conteudo.mapas_btn2' => 'Pontos dos Flancos (9 Pontos)',
			'guia_conteudo.mapas_btn3' => 'Pontos dos Glúteos (Ventro Glúteo / Dorso)',
			'guia_conteudo.mapas_btn4' => 'Pontos da Coxa (Vasto Lateral)',
			'guia_conteudo.mapas_btn5' => 'Pontos do Deltoide (Braço)',
			'guia_conteudo.dicionario_titulo' => '📖 DICIONÁRIO MAROMBA E CLÍNICO',
			'guia_conteudo.dicionario_subtitulo' => 'O dialeto das academias e dos tratamentos, traduzido de forma direta:',
			'guia_conteudo.dic_cat1' => '💪 SOBRE O SHAPE (CORPO)',
			'guia_conteudo.dic_cat2' => '🏋️ SOBRE O TREINO',
			'guia_conteudo.dic_cat3' => '🥦 SOBRE A DIETA',
			'guia_conteudo.dic_cat4' => '💉 SOBRE OS INJETÁVEIS E "ADITIVOS"',
			'biometria.motivo' => 'Desbloqueie para aceder aos seus dados clínicos',
			'biometria.erro_cancelado' => 'Biometria cancelada. Tente novamente ou use a senha do App.',
			'biometria.erro_sensor' => 'Erro no sensor biométrico.',
			'biometria.titulo' => 'Aplicativo Bloqueado',
			'biometria.subtitulo' => 'Protegendo o seu histórico clínico...',
			'biometria.btn_biometria' => 'USAR BIOMETRIA',
			'biometria.btn_senha' => 'ACESSAR COM SENHA DO APP',
			'visualizador.erro_imagem' => 'Imagem não encontrada.',
			'geral.sim' => 'Sim',
			'geral.nao' => 'Não',
			'geral.ok' => 'OK',
			'geral.cancelar' => 'Cancelar',
			'calculadora.titulo' => 'Calculadora de Injetáveis',
			'calculadora.limpar' => 'Limpar Tudo',
			'calculadora.aviso' => '⚠️ Ferramenta educativa. Confirme doses com um profissional de saúde.',
			'calculadora.volume' => 'Volume Frasco (mL)',
			'calculadora.concentracao' => 'Concentração',
			'calculadora.assistente' => 'Assistente de Reconstituição',
			'calculadora.dose_semanal' => 'Dose Semanal',
			'calculadora.intervalo' => 'Intervalo (dias)',
			'calculadora.unidade' => 'Unidade',
			'calculadora.seringa' => 'Seringa (UI)',
			'calculadora.resultados' => 'Resultados',
			'calculadora.selecoes_vazias' => 'Faça as seleções acima para calcular a quantidade de fluido aspirado para a dose desejada.',
			'calculadora.res_para_dose' => 'Para a dose de ',
			'calculadora.res_aspire' => ', aspire o conteúdo da seringa até: ',
			'calculadora.res_ou' => ' mL ou ',
			'calculadora.res_unidades' => ' unidades.',
			'calculadora.res_conc' => 'Concentração do frasco reconstituído:\n',
			'calculadora.res_contem' => 'O frasco contém ',
			'calculadora.res_doses' => ' doses',
			'calculadora.res_de' => ' de ',
			'calculadora.res_cada' => ' cada.',
			'calculadora.diluicao_titulo' => 'Calculadora de Diluição',
			'calculadora.diluicao_desc' => 'Deseja calcular a reconstituição ou descobrir a concentração de um frasco?\n\nIsto calculará automaticamente a Concentração cruzando a Massa Total da substância com a quantidade de líquido.',
			'calculadora.passo1' => 'Cálculo\nPASSO 1 DE 2:',
			'calculadora.passo1_label' => 'Total da Substância (mg)',
			'calculadora.passo1_hint' => 'Ex: 5 (para frascos de 5mg)',
			'calculadora.passo2' => 'Cálculo\nPASSO 2 DE 2:',
			'calculadora.passo2_label' => 'Volume do Líquido (mL)',
			'calculadora.passo2_hint' => 'Quantos mL totais tem o frasco?',
			'calculadora.msg_sucesso' => 'Diluição calculada com sucesso!',
			'calculadora.msg_invalido' => 'Valores inválidos.',
			'calculadora.simulador_titulo' => 'Simulador de Liberação (Farmacocinética)',
			'calculadora.simulador_desc' => 'Teste: 2 injeções de 250mg de Enantato (Dia 0 e Dia 7)',
			'simulador.titulo' => 'Simulador de Ciclos',
			'simulador.subtitulo' => 'Elabore o seu protocolo',
			'simulador.nome_ciclo' => 'Nome do Ciclo (opcional)',
			'simulador.duracao' => 'Duração',
			'simulador.semanas' => ({required Object s}) => '${s} semanas',
			'simulador.composto_title' => 'Composto(s)',
			'simulador.composto_n' => ({required Object n}) => 'Composto #${n}',
			'simulador.remover' => 'Remover Composto',
			'simulador.dose' => 'Dose (mg)',
			'simulador.categoria' => 'Categoria',
			'simulador.selecione' => 'Selecione o composto',
			'simulador.esquema' => 'Esquema de dosagem (Agendar)',
			'simulador.freq_1' => 'Diariamente',
			'simulador.freq_2' => 'Um dia sim, um dia não',
			'simulador.freq_3' => 'A cada 3 dias',
			'simulador.freq_4' => 'A cada 4 dias',
			'simulador.freq_5' => 'A cada 5 dias',
			'simulador.freq_7' => 'A cada 7 dias (1x/sem)',
			'simulador.freq_14' => 'A cada 14 dias',
			'simulador.de_sem' => 'De (Semana)',
			'simulador.ate_sem' => 'Até (Semana)',
			'simulador.semana_n' => ({required Object s}) => 'Semana ${s}',
			'simulador.btn_trama' => 'Simular',
			'simulador.btn_adicionar' => 'Adicionar Composto',
			'simulador.btn_reiniciar' => 'Reiniciar',
			'simulador.grafico_titulo' => 'Liberação Diária de Fármaco Ativo (mg)',
			'simulador.grafico_nota' => 'Nota: A linha representa a miligramagem efetiva libertada no sangue a cada dia, aplicando o princípio da superposição (acúmulo) e o peso do éster.',
			'dashboard_alertas.atencao_coleta' => ({required Object dias}) => 'Atenção! Coleta em ${dias} dia(s)',
			'dashboard_alertas.texto_protecao' => 'O seu período de proteção biométrica começou. Abra o checklist clínico para não invalidar os resultados.',
			'dashboard_alertas.btn_abrir_checklist' => 'ABRIR CHECKLIST CLÍNICO',
			'dashboard_alertas.coleta_agendada' => 'Coleta Agendada',
			'dashboard_alertas.texto_exames' => ({required Object dias, required Object data}) => 'Você possui exames agendados para daqui a ${dias} dias (${data}).',
			'dashboard_alertas.btn_ver_painel' => 'VER PAINEL E REAGENDAR',
			'dashboard_alertas.label_mix' => 'Mix: ',
			'dashboard_alertas.label_data' => 'Data: ',
			'dashboard_alertas.label_local' => 'Local: ',
			'dashboard_alertas.label_dose' => 'Dose: ',
			'regioes.selecione' => 'Selecione os Locais',
			'regioes.nenhum' => 'Nenhum',
			'regioes.selecionados' => ({required Object qtd}) => '${qtd} selecionado(s)',
			'regioes.confirmar' => 'CONFIRMAR',
			'regioes.cancelar' => 'Cancelar',
			'regioes.ventro_gluteo' => 'Ventro Glúteo (IM)',
			'regioes.vasto_lateral' => 'Vasto Lateral (IM)',
			'regioes.deltoide' => 'Deltoide (IM)',
			'regioes.gluteo_superior' => 'Glúteo Superior (IM)',
			'regioes.barriga' => 'Barriga (SC)',
			'regioes.flanco' => 'Flanco (SC)',
			'regioes.perna_anterior' => 'Perna Anterior (SC)',
			'regioes.braco_triceps' => 'Braço Tríceps (SC)',
			'formulario_extras.dialogo_rotulo_titulo' => 'Preenchimento Seguro',
			'formulario_extras.dialogo_rotulo_desc' => 'Deseja usar a Calculadora automática de Rótulo?\n\nIsso evita erros na conversão de medicamentos como a Tirzepatida ou Semaglutida.',
			'formulario_extras.seringa_30' => '30 UI (0.3 mL)',
			'formulario_extras.seringa_50' => '50 UI (0.5 mL)',
			'formulario_extras.seringa_100' => '100 UI (1 mL)',
			'formulario_extras.seringa_3ml' => 'Seringa 3 mL',
			'formulario_extras.seringa_5ml' => 'Seringa 5 mL',
			'formulario_extras.assistente' => 'Assistente',
			'exames.checklist_titulo' => 'Protocolo Pré-Exame',
			'exames.checklist_subtitulo' => 'Confirme as regras abaixo para evitar falsos positivos nos seus resultados hormonais.',
			'exames.item1_tit' => '1. Jejum Estrito (8 a 12h)',
			'exames.item1_desc' => 'Obrigatório para Insulina Basal e Glicemia. Máximo 14h. Beba bastante água, está liberada!',
			'exames.item2_tit' => '2. Pausa nos Treinos (48h)',
			'exames.item2_desc' => 'Suspenda a musculação. Microlesões elevam falsamente a CPK (dano muscular), Creatinina e TGO (AST).',
			'exames.item3_tit' => '3. Repouso Pélvico (72h)',
			'exames.item3_desc' => 'Sem ejaculação (evita picos falsos de Prolactina e PSA). Não ande de moto, bicicleta ou cavalo.',
			'exames.item4_tit' => '4. Proteção Hepática (72h)',
			'exames.item4_desc' => 'Zero álcool para não gerar picos agudos de Gama-GT, Triglicerídeos e inflamação sistêmica (PCR).',
			'exames.item5_tit' => '5. Horário da Coleta',
			'exames.item5_desc' => 'Coleta estrita entre 07h e 09h da manhã para pegar Testosterona, TSH e Prolactina no pico basal.',
			'exames.item6_tit' => '6. Fidelidade ao Ciclo',
			'exames.item6_desc' => 'Não pause ou atrase as injeções no app. O exame deve refletir a cinética hormonal real do corpo.',
			'exames.btn_confirmar' => 'CONFIRMAR CHECKLIST',
			'exames.painel_titulo' => 'Sugestão de Laboratório',
			'exames.painel_subtitulo' => 'Lista personalizada cruzando sexo biológico, idade, peso e protocolo ativo.',
			'exames.btn_agendar' => 'AGENDAR DATA DA COLETA',
			'exames.btn_ja_fiz' => 'JÁ FIZ A COLETA NO LABORATÓRIO',
			'exames.btn_copiar_medico' => 'COPIAR LISTA PARA O MÉDICO',
			'exames.btn_enviar_email' => 'ENVIAR PARA MEU E-MAIL',
			'exames.msg_selecione_bloco' => 'Selecione pelo menos um bloco de exames.',
			'exames.email_assunto' => 'Sugestão de Exames - Controle de Injetáveis',
			'exames.msg_copiado' => 'Lista copiada! Cole no WhatsApp ou leve na consulta.',
			'exames.aviso_clinico' => 'Aviso: Sugestão informativa para discussão médica. Não substitui prescrição profissional; intervalos podem ser ajustados pelo seu médico.',
			'exames.sec_laboratoriais' => 'Laboratoriais',
			'exames.sec_protocolo' => 'Específicos do Protocolo',
			'exames.sec_ponderal' => 'Perfil Ponderal e Metabólico',
			'exames.sec_cardiologicos' => 'Cardiológicos',
			'exames.sec_imagem' => 'Imagem e Rastreamento',
			'exames.primeiro_exame' => '1º Exame',
			'exames.periodicidade' => 'Periodicidade',
			'exames.nomes.hemo' => 'Hemograma Completo',
			'exames.nomes.marcadores' => 'Marcadores Inflamatórios (PCR e Ferritina)',
			'exames.nomes.lipidico' => 'Perfil Lipídico (Colesterol Total, HDL, LDL, VLDL, Triglicerídeos)',
			'exames.nomes.figado' => 'Função Hepática (TGO, TGP, Gama-GT)',
			'exames.nomes.rim' => 'Função Renal (Ureia e Creatinina)',
			'exames.nomes.cpk' => 'Dano Muscular (CPK)',
			'exames.nomes.testo' => 'Testosterona Total e Livre',
			'exames.nomes.e2' => 'Estradiol (E2)',
			'exames.nomes.shbg' => 'SHBG',
			'exames.nomes.dht' => 'DHT (Di-hidrotestosterona)',
			'exames.nomes.prolactina' => 'Prolactina',
			'exames.nomes.tireoide' => 'Tireoide (TSH e T4 Livre)',
			'exames.nomes.psa' => 'PSA Total e Livre (Próstata)',
			'exames.nomes.glicemia' => 'Glicemia em Jejum',
			'exames.nomes.insulina' => 'Insulina Basal',
			'exames.nomes.hba1c' => 'Hemoglobina Glicada (HbA1c)',
			'complementos.intervalo_cada' => ({required Object dias}) => 'Intervalo: A cada ${dias} dias',
			'complementos.masculino' => 'Masculino',
			'complementos.feminino' => 'Feminino',
			'complementos.selecione_erro' => 'Selecione',
			'complementos.seringa_intervalo' => ({required Object seringa, required Object dias}) => 'Seringa: ${seringa} UI | Intervalo: ${dias} dias',
			'navegacao.inicio' => 'Início',
			'navegacao.tratamento' => 'Tratamento',
			'navegacao.ferramentas' => 'Ferramentas',
			'navegacao.perfil' => 'Perfil',
			'evolucao.titulo' => 'Evolução Clínica',
			'evolucao.card_subtitulo' => 'Histórico de exames, alertas, bioimpedância e gráficos.',
			'evolucao.aba_alertas' => 'Alertas',
			'evolucao.aba_tabela' => 'Tabela',
			'evolucao.aba_graficos' => 'Gráficos',
			'evolucao.btn_registrar' => 'Registrar',
			'evolucao.btn_salvar' => 'SALVAR REGISTRO',
			'evolucao.modal_novo' => 'Novo Registro Clínico',
			'evolucao.modal_editar' => 'Editar Registro Clínico',
			'evolucao.tipo_sangue' => 'Exame de Sangue',
			'evolucao.tipo_corpo' => 'Bioimpedância / Medidas',
			'evolucao.data_registro' => 'Data do Registro',
			'evolucao.instrucao_laudo' => 'Preencha apenas os marcadores presentes no seu laudo:',
			'evolucao.obs_opcional' => 'Observações (opcional)',
			'evolucao.sem_resultados' => 'Nenhum resultado registrado ainda',
			'evolucao.sem_resultados_desc' => 'Toque no botão abaixo para registrar seu primeiro exame de sangue ou bioimpedância e acompanhar sua evolução.',
			'evolucao.tudo_na_faixa' => 'Último Exame: Tudo na Faixa',
			'evolucao.ultima_bio' => 'Última Bioimpedância',
			'evolucao.historico_titulo' => 'Histórico de Registros',
			'evolucao.sem_categoria' => 'Sem registros nesta categoria.',
			'evolucao.escolha_marcador' => 'Escolha o Marcador para Visualizar',
			'evolucao.sem_dados_marcador' => 'Nenhum dado registrado para este marcador.',
			'evolucao.tooltip_email' => 'Enviar relatório para meu e-mail',
			'evolucao.tooltip_copiar' => 'Copiar relatório para o médico',
			'evolucao.msg_copiado' => 'Relatório copiado! Cole no WhatsApp ou leve na consulta.',
			'evolucao.msg_salvo' => 'Registro salvo com sucesso!',
			'evolucao.msg_excluido' => 'Registro excluído com sucesso!',
			'evolucao.excluir_titulo' => 'Excluir Registro',
			'evolucao.excluir_desc' => 'Tem certeza que deseja excluir este registro clínico? Esta ação não pode ser desfeita.',
			'evolucao.btn_excluir' => 'Excluir',
			'cronograma_modal.titulo' => 'Período do Cronograma',
			'cronograma_modal.frasco_atual' => ({required Object vol}) => 'Frasco atual (${vol} mL)',
			'cronograma_modal.frasco_novo' => ({required Object vol}) => 'Frasco novo (${vol} mL)',
			'cronograma_modal.op_frasco' => 'Frasco inteiro',
			'cronograma_modal.op_frasco_sub' => 'Até acabar o saldo',
			'cronograma_modal.op_semanas' => 'Por Semanas',
			'cronograma_modal.op_semanas_sub' => 'Ex: 4 ou 8 semanas',
			'cronograma_modal.op_meses' => 'Por Meses',
			'cronograma_modal.op_meses_sub' => 'Ex: 3 meses',
			'cronograma_modal.op_injecoes' => 'Por Injeções',
			'cronograma_modal.op_injecoes_sub' => 'Qtd. exata de doses',
			'cronograma_modal.lbl_semanas' => 'Semanas',
			'cronograma_modal.lbl_meses' => 'Meses',
			'cronograma_modal.lbl_injecoes' => 'Injeções',
			'cronograma_modal.btn_gerar_uma' => 'GERAR 1 APLICAÇÃO',
			'cronograma_modal.btn_gerar_varias' => ({required Object qtd}) => 'GERAR ${qtd} APLICAÇÕES',
			'cronograma_modal.btn_informe_qtd' => 'INFORME A QUANTIDADE',
			_ => null,
		};
	}
}
