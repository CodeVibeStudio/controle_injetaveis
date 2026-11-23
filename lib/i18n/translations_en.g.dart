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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$notificacoes$en notificacoes = _Translations$notificacoes$en._(_root);
	@override late final _Translations$erros$en erros = _Translations$erros$en._(_root);
	@override late final _Translations$login$en login = _Translations$login$en._(_root);
	@override late final _Translations$perfil$en perfil = _Translations$perfil$en._(_root);
	@override late final _Translations$guia$en guia = _Translations$guia$en._(_root);
	@override late final _Translations$dashboard$en dashboard = _Translations$dashboard$en._(_root);
	@override late final _Translations$setup$en setup = _Translations$setup$en._(_root);
	@override late final _Translations$formulario$en formulario = _Translations$formulario$en._(_root);
	@override late final _Translations$cronograma$en cronograma = _Translations$cronograma$en._(_root);
	@override late final _Translations$guia_conteudo$en guia_conteudo = _Translations$guia_conteudo$en._(_root);
	@override late final _Translations$biometria$en biometria = _Translations$biometria$en._(_root);
	@override late final _Translations$visualizador$en visualizador = _Translations$visualizador$en._(_root);
	@override late final _Translations$geral$en geral = _Translations$geral$en._(_root);
	@override late final _Translations$calculadora$en calculadora = _Translations$calculadora$en._(_root);
	@override late final _Translations$simulador$en simulador = _Translations$simulador$en._(_root);
	@override late final _Translations$dashboard_alertas$en dashboard_alertas = _Translations$dashboard_alertas$en._(_root);
	@override late final _Translations$regioes$en regioes = _Translations$regioes$en._(_root);
	@override late final _Translations$formulario_extras$en formulario_extras = _Translations$formulario_extras$en._(_root);
	@override late final _Translations$exames$en exames = _Translations$exames$en._(_root);
	@override late final _Translations$complementos$en complementos = _Translations$complementos$en._(_root);
	@override late final _Translations$navegacao$en navegacao = _Translations$navegacao$en._(_root);
	@override late final _Translations$evolucao$en evolucao = _Translations$evolucao$en._(_root);
	@override late final _Translations$cronograma_modal$en cronograma_modal = _Translations$cronograma_modal$en._(_root);
}

// Path: notificacoes
class _Translations$notificacoes$en extends Translations$notificacoes$pt {
	_Translations$notificacoes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo_injecao => 'Injection Day! 💉';
	@override String corpo_injecao({required Object medicamento, required Object local}) => 'Today is the day to inject ${medicamento} (${local}).';
}

// Path: erros
class _Translations$erros$en extends Translations$erros$pt {
	_Translations$erros$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sem_internet => 'Please check your internet connection and try again.';
	@override String get falha_app => 'Failed to start the application';
}

// Path: login
class _Translations$login$en extends Translations$login$pt {
	_Translations$login$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Injectables Control';
	@override String get email => 'Email';
	@override String get senha => 'Password';
	@override String get entrar => 'LOGIN';
	@override String get criar_conta => 'CREATE NEW ACCOUNT';
	@override String get esqueci_senha => 'Forgot my password';
}

// Path: perfil
class _Translations$perfil$en extends Translations$perfil$pt {
	_Translations$perfil$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'My Profile';
	@override String get idioma => 'Language';
	@override String get dados_biologicos => 'Biological Data';
	@override String get descricao_biologicos => 'This information is essential for the app to cross-reference your age, biological sex, and weight, generating accurate and safe clinical blood panels.';
	@override String get nome => 'Full Name';
	@override String get peso => 'Weight (kg)';
	@override String get sexo => 'Biological Sex';
	@override String get data_nascimento => 'Date of Birth (DD/MM/YYYY)';
	@override String get btn_salvar => 'SAVE PROFILE';
	@override String get msg_sucesso => 'Profile saved successfully!';
	@override String get msg_erro => 'Error saving: ';
	@override String get erro_sexo => 'Please select your biological sex.';
	@override String get erro_data => 'Enter a valid date of birth (DD/MM/YYYY).';
}

// Path: guia
class _Translations$guia$en extends Translations$guia$pt {
	_Translations$guia$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Guide and Terms of Use';
	@override String get aviso_scroll => '⬇️ Scroll to the bottom to enable acceptance.';
	@override String get texto_aceite => 'I declare that I have read the instructions, am aware of the medical risks, and accept the Terms of Responsibility and Exemption.';
	@override String get btn_aceitar => 'I UNDERSTAND AND ACCEPT';
	@override String get msg_sucesso => 'Terms accepted and registered. Access granted!';
	@override String get msg_erro => 'Error registering: ';
	@override String get tooltip_sair => 'Exit App';
}

// Path: dashboard
class _Translations$dashboard$en extends Translations$dashboard$pt {
	_Translations$dashboard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Treatment';
	@override String get resumo_clinico => 'Clinical Summary';
	@override String get proxima_aplicacao => 'Next Injection';
	@override String get ultima_aplicacao => 'Last Injection';
	@override String get gerir_medicamentos => 'MANAGE MEDICATIONS';
	@override String get nenhuma_aplicacao => 'No future injections scheduled.';
	@override String get nenhum_historico => 'No injection history.';
}

// Path: setup
class _Translations$setup$en extends Translations$setup$pt {
	_Translations$setup$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Medication Database';
	@override String get btn_novo => 'NEW';
	@override String get nenhum_medicamento => 'No medications configured.';
	@override String get simulador_titulo => 'Cycle Simulator';
	@override String get simulador_subtitulo => 'Plan your protocols and visualize blood release.';
}

// Path: formulario
class _Translations$formulario$en extends Translations$formulario$pt {
	_Translations$formulario$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo_novo => 'New Medication';
	@override String get titulo_editar => 'Edit Medication';
	@override String get btn_atualizar => 'UPDATE MEDICATION';
	@override String get btn_guardar => 'SAVE MEDICATION';
	@override String get btn_arquivar => 'END TREATMENT (ARCHIVE)';
	@override String get campo_mix => 'Selected Mix';
	@override String get campo_medicamento => 'Medication (Type)';
	@override String get campo_catalogo => 'Catalog (Search...)';
	@override String get btn_novo_catalogo => 'NEW';
	@override String get btn_abrir_catalogo => 'CATALOG';
	@override String get btn_criar_mix => 'CREATE MIX';
	@override String get modo_mix_titulo => 'MIX MODE ACTIVATED';
	@override String get modo_mix_editar => 'You can change Interval, Syringe, and Sites freely. To change base DOSES, click DISMANTLE MIX.';
	@override String get modo_mix_novo => 'Interval, Syringe, and Region were imported automatically.';
	@override String get campo_intervalo => 'Interval (days)';
	@override String get qtd_curto => 'Qty. Vials';
	@override String get vol_curto => 'Vol. (mL)';
	@override String get conc_curto => 'Conc. (mg/mL)';
	@override String get campo_dose_semanal => 'Weekly Dose';
	@override String get campo_unidade => 'Unit';
	@override String get resultado_dose => 'Calculated Dose per Injection:';
	@override String get resultado_vazio => 'Waiting for values...';
	@override String get campo_seringa => 'Syringe (IU)';
	@override String get campo_locais => 'Rotation Sites';
	@override String get campo_data => 'Start Date';
	@override String get campo_hora => 'Injection Time';
	@override String get freq_intervalo => 'Interval (Days)';
	@override String get freq_dias_semana => 'Days of the Week';
	@override Map<String, String> get dias_semana => {
		'1': 'Mon',
		'2': 'Tue',
		'3': 'Wed',
		'4': 'Thu',
		'5': 'Fri',
		'6': 'Sat',
		'7': 'Sun',
	};
}

// Path: cronograma
class _Translations$cronograma$en extends Translations$cronograma$pt {
	_Translations$cronograma$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String titulo({required Object nome}) => 'Schedule: ${nome}';
	@override String get btn_gerar_novo => 'GENERATE NEW CYCLE';
	@override String get nenhum_gerado => 'No schedule generated yet.';
	@override String get btn_gerar => 'GENERATE SCHEDULE';
	@override String info_seringa({required Object seringa, required Object intervalo}) => 'Syringe: ${seringa} IU | Interval: ${intervalo} days';
}

// Path: guia_conteudo
class _Translations$guia_conteudo$en extends Translations$guia_conteudo$pt {
	_Translations$guia_conteudo$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get termos_titulo => '⚖️ TERMS OF RESPONSIBILITY & PRIVACY';
	@override String get termos_texto => 'By using Injectables Control, the user declares to be fully aware that:\n\n1. The user assumes TOTAL and exclusive responsibility for the doses, mixtures (Mix), vial balances, and protocols generated.\n2. CodeVibe Studio is NOT responsible for filling errors or miscalculations generated by incorrect data.\n3. The "Lab Panel", "Clinical Progress" (alerts, color-coded tables, and charts), and "Cycle Simulator" are informational and mathematical estimates. They DO NOT constitute medical diagnosis, prescription, or advice.\n4. Privacy: Your health records are stored privately with individual access isolation and are never sold or shared with third parties. You can edit or delete your records at any time.\n5. The user exempts the creators from any clinical complication arising from the use of this organizational tool.';
	@override String get aviso_titulo => '🚨 IMPORTANT MEDICAL WARNING';
	@override String get aviso_texto => 'This application is exclusively a logistical and mathematical support tool. IT DOES NOT REPLACE MEDICAL ADVICE.\n\n• The app does not prescribe or recommend treatments.\n• If any marker appears out of range in Clinical Progress, bring the report to your doctor for evaluation.\n• In case of extreme pain, fever, intense redness, swelling, shortness of breath, or any discomfort after an injection, SEEK AN EMERGENCY ROOM IMMEDIATELY or contact your doctor.\n• Never start, titrate, or change dosages without the knowledge and authorization of your healthcare professional.';
	@override String get higiene_titulo => '🧼 HYGIENE AND ASEPSIS';
	@override String get higiene_texto => 'Lack of hygiene can cause serious infections and abscesses. Strictly follow:\n\n• Wash hands with soap and water before touching materials.\n• Clean the vial rubber with cotton and 70% Alcohol.\n• Cleanse the skin with 70% Alcohol and let it air dry before puncturing.\n• Use ONLY sterile, single-use (disposable) syringes and needles.\n• Dispose of sharps in a suitable rigid container.';
	@override String get como_usar_titulo => '📱 HOW TO USE THE APP';
	@override String get como_usar_texto => '• Home (Clinical Summary): Dynamic priority highlights your Next and Last Injection at the top, moving exam alerts up only when action is needed.\n\n• Medication Database & Smart Schedule: Register your vials, rotation sites, and generate cycles by Full Vial, Weeks, Months, or Injections. When generating a new cycle, the app automatically deducts already applied volume, letting you continue the current vial (ideal for dose titration) or start a new vial.\n\n• Clinical Progress: Log blood tests and bioimpedance/body measurements. Track out-of-range alerts, color-coded comparison tables, trend charts with reference bands, and share clean reports via email or copy for your doctor.\n\n• Calculators & Cycle Simulator: Use the Reconstitution Assistant, Virtual Syringe, and Pharmacokinetic Simulator to visualize theoretical release curves.\n\n• Safe Mix: Group compatible compounds in the same syringe with automatic volume summation.';
	@override String get cerebro_titulo => '🧬 ANALYTICAL BRAIN & EXAMS';
	@override String get cerebro_texto => 'The app features a predictive safety engine:\n\n• Biometric Profile: Cross-references biological sex, age, weight, and active protocol to suggest relevant exams for medical discussion, with direct email or copy options.\n\n• Repeat Control: Once you confirm a collection, the history saves completed exams and automatically hides those still within their validity window.\n\n• Pre-Exam Protocol: Before a scheduled collection, the system unlocks a Clinical Checklist (Fasting, Training Pause/CPK, Pelvic Rest, etc.) to avoid false positives.\n\n• Biomarker Window: The first ideal window is suggested 45 days after starting a protocol, with follow-ups every 90 days.';
	@override String get notificacoes_titulo => '🔔 NATIVE NOTIFICATION ENGINE';
	@override String get notificacoes_texto => 'To ensure maximum performance and save battery, our engine adopts a silent architecture:\n\n• Anti-Spam Queue: Recent devices limit alarms per app. Therefore, the app automatically schedules the next 60 injections and refreshes the queue as you mark doses completed.\n\n• Android Tip: To prevent OS delays or blocks, keep Battery set to "Unrestricted" and "Alarms & reminders" allowed in Settings → Apps → Injectables Control.';
	@override String get seringas_titulo => '💉 SYRINGES AND NEEDLES GUIDE';
	@override String get seringas_subtitulo => 'Understand the proper material for each application:';
	@override String get seringas_btn => 'View Needles and Syringes';
	@override String get seringas_texto1 => '💉 RECOMMENDED NEEDLES:';
	@override String get seringas_texto2 => '• Subcutaneous (SC - Fat): Short and thin needles, e.g., 13x0.45mm or 13x0.3mm (brown/gray). Applied at a 90° or 45° angle depending on adipose tissue.\n• Intramuscular (IM - Muscle): Long needles to reach the muscle, e.g., 25x0.7mm or 30x0.7mm (black/blue) and for larger volumes 25x0.8mm (green). Apply at a 90° angle.';
	@override String get seringas_texto3 => '🧪 SYRINGES AND SCALES:';
	@override String get seringas_texto4 => '• Insulin Syringes (100 IU = 1 mL): Detailed scale. 10 IU equals 0.1 mL. Ideal for highly precise subcutaneous microdoses.\n• 3 mL or 5 mL Syringes: Used for intramuscular applications requiring a larger volume of diluent or oil.';
	@override String get mapas_titulo => '🗺️ APPLICATION SITES MAP';
	@override String get mapas_alerta_titulo => 'CLINICAL UPDATE (IM)';
	@override String get mapas_alerta_texto => '✅ The Ventrogluteal is now considered the gold standard and safest site for intramuscular injections, being completely free of large vessels and nerves.\n\n❌ The old "Dorsogluteal" (upper outer quadrant) is being abandoned in current clinical practice. It poses a high risk of sciatic nerve injury and has more risks than benefits.';
	@override String get mapas_subtitulo => 'Click on the region to view exact locations and rotate properly:';
	@override String get mapas_btn1 => 'Belly Points (8 Points)';
	@override String get mapas_btn2 => 'Flank Points (9 Points)';
	@override String get mapas_btn3 => 'Gluteal Points (Ventro/Dorso)';
	@override String get mapas_btn4 => 'Thigh Points (Vastus Lateralis)';
	@override String get mapas_btn5 => 'Deltoid Points (Arm)';
	@override String get dicionario_titulo => '📖 GYM & CLINICAL DICTIONARY';
	@override String get dicionario_subtitulo => 'The dialect of gyms and treatments, translated directly:';
	@override String get dic_cat1 => '💪 ABOUT THE SHAPE (BODY)';
	@override String get dic_cat2 => '🏋️ ABOUT TRAINING';
	@override String get dic_cat3 => '🥦 ABOUT DIET';
	@override String get dic_cat4 => '💉 ABOUT INJECTABLES & "ADDITIVES"';
}

// Path: biometria
class _Translations$biometria$en extends Translations$biometria$pt {
	_Translations$biometria$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get motivo => 'Unlock to access your clinical data';
	@override String get erro_cancelado => 'Biometrics canceled. Try again or use the App password.';
	@override String get erro_sensor => 'Biometric sensor error.';
	@override String get titulo => 'Application Locked';
	@override String get subtitulo => 'Protecting your clinical history...';
	@override String get btn_biometria => 'USE BIOMETRICS';
	@override String get btn_senha => 'ACCESS WITH APP PASSWORD';
}

// Path: visualizador
class _Translations$visualizador$en extends Translations$visualizador$pt {
	_Translations$visualizador$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get erro_imagem => 'Image not found.';
}

// Path: geral
class _Translations$geral$en extends Translations$geral$pt {
	_Translations$geral$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sim => 'Yes';
	@override String get nao => 'No';
	@override String get ok => 'OK';
	@override String get cancelar => 'Cancel';
}

// Path: calculadora
class _Translations$calculadora$en extends Translations$calculadora$pt {
	_Translations$calculadora$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Injectables Calculator';
	@override String get limpar => 'Clear All';
	@override String get aviso => '⚠️ Educational tool. Confirm doses with a healthcare professional.';
	@override String get volume => 'Vial Volume (mL)';
	@override String get concentracao => 'Concentration';
	@override String get assistente => 'Reconstitution Assistant';
	@override String get dose_semanal => 'Weekly Dose';
	@override String get intervalo => 'Interval (days)';
	@override String get unidade => 'Unit';
	@override String get seringa => 'Syringe (IU)';
	@override String get resultados => 'Results';
	@override String get selecoes_vazias => 'Make the selections above to calculate the amount of fluid to draw for the desired dose.';
	@override String get res_para_dose => 'For the dose of ';
	@override String get res_aspire => ', draw the syringe content to: ';
	@override String get res_ou => ' mL or ';
	@override String get res_unidades => ' units.';
	@override String get res_conc => 'Reconstituted vial concentration:\n';
	@override String get res_contem => 'The vial contains ';
	@override String get res_doses => ' doses';
	@override String get res_de => ' of ';
	@override String get res_cada => ' each.';
	@override String get diluicao_titulo => 'Dilution Calculator';
	@override String get diluicao_desc => 'Do you want to calculate the reconstitution or find out the concentration of a vial?\n\nThis will automatically calculate the Concentration by crossing the Total Mass of the substance with the amount of liquid.';
	@override String get passo1 => 'Calculation\nSTEP 1 OF 2:';
	@override String get passo1_label => 'Total Substance (mg)';
	@override String get passo1_hint => 'Ex: 5 (for 5mg vials)';
	@override String get passo2 => 'Calculation\nSTEP 2 OF 2:';
	@override String get passo2_label => 'Liquid Volume (mL)';
	@override String get passo2_hint => 'How many total mL are in the vial?';
	@override String get msg_sucesso => 'Dilution calculated successfully!';
	@override String get msg_invalido => 'Invalid values.';
	@override String get simulador_titulo => 'Release Simulator (Pharmacokinetics)';
	@override String get simulador_desc => 'Test: 2 injections of 250mg of Enanthate (Day 0 and Day 7)';
}

// Path: simulador
class _Translations$simulador$en extends Translations$simulador$pt {
	_Translations$simulador$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Cycle Simulator';
	@override String get subtitulo => 'Build your protocol';
	@override String get nome_ciclo => 'Cycle Name (optional)';
	@override String get duracao => 'Duration';
	@override String semanas({required Object s}) => '${s} weeks';
	@override String get composto_title => 'Compound(s)';
	@override String composto_n({required Object n}) => 'Compound #${n}';
	@override String get remover => 'Remove Compound';
	@override String get dose => 'Dose (mg)';
	@override String get categoria => 'Category';
	@override String get selecione => 'Select compound';
	@override String get esquema => 'Dosing schedule (Schedule)';
	@override String get freq_1 => 'Daily';
	@override String get freq_2 => 'Every other day';
	@override String get freq_3 => 'Every 3 days';
	@override String get freq_4 => 'Every 4 days';
	@override String get freq_5 => 'Every 5 days';
	@override String get freq_7 => 'Every 7 days (1x/wk)';
	@override String get freq_14 => 'Every 14 days';
	@override String get de_sem => 'From (Week)';
	@override String get ate_sem => 'To (Week)';
	@override String semana_n({required Object s}) => 'Week ${s}';
	@override String get btn_trama => 'Simulate';
	@override String get btn_adicionar => 'Add Compound';
	@override String get btn_reiniciar => 'Reset';
	@override String get grafico_titulo => 'Daily Active Drug Release (mg)';
	@override String get grafico_nota => 'Note: The line represents the effective milligrams released into the blood each day, applying the superposition principle (accumulation) and the ester weight.';
}

// Path: dashboard_alertas
class _Translations$dashboard_alertas$en extends Translations$dashboard_alertas$pt {
	_Translations$dashboard_alertas$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String atencao_coleta({required Object dias}) => 'Attention! Collection in ${dias} day(s)';
	@override String get texto_protecao => 'Your biometric protection period has started. Open the clinical checklist so you don\'t invalidate the results.';
	@override String get btn_abrir_checklist => 'OPEN CLINICAL CHECKLIST';
	@override String get coleta_agendada => 'Scheduled Collection';
	@override String texto_exames({required Object dias, required Object data}) => 'You have exams scheduled for ${dias} days from now (${data}).';
	@override String get btn_ver_painel => 'VIEW PANEL AND RESCHEDULE';
	@override String get label_mix => 'Mix: ';
	@override String get label_data => 'Date: ';
	@override String get label_local => 'Site: ';
	@override String get label_dose => 'Dose: ';
}

// Path: regioes
class _Translations$regioes$en extends Translations$regioes$pt {
	_Translations$regioes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selecione => 'Select Sites';
	@override String get nenhum => 'None';
	@override String selecionados({required Object qtd}) => '${qtd} selected';
	@override String get confirmar => 'CONFIRM';
	@override String get cancelar => 'Cancel';
	@override String get ventro_gluteo => 'Ventrogluteal (IM)';
	@override String get vasto_lateral => 'Vastus Lateralis (IM)';
	@override String get deltoide => 'Deltoid (IM)';
	@override String get gluteo_superior => 'Dorsogluteal (IM)';
	@override String get barriga => 'Belly (SC)';
	@override String get flanco => 'Flank (SC)';
	@override String get perna_anterior => 'Anterior Thigh (SC)';
	@override String get braco_triceps => 'Triceps (SC)';
}

// Path: formulario_extras
class _Translations$formulario_extras$en extends Translations$formulario_extras$pt {
	_Translations$formulario_extras$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get dialogo_rotulo_titulo => 'Safe Filling';
	@override String get dialogo_rotulo_desc => 'Do you want to use the automatic Label Calculator?\n\nThis prevents errors in the conversion of medications such as Tirzepatide or Semaglutide.';
	@override String get seringa_30 => '30 IU (0.3 mL)';
	@override String get seringa_50 => '50 IU (0.5 mL)';
	@override String get seringa_100 => '100 IU (1 mL)';
	@override String get seringa_3ml => '3 mL Syringe';
	@override String get seringa_5ml => '5 mL Syringe';
	@override String get assistente => 'Assistant';
}

// Path: exames
class _Translations$exames$en extends Translations$exames$pt {
	_Translations$exames$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get checklist_titulo => 'Pre-Exam Protocol';
	@override String get checklist_subtitulo => 'Confirm the rules below to avoid false positives in your hormonal results.';
	@override String get item1_tit => '1. Strict Fasting (8 to 12h)';
	@override String get item1_desc => 'Mandatory for Basal Insulin and Glycemia. Max 14h. Drink plenty of water, it\'s allowed!';
	@override String get item2_tit => '2. Training Pause (48h)';
	@override String get item2_desc => 'Suspend weightlifting. Micro-lesions falsely elevate CPK, Creatinine, and AST.';
	@override String get item3_tit => '3. Pelvic Rest (72h)';
	@override String get item3_desc => 'No ejaculation (avoids false Prolactin and PSA peaks). Do not ride motorcycles or bicycles.';
	@override String get item4_tit => '4. Liver Protection (72h)';
	@override String get item4_desc => 'Zero alcohol to avoid acute peaks in GGT, Triglycerides, and systemic inflammation.';
	@override String get item5_tit => '5. Collection Time';
	@override String get item5_desc => 'Strict collection between 07h and 09h AM to catch Testosterone, TSH, and Prolactin at their basal peak.';
	@override String get item6_tit => '6. Cycle Fidelity';
	@override String get item6_desc => 'Do not pause or delay injections in the app. The exam must reflect real hormonal kinetics.';
	@override String get btn_confirmar => 'CONFIRM CHECKLIST';
	@override String get painel_titulo => 'Laboratory Suggestion';
	@override String get painel_subtitulo => 'Personalized panel cross-referencing biological sex, age, weight, and active protocol.';
	@override String get btn_agendar => 'SCHEDULE COLLECTION DATE';
	@override String get btn_ja_fiz => 'I ALREADY DID THE COLLECTION';
	@override String get btn_copiar_medico => 'COPY LIST FOR DOCTOR';
	@override String get btn_enviar_email => 'SEND TO MY EMAIL';
	@override String get msg_selecione_bloco => 'Select at least one exam section.';
	@override String get email_assunto => 'Lab Exam Suggestion - Injectables Control';
	@override String get msg_copiado => 'List copied! Paste it into a message or take it to your appointment.';
	@override String get aviso_clinico => 'Notice: Informational suggestion for medical discussion. Does not replace professional evaluation; intervals may be adjusted by your doctor.';
	@override String get sec_laboratoriais => 'Lab Tests';
	@override String get sec_protocolo => 'Protocol Specifics';
	@override String get sec_ponderal => 'Weight & Metabolic Profile';
	@override String get sec_cardiologicos => 'Cardiology';
	@override String get sec_imagem => 'Imaging & Screening';
	@override String get primeiro_exame => '1st Exam';
	@override String get periodicidade => 'Frequency';
	@override late final _Translations$exames$nomes$en nomes = _Translations$exames$nomes$en._(_root);
}

// Path: complementos
class _Translations$complementos$en extends Translations$complementos$pt {
	_Translations$complementos$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String intervalo_cada({required Object dias}) => 'Interval: Every ${dias} days';
	@override String get masculino => 'Male';
	@override String get feminino => 'Female';
	@override String get selecione_erro => 'Select';
	@override String seringa_intervalo({required Object seringa, required Object dias}) => 'Syringe: ${seringa} IU | Interval: ${dias} days';
}

// Path: navegacao
class _Translations$navegacao$en extends Translations$navegacao$pt {
	_Translations$navegacao$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get inicio => 'Home';
	@override String get tratamento => 'Treatment';
	@override String get ferramentas => 'Tools';
	@override String get perfil => 'Profile';
}

// Path: evolucao
class _Translations$evolucao$en extends Translations$evolucao$pt {
	_Translations$evolucao$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Clinical Progress';
	@override String get card_subtitulo => 'Lab history, alerts, bioimpedance, and charts.';
	@override String get aba_alertas => 'Alerts';
	@override String get aba_tabela => 'Table';
	@override String get aba_graficos => 'Charts';
	@override String get btn_registrar => 'Log Entry';
	@override String get btn_salvar => 'SAVE RECORD';
	@override String get modal_novo => 'New Clinical Record';
	@override String get modal_editar => 'Edit Clinical Record';
	@override String get tipo_sangue => 'Blood Test';
	@override String get tipo_corpo => 'Bioimpedance / Body';
	@override String get data_registro => 'Record Date';
	@override String get instrucao_laudo => 'Fill in only the markers present in your lab report:';
	@override String get obs_opcional => 'Notes (optional)';
	@override String get sem_resultados => 'No results logged yet';
	@override String get sem_resultados_desc => 'Tap the button below to log your first blood test or bioimpedance and track your progress.';
	@override String get tudo_na_faixa => 'Last Exam: All Within Range';
	@override String get ultima_bio => 'Latest Bioimpedance';
	@override String get historico_titulo => 'Record History';
	@override String get sem_categoria => 'No records in this category.';
	@override String get escolha_marcador => 'Select Marker to View';
	@override String get sem_dados_marcador => 'No data logged for this marker.';
	@override String get tooltip_email => 'Send report to my email';
	@override String get tooltip_copiar => 'Copy report for doctor';
	@override String get msg_copiado => 'Report copied! Paste it into a message or bring it to your appointment.';
	@override String get msg_salvo => 'Record saved successfully!';
	@override String get msg_excluido => 'Record deleted successfully!';
	@override String get excluir_titulo => 'Delete Record';
	@override String get excluir_desc => 'Are you sure you want to delete this clinical record? This action cannot be undone.';
	@override String get btn_excluir => 'Delete';
}

// Path: cronograma_modal
class _Translations$cronograma_modal$en extends Translations$cronograma_modal$pt {
	_Translations$cronograma_modal$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titulo => 'Schedule Period';
	@override String frasco_atual({required Object vol}) => 'Current vial (${vol} mL)';
	@override String frasco_novo({required Object vol}) => 'New vial (${vol} mL)';
	@override String get op_frasco => 'Full vial';
	@override String get op_frasco_sub => 'Until balance runs out';
	@override String get op_semanas => 'By Weeks';
	@override String get op_semanas_sub => 'E.g.: 4 or 8 weeks';
	@override String get op_meses => 'By Months';
	@override String get op_meses_sub => 'E.g.: 3 months';
	@override String get op_injecoes => 'By Injections';
	@override String get op_injecoes_sub => 'Exact number of doses';
	@override String get lbl_semanas => 'Weeks';
	@override String get lbl_meses => 'Months';
	@override String get lbl_injecoes => 'Injections';
	@override String get btn_gerar_uma => 'GENERATE 1 INJECTION';
	@override String btn_gerar_varias({required Object qtd}) => 'GENERATE ${qtd} INJECTIONS';
	@override String get btn_informe_qtd => 'ENTER QUANTITY';
}

// Path: exames.nomes
class _Translations$exames$nomes$en extends Translations$exames$nomes$pt {
	_Translations$exames$nomes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hemo => 'Complete Blood Count (CBC)';
	@override String get marcadores => 'Inflammatory Markers (CRP and Ferritin)';
	@override String get lipidico => 'Lipid Profile (Total Chol., HDL, LDL, VLDL, Triglycerides)';
	@override String get figado => 'Liver Function (AST, ALT, GGT)';
	@override String get rim => 'Kidney Function (Urea and Creatinine)';
	@override String get cpk => 'Muscle Damage (CPK)';
	@override String get testo => 'Total and Free Testosterone';
	@override String get e2 => 'Estradiol (E2)';
	@override String get shbg => 'SHBG';
	@override String get dht => 'DHT (Dihydrotestosterone)';
	@override String get prolactina => 'Prolactin';
	@override String get tireoide => 'Thyroid (TSH and Free T4)';
	@override String get psa => 'Total and Free PSA (Prostate)';
	@override String get glicemia => 'Fasting Blood Glucose';
	@override String get insulina => 'Basal Insulin';
	@override String get hba1c => 'Glycated Hemoglobin (HbA1c)';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'notificacoes.titulo_injecao' => 'Injection Day! 💉',
			'notificacoes.corpo_injecao' => ({required Object medicamento, required Object local}) => 'Today is the day to inject ${medicamento} (${local}).',
			'erros.sem_internet' => 'Please check your internet connection and try again.',
			'erros.falha_app' => 'Failed to start the application',
			'login.titulo' => 'Injectables Control',
			'login.email' => 'Email',
			'login.senha' => 'Password',
			'login.entrar' => 'LOGIN',
			'login.criar_conta' => 'CREATE NEW ACCOUNT',
			'login.esqueci_senha' => 'Forgot my password',
			'perfil.titulo' => 'My Profile',
			'perfil.idioma' => 'Language',
			'perfil.dados_biologicos' => 'Biological Data',
			'perfil.descricao_biologicos' => 'This information is essential for the app to cross-reference your age, biological sex, and weight, generating accurate and safe clinical blood panels.',
			'perfil.nome' => 'Full Name',
			'perfil.peso' => 'Weight (kg)',
			'perfil.sexo' => 'Biological Sex',
			'perfil.data_nascimento' => 'Date of Birth (DD/MM/YYYY)',
			'perfil.btn_salvar' => 'SAVE PROFILE',
			'perfil.msg_sucesso' => 'Profile saved successfully!',
			'perfil.msg_erro' => 'Error saving: ',
			'perfil.erro_sexo' => 'Please select your biological sex.',
			'perfil.erro_data' => 'Enter a valid date of birth (DD/MM/YYYY).',
			'guia.titulo' => 'Guide and Terms of Use',
			'guia.aviso_scroll' => '⬇️ Scroll to the bottom to enable acceptance.',
			'guia.texto_aceite' => 'I declare that I have read the instructions, am aware of the medical risks, and accept the Terms of Responsibility and Exemption.',
			'guia.btn_aceitar' => 'I UNDERSTAND AND ACCEPT',
			'guia.msg_sucesso' => 'Terms accepted and registered. Access granted!',
			'guia.msg_erro' => 'Error registering: ',
			'guia.tooltip_sair' => 'Exit App',
			'dashboard.titulo' => 'Treatment',
			'dashboard.resumo_clinico' => 'Clinical Summary',
			'dashboard.proxima_aplicacao' => 'Next Injection',
			'dashboard.ultima_aplicacao' => 'Last Injection',
			'dashboard.gerir_medicamentos' => 'MANAGE MEDICATIONS',
			'dashboard.nenhuma_aplicacao' => 'No future injections scheduled.',
			'dashboard.nenhum_historico' => 'No injection history.',
			'setup.titulo' => 'Medication Database',
			'setup.btn_novo' => 'NEW',
			'setup.nenhum_medicamento' => 'No medications configured.',
			'setup.simulador_titulo' => 'Cycle Simulator',
			'setup.simulador_subtitulo' => 'Plan your protocols and visualize blood release.',
			'formulario.titulo_novo' => 'New Medication',
			'formulario.titulo_editar' => 'Edit Medication',
			'formulario.btn_atualizar' => 'UPDATE MEDICATION',
			'formulario.btn_guardar' => 'SAVE MEDICATION',
			'formulario.btn_arquivar' => 'END TREATMENT (ARCHIVE)',
			'formulario.campo_mix' => 'Selected Mix',
			'formulario.campo_medicamento' => 'Medication (Type)',
			'formulario.campo_catalogo' => 'Catalog (Search...)',
			'formulario.btn_novo_catalogo' => 'NEW',
			'formulario.btn_abrir_catalogo' => 'CATALOG',
			'formulario.btn_criar_mix' => 'CREATE MIX',
			'formulario.modo_mix_titulo' => 'MIX MODE ACTIVATED',
			'formulario.modo_mix_editar' => 'You can change Interval, Syringe, and Sites freely. To change base DOSES, click DISMANTLE MIX.',
			'formulario.modo_mix_novo' => 'Interval, Syringe, and Region were imported automatically.',
			'formulario.campo_intervalo' => 'Interval (days)',
			'formulario.qtd_curto' => 'Qty. Vials',
			'formulario.vol_curto' => 'Vol. (mL)',
			'formulario.conc_curto' => 'Conc. (mg/mL)',
			'formulario.campo_dose_semanal' => 'Weekly Dose',
			'formulario.campo_unidade' => 'Unit',
			'formulario.resultado_dose' => 'Calculated Dose per Injection:',
			'formulario.resultado_vazio' => 'Waiting for values...',
			'formulario.campo_seringa' => 'Syringe (IU)',
			'formulario.campo_locais' => 'Rotation Sites',
			'formulario.campo_data' => 'Start Date',
			'formulario.campo_hora' => 'Injection Time',
			'formulario.freq_intervalo' => 'Interval (Days)',
			'formulario.freq_dias_semana' => 'Days of the Week',
			'formulario.dias_semana."1"' => 'Mon',
			'formulario.dias_semana."2"' => 'Tue',
			'formulario.dias_semana."3"' => 'Wed',
			'formulario.dias_semana."4"' => 'Thu',
			'formulario.dias_semana."5"' => 'Fri',
			'formulario.dias_semana."6"' => 'Sat',
			'formulario.dias_semana."7"' => 'Sun',
			'cronograma.titulo' => ({required Object nome}) => 'Schedule: ${nome}',
			'cronograma.btn_gerar_novo' => 'GENERATE NEW CYCLE',
			'cronograma.nenhum_gerado' => 'No schedule generated yet.',
			'cronograma.btn_gerar' => 'GENERATE SCHEDULE',
			'cronograma.info_seringa' => ({required Object seringa, required Object intervalo}) => 'Syringe: ${seringa} IU | Interval: ${intervalo} days',
			'guia_conteudo.termos_titulo' => '⚖️ TERMS OF RESPONSIBILITY & PRIVACY',
			'guia_conteudo.termos_texto' => 'By using Injectables Control, the user declares to be fully aware that:\n\n1. The user assumes TOTAL and exclusive responsibility for the doses, mixtures (Mix), vial balances, and protocols generated.\n2. CodeVibe Studio is NOT responsible for filling errors or miscalculations generated by incorrect data.\n3. The "Lab Panel", "Clinical Progress" (alerts, color-coded tables, and charts), and "Cycle Simulator" are informational and mathematical estimates. They DO NOT constitute medical diagnosis, prescription, or advice.\n4. Privacy: Your health records are stored privately with individual access isolation and are never sold or shared with third parties. You can edit or delete your records at any time.\n5. The user exempts the creators from any clinical complication arising from the use of this organizational tool.',
			'guia_conteudo.aviso_titulo' => '🚨 IMPORTANT MEDICAL WARNING',
			'guia_conteudo.aviso_texto' => 'This application is exclusively a logistical and mathematical support tool. IT DOES NOT REPLACE MEDICAL ADVICE.\n\n• The app does not prescribe or recommend treatments.\n• If any marker appears out of range in Clinical Progress, bring the report to your doctor for evaluation.\n• In case of extreme pain, fever, intense redness, swelling, shortness of breath, or any discomfort after an injection, SEEK AN EMERGENCY ROOM IMMEDIATELY or contact your doctor.\n• Never start, titrate, or change dosages without the knowledge and authorization of your healthcare professional.',
			'guia_conteudo.higiene_titulo' => '🧼 HYGIENE AND ASEPSIS',
			'guia_conteudo.higiene_texto' => 'Lack of hygiene can cause serious infections and abscesses. Strictly follow:\n\n• Wash hands with soap and water before touching materials.\n• Clean the vial rubber with cotton and 70% Alcohol.\n• Cleanse the skin with 70% Alcohol and let it air dry before puncturing.\n• Use ONLY sterile, single-use (disposable) syringes and needles.\n• Dispose of sharps in a suitable rigid container.',
			'guia_conteudo.como_usar_titulo' => '📱 HOW TO USE THE APP',
			'guia_conteudo.como_usar_texto' => '• Home (Clinical Summary): Dynamic priority highlights your Next and Last Injection at the top, moving exam alerts up only when action is needed.\n\n• Medication Database & Smart Schedule: Register your vials, rotation sites, and generate cycles by Full Vial, Weeks, Months, or Injections. When generating a new cycle, the app automatically deducts already applied volume, letting you continue the current vial (ideal for dose titration) or start a new vial.\n\n• Clinical Progress: Log blood tests and bioimpedance/body measurements. Track out-of-range alerts, color-coded comparison tables, trend charts with reference bands, and share clean reports via email or copy for your doctor.\n\n• Calculators & Cycle Simulator: Use the Reconstitution Assistant, Virtual Syringe, and Pharmacokinetic Simulator to visualize theoretical release curves.\n\n• Safe Mix: Group compatible compounds in the same syringe with automatic volume summation.',
			'guia_conteudo.cerebro_titulo' => '🧬 ANALYTICAL BRAIN & EXAMS',
			'guia_conteudo.cerebro_texto' => 'The app features a predictive safety engine:\n\n• Biometric Profile: Cross-references biological sex, age, weight, and active protocol to suggest relevant exams for medical discussion, with direct email or copy options.\n\n• Repeat Control: Once you confirm a collection, the history saves completed exams and automatically hides those still within their validity window.\n\n• Pre-Exam Protocol: Before a scheduled collection, the system unlocks a Clinical Checklist (Fasting, Training Pause/CPK, Pelvic Rest, etc.) to avoid false positives.\n\n• Biomarker Window: The first ideal window is suggested 45 days after starting a protocol, with follow-ups every 90 days.',
			'guia_conteudo.notificacoes_titulo' => '🔔 NATIVE NOTIFICATION ENGINE',
			'guia_conteudo.notificacoes_texto' => 'To ensure maximum performance and save battery, our engine adopts a silent architecture:\n\n• Anti-Spam Queue: Recent devices limit alarms per app. Therefore, the app automatically schedules the next 60 injections and refreshes the queue as you mark doses completed.\n\n• Android Tip: To prevent OS delays or blocks, keep Battery set to "Unrestricted" and "Alarms & reminders" allowed in Settings → Apps → Injectables Control.',
			'guia_conteudo.seringas_titulo' => '💉 SYRINGES AND NEEDLES GUIDE',
			'guia_conteudo.seringas_subtitulo' => 'Understand the proper material for each application:',
			'guia_conteudo.seringas_btn' => 'View Needles and Syringes',
			'guia_conteudo.seringas_texto1' => '💉 RECOMMENDED NEEDLES:',
			'guia_conteudo.seringas_texto2' => '• Subcutaneous (SC - Fat): Short and thin needles, e.g., 13x0.45mm or 13x0.3mm (brown/gray). Applied at a 90° or 45° angle depending on adipose tissue.\n• Intramuscular (IM - Muscle): Long needles to reach the muscle, e.g., 25x0.7mm or 30x0.7mm (black/blue) and for larger volumes 25x0.8mm (green). Apply at a 90° angle.',
			'guia_conteudo.seringas_texto3' => '🧪 SYRINGES AND SCALES:',
			'guia_conteudo.seringas_texto4' => '• Insulin Syringes (100 IU = 1 mL): Detailed scale. 10 IU equals 0.1 mL. Ideal for highly precise subcutaneous microdoses.\n• 3 mL or 5 mL Syringes: Used for intramuscular applications requiring a larger volume of diluent or oil.',
			'guia_conteudo.mapas_titulo' => '🗺️ APPLICATION SITES MAP',
			'guia_conteudo.mapas_alerta_titulo' => 'CLINICAL UPDATE (IM)',
			'guia_conteudo.mapas_alerta_texto' => '✅ The Ventrogluteal is now considered the gold standard and safest site for intramuscular injections, being completely free of large vessels and nerves.\n\n❌ The old "Dorsogluteal" (upper outer quadrant) is being abandoned in current clinical practice. It poses a high risk of sciatic nerve injury and has more risks than benefits.',
			'guia_conteudo.mapas_subtitulo' => 'Click on the region to view exact locations and rotate properly:',
			'guia_conteudo.mapas_btn1' => 'Belly Points (8 Points)',
			'guia_conteudo.mapas_btn2' => 'Flank Points (9 Points)',
			'guia_conteudo.mapas_btn3' => 'Gluteal Points (Ventro/Dorso)',
			'guia_conteudo.mapas_btn4' => 'Thigh Points (Vastus Lateralis)',
			'guia_conteudo.mapas_btn5' => 'Deltoid Points (Arm)',
			'guia_conteudo.dicionario_titulo' => '📖 GYM & CLINICAL DICTIONARY',
			'guia_conteudo.dicionario_subtitulo' => 'The dialect of gyms and treatments, translated directly:',
			'guia_conteudo.dic_cat1' => '💪 ABOUT THE SHAPE (BODY)',
			'guia_conteudo.dic_cat2' => '🏋️ ABOUT TRAINING',
			'guia_conteudo.dic_cat3' => '🥦 ABOUT DIET',
			'guia_conteudo.dic_cat4' => '💉 ABOUT INJECTABLES & "ADDITIVES"',
			'biometria.motivo' => 'Unlock to access your clinical data',
			'biometria.erro_cancelado' => 'Biometrics canceled. Try again or use the App password.',
			'biometria.erro_sensor' => 'Biometric sensor error.',
			'biometria.titulo' => 'Application Locked',
			'biometria.subtitulo' => 'Protecting your clinical history...',
			'biometria.btn_biometria' => 'USE BIOMETRICS',
			'biometria.btn_senha' => 'ACCESS WITH APP PASSWORD',
			'visualizador.erro_imagem' => 'Image not found.',
			'geral.sim' => 'Yes',
			'geral.nao' => 'No',
			'geral.ok' => 'OK',
			'geral.cancelar' => 'Cancel',
			'calculadora.titulo' => 'Injectables Calculator',
			'calculadora.limpar' => 'Clear All',
			'calculadora.aviso' => '⚠️ Educational tool. Confirm doses with a healthcare professional.',
			'calculadora.volume' => 'Vial Volume (mL)',
			'calculadora.concentracao' => 'Concentration',
			'calculadora.assistente' => 'Reconstitution Assistant',
			'calculadora.dose_semanal' => 'Weekly Dose',
			'calculadora.intervalo' => 'Interval (days)',
			'calculadora.unidade' => 'Unit',
			'calculadora.seringa' => 'Syringe (IU)',
			'calculadora.resultados' => 'Results',
			'calculadora.selecoes_vazias' => 'Make the selections above to calculate the amount of fluid to draw for the desired dose.',
			'calculadora.res_para_dose' => 'For the dose of ',
			'calculadora.res_aspire' => ', draw the syringe content to: ',
			'calculadora.res_ou' => ' mL or ',
			'calculadora.res_unidades' => ' units.',
			'calculadora.res_conc' => 'Reconstituted vial concentration:\n',
			'calculadora.res_contem' => 'The vial contains ',
			'calculadora.res_doses' => ' doses',
			'calculadora.res_de' => ' of ',
			'calculadora.res_cada' => ' each.',
			'calculadora.diluicao_titulo' => 'Dilution Calculator',
			'calculadora.diluicao_desc' => 'Do you want to calculate the reconstitution or find out the concentration of a vial?\n\nThis will automatically calculate the Concentration by crossing the Total Mass of the substance with the amount of liquid.',
			'calculadora.passo1' => 'Calculation\nSTEP 1 OF 2:',
			'calculadora.passo1_label' => 'Total Substance (mg)',
			'calculadora.passo1_hint' => 'Ex: 5 (for 5mg vials)',
			'calculadora.passo2' => 'Calculation\nSTEP 2 OF 2:',
			'calculadora.passo2_label' => 'Liquid Volume (mL)',
			'calculadora.passo2_hint' => 'How many total mL are in the vial?',
			'calculadora.msg_sucesso' => 'Dilution calculated successfully!',
			'calculadora.msg_invalido' => 'Invalid values.',
			'calculadora.simulador_titulo' => 'Release Simulator (Pharmacokinetics)',
			'calculadora.simulador_desc' => 'Test: 2 injections of 250mg of Enanthate (Day 0 and Day 7)',
			'simulador.titulo' => 'Cycle Simulator',
			'simulador.subtitulo' => 'Build your protocol',
			'simulador.nome_ciclo' => 'Cycle Name (optional)',
			'simulador.duracao' => 'Duration',
			'simulador.semanas' => ({required Object s}) => '${s} weeks',
			'simulador.composto_title' => 'Compound(s)',
			'simulador.composto_n' => ({required Object n}) => 'Compound #${n}',
			'simulador.remover' => 'Remove Compound',
			'simulador.dose' => 'Dose (mg)',
			'simulador.categoria' => 'Category',
			'simulador.selecione' => 'Select compound',
			'simulador.esquema' => 'Dosing schedule (Schedule)',
			'simulador.freq_1' => 'Daily',
			'simulador.freq_2' => 'Every other day',
			'simulador.freq_3' => 'Every 3 days',
			'simulador.freq_4' => 'Every 4 days',
			'simulador.freq_5' => 'Every 5 days',
			'simulador.freq_7' => 'Every 7 days (1x/wk)',
			'simulador.freq_14' => 'Every 14 days',
			'simulador.de_sem' => 'From (Week)',
			'simulador.ate_sem' => 'To (Week)',
			'simulador.semana_n' => ({required Object s}) => 'Week ${s}',
			'simulador.btn_trama' => 'Simulate',
			'simulador.btn_adicionar' => 'Add Compound',
			'simulador.btn_reiniciar' => 'Reset',
			'simulador.grafico_titulo' => 'Daily Active Drug Release (mg)',
			'simulador.grafico_nota' => 'Note: The line represents the effective milligrams released into the blood each day, applying the superposition principle (accumulation) and the ester weight.',
			'dashboard_alertas.atencao_coleta' => ({required Object dias}) => 'Attention! Collection in ${dias} day(s)',
			'dashboard_alertas.texto_protecao' => 'Your biometric protection period has started. Open the clinical checklist so you don\'t invalidate the results.',
			'dashboard_alertas.btn_abrir_checklist' => 'OPEN CLINICAL CHECKLIST',
			'dashboard_alertas.coleta_agendada' => 'Scheduled Collection',
			'dashboard_alertas.texto_exames' => ({required Object dias, required Object data}) => 'You have exams scheduled for ${dias} days from now (${data}).',
			'dashboard_alertas.btn_ver_painel' => 'VIEW PANEL AND RESCHEDULE',
			'dashboard_alertas.label_mix' => 'Mix: ',
			'dashboard_alertas.label_data' => 'Date: ',
			'dashboard_alertas.label_local' => 'Site: ',
			'dashboard_alertas.label_dose' => 'Dose: ',
			'regioes.selecione' => 'Select Sites',
			'regioes.nenhum' => 'None',
			'regioes.selecionados' => ({required Object qtd}) => '${qtd} selected',
			'regioes.confirmar' => 'CONFIRM',
			'regioes.cancelar' => 'Cancel',
			'regioes.ventro_gluteo' => 'Ventrogluteal (IM)',
			'regioes.vasto_lateral' => 'Vastus Lateralis (IM)',
			'regioes.deltoide' => 'Deltoid (IM)',
			'regioes.gluteo_superior' => 'Dorsogluteal (IM)',
			'regioes.barriga' => 'Belly (SC)',
			'regioes.flanco' => 'Flank (SC)',
			'regioes.perna_anterior' => 'Anterior Thigh (SC)',
			'regioes.braco_triceps' => 'Triceps (SC)',
			'formulario_extras.dialogo_rotulo_titulo' => 'Safe Filling',
			'formulario_extras.dialogo_rotulo_desc' => 'Do you want to use the automatic Label Calculator?\n\nThis prevents errors in the conversion of medications such as Tirzepatide or Semaglutide.',
			'formulario_extras.seringa_30' => '30 IU (0.3 mL)',
			'formulario_extras.seringa_50' => '50 IU (0.5 mL)',
			'formulario_extras.seringa_100' => '100 IU (1 mL)',
			'formulario_extras.seringa_3ml' => '3 mL Syringe',
			'formulario_extras.seringa_5ml' => '5 mL Syringe',
			'formulario_extras.assistente' => 'Assistant',
			'exames.checklist_titulo' => 'Pre-Exam Protocol',
			'exames.checklist_subtitulo' => 'Confirm the rules below to avoid false positives in your hormonal results.',
			'exames.item1_tit' => '1. Strict Fasting (8 to 12h)',
			'exames.item1_desc' => 'Mandatory for Basal Insulin and Glycemia. Max 14h. Drink plenty of water, it\'s allowed!',
			'exames.item2_tit' => '2. Training Pause (48h)',
			'exames.item2_desc' => 'Suspend weightlifting. Micro-lesions falsely elevate CPK, Creatinine, and AST.',
			'exames.item3_tit' => '3. Pelvic Rest (72h)',
			'exames.item3_desc' => 'No ejaculation (avoids false Prolactin and PSA peaks). Do not ride motorcycles or bicycles.',
			'exames.item4_tit' => '4. Liver Protection (72h)',
			'exames.item4_desc' => 'Zero alcohol to avoid acute peaks in GGT, Triglycerides, and systemic inflammation.',
			'exames.item5_tit' => '5. Collection Time',
			'exames.item5_desc' => 'Strict collection between 07h and 09h AM to catch Testosterone, TSH, and Prolactin at their basal peak.',
			'exames.item6_tit' => '6. Cycle Fidelity',
			'exames.item6_desc' => 'Do not pause or delay injections in the app. The exam must reflect real hormonal kinetics.',
			'exames.btn_confirmar' => 'CONFIRM CHECKLIST',
			'exames.painel_titulo' => 'Laboratory Suggestion',
			'exames.painel_subtitulo' => 'Personalized panel cross-referencing biological sex, age, weight, and active protocol.',
			'exames.btn_agendar' => 'SCHEDULE COLLECTION DATE',
			'exames.btn_ja_fiz' => 'I ALREADY DID THE COLLECTION',
			'exames.btn_copiar_medico' => 'COPY LIST FOR DOCTOR',
			'exames.btn_enviar_email' => 'SEND TO MY EMAIL',
			'exames.msg_selecione_bloco' => 'Select at least one exam section.',
			'exames.email_assunto' => 'Lab Exam Suggestion - Injectables Control',
			'exames.msg_copiado' => 'List copied! Paste it into a message or take it to your appointment.',
			'exames.aviso_clinico' => 'Notice: Informational suggestion for medical discussion. Does not replace professional evaluation; intervals may be adjusted by your doctor.',
			'exames.sec_laboratoriais' => 'Lab Tests',
			'exames.sec_protocolo' => 'Protocol Specifics',
			'exames.sec_ponderal' => 'Weight & Metabolic Profile',
			'exames.sec_cardiologicos' => 'Cardiology',
			'exames.sec_imagem' => 'Imaging & Screening',
			'exames.primeiro_exame' => '1st Exam',
			'exames.periodicidade' => 'Frequency',
			'exames.nomes.hemo' => 'Complete Blood Count (CBC)',
			'exames.nomes.marcadores' => 'Inflammatory Markers (CRP and Ferritin)',
			'exames.nomes.lipidico' => 'Lipid Profile (Total Chol., HDL, LDL, VLDL, Triglycerides)',
			'exames.nomes.figado' => 'Liver Function (AST, ALT, GGT)',
			'exames.nomes.rim' => 'Kidney Function (Urea and Creatinine)',
			'exames.nomes.cpk' => 'Muscle Damage (CPK)',
			'exames.nomes.testo' => 'Total and Free Testosterone',
			'exames.nomes.e2' => 'Estradiol (E2)',
			'exames.nomes.shbg' => 'SHBG',
			'exames.nomes.dht' => 'DHT (Dihydrotestosterone)',
			'exames.nomes.prolactina' => 'Prolactin',
			'exames.nomes.tireoide' => 'Thyroid (TSH and Free T4)',
			'exames.nomes.psa' => 'Total and Free PSA (Prostate)',
			'exames.nomes.glicemia' => 'Fasting Blood Glucose',
			'exames.nomes.insulina' => 'Basal Insulin',
			'exames.nomes.hba1c' => 'Glycated Hemoglobin (HbA1c)',
			'complementos.intervalo_cada' => ({required Object dias}) => 'Interval: Every ${dias} days',
			'complementos.masculino' => 'Male',
			'complementos.feminino' => 'Female',
			'complementos.selecione_erro' => 'Select',
			'complementos.seringa_intervalo' => ({required Object seringa, required Object dias}) => 'Syringe: ${seringa} IU | Interval: ${dias} days',
			'navegacao.inicio' => 'Home',
			'navegacao.tratamento' => 'Treatment',
			'navegacao.ferramentas' => 'Tools',
			'navegacao.perfil' => 'Profile',
			'evolucao.titulo' => 'Clinical Progress',
			'evolucao.card_subtitulo' => 'Lab history, alerts, bioimpedance, and charts.',
			'evolucao.aba_alertas' => 'Alerts',
			'evolucao.aba_tabela' => 'Table',
			'evolucao.aba_graficos' => 'Charts',
			'evolucao.btn_registrar' => 'Log Entry',
			'evolucao.btn_salvar' => 'SAVE RECORD',
			'evolucao.modal_novo' => 'New Clinical Record',
			'evolucao.modal_editar' => 'Edit Clinical Record',
			'evolucao.tipo_sangue' => 'Blood Test',
			'evolucao.tipo_corpo' => 'Bioimpedance / Body',
			'evolucao.data_registro' => 'Record Date',
			'evolucao.instrucao_laudo' => 'Fill in only the markers present in your lab report:',
			'evolucao.obs_opcional' => 'Notes (optional)',
			'evolucao.sem_resultados' => 'No results logged yet',
			'evolucao.sem_resultados_desc' => 'Tap the button below to log your first blood test or bioimpedance and track your progress.',
			'evolucao.tudo_na_faixa' => 'Last Exam: All Within Range',
			'evolucao.ultima_bio' => 'Latest Bioimpedance',
			'evolucao.historico_titulo' => 'Record History',
			'evolucao.sem_categoria' => 'No records in this category.',
			'evolucao.escolha_marcador' => 'Select Marker to View',
			'evolucao.sem_dados_marcador' => 'No data logged for this marker.',
			'evolucao.tooltip_email' => 'Send report to my email',
			'evolucao.tooltip_copiar' => 'Copy report for doctor',
			'evolucao.msg_copiado' => 'Report copied! Paste it into a message or bring it to your appointment.',
			'evolucao.msg_salvo' => 'Record saved successfully!',
			'evolucao.msg_excluido' => 'Record deleted successfully!',
			'evolucao.excluir_titulo' => 'Delete Record',
			'evolucao.excluir_desc' => 'Are you sure you want to delete this clinical record? This action cannot be undone.',
			'evolucao.btn_excluir' => 'Delete',
			'cronograma_modal.titulo' => 'Schedule Period',
			'cronograma_modal.frasco_atual' => ({required Object vol}) => 'Current vial (${vol} mL)',
			'cronograma_modal.frasco_novo' => ({required Object vol}) => 'New vial (${vol} mL)',
			'cronograma_modal.op_frasco' => 'Full vial',
			'cronograma_modal.op_frasco_sub' => 'Until balance runs out',
			'cronograma_modal.op_semanas' => 'By Weeks',
			'cronograma_modal.op_semanas_sub' => 'E.g.: 4 or 8 weeks',
			'cronograma_modal.op_meses' => 'By Months',
			'cronograma_modal.op_meses_sub' => 'E.g.: 3 months',
			'cronograma_modal.op_injecoes' => 'By Injections',
			'cronograma_modal.op_injecoes_sub' => 'Exact number of doses',
			'cronograma_modal.lbl_semanas' => 'Weeks',
			'cronograma_modal.lbl_meses' => 'Months',
			'cronograma_modal.lbl_injecoes' => 'Injections',
			'cronograma_modal.btn_gerar_uma' => 'GENERATE 1 INJECTION',
			'cronograma_modal.btn_gerar_varias' => ({required Object qtd}) => 'GENERATE ${qtd} INJECTIONS',
			'cronograma_modal.btn_informe_qtd' => 'ENTER QUANTITY',
			_ => null,
		};
	}
}
