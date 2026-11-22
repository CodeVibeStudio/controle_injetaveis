///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$notificacoes$es notificacoes = _Translations$notificacoes$es._(_root);
	@override late final _Translations$erros$es erros = _Translations$erros$es._(_root);
	@override late final _Translations$login$es login = _Translations$login$es._(_root);
	@override late final _Translations$perfil$es perfil = _Translations$perfil$es._(_root);
	@override late final _Translations$guia$es guia = _Translations$guia$es._(_root);
	@override late final _Translations$dashboard$es dashboard = _Translations$dashboard$es._(_root);
	@override late final _Translations$setup$es setup = _Translations$setup$es._(_root);
	@override late final _Translations$formulario$es formulario = _Translations$formulario$es._(_root);
	@override late final _Translations$cronograma$es cronograma = _Translations$cronograma$es._(_root);
	@override late final _Translations$guia_conteudo$es guia_conteudo = _Translations$guia_conteudo$es._(_root);
	@override late final _Translations$biometria$es biometria = _Translations$biometria$es._(_root);
	@override late final _Translations$visualizador$es visualizador = _Translations$visualizador$es._(_root);
	@override late final _Translations$geral$es geral = _Translations$geral$es._(_root);
	@override late final _Translations$calculadora$es calculadora = _Translations$calculadora$es._(_root);
	@override late final _Translations$simulador$es simulador = _Translations$simulador$es._(_root);
	@override late final _Translations$dashboard_alertas$es dashboard_alertas = _Translations$dashboard_alertas$es._(_root);
	@override late final _Translations$regioes$es regioes = _Translations$regioes$es._(_root);
	@override late final _Translations$formulario_extras$es formulario_extras = _Translations$formulario_extras$es._(_root);
	@override late final _Translations$exames$es exames = _Translations$exames$es._(_root);
	@override late final _Translations$complementos$es complementos = _Translations$complementos$es._(_root);
	@override late final _Translations$navegacao$es navegacao = _Translations$navegacao$es._(_root);
}

// Path: notificacoes
class _Translations$notificacoes$es extends Translations$notificacoes$pt {
	_Translations$notificacoes$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo_injecao => '¡Día de Inyección! 💉';
	@override String corpo_injecao({required Object medicamento, required Object local}) => 'Hoy es el día de aplicar ${medicamento} (${local}).';
}

// Path: erros
class _Translations$erros$es extends Translations$erros$pt {
	_Translations$erros$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sem_internet => 'Verifique su conexión a internet e intente de nuevo.';
	@override String get falha_app => 'Error al iniciar la aplicación';
}

// Path: login
class _Translations$login$es extends Translations$login$pt {
	_Translations$login$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Control de Inyectables';
	@override String get email => 'Correo electrónico';
	@override String get senha => 'Contraseña';
	@override String get entrar => 'ENTRAR';
	@override String get criar_conta => 'CREAR NUEVA CUENTA';
	@override String get esqueci_senha => 'Olvidé mi contraseña';
}

// Path: perfil
class _Translations$perfil$es extends Translations$perfil$pt {
	_Translations$perfil$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Mi Perfil';
	@override String get idioma => 'Idioma';
	@override String get dados_biologicos => 'Datos Biológicos';
	@override String get descricao_biologicos => 'Esta información es esencial para que la aplicación cruce su edad, sexo biológico y peso, generando paneles de análisis clínicos precisos y seguros.';
	@override String get nome => 'Nombre Completo';
	@override String get peso => 'Peso (kg)';
	@override String get sexo => 'Sexo Biológico';
	@override String get data_nascimento => 'Fecha de Nacimiento (DD/MM/AAAA)';
	@override String get btn_salvar => 'GUARDAR PERFIL';
	@override String get msg_sucesso => '¡Perfil guardado con éxito!';
	@override String get msg_erro => 'Error al guardar: ';
	@override String get erro_sexo => 'Por favor, seleccione el sexo biológico.';
	@override String get erro_data => 'Ingrese una fecha de nacimiento válida (DD/MM/AAAA).';
}

// Path: guia
class _Translations$guia$es extends Translations$guia$pt {
	_Translations$guia$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Guía y Términos de Uso';
	@override String get aviso_scroll => '⬇️ Desplácese hasta el final para habilitar la aceptación.';
	@override String get texto_aceite => 'Declaro que he leído las instrucciones, soy consciente de los riesgos médicos y acepto los Términos de Responsabilidad e Isención.';
	@override String get btn_aceitar => 'ESTOY CONSCIENTE Y ACEPTO';
	@override String get msg_sucesso => '¡Términos aceptados y registrados. Acceso concedido!';
	@override String get msg_erro => 'Error al registrar: ';
	@override String get tooltip_sair => 'Salir de la App';
}

// Path: dashboard
class _Translations$dashboard$es extends Translations$dashboard$pt {
	_Translations$dashboard$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Tratamiento';
	@override String get resumo_clinico => 'Resumen Clínico';
	@override String get proxima_aplicacao => 'Próxima Inyección';
	@override String get ultima_aplicacao => 'Última Inyección';
	@override String get gerir_medicamentos => 'GESTIONAR MEDICAMENTOS';
	@override String get nenhuma_aplicacao => 'No hay inyecciones futuras programadas.';
	@override String get nenhum_historico => 'No hay historial de aplicaciones.';
}

// Path: setup
class _Translations$setup$es extends Translations$setup$pt {
	_Translations$setup$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Banco de Medicamentos';
	@override String get btn_novo => 'NUEVO';
	@override String get nenhum_medicamento => 'No hay medicamentos configurados.';
	@override String get simulador_titulo => 'Simulador de Ciclos';
	@override String get simulador_subtitulo => 'Planifique sus protocolos y visualice la liberación en sangre.';
}

// Path: formulario
class _Translations$formulario$es extends Translations$formulario$pt {
	_Translations$formulario$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo_novo => 'Nuevo Medicamento';
	@override String get titulo_editar => 'Editar Medicamento';
	@override String get btn_atualizar => 'ACTUALIZAR MEDICAMENTO';
	@override String get btn_guardar => 'GUARDAR MEDICAMENTO';
	@override String get btn_arquivar => 'FINALIZAR TRATAMIENTO (ARCHIVAR)';
	@override String get campo_mix => 'Mix Seleccionado';
	@override String get campo_medicamento => 'Medicamento (Escribir)';
	@override String get campo_catalogo => 'Catálogo (Buscar...)';
	@override String get btn_novo_catalogo => 'NUEVO';
	@override String get btn_abrir_catalogo => 'CATÁLOGO';
	@override String get btn_criar_mix => 'CREAR MIX';
	@override String get modo_mix_titulo => 'MODO MIX ACTIVADO';
	@override String get modo_mix_editar => 'Puede cambiar Intervalo, Jeringa y Sitios libremente. Para cambiar DOSIS base, haga clic en DESARMAR MIX.';
	@override String get modo_mix_novo => 'Intervalo, Jeringa y Región fueron importados automáticamente.';
	@override String get campo_intervalo => 'Intervalo (días)';
	@override String get qtd_curto => 'Cant. Viales';
	@override String get vol_curto => 'Vol. (mL)';
	@override String get conc_curto => 'Conc. (mg/mL)';
	@override String get campo_dose_semanal => 'Dosis Semanal';
	@override String get campo_unidade => 'Unidad';
	@override String get resultado_dose => 'Dosis Calculada por Inyección:';
	@override String get resultado_vazio => 'Esperando valores...';
	@override String get campo_seringa => 'Jeringa (UI)';
	@override String get campo_locais => 'Sitios de Rotación';
	@override String get campo_data => 'Fecha de Inicio';
	@override String get campo_hora => 'Hora de Aplicación';
	@override String get freq_intervalo => 'Intervalo (Días)';
	@override String get freq_dias_semana => 'Días de la Semana';
	@override Map<String, String> get dias_semana => {
		'1': 'Lun',
		'2': 'Mar',
		'3': 'Mié',
		'4': 'Jue',
		'5': 'Vie',
		'6': 'Sáb',
		'7': 'Dom',
	};
}

// Path: cronograma
class _Translations$cronograma$es extends Translations$cronograma$pt {
	_Translations$cronograma$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String titulo({required Object nome}) => 'Cronograma: ${nome}';
	@override String get btn_gerar_novo => 'GENERAR NUEVO CICLO';
	@override String get nenhum_gerado => 'No hay cronograma generado aún.';
	@override String get btn_gerar => 'GENERAR CRONOGRAMA';
	@override String info_seringa({required Object seringa, required Object intervalo}) => 'Jeringa: ${seringa} UI | Intervalo: ${intervalo} días';
}

// Path: guia_conteudo
class _Translations$guia_conteudo$es extends Translations$guia_conteudo$pt {
	_Translations$guia_conteudo$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get termos_titulo => '⚖️ TÉRMINOS DE RESPONSABILIDAD';
	@override String get termos_texto => 'Al usar Control Inyectables, el usuario declara estar plenamente consciente de que:\n\n1. El usuario asume TOTAL y exclusiva responsabilidad por las dosis, mezclas (Mix) y protocolos generados.\n2. CodeVibe Studio NO se responsabiliza por errores de llenado o cálculos equivocados generados por datos incorrectos.\n3. El "Chequeo de Biomarcadores" y el "Simulador de Ciclos" son estimaciones puramente matemáticas orientadas a la reducción de daños. NO tienen valor de prescripción o consejo médico.\n4. El usuario exime a los creadores de cualquier complicación clínica derivada del uso de esta herramienta logística.';
	@override String get aviso_titulo => '🚨 AVISO MÉDICO IMPORTANTE';
	@override String get aviso_texto => 'Esta aplicación es exclusivamente una herramienta de apoyo logístico y matemático. NO SUSTITUYE LA ORIENTACIÓN MÉDICA.\n\n• La app no receta, no prescribe y no recomienda tratamientos.\n• En caso de dolor extremo, fiebre, enrojecimiento intenso, hinchazón, falta de aire o cualquier malestar después de una aplicación, BUSQUE UNA EMERGENCIA HOSPITALARIA INMEDIATAMENTE o contacte a su médico.\n• Nunca inicie o altere dosis sin el conocimiento y autorización de su profesional de salud.';
	@override String get higiene_titulo => '🧼 HIGIENE Y ASEPSIA';
	@override String get higiene_texto => 'La falta de higiene puede causar infecciones graves y abscesos. Siga estrictamente:\n\n• Lávese las manos con agua y jabón antes de tocar los materiales.\n• Limpie la goma del vial con algodón y Alcohol al 70%.\n• Realice la asepsia de la piel con Alcohol al 70% y deje secar al aire antes de perforar.\n• Utilice SOLO jeringas y agujas estériles, de un solo uso (desechables).\n• Deseche los objetos punzantes en un contenedor rígido adecuado.';
	@override String get como_usar_titulo => '📱 CÓMO USAR LA APLICACIÓN';
	@override String get como_usar_texto => '• Banco de Medicamentos: Centro de gestión. Registre sus viales y dosis.\n\n• Calculadoras Inteligentes: Acceda a la Calculadora Central (Ícono Jeringa). Use el "Asistente de Reconstitución" para calcular la dilución de Polvos Liofilizados (Péptidos/GH) usando Agua Bacteriostática, o la Calculadora de Etiqueta en el propio formulario.\n\n• Simulador de Ciclos: Nueva herramienta interactiva. Traza un gráfico de liberación diaria en sangre calculando la vida media, el Principio de Superposición (acumulación) y el peso del éster.\n\n• Mix Seguro: Agrupe compuestos en la misma jeringa. La app suma los volúmenes finales de forma segura.\n\n• Cronograma Inteligente: El motor desvía colisiones en el mismo sitio. Tiene un bloqueo de seguridad que obliga a concluir la inyección actual antes de avanzar a fechas futuras.';
	@override String get cerebro_titulo => '🧬 CEREBRO ANALÍTICO Y EXÁMENES';
	@override String get cerebro_texto => 'La aplicación cuenta con un Motor Predictivo de seguridad:\n\n• Perfil Biométrico: Cruza su edad, peso y sexo biológico con la farmacología del tratamiento para sugerir paneles de sangre exactos.\n\n• Protocolo Pre-Examen: Antes de la recolección, el sistema impone un riguroso Checklist Clínico (Ayuno, Pausa de Entrenamiento/CPK, Reposo Pélvico, etc.) para evitar falsos positivos.\n\n• Alerta de Biomarcadores: La primera ventana ideal ("steady state") se sugiere 45 días después de iniciar un tratamiento nuevo. Los mantenimientos siguen cada 120 días.';
	@override String get notificacoes_titulo => '🔔 MOTOR DE NOTIFICACIONES NATIVAS';
	@override String get notificacoes_texto => 'Para garantizar el máximo rendimiento y ahorrar batería, nuestro motor adopta una arquitectura silenciosa:\n\n• Fila Anti-Spam: Dispositivos recientes bloquean abusos de alarmas (límite de 500/app). Por lo tanto, la app programa solo las próximas 60 inyecciones en la raíz del sistema.\n\n• Auto-abastecimiento: A medida que aplica sus dosis y hace "Check" en la app, la fila avanza, y las inyecciones futuras se programan automáticamente en segundo plano.';
	@override String get seringas_titulo => '💉 GUÍA DE JERINGAS Y AGUJAS';
	@override String get seringas_subtitulo => 'Entienda el material adecuado para cada aplicación:';
	@override String get seringas_btn => 'Ver Agujas y Jeringas';
	@override String get seringas_texto1 => '💉 AGUJAS RECOMENDADAS:';
	@override String get seringas_texto2 => '• Subcutánea (SC - Grasa): Agujas cortas y finas, ej: 13x0.45mm o 13x0.3mm (marrón/gris). Aplicada en ángulo de 90° o 45° dependiendo del tejido adiposo.\n• Intramuscular (IM - Músculo): Agujas largas para alcanzar el músculo, ej: 25x0.7mm o 30x0.7mm (negro/azul) y para volúmenes mayores 25x0.8mm (verde). Aplicar en ángulo de 90°.';
	@override String get seringas_texto3 => '🧪 JERINGAS Y ESCALAS:';
	@override String get seringas_texto4 => '• Jeringas de Insulina (100 UI = 1 mL): Escala detallada. 10 UI equivale a 0.1 mL. Ideal para microdosis subcutáneas de alta precisión.\n• Jeringas de 3 mL o 5 mL: Usadas para aplicaciones intramusculares que requieren un mayor volumen de diluyente o aceite.';
	@override String get mapas_titulo => '🗺️ MAPA DE PUNTOS DE APLICACIÓN';
	@override String get mapas_alerta_titulo => 'ACTUALIZACIÓN CLÍNICA (IM)';
	@override String get mapas_alerta_texto => '✅ El Ventroglúteo es hoy considerado el estándar de oro y el sitio más seguro para inyecciones intramusculares, por estar totalmente libre de grandes vasos y nervios.\n\n❌ El antiguo "Dorsoglúteo" (cuadrante superior externo) está siendo abandonado en la práctica clínica actual. Ofrece un alto riesgo de lesión del nervio ciático y presenta más riesgos que beneficios.';
	@override String get mapas_subtitulo => 'Haga clic en la región para ver las ubicaciones exactas y rotar correctamente:';
	@override String get mapas_btn1 => 'Puntos del Vientre (8 Puntos)';
	@override String get mapas_btn2 => 'Puntos de los Flancos (9 Puntos)';
	@override String get mapas_btn3 => 'Puntos de los Glúteos (Ventro/Dorso)';
	@override String get mapas_btn4 => 'Puntos del Muslo (Vasto Lateral)';
	@override String get mapas_btn5 => 'Puntos del Deltoides (Brazo)';
	@override String get dicionario_titulo => '📖 DICCIONARIO GYM Y CLÍNICO';
	@override String get dicionario_subtitulo => 'El dialecto de los gimnasios y tratamientos, traducido directamente:';
	@override String get dic_cat1 => '💪 SOBRE EL FÍSICO (CUERPO)';
	@override String get dic_cat2 => '🏋️ SOBRE EL ENTRENAMIENTO';
	@override String get dic_cat3 => '🥦 SOBRE LA DIETA';
	@override String get dic_cat4 => '💉 SOBRE LOS INYECTABLES Y "ADITIVOS"';
}

// Path: biometria
class _Translations$biometria$es extends Translations$biometria$pt {
	_Translations$biometria$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get motivo => 'Desbloquee para acceder a sus datos clínicos';
	@override String get erro_cancelado => 'Biometría cancelada. Intente de nuevo o use la contraseña de la App.';
	@override String get erro_sensor => 'Error en el sensor biométrico.';
	@override String get titulo => 'Aplicación Bloqueada';
	@override String get subtitulo => 'Protegiendo su historial clínico...';
	@override String get btn_biometria => 'USAR BIOMETRÍA';
	@override String get btn_senha => 'ACCEDER CON CONTRASEÑA DE LA APP';
}

// Path: visualizador
class _Translations$visualizador$es extends Translations$visualizador$pt {
	_Translations$visualizador$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get erro_imagem => 'Imagen no encontrada.';
}

// Path: geral
class _Translations$geral$es extends Translations$geral$pt {
	_Translations$geral$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sim => 'Sí';
	@override String get nao => 'No';
	@override String get ok => 'OK';
	@override String get cancelar => 'Cancelar';
}

// Path: calculadora
class _Translations$calculadora$es extends Translations$calculadora$pt {
	_Translations$calculadora$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Calculadora de Inyectables';
	@override String get limpar => 'Limpiar Todo';
	@override String get aviso => '⚠️ Herramienta educativa. Confirme dosis con un profesional de la salud.';
	@override String get volume => 'Volumen Vial (mL)';
	@override String get concentracao => 'Concentración';
	@override String get assistente => 'Asistente de Reconstitución';
	@override String get dose_semanal => 'Dosis Semanal';
	@override String get intervalo => 'Intervalo (días)';
	@override String get unidade => 'Unidad';
	@override String get seringa => 'Jeringa (UI)';
	@override String get resultados => 'Resultados';
	@override String get selecoes_vazias => 'Haga las selecciones arriba para calcular la cantidad de fluido a extraer para la dosis deseada.';
	@override String get res_para_dose => 'Para la dosis de ';
	@override String get res_aspire => ', aspire el contenido de la jeringa hasta: ';
	@override String get res_ou => ' mL o ';
	@override String get res_unidades => ' unidades.';
	@override String get res_conc => 'Concentración del vial reconstituido:\n';
	@override String get res_contem => 'El vial contiene ';
	@override String get res_doses => ' dosis';
	@override String get res_de => ' de ';
	@override String get res_cada => ' cada una.';
	@override String get diluicao_titulo => 'Calculadora de Dilución';
	@override String get diluicao_desc => '¿Desea calcular la reconstitución o descubrir la concentración de un vial?\n\nEsto calculará automáticamente la Concentración cruzando la Masa Total de la sustancia con la cantidad de líquido.';
	@override String get passo1 => 'Cálculo\nPASO 1 DE 2:';
	@override String get passo1_label => 'Total de la Sustancia (mg)';
	@override String get passo1_hint => 'Ej: 5 (para viales de 5mg)';
	@override String get passo2 => 'Cálculo\nPASO 2 DE 2:';
	@override String get passo2_label => 'Volumen del Líquido (mL)';
	@override String get passo2_hint => '¿Cuántos mL totales tiene el vial?';
	@override String get msg_sucesso => '¡Dilución calculada con éxito!';
	@override String get msg_invalido => 'Valores inválidos.';
	@override String get simulador_titulo => 'Simulador de Liberación (Farmacocinética)';
	@override String get simulador_desc => 'Prueba: 2 inyecciones de 250mg de Enantato (Día 0 y Día 7)';
}

// Path: simulador
class _Translations$simulador$es extends Translations$simulador$pt {
	_Translations$simulador$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Simulador de Ciclos';
	@override String get subtitulo => 'Elabore su protocolo';
	@override String get nome_ciclo => 'Nombre del Ciclo (opcional)';
	@override String get duracao => 'Duración';
	@override String semanas({required Object s}) => '${s} semanas';
	@override String get composto_title => 'Compuesto(s)';
	@override String composto_n({required Object n}) => 'Compuesto #${n}';
	@override String get remover => 'Eliminar Compuesto';
	@override String get dose => 'Dosis (mg)';
	@override String get categoria => 'Categoría';
	@override String get selecione => 'Seleccione el compuesto';
	@override String get esquema => 'Esquema de dosificación (Programar)';
	@override String get freq_1 => 'Diariamente';
	@override String get freq_2 => 'Un día sí, un día no';
	@override String get freq_3 => 'Cada 3 días';
	@override String get freq_4 => 'Cada 4 días';
	@override String get freq_5 => 'Cada 5 días';
	@override String get freq_7 => 'Cada 7 días (1x/sem)';
	@override String get freq_14 => 'Cada 14 días';
	@override String get de_sem => 'De (Semana)';
	@override String get ate_sem => 'Hasta (Semana)';
	@override String semana_n({required Object s}) => 'Semana ${s}';
	@override String get btn_trama => 'Simular';
	@override String get btn_adicionar => 'Añadir Compuesto';
	@override String get btn_reiniciar => 'Reiniciar';
	@override String get grafico_titulo => 'Liberación Diaria de Fármaco Activo (mg)';
	@override String get grafico_nota => 'Nota: La línea representa los miligramos efectivos liberados en la sangre cada día, aplicando el principio de superposición (acumulación) y el peso del éster.';
}

// Path: dashboard_alertas
class _Translations$dashboard_alertas$es extends Translations$dashboard_alertas$pt {
	_Translations$dashboard_alertas$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String atencao_coleta({required Object dias}) => '¡Atención! Recolección en ${dias} día(s)';
	@override String get texto_protecao => 'Su período de protección biométrica ha comenzado. Abra la lista de verificación clínica para no invalidar los resultados.';
	@override String get btn_abrir_checklist => 'ABRIR LISTA CLÍNICA';
	@override String get coleta_agendada => 'Recolección Programada';
	@override String texto_exames({required Object dias, required Object data}) => 'Tiene exámenes programados para dentro de ${dias} días (${data}).';
	@override String get btn_ver_painel => 'VER PANEL Y REPROGRAMAR';
	@override String get label_mix => 'Mix: ';
	@override String get label_data => 'Fecha: ';
	@override String get label_local => 'Sitio: ';
	@override String get label_dose => 'Dosis: ';
}

// Path: regioes
class _Translations$regioes$es extends Translations$regioes$pt {
	_Translations$regioes$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get selecione => 'Seleccione los Sitios';
	@override String get nenhum => 'Ninguno';
	@override String selecionados({required Object qtd}) => '${qtd} seleccionado(s)';
	@override String get confirmar => 'CONFIRMAR';
	@override String get cancelar => 'Cancelar';
	@override String get ventro_gluteo => 'Ventroglúteo (IM)';
	@override String get vasto_lateral => 'Vasto Lateral (IM)';
	@override String get deltoide => 'Deltoides (IM)';
	@override String get gluteo_superior => 'Glúteo Superior (IM)';
	@override String get barriga => 'Vientre (SC)';
	@override String get flanco => 'Flanco (SC)';
	@override String get perna_anterior => 'Pierna Anterior (SC)';
	@override String get braco_triceps => 'Tríceps (SC)';
}

// Path: formulario_extras
class _Translations$formulario_extras$es extends Translations$formulario_extras$pt {
	_Translations$formulario_extras$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get dialogo_rotulo_titulo => 'Llenado Seguro';
	@override String get dialogo_rotulo_desc => '¿Desea utilizar la Calculadora automática de Etiquetas?\n\nEsto evita errores en la conversión de medicamentos como Tirzepatida o Semaglutida.';
	@override String get seringa_30 => '30 UI (0.3 mL)';
	@override String get seringa_50 => '50 UI (0.5 mL)';
	@override String get seringa_100 => '100 UI (1 mL)';
	@override String get seringa_3ml => 'Jeringa de 3 mL';
	@override String get seringa_5ml => 'Jeringa de 5 mL';
	@override String get assistente => 'Asistente';
}

// Path: exames
class _Translations$exames$es extends Translations$exames$pt {
	_Translations$exames$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get checklist_titulo => 'Protocolo Pre-Examen';
	@override String get checklist_subtitulo => 'Confirme las reglas a continuación para evitar falsos positivos en sus resultados hormonales.';
	@override String get item1_tit => '1. Ayuno Estricto (8 a 12h)';
	@override String get item1_desc => 'Obligatorio para Insulina Basal y Glucemia. Máx 14h. ¡Beba mucha agua, está permitida!';
	@override String get item2_tit => '2. Pausa de Entrenamiento (48h)';
	@override String get item2_desc => 'Suspenda las pesas. Las microlesiones elevan falsamente la CPK, Creatinina y AST.';
	@override String get item3_tit => '3. Reposo Pélvico (72h)';
	@override String get item3_desc => 'Sin eyaculación (evita picos falsos de Prolactina y PSA). No ande en moto o bicicleta.';
	@override String get item4_tit => '4. Protección Hepática (72h)';
	@override String get item4_desc => 'Cero alcohol para no generar picos agudos de GGT, Triglicéridos e inflamación sistémica.';
	@override String get item5_tit => '5. Horario de Recolección';
	@override String get item5_desc => 'Recolección estricta entre 07h y 09h AM para captar Testosterona, TSH y Prolactina en su pico basal.';
	@override String get item6_tit => '6. Fidelidad al Ciclo';
	@override String get item6_desc => 'No pause ni retrase las inyecciones en la app. El examen debe reflejar la cinética hormonal real.';
	@override String get btn_confirmar => 'CONFIRMAR CHECKLIST';
	@override String get painel_titulo => 'Sugerencia de Laboratorio';
	@override String get painel_subtitulo => 'Lista personalizada cruzando sexo biológico, edad, peso y protocolo activo.';
	@override String get btn_agendar => 'PROGRAMAR FECHA DE RECOLECCIÓN';
	@override String get btn_ja_fiz => 'YA HICE LA RECOLECCIÓN';
	@override String get btn_copiar_medico => 'COPIAR LISTA PARA EL MÉDICO';
	@override String get btn_enviar_email => 'ENVIAR A MI CORREO';
	@override String get msg_selecione_bloco => 'Seleccione al menos un bloque de exámenes.';
	@override String get email_assunto => 'Sugerencia de Exámenes - Control de Inyectables';
	@override String get msg_copiado => '¡Lista copiada! Péguela en un mensaje o llévela a su consulta.';
	@override String get aviso_clinico => 'Aviso: Sugerencia informativa para discusión médica. No sustituye la evaluación profesional; su médico puede ajustar los intervalos.';
	@override String get sec_laboratoriais => 'Laboratorio';
	@override String get sec_protocolo => 'Específicos del Protocolo';
	@override String get sec_ponderal => 'Perfil Ponderal y Metabólico';
	@override String get sec_cardiologicos => 'Cardiológicos';
	@override String get sec_imagem => 'Imagen y Tamizaje';
	@override String get primeiro_exame => '1er Examen';
	@override String get periodicidade => 'Periodicidad';
	@override late final _Translations$exames$nomes$es nomes = _Translations$exames$nomes$es._(_root);
}

// Path: complementos
class _Translations$complementos$es extends Translations$complementos$pt {
	_Translations$complementos$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String intervalo_cada({required Object dias}) => 'Intervalo: Cada ${dias} días';
	@override String get masculino => 'Masculino';
	@override String get feminino => 'Femenino';
	@override String get selecione_erro => 'Seleccione';
	@override String seringa_intervalo({required Object seringa, required Object dias}) => 'Jeringa: ${seringa} UI | Intervalo: ${dias} días';
}

// Path: navegacao
class _Translations$navegacao$es extends Translations$navegacao$pt {
	_Translations$navegacao$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get inicio => 'Inicio';
	@override String get tratamento => 'Tratamiento';
	@override String get ferramentas => 'Herramientas';
	@override String get perfil => 'Perfil';
}

// Path: exames.nomes
class _Translations$exames$nomes$es extends Translations$exames$nomes$pt {
	_Translations$exames$nomes$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get hemo => 'Hemograma Completo';
	@override String get marcadores => 'Marcadores Inflamatorios (PCR y Ferritina)';
	@override String get lipidico => 'Perfil Lipídico (Colesterol Total, HDL, LDL, VLDL, Triglicéridos)';
	@override String get figado => 'Función Hepática (AST, ALT, GGT)';
	@override String get rim => 'Función Renal (Urea y Creatinina)';
	@override String get cpk => 'Daño Muscular (CPK)';
	@override String get testo => 'Testosterona Total y Libre';
	@override String get e2 => 'Estradiol (E2)';
	@override String get shbg => 'SHBG';
	@override String get dht => 'DHT (Dihidrotestosterona)';
	@override String get prolactina => 'Prolactina';
	@override String get tireoide => 'Tiroides (TSH y T4 Libre)';
	@override String get psa => 'PSA Total y Libre (Próstata)';
	@override String get glicemia => 'Glucemia en Ayunas';
	@override String get insulina => 'Insulina Basal';
	@override String get hba1c => 'Hemoglobina Glicosilada (HbA1c)';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'notificacoes.titulo_injecao' => '¡Día de Inyección! 💉',
			'notificacoes.corpo_injecao' => ({required Object medicamento, required Object local}) => 'Hoy es el día de aplicar ${medicamento} (${local}).',
			'erros.sem_internet' => 'Verifique su conexión a internet e intente de nuevo.',
			'erros.falha_app' => 'Error al iniciar la aplicación',
			'login.titulo' => 'Control de Inyectables',
			'login.email' => 'Correo electrónico',
			'login.senha' => 'Contraseña',
			'login.entrar' => 'ENTRAR',
			'login.criar_conta' => 'CREAR NUEVA CUENTA',
			'login.esqueci_senha' => 'Olvidé mi contraseña',
			'perfil.titulo' => 'Mi Perfil',
			'perfil.idioma' => 'Idioma',
			'perfil.dados_biologicos' => 'Datos Biológicos',
			'perfil.descricao_biologicos' => 'Esta información es esencial para que la aplicación cruce su edad, sexo biológico y peso, generando paneles de análisis clínicos precisos y seguros.',
			'perfil.nome' => 'Nombre Completo',
			'perfil.peso' => 'Peso (kg)',
			'perfil.sexo' => 'Sexo Biológico',
			'perfil.data_nascimento' => 'Fecha de Nacimiento (DD/MM/AAAA)',
			'perfil.btn_salvar' => 'GUARDAR PERFIL',
			'perfil.msg_sucesso' => '¡Perfil guardado con éxito!',
			'perfil.msg_erro' => 'Error al guardar: ',
			'perfil.erro_sexo' => 'Por favor, seleccione el sexo biológico.',
			'perfil.erro_data' => 'Ingrese una fecha de nacimiento válida (DD/MM/AAAA).',
			'guia.titulo' => 'Guía y Términos de Uso',
			'guia.aviso_scroll' => '⬇️ Desplácese hasta el final para habilitar la aceptación.',
			'guia.texto_aceite' => 'Declaro que he leído las instrucciones, soy consciente de los riesgos médicos y acepto los Términos de Responsabilidad e Isención.',
			'guia.btn_aceitar' => 'ESTOY CONSCIENTE Y ACEPTO',
			'guia.msg_sucesso' => '¡Términos aceptados y registrados. Acceso concedido!',
			'guia.msg_erro' => 'Error al registrar: ',
			'guia.tooltip_sair' => 'Salir de la App',
			'dashboard.titulo' => 'Tratamiento',
			'dashboard.resumo_clinico' => 'Resumen Clínico',
			'dashboard.proxima_aplicacao' => 'Próxima Inyección',
			'dashboard.ultima_aplicacao' => 'Última Inyección',
			'dashboard.gerir_medicamentos' => 'GESTIONAR MEDICAMENTOS',
			'dashboard.nenhuma_aplicacao' => 'No hay inyecciones futuras programadas.',
			'dashboard.nenhum_historico' => 'No hay historial de aplicaciones.',
			'setup.titulo' => 'Banco de Medicamentos',
			'setup.btn_novo' => 'NUEVO',
			'setup.nenhum_medicamento' => 'No hay medicamentos configurados.',
			'setup.simulador_titulo' => 'Simulador de Ciclos',
			'setup.simulador_subtitulo' => 'Planifique sus protocolos y visualice la liberación en sangre.',
			'formulario.titulo_novo' => 'Nuevo Medicamento',
			'formulario.titulo_editar' => 'Editar Medicamento',
			'formulario.btn_atualizar' => 'ACTUALIZAR MEDICAMENTO',
			'formulario.btn_guardar' => 'GUARDAR MEDICAMENTO',
			'formulario.btn_arquivar' => 'FINALIZAR TRATAMIENTO (ARCHIVAR)',
			'formulario.campo_mix' => 'Mix Seleccionado',
			'formulario.campo_medicamento' => 'Medicamento (Escribir)',
			'formulario.campo_catalogo' => 'Catálogo (Buscar...)',
			'formulario.btn_novo_catalogo' => 'NUEVO',
			'formulario.btn_abrir_catalogo' => 'CATÁLOGO',
			'formulario.btn_criar_mix' => 'CREAR MIX',
			'formulario.modo_mix_titulo' => 'MODO MIX ACTIVADO',
			'formulario.modo_mix_editar' => 'Puede cambiar Intervalo, Jeringa y Sitios libremente. Para cambiar DOSIS base, haga clic en DESARMAR MIX.',
			'formulario.modo_mix_novo' => 'Intervalo, Jeringa y Región fueron importados automáticamente.',
			'formulario.campo_intervalo' => 'Intervalo (días)',
			'formulario.qtd_curto' => 'Cant. Viales',
			'formulario.vol_curto' => 'Vol. (mL)',
			'formulario.conc_curto' => 'Conc. (mg/mL)',
			'formulario.campo_dose_semanal' => 'Dosis Semanal',
			'formulario.campo_unidade' => 'Unidad',
			'formulario.resultado_dose' => 'Dosis Calculada por Inyección:',
			'formulario.resultado_vazio' => 'Esperando valores...',
			'formulario.campo_seringa' => 'Jeringa (UI)',
			'formulario.campo_locais' => 'Sitios de Rotación',
			'formulario.campo_data' => 'Fecha de Inicio',
			'formulario.campo_hora' => 'Hora de Aplicación',
			'formulario.freq_intervalo' => 'Intervalo (Días)',
			'formulario.freq_dias_semana' => 'Días de la Semana',
			'formulario.dias_semana."1"' => 'Lun',
			'formulario.dias_semana."2"' => 'Mar',
			'formulario.dias_semana."3"' => 'Mié',
			'formulario.dias_semana."4"' => 'Jue',
			'formulario.dias_semana."5"' => 'Vie',
			'formulario.dias_semana."6"' => 'Sáb',
			'formulario.dias_semana."7"' => 'Dom',
			'cronograma.titulo' => ({required Object nome}) => 'Cronograma: ${nome}',
			'cronograma.btn_gerar_novo' => 'GENERAR NUEVO CICLO',
			'cronograma.nenhum_gerado' => 'No hay cronograma generado aún.',
			'cronograma.btn_gerar' => 'GENERAR CRONOGRAMA',
			'cronograma.info_seringa' => ({required Object seringa, required Object intervalo}) => 'Jeringa: ${seringa} UI | Intervalo: ${intervalo} días',
			'guia_conteudo.termos_titulo' => '⚖️ TÉRMINOS DE RESPONSABILIDAD',
			'guia_conteudo.termos_texto' => 'Al usar Control Inyectables, el usuario declara estar plenamente consciente de que:\n\n1. El usuario asume TOTAL y exclusiva responsabilidad por las dosis, mezclas (Mix) y protocolos generados.\n2. CodeVibe Studio NO se responsabiliza por errores de llenado o cálculos equivocados generados por datos incorrectos.\n3. El "Chequeo de Biomarcadores" y el "Simulador de Ciclos" son estimaciones puramente matemáticas orientadas a la reducción de daños. NO tienen valor de prescripción o consejo médico.\n4. El usuario exime a los creadores de cualquier complicación clínica derivada del uso de esta herramienta logística.',
			'guia_conteudo.aviso_titulo' => '🚨 AVISO MÉDICO IMPORTANTE',
			'guia_conteudo.aviso_texto' => 'Esta aplicación es exclusivamente una herramienta de apoyo logístico y matemático. NO SUSTITUYE LA ORIENTACIÓN MÉDICA.\n\n• La app no receta, no prescribe y no recomienda tratamientos.\n• En caso de dolor extremo, fiebre, enrojecimiento intenso, hinchazón, falta de aire o cualquier malestar después de una aplicación, BUSQUE UNA EMERGENCIA HOSPITALARIA INMEDIATAMENTE o contacte a su médico.\n• Nunca inicie o altere dosis sin el conocimiento y autorización de su profesional de salud.',
			'guia_conteudo.higiene_titulo' => '🧼 HIGIENE Y ASEPSIA',
			'guia_conteudo.higiene_texto' => 'La falta de higiene puede causar infecciones graves y abscesos. Siga estrictamente:\n\n• Lávese las manos con agua y jabón antes de tocar los materiales.\n• Limpie la goma del vial con algodón y Alcohol al 70%.\n• Realice la asepsia de la piel con Alcohol al 70% y deje secar al aire antes de perforar.\n• Utilice SOLO jeringas y agujas estériles, de un solo uso (desechables).\n• Deseche los objetos punzantes en un contenedor rígido adecuado.',
			'guia_conteudo.como_usar_titulo' => '📱 CÓMO USAR LA APLICACIÓN',
			'guia_conteudo.como_usar_texto' => '• Banco de Medicamentos: Centro de gestión. Registre sus viales y dosis.\n\n• Calculadoras Inteligentes: Acceda a la Calculadora Central (Ícono Jeringa). Use el "Asistente de Reconstitución" para calcular la dilución de Polvos Liofilizados (Péptidos/GH) usando Agua Bacteriostática, o la Calculadora de Etiqueta en el propio formulario.\n\n• Simulador de Ciclos: Nueva herramienta interactiva. Traza un gráfico de liberación diaria en sangre calculando la vida media, el Principio de Superposición (acumulación) y el peso del éster.\n\n• Mix Seguro: Agrupe compuestos en la misma jeringa. La app suma los volúmenes finales de forma segura.\n\n• Cronograma Inteligente: El motor desvía colisiones en el mismo sitio. Tiene un bloqueo de seguridad que obliga a concluir la inyección actual antes de avanzar a fechas futuras.',
			'guia_conteudo.cerebro_titulo' => '🧬 CEREBRO ANALÍTICO Y EXÁMENES',
			'guia_conteudo.cerebro_texto' => 'La aplicación cuenta con un Motor Predictivo de seguridad:\n\n• Perfil Biométrico: Cruza su edad, peso y sexo biológico con la farmacología del tratamiento para sugerir paneles de sangre exactos.\n\n• Protocolo Pre-Examen: Antes de la recolección, el sistema impone un riguroso Checklist Clínico (Ayuno, Pausa de Entrenamiento/CPK, Reposo Pélvico, etc.) para evitar falsos positivos.\n\n• Alerta de Biomarcadores: La primera ventana ideal ("steady state") se sugiere 45 días después de iniciar un tratamiento nuevo. Los mantenimientos siguen cada 120 días.',
			'guia_conteudo.notificacoes_titulo' => '🔔 MOTOR DE NOTIFICACIONES NATIVAS',
			'guia_conteudo.notificacoes_texto' => 'Para garantizar el máximo rendimiento y ahorrar batería, nuestro motor adopta una arquitectura silenciosa:\n\n• Fila Anti-Spam: Dispositivos recientes bloquean abusos de alarmas (límite de 500/app). Por lo tanto, la app programa solo las próximas 60 inyecciones en la raíz del sistema.\n\n• Auto-abastecimiento: A medida que aplica sus dosis y hace "Check" en la app, la fila avanza, y las inyecciones futuras se programan automáticamente en segundo plano.',
			'guia_conteudo.seringas_titulo' => '💉 GUÍA DE JERINGAS Y AGUJAS',
			'guia_conteudo.seringas_subtitulo' => 'Entienda el material adecuado para cada aplicación:',
			'guia_conteudo.seringas_btn' => 'Ver Agujas y Jeringas',
			'guia_conteudo.seringas_texto1' => '💉 AGUJAS RECOMENDADAS:',
			'guia_conteudo.seringas_texto2' => '• Subcutánea (SC - Grasa): Agujas cortas y finas, ej: 13x0.45mm o 13x0.3mm (marrón/gris). Aplicada en ángulo de 90° o 45° dependiendo del tejido adiposo.\n• Intramuscular (IM - Músculo): Agujas largas para alcanzar el músculo, ej: 25x0.7mm o 30x0.7mm (negro/azul) y para volúmenes mayores 25x0.8mm (verde). Aplicar en ángulo de 90°.',
			'guia_conteudo.seringas_texto3' => '🧪 JERINGAS Y ESCALAS:',
			'guia_conteudo.seringas_texto4' => '• Jeringas de Insulina (100 UI = 1 mL): Escala detallada. 10 UI equivale a 0.1 mL. Ideal para microdosis subcutáneas de alta precisión.\n• Jeringas de 3 mL o 5 mL: Usadas para aplicaciones intramusculares que requieren un mayor volumen de diluyente o aceite.',
			'guia_conteudo.mapas_titulo' => '🗺️ MAPA DE PUNTOS DE APLICACIÓN',
			'guia_conteudo.mapas_alerta_titulo' => 'ACTUALIZACIÓN CLÍNICA (IM)',
			'guia_conteudo.mapas_alerta_texto' => '✅ El Ventroglúteo es hoy considerado el estándar de oro y el sitio más seguro para inyecciones intramusculares, por estar totalmente libre de grandes vasos y nervios.\n\n❌ El antiguo "Dorsoglúteo" (cuadrante superior externo) está siendo abandonado en la práctica clínica actual. Ofrece un alto riesgo de lesión del nervio ciático y presenta más riesgos que beneficios.',
			'guia_conteudo.mapas_subtitulo' => 'Haga clic en la región para ver las ubicaciones exactas y rotar correctamente:',
			'guia_conteudo.mapas_btn1' => 'Puntos del Vientre (8 Puntos)',
			'guia_conteudo.mapas_btn2' => 'Puntos de los Flancos (9 Puntos)',
			'guia_conteudo.mapas_btn3' => 'Puntos de los Glúteos (Ventro/Dorso)',
			'guia_conteudo.mapas_btn4' => 'Puntos del Muslo (Vasto Lateral)',
			'guia_conteudo.mapas_btn5' => 'Puntos del Deltoides (Brazo)',
			'guia_conteudo.dicionario_titulo' => '📖 DICCIONARIO GYM Y CLÍNICO',
			'guia_conteudo.dicionario_subtitulo' => 'El dialecto de los gimnasios y tratamientos, traducido directamente:',
			'guia_conteudo.dic_cat1' => '💪 SOBRE EL FÍSICO (CUERPO)',
			'guia_conteudo.dic_cat2' => '🏋️ SOBRE EL ENTRENAMIENTO',
			'guia_conteudo.dic_cat3' => '🥦 SOBRE LA DIETA',
			'guia_conteudo.dic_cat4' => '💉 SOBRE LOS INYECTABLES Y "ADITIVOS"',
			'biometria.motivo' => 'Desbloquee para acceder a sus datos clínicos',
			'biometria.erro_cancelado' => 'Biometría cancelada. Intente de nuevo o use la contraseña de la App.',
			'biometria.erro_sensor' => 'Error en el sensor biométrico.',
			'biometria.titulo' => 'Aplicación Bloqueada',
			'biometria.subtitulo' => 'Protegiendo su historial clínico...',
			'biometria.btn_biometria' => 'USAR BIOMETRÍA',
			'biometria.btn_senha' => 'ACCEDER CON CONTRASEÑA DE LA APP',
			'visualizador.erro_imagem' => 'Imagen no encontrada.',
			'geral.sim' => 'Sí',
			'geral.nao' => 'No',
			'geral.ok' => 'OK',
			'geral.cancelar' => 'Cancelar',
			'calculadora.titulo' => 'Calculadora de Inyectables',
			'calculadora.limpar' => 'Limpiar Todo',
			'calculadora.aviso' => '⚠️ Herramienta educativa. Confirme dosis con un profesional de la salud.',
			'calculadora.volume' => 'Volumen Vial (mL)',
			'calculadora.concentracao' => 'Concentración',
			'calculadora.assistente' => 'Asistente de Reconstitución',
			'calculadora.dose_semanal' => 'Dosis Semanal',
			'calculadora.intervalo' => 'Intervalo (días)',
			'calculadora.unidade' => 'Unidad',
			'calculadora.seringa' => 'Jeringa (UI)',
			'calculadora.resultados' => 'Resultados',
			'calculadora.selecoes_vazias' => 'Haga las selecciones arriba para calcular la cantidad de fluido a extraer para la dosis deseada.',
			'calculadora.res_para_dose' => 'Para la dosis de ',
			'calculadora.res_aspire' => ', aspire el contenido de la jeringa hasta: ',
			'calculadora.res_ou' => ' mL o ',
			'calculadora.res_unidades' => ' unidades.',
			'calculadora.res_conc' => 'Concentración del vial reconstituido:\n',
			'calculadora.res_contem' => 'El vial contiene ',
			'calculadora.res_doses' => ' dosis',
			'calculadora.res_de' => ' de ',
			'calculadora.res_cada' => ' cada una.',
			'calculadora.diluicao_titulo' => 'Calculadora de Dilución',
			'calculadora.diluicao_desc' => '¿Desea calcular la reconstitución o descubrir la concentración de un vial?\n\nEsto calculará automáticamente la Concentración cruzando la Masa Total de la sustancia con la cantidad de líquido.',
			'calculadora.passo1' => 'Cálculo\nPASO 1 DE 2:',
			'calculadora.passo1_label' => 'Total de la Sustancia (mg)',
			'calculadora.passo1_hint' => 'Ej: 5 (para viales de 5mg)',
			'calculadora.passo2' => 'Cálculo\nPASO 2 DE 2:',
			'calculadora.passo2_label' => 'Volumen del Líquido (mL)',
			'calculadora.passo2_hint' => '¿Cuántos mL totales tiene el vial?',
			'calculadora.msg_sucesso' => '¡Dilución calculada con éxito!',
			'calculadora.msg_invalido' => 'Valores inválidos.',
			'calculadora.simulador_titulo' => 'Simulador de Liberación (Farmacocinética)',
			'calculadora.simulador_desc' => 'Prueba: 2 inyecciones de 250mg de Enantato (Día 0 y Día 7)',
			'simulador.titulo' => 'Simulador de Ciclos',
			'simulador.subtitulo' => 'Elabore su protocolo',
			'simulador.nome_ciclo' => 'Nombre del Ciclo (opcional)',
			'simulador.duracao' => 'Duración',
			'simulador.semanas' => ({required Object s}) => '${s} semanas',
			'simulador.composto_title' => 'Compuesto(s)',
			'simulador.composto_n' => ({required Object n}) => 'Compuesto #${n}',
			'simulador.remover' => 'Eliminar Compuesto',
			'simulador.dose' => 'Dosis (mg)',
			'simulador.categoria' => 'Categoría',
			'simulador.selecione' => 'Seleccione el compuesto',
			'simulador.esquema' => 'Esquema de dosificación (Programar)',
			'simulador.freq_1' => 'Diariamente',
			'simulador.freq_2' => 'Un día sí, un día no',
			'simulador.freq_3' => 'Cada 3 días',
			'simulador.freq_4' => 'Cada 4 días',
			'simulador.freq_5' => 'Cada 5 días',
			'simulador.freq_7' => 'Cada 7 días (1x/sem)',
			'simulador.freq_14' => 'Cada 14 días',
			'simulador.de_sem' => 'De (Semana)',
			'simulador.ate_sem' => 'Hasta (Semana)',
			'simulador.semana_n' => ({required Object s}) => 'Semana ${s}',
			'simulador.btn_trama' => 'Simular',
			'simulador.btn_adicionar' => 'Añadir Compuesto',
			'simulador.btn_reiniciar' => 'Reiniciar',
			'simulador.grafico_titulo' => 'Liberación Diaria de Fármaco Activo (mg)',
			'simulador.grafico_nota' => 'Nota: La línea representa los miligramos efectivos liberados en la sangre cada día, aplicando el principio de superposición (acumulación) y el peso del éster.',
			'dashboard_alertas.atencao_coleta' => ({required Object dias}) => '¡Atención! Recolección en ${dias} día(s)',
			'dashboard_alertas.texto_protecao' => 'Su período de protección biométrica ha comenzado. Abra la lista de verificación clínica para no invalidar los resultados.',
			'dashboard_alertas.btn_abrir_checklist' => 'ABRIR LISTA CLÍNICA',
			'dashboard_alertas.coleta_agendada' => 'Recolección Programada',
			'dashboard_alertas.texto_exames' => ({required Object dias, required Object data}) => 'Tiene exámenes programados para dentro de ${dias} días (${data}).',
			'dashboard_alertas.btn_ver_painel' => 'VER PANEL Y REPROGRAMAR',
			'dashboard_alertas.label_mix' => 'Mix: ',
			'dashboard_alertas.label_data' => 'Fecha: ',
			'dashboard_alertas.label_local' => 'Sitio: ',
			'dashboard_alertas.label_dose' => 'Dosis: ',
			'regioes.selecione' => 'Seleccione los Sitios',
			'regioes.nenhum' => 'Ninguno',
			'regioes.selecionados' => ({required Object qtd}) => '${qtd} seleccionado(s)',
			'regioes.confirmar' => 'CONFIRMAR',
			'regioes.cancelar' => 'Cancelar',
			'regioes.ventro_gluteo' => 'Ventroglúteo (IM)',
			'regioes.vasto_lateral' => 'Vasto Lateral (IM)',
			'regioes.deltoide' => 'Deltoides (IM)',
			'regioes.gluteo_superior' => 'Glúteo Superior (IM)',
			'regioes.barriga' => 'Vientre (SC)',
			'regioes.flanco' => 'Flanco (SC)',
			'regioes.perna_anterior' => 'Pierna Anterior (SC)',
			'regioes.braco_triceps' => 'Tríceps (SC)',
			'formulario_extras.dialogo_rotulo_titulo' => 'Llenado Seguro',
			'formulario_extras.dialogo_rotulo_desc' => '¿Desea utilizar la Calculadora automática de Etiquetas?\n\nEsto evita errores en la conversión de medicamentos como Tirzepatida o Semaglutida.',
			'formulario_extras.seringa_30' => '30 UI (0.3 mL)',
			'formulario_extras.seringa_50' => '50 UI (0.5 mL)',
			'formulario_extras.seringa_100' => '100 UI (1 mL)',
			'formulario_extras.seringa_3ml' => 'Jeringa de 3 mL',
			'formulario_extras.seringa_5ml' => 'Jeringa de 5 mL',
			'formulario_extras.assistente' => 'Asistente',
			'exames.checklist_titulo' => 'Protocolo Pre-Examen',
			'exames.checklist_subtitulo' => 'Confirme las reglas a continuación para evitar falsos positivos en sus resultados hormonales.',
			'exames.item1_tit' => '1. Ayuno Estricto (8 a 12h)',
			'exames.item1_desc' => 'Obligatorio para Insulina Basal y Glucemia. Máx 14h. ¡Beba mucha agua, está permitida!',
			'exames.item2_tit' => '2. Pausa de Entrenamiento (48h)',
			'exames.item2_desc' => 'Suspenda las pesas. Las microlesiones elevan falsamente la CPK, Creatinina y AST.',
			'exames.item3_tit' => '3. Reposo Pélvico (72h)',
			'exames.item3_desc' => 'Sin eyaculación (evita picos falsos de Prolactina y PSA). No ande en moto o bicicleta.',
			'exames.item4_tit' => '4. Protección Hepática (72h)',
			'exames.item4_desc' => 'Cero alcohol para no generar picos agudos de GGT, Triglicéridos e inflamación sistémica.',
			'exames.item5_tit' => '5. Horario de Recolección',
			'exames.item5_desc' => 'Recolección estricta entre 07h y 09h AM para captar Testosterona, TSH y Prolactina en su pico basal.',
			'exames.item6_tit' => '6. Fidelidad al Ciclo',
			'exames.item6_desc' => 'No pause ni retrase las inyecciones en la app. El examen debe reflejar la cinética hormonal real.',
			'exames.btn_confirmar' => 'CONFIRMAR CHECKLIST',
			'exames.painel_titulo' => 'Sugerencia de Laboratorio',
			'exames.painel_subtitulo' => 'Lista personalizada cruzando sexo biológico, edad, peso y protocolo activo.',
			'exames.btn_agendar' => 'PROGRAMAR FECHA DE RECOLECCIÓN',
			'exames.btn_ja_fiz' => 'YA HICE LA RECOLECCIÓN',
			'exames.btn_copiar_medico' => 'COPIAR LISTA PARA EL MÉDICO',
			'exames.btn_enviar_email' => 'ENVIAR A MI CORREO',
			'exames.msg_selecione_bloco' => 'Seleccione al menos un bloque de exámenes.',
			'exames.email_assunto' => 'Sugerencia de Exámenes - Control de Inyectables',
			'exames.msg_copiado' => '¡Lista copiada! Péguela en un mensaje o llévela a su consulta.',
			'exames.aviso_clinico' => 'Aviso: Sugerencia informativa para discusión médica. No sustituye la evaluación profesional; su médico puede ajustar los intervalos.',
			'exames.sec_laboratoriais' => 'Laboratorio',
			'exames.sec_protocolo' => 'Específicos del Protocolo',
			'exames.sec_ponderal' => 'Perfil Ponderal y Metabólico',
			'exames.sec_cardiologicos' => 'Cardiológicos',
			'exames.sec_imagem' => 'Imagen y Tamizaje',
			'exames.primeiro_exame' => '1er Examen',
			'exames.periodicidade' => 'Periodicidad',
			'exames.nomes.hemo' => 'Hemograma Completo',
			'exames.nomes.marcadores' => 'Marcadores Inflamatorios (PCR y Ferritina)',
			'exames.nomes.lipidico' => 'Perfil Lipídico (Colesterol Total, HDL, LDL, VLDL, Triglicéridos)',
			'exames.nomes.figado' => 'Función Hepática (AST, ALT, GGT)',
			'exames.nomes.rim' => 'Función Renal (Urea y Creatinina)',
			'exames.nomes.cpk' => 'Daño Muscular (CPK)',
			'exames.nomes.testo' => 'Testosterona Total y Libre',
			'exames.nomes.e2' => 'Estradiol (E2)',
			'exames.nomes.shbg' => 'SHBG',
			'exames.nomes.dht' => 'DHT (Dihidrotestosterona)',
			'exames.nomes.prolactina' => 'Prolactina',
			'exames.nomes.tireoide' => 'Tiroides (TSH y T4 Libre)',
			'exames.nomes.psa' => 'PSA Total y Libre (Próstata)',
			'exames.nomes.glicemia' => 'Glucemia en Ayunas',
			'exames.nomes.insulina' => 'Insulina Basal',
			'exames.nomes.hba1c' => 'Hemoglobina Glicosilada (HbA1c)',
			'complementos.intervalo_cada' => ({required Object dias}) => 'Intervalo: Cada ${dias} días',
			'complementos.masculino' => 'Masculino',
			'complementos.feminino' => 'Femenino',
			'complementos.selecione_erro' => 'Seleccione',
			'complementos.seringa_intervalo' => ({required Object seringa, required Object dias}) => 'Jeringa: ${seringa} UI | Intervalo: ${dias} días',
			'navegacao.inicio' => 'Inicio',
			'navegacao.tratamento' => 'Tratamiento',
			'navegacao.ferramentas' => 'Herramientas',
			'navegacao.perfil' => 'Perfil',
			_ => null,
		};
	}
}
