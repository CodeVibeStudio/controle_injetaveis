import 'package:local_auth/local_auth.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'utils/calculadora_reconstituicao_ecra.dart';
import 'utils/simulador_ciclos_ecra.dart'; // 👇 AQUI ESTÁ O IMPORT CORRETO

import 'package:flutter_localizations/flutter_localizations.dart';

import 'i18n/translations.g.dart';

// ==========================================================
// MOTOR DE NOTIFICAÇÕES CORRIGIDO
// ==========================================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> agendarNotificacao(
  int id,
  String titulo,
  String corpo,
  DateTime dataAgendada,
) async {
  tz.TZDateTime dataHoraDisparo = tz.TZDateTime.from(dataAgendada, tz.local);
  final agora = tz.TZDateTime.now(tz.local);

  if (dataHoraDisparo.isBefore(agora)) {
    if (dataAgendada.year == agora.year &&
        dataAgendada.month == agora.month &&
        dataAgendada.day == agora.day) {
      dataHoraDisparo = agora.add(const Duration(minutes: 1));
    } else {
      return;
    }
  }

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_injetaveis',
    'Lembretes de Injeção',
    channelDescription: 'Canal para avisar sobre os dias de aplicação.',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
  );
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id: id,
    title: titulo,
    body: corpo,
    scheduledDate: dataHoraDisparo,
    notificationDetails: platformDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

// ==========================================================
// MOTOR DE SINCRONIZAÇÃO DE ALARMES (ANTI-FANTASMAS)
// ==========================================================
Future<void> atualizarAlarmesNativos() async {
  try {
    await flutterLocalNotificationsPlugin.cancelAll();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final pendentes = await Supabase.instance.client
        .from('cronograma')
        .select(
          'id, data_aplicacao, local_aplicacao, medicamentos(nome, hora_aplicacao)',
        )
        .eq('user_id', userId)
        .eq('status_aplicado', false)
        .order('data_aplicacao', ascending: true)
        .limit(60);

    for (var dose in pendentes) {
      DateTime dataBase = DateTime.parse(dose['data_aplicacao'].toString());

      String horaStr = '08:00';
      if (dose['medicamentos'] != null &&
          dose['medicamentos']['hora_aplicacao'] != null) {
        horaStr = dose['medicamentos']['hora_aplicacao'].toString();
      }
      int h = int.parse(horaStr.split(':')[0]);
      int m = int.parse(horaStr.split(':')[1]);

      DateTime dataHoraExata = DateTime(
        dataBase.year,
        dataBase.month,
        dataBase.day,
        h,
        m,
      );

      if (dataHoraExata.isAfter(DateTime.now())) {
        int idNotificacao = dose['id'].hashCode;
        String nomeMed = dose['medicamentos']?['nome'] ?? 'Medicamento';

        await agendarNotificacao(
          idNotificacao,
          t.notificacoes.titulo_injecao,
          t.notificacoes.corpo_injecao(
            medicamento: nomeMed,
            local: dose['local_aplicacao'],
          ),
          dataHoraExata,
        );
      }
    }
  } catch (e) {
    debugPrint('Erro ao sincronizar alarmes nativos: $e');
  }
}

// 👇 CONTROLO DE SESSÃO E LOGOUT GLOBAL
bool sessaoRecemLogada = false;

Future<void> sairDaConta(BuildContext context) async {
  sessaoRecemLogada = false;
  await Supabase.instance.client.auth.signOut();
  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthGate()),
      (Route<dynamic> route) => false,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale');
  if (savedLocale != null) {
    LocaleSettings.setLocaleRaw(savedLocale);
  }

  try {
    tz.initializeTimeZones();

    final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
    String timeZoneName = 'America/Sao_Paulo';

    if (tzResult is String) {
      timeZoneName = tzResult;
    } else {
      try {
        timeZoneName = tzResult.timezone;
      } catch (_) {
        try {
          timeZoneName = tzResult.id;
        } catch (_) {
          try {
            timeZoneName = tzResult.iana;
          } catch (_) {}
        }
      }
    }

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initSettings);

    await Supabase.initialize(
      url: 'https://fdwrcrkjudadnwcqheoq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkd3JjcmtqdWRhZG53Y3FoZW9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2OTUyODUsImV4cCI6MjEwNjI3MTI4NX0.0nzSgxmFp3Tc7PGcMKyBP3cTUrzXlR9mlj3NcVkQFUE',
    );

    runApp(TranslationProvider(child: const InjetaveisApp()));
  } catch (e, stackTrace) {
    debugPrint('Erro fatal na inicialização: $e\n$stackTrace');

    runApp(
      TranslationProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      t.erros.falha_app,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(t.erros.sem_internet, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Text(
                      'Detalhe técnico: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InjetaveisApp extends StatelessWidget {
  const InjetaveisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Injetáveis',
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.data?.session;
        if (session != null) {
          if (sessaoRecemLogada) {
            return const DashboardEcra();
          }
          return const BiometriaEcra();
        }
        return const LoginEcra();
      },
    );
  }
}

// ==========================================================
// ECRÃ DE LOGIN
// ==========================================================
class LoginEcra extends StatefulWidget {
  const LoginEcra({super.key});
  @override
  State<LoginEcra> createState() => _LoginEcraState();
}

class _LoginEcraState extends State<LoginEcra> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool carregando = false;
  bool _ocultarSenha = true;

  String _traduzirErro(Object erro) {
    final String msg = erro.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Email ou palavra-passe incorretos.';
    } else if (msg.contains('missing email or phone') ||
        msg.contains('Anonymous sign-ins are disabled') ||
        msg.contains('validation_failed')) {
      return 'Por favor, preencha o email e a palavra-passe.';
    } else if (msg.contains('User already registered')) {
      return 'Este email já está registado no sistema.';
    } else if (msg.contains('Password should be at least')) {
      return 'A palavra-passe deve ter pelo menos 6 caracteres.';
    } else if (msg.contains('Unable to validate email address')) {
      return 'Formato de email inválido.';
    }
    return 'Ocorreu um erro. Verifique os dados e tente novamente.';
  }

  void _mostrarAviso(String mensagem, Color cor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> entrar() async {
    setState(() => carregando = true);
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      sessaoRecemLogada = true;
    } catch (e) {
      _mostrarAviso(_traduzirErro(e), Colors.red[700]!);
    }
    setState(() => carregando = false);
  }

  Future<void> registar() async {
    setState(() => carregando = true);
    try {
      await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      sessaoRecemLogada = true;
      _mostrarAviso(
        'Conta criada! Verifique o seu email (e a pasta SPAM) para confirmar.',
        Colors.green[700]!,
      );
    } catch (e) {
      _mostrarAviso(_traduzirErro(e), Colors.red[700]!);
    }
    setState(() => carregando = false);
  }

  Future<void> recuperarSenha() async {
    if (emailController.text.trim().isEmpty) {
      _mostrarAviso(
        'Por favor, digite o seu email para recuperar a senha.',
        Colors.orange[800]!,
      );
      return;
    }
    setState(() => carregando = true);
    try {
      await supabase.auth.resetPasswordForEmail(emailController.text.trim());
      _mostrarAviso(
        'Se o email existir, receberá um link de recuperação.',
        Colors.green[700]!,
      );
    } catch (e) {
      _mostrarAviso(_traduzirErro(e), Colors.red[700]!);
    }
    setState(() => carregando = false);
  }

  Future<void> _abrirUrl(String urlApp) async {
    final Uri url = Uri.parse(urlApp);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.vaccines,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.login.titulo, // 👇 Traduzido
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: t.login.email, // 👇 Traduzido
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: _ocultarSenha,
                        decoration: InputDecoration(
                          labelText: t.login.senha, // 👇 Traduzido
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarSenha
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarSenha = !_ocultarSenha;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (carregando)
                        const CircularProgressIndicator()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: entrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                t.login.entrar, // 👇 Traduzido
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: registar,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1E3A8A),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(t.login.criar_conta), // 👇 Traduzido
                            ),

                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: recuperarSenha,
                              child: Text(
                                t.login.esqueci_senha, // 👇 Traduzido
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _abrirUrl('mailto:codevibe.br@gmail.com'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, color: Colors.red[400], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'codevibe.br@gmail.com',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              InkWell(
                onTap: () => _abrirUrl('https://instagram.com/codevibestudio'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.pinkAccent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '@codevibestudio',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              InkWell(
                onTap: () => _abrirUrl('https://codevibestudio.vercel.app'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.language,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'codevibestudio.vercel.app',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '© 2026 CodeVibe Studio. Todos os direitos reservados.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// DASHBOARD
// ==========================================================
class DashboardEcra extends StatefulWidget {
  const DashboardEcra({super.key});
  @override
  State<DashboardEcra> createState() => _DashboardEcraState();
}

class _DashboardEcraState extends State<DashboardEcra> {
  final supabase = Supabase.instance.client;
  bool carregando = true;
  List<dynamic> proximasDoses = [];
  List<dynamic> ultimasDoses = [];

  DateTime? proximaDataExame;
  List<String> listaExamesSugeridos = [];
  int diasParaExame = 999;
  bool exigeExames = false;

  Map<String, dynamic>? agendamentoAtivo;

  Widget _formatarTextoDose(String textoOriginal) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'([\d,.]+\s*UI)|(\([^)]+\))');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(textoOriginal)) {
      final matchString = match.group(0)!;

      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(text: textoOriginal.substring(lastMatchEnd, match.start)),
        );
      }

      if (matchString.contains('UI')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.deepPurple[700],
            ),
          ),
        );
      } else if (matchString.startsWith('(')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.teal[800],
            ),
          ),
        );
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < textoOriginal.length) {
      spans.add(TextSpan(text: textoOriginal.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: spans,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pedirPermissaoNotificacoes();
    _arranqueSeguro();
  }

  Future<void> _arranqueSeguro() async {
    setState(() => carregando = true);
    await Future.wait([_verificarAgendamentoAtivo(), _calcularExames()]);
    await _carregarResumo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarPendencias();
      atualizarAlarmesNativos();
    });
  }

  Future<void> _verificarAgendamentoAtivo() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final res = await supabase
          .from('agendamento_exames')
          .select()
          .eq('user_id', userId)
          .order('criado_em', ascending: false)
          .limit(1);

      if (res.isNotEmpty) {
        final agendamento = Map<String, dynamic>.from(res.first);
        DateTime dataAgendada = DateTime.parse(
          agendamento['data_agendada'].toString(),
        );
        DateTime hoje = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        DateTime alvo = DateTime(
          dataAgendada.year,
          dataAgendada.month,
          dataAgendada.day,
        );
        int diferenca = alvo.difference(hoje).inDays;

        if (diferenca >= 0) {
          setState(() {
            agendamento['dias_restantes'] = diferenca;
            agendamento['data_obj'] = alvo;
            agendamentoAtivo = agendamento;
          });
        } else {
          setState(() => agendamentoAtivo = null);
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar agendamento: $e');
    }
  }

  void _abrirChecklistExames() {
    if (agendamentoAtivo == null) return;

    bool cienteJejum = agendamentoAtivo!['ciente_jejum'] ?? false;
    bool cienteTreino = agendamentoAtivo!['ciente_treino'] ?? false;
    bool cienteProstata = agendamentoAtivo!['ciente_prostata'] ?? false;
    bool cienteFigado = agendamentoAtivo!['ciente_figado'] ?? false;
    bool cienteHorario = agendamentoAtivo!['ciente_horario'] ?? false;
    bool cienteFidelidade = agendamentoAtivo!['ciente_fidelidade'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rule_folder,
                          color: Colors.orange[800],
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.exames.checklist_titulo, // 👇 Traduzido
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.exames.checklist_subtitulo, // 👇 Traduzido
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item1_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ), // 👇 Traduzido
                            subtitle: Text(t.exames.item1_desc), // 👇 Traduzido
                            value: cienteJejum,
                            onChanged: (val) =>
                                setStateSheet(() => cienteJejum = val!),
                          ),
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item2_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(t.exames.item2_desc),
                            value: cienteTreino,
                            onChanged: (val) =>
                                setStateSheet(() => cienteTreino = val!),
                          ),
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item3_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(t.exames.item3_desc),
                            value: cienteProstata,
                            onChanged: (val) =>
                                setStateSheet(() => cienteProstata = val!),
                          ),
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item4_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(t.exames.item4_desc),
                            value: cienteFigado,
                            onChanged: (val) =>
                                setStateSheet(() => cienteFigado = val!),
                          ),
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item5_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(t.exames.item5_desc),
                            value: cienteHorario,
                            onChanged: (val) =>
                                setStateSheet(() => cienteHorario = val!),
                          ),
                          CheckboxListTile(
                            activeColor: Colors.green,
                            title: Text(
                              t.exames.item6_tit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(t.exames.item6_desc),
                            value: cienteFidelidade,
                            onChanged: (val) =>
                                setStateSheet(() => cienteFidelidade = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await supabase
                                .from('agendamento_exames')
                                .update({
                                  'ciente_jejum': cienteJejum,
                                  'ciente_treino': cienteTreino,
                                  'ciente_prostata': cienteProstata,
                                  'ciente_figado': cienteFigado,
                                  'ciente_horario': cienteHorario,
                                  'ciente_fidelidade': cienteFidelidade,
                                })
                                .eq('id', agendamentoAtivo!['id']);

                            if (mounted) {
                              Navigator.pop(context);
                              _verificarAgendamentoAtivo();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Protocolo guardado com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                          }
                        },
                        icon: const Icon(Icons.verified, color: Colors.white),
                        label: Text(
                          t.exames.btn_confirmar, // 👇 Traduzido
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _carregarDoCache(SharedPreferences prefs) {
    final cacheProximas = prefs.getString('cache_proximas_doses');
    final cacheUltimas = prefs.getString('cache_ultimas_doses');

    if (mounted) {
      setState(() {
        proximasDoses = cacheProximas != null ? jsonDecode(cacheProximas) : [];
        ultimasDoses = cacheUltimas != null ? jsonDecode(cacheUltimas) : [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modo Offline: A mostrar dados guardados no aparelho.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _carregarResumo() async {
    setState(() => carregando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final conectividade = await Connectivity().checkConnectivity();

      bool semInternet = false;
      semInternet = (conectividade as List).contains(ConnectivityResult.none);

      if (semInternet) {
        _carregarDoCache(prefs);
        if (mounted) setState(() => carregando = false);
        return;
      }

      final respProxima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', false)
          .order('data_aplicacao', ascending: true)
          .timeout(const Duration(seconds: 5));

      final respUltima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', true)
          .order('data_aplicacao', ascending: false)
          .timeout(const Duration(seconds: 5));

      List<dynamic> proximasFiltradas = [];
      Set<String> medicamentosProximosVistos = {};
      for (var dose in respProxima) {
        String idMed = dose['medicamento_id'].toString();
        if (!medicamentosProximosVistos.contains(idMed)) {
          proximasFiltradas.add(dose);
          medicamentosProximosVistos.add(idMed);
        }
      }

      List<dynamic> ultimasFiltradas = [];
      Set<String> medicamentosUltimosVistos = {};
      for (var dose in respUltima) {
        String idMed = dose['medicamento_id'].toString();
        if (!medicamentosUltimosVistos.contains(idMed)) {
          ultimasFiltradas.add(dose);
          medicamentosUltimosVistos.add(idMed);
        }
      }

      await prefs.setString(
        'cache_proximas_doses',
        jsonEncode(proximasFiltradas),
      );
      await prefs.setString(
        'cache_ultimas_doses',
        jsonEncode(ultimasFiltradas),
      );

      if (mounted) {
        setState(() {
          proximasDoses = proximasFiltradas;
          ultimasDoses = ultimasFiltradas;
        });
      }
    } catch (e) {
      debugPrint('Falha na rede ou limite de tempo atingido: $e');
      final prefs = await SharedPreferences.getInstance();
      _carregarDoCache(prefs);
    }

    if (mounted) {
      setState(() => carregando = false);
    }
  }

  Future<void> _verificarPendencias() async {
    final usuarioId = supabase.auth.currentUser?.id;
    if (usuarioId == null) return;

    try {
      final respostaTermos = await supabase
          .from('aceites_termos')
          .select()
          .eq('user_id', usuarioId);
      if (respostaTermos.isEmpty) {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GuiaFaqEcra(obrigatorio: true),
            ),
          );
        }
      }

      if (!mounted) return;
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('id', usuarioId)
          .maybeSingle();

      if (perfil == null ||
          perfil['genero'] == null ||
          perfil['data_nascimento'] == null) {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PerfilEcra(obrigatorio: true),
            ),
          );
          _calcularExames();
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar pendências: $e');
    }
  }

  void _pedirPermissaoNotificacoes() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  Future<void> _calcularExames() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('id', userId)
          .maybeSingle();

      String genero = perfil != null && perfil['genero'] != null
          ? perfil['genero']
          : 'Masculino';

      int idade = 30;
      if (perfil != null && perfil['data_nascimento'] != null) {
        DateTime nascimento = DateTime.parse(perfil['data_nascimento']);
        idade = DateTime.now().year - nascimento.year;
      }

      final tratamentos = await supabase
          .from('medicamentos')
          .select('categoria_clinica, data_inicio')
          .order('data_inicio', ascending: false);

      if (tratamentos.isEmpty) {
        setState(() => exigeExames = false);
        return;
      }

      bool isHormonal = false;
      bool isMetabolico = false;
      DateTime inicioMaisRecente = DateTime.parse(
        tratamentos.last['data_inicio'].toString(),
      );

      for (var med in tratamentos) {
        String cat = med['categoria_clinica'].toString();
        DateTime dt = DateTime.parse(med['data_inicio'].toString());

        if (dt.isAfter(inicioMaisRecente)) inicioMaisRecente = dt;

        if (cat.contains('Testosterona') ||
            cat.contains('DHT') ||
            cat.contains('19-Nor') ||
            cat.contains('Mix')) {
          isHormonal = true;
        } else if (cat.contains('GLP-1')) {
          isMetabolico = true;
        }
      }

      if (!isHormonal && !isMetabolico) {
        setState(() => exigeExames = false);
        return;
      }

      Set<String> exames = {
        t.exames.nomes.hemo,
        t.exames.nomes.marcadores,
        t.exames.nomes.lipidico,
        t.exames.nomes.figado,
        t.exames.nomes.rim,
        t.exames.nomes.cpk,
      };

      if (isHormonal) {
        exames.addAll([
          t.exames.nomes.testo,
          t.exames.nomes.e2,
          t.exames.nomes.shbg,
          t.exames.nomes.dht,
          t.exames.nomes.prolactina,
          t.exames.nomes.tireoide,
        ]);
        if (genero == 'Masculino' && idade >= 40) {
          exames.add(t.exames.nomes.psa);
        }
      }

      if (isMetabolico || isHormonal) {
        exames.addAll([
          t.exames.nomes.glicemia,
          t.exames.nomes.insulina,
          t.exames.nomes.hba1c,
        ]);
      }

      final historico = await supabase
          .from('historico_exames')
          .select()
          .eq('user_id', userId)
          .order('data_exame', ascending: false)
          .limit(1);

      DateTime dataAlvo;
      if (historico.isEmpty) {
        dataAlvo = inicioMaisRecente.add(const Duration(days: 45));
      } else {
        DateTime ultimo = DateTime.parse(
          historico.first['data_exame'].toString(),
        );
        dataAlvo = ultimo.add(const Duration(days: 120));
      }

      if (dataAlvo.isBefore(DateTime.now())) {
        dataAlvo = DateTime.now();
      }

      setState(() {
        exigeExames = true;
        proximaDataExame = dataAlvo;
        listaExamesSugeridos = exames.toList();

        DateTime hoje = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        DateTime alvo = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day);
        diasParaExame = alvo.difference(hoje).inDays;
      });
    } catch (e) {
      debugPrint('Erro no Cérebro Analítico: $e');
    }
  }

  Future<void> _registarExameFeito() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('historico_exames').insert({
        'user_id': userId,
        'data_exame': DateTime.now().toIso8601String().split('T')[0],
        'categoria_alvo': 'Painel Automático',
      });

      Navigator.pop(context);
      _calcularExames();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Exames registados! Nova janela de manutenção agendada.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _agendarExameFuturo() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 150)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
        ),
        child: child!,
      ),
    );

    if (dataEscolhida == null) return;

    setState(() => carregando = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('agendamento_exames').insert({
        'user_id': userId,
        'data_agendada': dataEscolhida.toIso8601String().split('T')[0],
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Coleta agendada! O seu protocolo de preparação foi ativado.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        _arranqueSeguro();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => carregando = false);
  }

  void _abrirPainelExames() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.biotech, color: Colors.indigo, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      t.exames.painel_titulo, // 👇 Traduzido
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  t.exames.painel_subtitulo, // 👇 Traduzido
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ...listaExamesSugeridos.map(
                  (exame) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exame,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _agendarExameFuturo,
                    icon: const Icon(Icons.edit_calendar, color: Colors.white),
                    label: Text(
                      t.exames.btn_agendar, // 👇 Traduzido
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _registarExameFeito,
                    icon: const Icon(Icons.history, color: Color(0xFF1E3A8A)),
                    label: Text(
                      t.exames.btn_ja_fiz, // 👇 Traduzido
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1E3A8A),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarData(String dataIso) {
    final partes = dataIso.split('-');
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.dashboard.titulo, // 👇 Traduzido
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/seringa_icon.png',
              width: 44,
              height: 44,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.calculate),
            ),
            tooltip: 'Calculadora de Reconstituição',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalculadoraReconstituicaoEcra(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Guia e Termos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuiaFaqEcra()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Meu Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerfilEcra()),
            ).then((_) => _calcularExames()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => sairDaConta(context),
          ),
        ],
      ),
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.dashboard.resumo_clinico, // 👇 Traduzido
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (agendamentoAtivo != null &&
                                agendamentoAtivo!['dias_restantes'] <= 3)
                              Card(
                                color: Colors.orange[50],
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.orange[800]!,
                                    width: 1.5,
                                  ),
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.assignment_late,
                                            color: Colors.orange[800],
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              agendamentoAtivo!['dias_restantes'] ==
                                                      0
                                                  ? 'A coleta de sangue é HOJE!'
                                                  : t.dashboard_alertas
                                                        .atencao_coleta(
                                                          dias:
                                                              agendamentoAtivo!['dias_restantes'],
                                                        ),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t.dashboard_alertas.texto_protecao,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _abrirChecklistExames,
                                          icon: const Icon(
                                            Icons.checklist,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            t
                                                .dashboard_alertas
                                                .btn_abrir_checklist,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (exigeExames && proximaDataExame != null)
                              Card(
                                color: agendamentoAtivo != null
                                    ? Colors.indigo[50]
                                    : (diasParaExame <= 0
                                          ? Colors.red[50]
                                          : (diasParaExame <= 15
                                                ? Colors.orange[50]
                                                : Colors.teal[50])),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: agendamentoAtivo != null
                                        ? Colors.indigo
                                        : (diasParaExame <= 0
                                              ? Colors.red
                                              : (diasParaExame <= 15
                                                    ? Colors.orange
                                                    : Colors.teal)),
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            agendamentoAtivo != null
                                                ? Icons.event_available
                                                : Icons.biotech,
                                            color: agendamentoAtivo != null
                                                ? Colors.indigo[800]
                                                : (diasParaExame <= 0
                                                      ? Colors.red[800]
                                                      : (diasParaExame <= 15
                                                            ? Colors.orange[800]
                                                            : Colors
                                                                  .teal[800])),
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              agendamentoAtivo != null
                                                  ? t
                                                        .dashboard_alertas
                                                        .coleta_agendada
                                                  : (diasParaExame <= 0
                                                        ? 'Exames Atrasados'
                                                        : (diasParaExame <= 15
                                                              ? 'Exames Próximos'
                                                              : 'Check-up de Biomarcadores')),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: agendamentoAtivo != null
                                                    ? Colors.indigo[800]
                                                    : (diasParaExame <= 0
                                                          ? Colors.red[800]
                                                          : (diasParaExame <= 15
                                                                ? Colors
                                                                      .orange[800]
                                                                : Colors
                                                                      .teal[800])),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        agendamentoAtivo != null
                                            ? t.dashboard_alertas.texto_exames(
                                                dias:
                                                    agendamentoAtivo!['dias_restantes'],
                                                data:
                                                    '${(agendamentoAtivo!['data_obj'] as DateTime).day.toString().padLeft(2, '0')}/${(agendamentoAtivo!['data_obj'] as DateTime).month.toString().padLeft(2, '0')}',
                                              )
                                            : (diasParaExame <= 0
                                                  ? 'A sua janela ideal de exames de controle já começou! Veja o que solicitar ao seu médico.'
                                                  : 'Próxima coleta sugerida em $diasParaExame dias (${proximaDataExame!.day.toString().padLeft(2, '0')}/${proximaDataExame!.month.toString().padLeft(2, '0')}).'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: _abrirPainelExames,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF1E3A8A,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFF1E3A8A),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            agendamentoAtivo != null
                                                ? t
                                                      .dashboard_alertas
                                                      .btn_ver_painel
                                                : 'VER PAINEL SUGERIDO',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (exigeExames) const SizedBox(height: 16),
                            Card(
                              color: Colors.blue[50],
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.notification_important,
                                          color: Colors.blue,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t.dashboard.proxima_aplicacao, // 👇 Traduzido
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    if (proximasDoses.isNotEmpty) ...[
                                      ...proximasDoses.map(
                                        (dose) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dose['medicamentos'] != null
                                                    ? dose['medicamentos']['nome']
                                                          .toString()
                                                          .replaceAll(
                                                            '[Arquivado] ',
                                                            '',
                                                          )
                                                          .replaceAll(
                                                            '[Oculto] ',
                                                            '',
                                                          )
                                                    : 'Medicamento indisponível',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                              Text(
                                                '${t.dashboard_alertas.label_data}${_formatarData(dose['data_aplicacao'])}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '${t.dashboard_alertas.label_local}${dose['local_aplicacao']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              _formatarTextoDose(
                                                '${t.dashboard_alertas.label_dose}${dose['dose_ajustada']}',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ] else
                                      const Text(
                                        'Nenhuma aplicação futura agendada.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t
                                              .dashboard
                                              .ultima_aplicacao, // 👇 Traduzido
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    if (ultimasDoses.isNotEmpty) ...[
                                      ...ultimasDoses.map(
                                        (dose) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dose['medicamentos'] != null
                                                    ? dose['medicamentos']['nome']
                                                          .toString()
                                                    : 'Medicamento indisponível',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${t.dashboard_alertas.label_data}${_formatarData(dose['data_aplicacao'])}',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ] else
                                      const Text(
                                        'Nenhum histórico de aplicações.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetupEcra(),
                          ),
                        ).then((_) {
                          _arranqueSeguro();
                        });
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: Text(
                        t.dashboard.gerir_medicamentos, // 👇 Traduzido
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==========================================================
// BANCO DE MEDICAMENTOS (SetupEcra)
// ==========================================================
class SetupEcra extends StatefulWidget {
  const SetupEcra({super.key});
  @override
  State<SetupEcra> createState() => _SetupEcraState();
}

class _SetupEcraState extends State<SetupEcra> {
  final supabase = Supabase.instance.client;

  Widget _formatarTextoDose(String textoOriginal) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'([\d,.]+\s*UI)|(\([^)]+\))');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(textoOriginal)) {
      final matchString = match.group(0)!;

      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(text: textoOriginal.substring(lastMatchEnd, match.start)),
        );
      }

      if (matchString.contains('UI')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.deepPurple[700],
            ),
          ),
        );
      } else if (matchString.startsWith('(')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.teal[800],
            ),
          ),
        );
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < textoOriginal.length) {
      spans.add(TextSpan(text: textoOriginal.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: spans,
      ),
    );
  }

  Future<List<dynamic>> obterMedicamentos() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final conectividade = await Connectivity().checkConnectivity();
      bool semInternet = false;
      semInternet = (conectividade as List).contains(ConnectivityResult.none);

      if (semInternet) {
        final cache = prefs.getString('cache_medicamentos');
        if (cache != null) return jsonDecode(cache);
        return [];
      }

      final List<dynamic> res = await supabase
          .from('medicamentos')
          .select()
          .order('criado_em')
          .timeout(const Duration(seconds: 5));

      final listaFiltrada = res
          .where((m) => !m['nome'].toString().startsWith('[Oculto]'))
          .toList();

      await prefs.setString('cache_medicamentos', jsonEncode(listaFiltrada));

      return listaFiltrada;
    } catch (e) {
      final cache = prefs.getString('cache_medicamentos');
      if (cache != null) return jsonDecode(cache);
      return [];
    }
  }

  Future<void> _deletarMedicamento(dynamic id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Excluir Medicamento',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Tem a certeza que deseja excluir este medicamento e todo o seu cronograma?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await supabase.from('cronograma').delete().eq('medicamento_id', id);
      await supabase.from('medicamentos').delete().eq('id', id);
      await atualizarAlarmesNativos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
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
          t.setup.titulo, // 👇 Traduzido
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormularioMedicamentoEcra(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          t.setup.btn_novo, // 👇 Traduzido
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: obterMedicamentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final medicamentos = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (medicamentos.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Center(
                    child: Text(
                      t.setup.nenhum_medicamento, // 👇 Traduzido
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                ...medicamentos.map((med) {
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CronogramaEcra(medicamento: med),
                      ),
                    ),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    med['nome'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FormularioMedicamentoEcra(
                                                medicamentoEditado: med,
                                              ),
                                        ),
                                      ).then((_) => setState(() {})),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deletarMedicamento(med['id']),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            if (med['detalhes_dose'] != null &&
                                med['detalhes_dose'].toString().isNotEmpty) ...[
                              _formatarTextoDose(
                                'Dose: ${med['detalhes_dose']}',
                              ),
                              const SizedBox(height: 4),
                            ] else if (med['dose_semanal'] != null &&
                                med['dose_semanal'] > 0) ...[
                              Text(
                                'Dose Semanal: ${med['dose_semanal']} ${med['unidade_dose'] ?? 'mg'}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              (med['tipo_frequencia'] == 'dias_semana' &&
                                      med['dias_semana'] != null &&
                                      med['dias_semana'].toString().isNotEmpty)
                                  ? '${t.formulario.freq_dias_semana}: ${med['dias_semana'].toString().split(',').map((d) => t.formulario.dias_semana[d.toString()]!).join(', ')}'
                                  : t.complementos.intervalo_cada(
                                      dias: med['intervalo_dias'] ?? 1,
                                    ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 24),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF1E3A8A), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.auto_graph, color: Colors.white),
                  ),
                  title: Text(
                    t.setup.simulador_titulo, // 👇 Traduzido
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  subtitle: Text(
                    t.setup.simulador_subtitulo, // 👇 Traduzido
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimuladorCiclosEcra(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 64),
            ],
          );
        },
      ),
    );
  }
}

class FormularioMedicamentoEcra extends StatefulWidget {
  final Map<String, dynamic>? medicamentoEditado;
  const FormularioMedicamentoEcra({super.key, this.medicamentoEditado});

  @override
  State<FormularioMedicamentoEcra> createState() =>
      _FormularioMedicamentoEcraState();
}

class _FormularioMedicamentoEcraState extends State<FormularioMedicamentoEcra> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool carregando = false;

  List<dynamic> listaCatalogo = [];
  String? nomeSelecionado;
  bool modoNovoMedicamento = true;
  bool modoEdicao = false;

  bool _isMix = false;
  List<dynamic> medicamentosBaseMix = [];

  String tipoFrequencia = 'intervalo';
  List<int> diasSemanaSelecionados = [];

  final nomeCtrl = TextEditingController();
  final ampolasCtrl = TextEditingController();
  final volumeCtrl = TextEditingController();
  final concentracaoCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final intervaloCtrl = TextEditingController();

  String? categoriaSelecionada;
  String? unidadeSelecionada;
  int? seringaSelecionada;

  String? regiaoSelecionada;
  List<String> regioesSelecionadasList = [];

  DateTime dataInicio = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 8, minute: 0);

  String textoDetalhesDose = '';
  double calcVolumeMl = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarCatalogo();

    if (widget.medicamentoEditado != null) {
      modoEdicao = true;
      modoNovoMedicamento = true;
      nomeCtrl.text = widget.medicamentoEditado!['nome'];
      ampolasCtrl.text = widget.medicamentoEditado!['quantidade_ampolas']
          .toString();
      volumeCtrl.text = widget.medicamentoEditado!['volume_frasco_ml']
          .toString();
      concentracaoCtrl.text = widget.medicamentoEditado!['concentracao_mg_ml']
          .toString();
      doseCtrl.text = widget.medicamentoEditado!['dose_semanal'].toString();
      intervaloCtrl.text = widget.medicamentoEditado!['intervalo_dias']
          .toString();

      if (widget.medicamentoEditado!['tipo_frequencia'] != null) {
        tipoFrequencia = widget.medicamentoEditado!['tipo_frequencia'];
      }
      if (widget.medicamentoEditado!['dias_semana'] != null &&
          widget.medicamentoEditado!['dias_semana'].toString().isNotEmpty) {
        diasSemanaSelecionados = widget.medicamentoEditado!['dias_semana']
            .toString()
            .split(',')
            .map((e) => int.parse(e))
            .toList();
      }

      unidadeSelecionada = widget.medicamentoEditado!['unidade_dose'];
      seringaSelecionada = widget.medicamentoEditado!['seringa_ui'];

      if (widget.medicamentoEditado!['regiao_rodizio'] != null) {
        regiaoSelecionada = widget.medicamentoEditado!['regiao_rodizio'];
        regioesSelecionadasList = regiaoSelecionada!.split(', ');
      }

      dataInicio =
          DateTime.tryParse(widget.medicamentoEditado!['data_inicio']) ??
          DateTime.now();

      if (widget.medicamentoEditado!['hora_aplicacao'] != null) {
        final partesHora = widget.medicamentoEditado!['hora_aplicacao']
            .toString()
            .split(':');
        horaInicio = TimeOfDay(
          hour: int.parse(partesHora[0]),
          minute: int.parse(partesHora[1]),
        );
      }

      if (widget.medicamentoEditado!['detalhes_dose'] != null) {
        textoDetalhesDose = widget.medicamentoEditado!['detalhes_dose'];
      }

      categoriaSelecionada = widget.medicamentoEditado!['categoria_clinica'];

      if (nomeCtrl.text.startsWith('Mix:')) _isMix = true;
    }

    doseCtrl.addListener(_recalcularEquivalencia);
    concentracaoCtrl.addListener(_recalcularEquivalencia);
    intervaloCtrl.addListener(_recalcularEquivalencia);

    if (modoEdicao && !_isMix) {
      _recalcularEquivalencia();
    }
  }

  @override
  void dispose() {
    doseCtrl.dispose();
    concentracaoCtrl.dispose();
    intervaloCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarCatalogo() async {
    try {
      final resposta = await supabase.rpc('obter_nomes_unicos');
      List<dynamic> listaProcessada = [];

      for (var item in resposta) {
        String nomeReal = item['nome'].toString();

        if (nomeReal.startsWith('Mix') || nomeReal.startsWith('[Arquivado]')) {
          continue;
        }

        if (nomeReal.startsWith('[Oculto] ')) {
          nomeReal = nomeReal.replaceFirst('[Oculto] ', '');
          item['nome'] = nomeReal;
        }

        if (!listaProcessada.any(
          (e) => e['nome'].toString().toLowerCase() == nomeReal.toLowerCase(),
        )) {
          listaProcessada.add(Map<String, dynamic>.from(item));
        }
      }

      setState(() {
        listaCatalogo = listaProcessada;
        listaCatalogo.sort(
          (a, b) => a['nome'].toString().toLowerCase().compareTo(
            b['nome'].toString().toLowerCase(),
          ),
        );

        if (listaCatalogo.isNotEmpty && !modoEdicao) {
          modoNovoMedicamento = false;
        }
      });
    } catch (e) {
      debugPrint('Erro ao carregar catálogo: $e');
    }
  }

  void _limparSelecao() {
    setState(() {
      nomeSelecionado = null;
      modoNovoMedicamento = true;
      nomeCtrl.clear();
      ampolasCtrl.clear();
      volumeCtrl.clear();
      concentracaoCtrl.clear();
      doseCtrl.clear();
      intervaloCtrl.clear();
      unidadeSelecionada = null;
      seringaSelecionada = null;
      regiaoSelecionada = null;
      regioesSelecionadasList = [];
      _isMix = false;
      textoDetalhesDose = '';
      calcVolumeMl = 0.0;
    });
  }

  Future<void> _abrirSeletorLocais() async {
    final locaisDisponiveis = [
      t.regioes.ventro_gluteo,
      t.regioes.vasto_lateral,
      t.regioes.deltoide,
      t.regioes.gluteo_superior,
      t.regioes.barriga,
      t.regioes.flanco,
      t.regioes.perna_anterior,
      t.regioes.braco_triceps,
    ];
    List<String> tempSelecionados = List.from(regioesSelecionadasList);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Selecione os Locais',
            style: TextStyle(color: Color(0xFF1E3A8A)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: locaisDisponiveis
                  .map(
                    (local) => CheckboxListTile(
                      title: Text(
                        local,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: tempSelecionados.contains(local),
                      activeColor: Colors.orange,
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true) {
                            tempSelecionados.add(local);
                          } else {
                            tempSelecionados.remove(local);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() {
                  regioesSelecionadasList = tempSelecionados;
                  regiaoSelecionada = regioesSelecionadasList.join(', ');
                });
                Navigator.pop(ctx);
              },
              child: const Text(
                'CONFIRMAR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirSeletorDeMix() async {
    setState(() => carregando = true);
    List<dynamic> meusMedicamentos = [];
    try {
      meusMedicamentos = await supabase
          .from('medicamentos')
          .select()
          .order('criado_em');
    } catch (e) {
      debugPrint('Erro ao buscar medicamentos para o Mix: $e');
    }
    setState(() => carregando = false);

    List<dynamic> listaMisturavel = List<dynamic>.from(meusMedicamentos)
        .where((m) {
          final n = m['nome'].toString();
          return !n.startsWith('Mix') &&
              !n.startsWith('[Oculto]') &&
              !n.startsWith('[Arquivado]');
        })
        .toList();

    if (listaMisturavel.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Configure pelo menos 2 medicamentos no seu Banco primeiro para criar um Mix.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<dynamic> selecionados = List<dynamic>.from(medicamentosBaseMix);

    final resultado = await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Criar Mix Seguro',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listaMisturavel.length,
                  itemBuilder: (context, index) {
                    final med = listaMisturavel[index];
                    final isSelected = selecionados.any(
                      (m) => m['id'] == med['id'],
                    );
                    return CheckboxListTile(
                      title: Text(
                        med['nome'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${med['concentracao_mg_ml']} mg/mL | Seringa: ${med['seringa_ui']} UI | Local: ${med['regiao_rodizio']}\nIntervalo: ${med['intervalo_dias']} dias',
                      ),
                      value: isSelected,
                      activeColor: Colors.orange,
                      onChanged: (bool? val) {
                        setStateDialog(() {
                          if (val == true) {
                            selecionados.add(med);
                          } else {
                            selecionados.removeWhere(
                              (m) => m['id'] == med['id'],
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () => Navigator.pop(ctx, selecionados),
                  child: const Text(
                    'CRIAR MIX',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      if (resultado.length >= 2) {
        int? intRef = resultado.first['intervalo_dias'];
        int? serRef = resultado.first['seringa_ui'];
        String? regRef = resultado.first['regiao_rodizio'];

        bool isConsistent = resultado.every(
          (m) =>
              m['intervalo_dias'] == intRef &&
              m['seringa_ui'] == serRef &&
              m['regiao_rodizio'] == regRef,
        );

        if (!isConsistent) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(
                  '⚠️ Incompatibilidade',
                  style: TextStyle(color: Colors.red),
                ),
                content: const Text(
                  'Os medicamentos selecionados possuem Intervalos, Seringas ou Regiões diferentes.\n\nPara criar um Mix seguro, os medicamentos base precisam de ter estas configurações exatamente iguais. Por favor, edite-os no Banco de Medicamentos e tente novamente.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }

        setState(() {
          _isMix = true;
          modoNovoMedicamento = false;
          nomeSelecionado = null;
          medicamentosBaseMix = resultado;
          final nomes = medicamentosBaseMix.map((m) => m['nome']).join(' + ');
          nomeCtrl.text = 'Mix: $nomes';
          intervaloCtrl.text = intRef.toString();
          seringaSelecionada = serRef;

          regiaoSelecionada = regRef;
          if (regRef != null) {
            regioesSelecionadasList = regRef.split(', ');
          }

          _recalcularEquivalencia();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Selecione pelo menos 2 medicamentos para criar um Mix.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _aplicarPreenchimentoSeguro(String nome) {
    final med = listaCatalogo.firstWhere(
      (e) => e['nome'] == nome,
      orElse: () => {},
    );
    if (med.isEmpty) return;

    volumeCtrl.text = med['volume_frasco_ml'] != null
        ? med['volume_frasco_ml'].toString()
        : '';
    concentracaoCtrl.text = med['concentracao_mg_ml'] != null
        ? med['concentracao_mg_ml'].toString()
        : '';
    intervaloCtrl.text = med['intervalo_dias'] != null
        ? med['intervalo_dias'].toString()
        : '';
    doseCtrl.text = med['dose_semanal'] != null
        ? med['dose_semanal'].toString()
        : '';
    ampolasCtrl.text = med['qtd_ampolas'] != null
        ? med['qtd_ampolas'].toString()
        : '';

    if (med['unidade'] != null) {
      setState(() => unidadeSelecionada = med['unidade'].toString());
    }

    if (med['regiao_base'] != null) {
      setState(() {
        regiaoSelecionada = med['regiao_base'].toString();
        regioesSelecionadasList = regiaoSelecionada!.split(', ');
      });
    }

    if (med['seringa_ui'] != null) {
      setState(
        () => seringaSelecionada =
            int.tryParse(med['seringa_ui'].toString()) ?? 100,
      );
    }
  }

  void _recalcularEquivalencia() {
    if (_isMix) {
      if (intervaloCtrl.text.isEmpty) {
        setState(() {
          textoDetalhesDose = '';
          calcVolumeMl = 0.0;
        });
        return;
      }
      try {
        int intervalo = int.parse(intervaloCtrl.text.replaceAll(',', '.'));
        List<String> partes = [];
        double totalMl = 0.0;

        for (var b in medicamentosBaseMix) {
          double dSemanal = (b['dose_semanal'] as num).toDouble();
          double conc = (b['concentracao_mg_ml'] as num).toDouble();
          String unid = b['unidade_dose']?.toString() ?? 'mg';

          double fator = (intervalo == 3)
              ? (dSemanal / 2)
              : ((dSemanal / 7) * intervalo);
          double doseMg = (unid == 'mL') ? (fator * conc) : fator;

          double vol = doseMg / conc;
          double doseUi = vol * 100;
          totalMl += vol;

          String nomeCompleto = b['nome'].toString();
          String nomeAbrev = nomeCompleto.length >= 4
              ? nomeCompleto.substring(0, 4)
              : nomeCompleto;

          partes.add(
            '${doseMg.toStringAsFixed(2).replaceAll('.', ',')}mg / ${doseUi.toStringAsFixed(2).replaceAll('.', ',')} UI ($nomeAbrev)',
          );
        }
        setState(() {
          textoDetalhesDose = partes.join(' + ');
          calcVolumeMl = totalMl;

          if (seringaSelecionada == null ||
              calcVolumeMl > seringaSelecionada! / 100.0) {
            if (calcVolumeMl <= 0.3) {
              seringaSelecionada = 30;
            } else if (calcVolumeMl <= 0.5)
              seringaSelecionada = 50;
            else if (calcVolumeMl <= 1.0)
              seringaSelecionada = 100;
            else if (calcVolumeMl <= 3.0)
              seringaSelecionada = 300;
            else
              seringaSelecionada = 500;
          }
        });
      } catch (e) {}
    } else {
      if (doseCtrl.text.isEmpty ||
          concentracaoCtrl.text.isEmpty ||
          unidadeSelecionada == null ||
          (tipoFrequencia == 'intervalo' && intervaloCtrl.text.isEmpty) ||
          (tipoFrequencia == 'dias_semana' && diasSemanaSelecionados.isEmpty)) {
        setState(() {
          textoDetalhesDose = '';
          calcVolumeMl = 0.0;
        });
        return;
      }
      try {
        double doseSemanal = double.parse(doseCtrl.text.replaceAll(',', '.'));
        double concentracao = double.parse(
          concentracaoCtrl.text.replaceAll(',', '.'),
        );

        if (concentracao > 0) {
          setState(() {
            double fator = 0;
            if (tipoFrequencia == 'dias_semana') {
              fator = doseSemanal / diasSemanaSelecionados.length;
            } else {
              int intervalo = int.parse(
                intervaloCtrl.text.replaceAll(',', '.'),
              );
              fator = (intervalo == 3)
                  ? (doseSemanal / 2)
                  : ((doseSemanal / 7) * intervalo);
            }

            double doseMg = (unidadeSelecionada == 'mL')
                ? (fator * concentracao)
                : fator;

            calcVolumeMl = doseMg / concentracao;
            double doseUi = calcVolumeMl * 100;
            textoDetalhesDose =
                '${doseMg.toStringAsFixed(2).replaceAll('.', ',')} mg / ${doseUi.toStringAsFixed(2).replaceAll('.', ',')} UI';

            if (seringaSelecionada == null ||
                calcVolumeMl > seringaSelecionada! / 100.0) {
              if (calcVolumeMl <= 0.3) {
                seringaSelecionada = 30;
              } else if (calcVolumeMl <= 0.5)
                seringaSelecionada = 50;
              else if (calcVolumeMl <= 1.0)
                seringaSelecionada = 100;
              else if (calcVolumeMl <= 3.0)
                seringaSelecionada = 300;
              else
                seringaSelecionada = 500;
            }
          });
        }
      } catch (e) {}
    }
  }

  Future<void> _abrirCalculadoraSegura() async {
    final querUsar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          t.formulario_extras.dialogo_rotulo_titulo,
          style: const TextStyle(color: Color(0xFF1E3A8A)),
        ),
        content: Text(t.formulario_extras.dialogo_rotulo_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.geral.nao),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
        title: const Text(
          'Calculadora de Rótulo\nPASSO 1 DE 2:',
          style: TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: mgCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Total da Substância (mg)', // 👈 Texto universal
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
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
          'Calculadora de Rótulo\nPASSO 2 DE 2:',
          style: TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: mlCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Volume do Líquido (mL)', // 👈 Texto universal
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
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
      String strMg = mg == mg.truncateToDouble()
          ? mg.toStringAsFixed(0)
          : mg.toStringAsFixed(1);
      String strMl = ml == ml.truncateToDouble()
          ? ml.toStringAsFixed(0)
          : ml.toStringAsFixed(1);
      String strRes = resultado == resultado.truncateToDouble()
          ? resultado.toStringAsFixed(0)
          : resultado.toStringAsFixed(2);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sucesso', style: TextStyle(color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Cálculo perfeito!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '$strMg mg ÷ $strMl mL = $strRes mg/mL',
                style: const TextStyle(fontSize: 18, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 12),
              const Text(
                'A concentração foi inserida no formulário automaticamente.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        concentracaoCtrl.text = strRes;
        _recalcularEquivalencia();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Valores inválidos.')));
    }
  }

  Future<void> _escolherData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: dataInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
        ),
        child: child!,
      ),
    );
    if (selecionada != null && selecionada != dataInicio) {
      setState(() => dataInicio = selecionada);
    }
  }

  Future<void> _escolherHora(BuildContext context) async {
    final TimeOfDay? selecionada = await showTimePicker(
      context: context,
      initialTime: horaInicio,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
        ),
        child: child!,
      ),
    );
    if (selecionada != null && selecionada != horaInicio) {
      setState(() => horaInicio = selecionada);
    }
  }

  String _identificarCategoriaClinica(String nomeMedicamento) {
    final nome = nomeMedicamento.toLowerCase();

    if (nome.contains('tirzepatida') ||
        nome.contains('semaglutida') ||
        nome.contains('ozempic') ||
        nome.contains('mounjaro') ||
        nome.contains('saxenda') ||
        nome.contains('liraglutida')) {
      return 'GLP-1';
    } else if (nome.contains('testosterona') ||
        nome.contains('durateston') ||
        nome.contains('enantato') ||
        nome.contains('cipionato') ||
        nome.contains('sustanon')) {
      return 'Testosterona Base';
    } else if (nome.contains('masteron') ||
        nome.contains('drostanolona') ||
        nome.contains('primobolan') ||
        nome.contains('oxandrolona') ||
        nome.contains('stanozolol')) {
      return 'Derivado DHT';
    } else if (nome.contains('nandrolona') ||
        nome.contains('deca') ||
        nome.contains('trembolona')) {
      return 'Derivado 19-Nor';
    } else if (nome.contains('ghk') ||
        nome.contains('bpc') ||
        nome.contains('tb-500') ||
        nome.contains('tb500') ||
        nome.contains('gh ') ||
        nome.contains('somatropina')) {
      return 'Peptídeos';
    }

    return 'Outros';
  }

  Future<void> _guardarMedicamento() async {
    if (!_formKey.currentState!.validate()) return;

    if (regioesSelecionadasList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um Local de Rodízio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (calcVolumeMl >= 1.0 &&
        (regiaoSelecionada?.contains('Barriga') == true ||
            regiaoSelecionada?.contains('Flanco') == true)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.deepOrange, size: 28),
              SizedBox(width: 8),
              Text(
                'Risco de Lesão',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ALERTA MÉDICO - VOLUME INCOMPATÍVEL COM VIA SUBCUTÂNEA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  'Volume: ${calcVolumeMl.toStringAsFixed(2)} mL.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Volumes iguais ou maiores que 1 mL devem ser aplicados via INTRAMUSCULAR!',
                ),
                const SizedBox(height: 16),
                const Text(
                  '✅ OPÇÕES SEGURAS:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '- Glúteo (Ventroglúteo): Mais seguro, distante de grandes nervos.',
                ),
                const Text(
                  '- Coxa (Vasto lateral): Face externa. O mais prático para autoinjeção.',
                ),
                const Text(
                  '- Deltoide (Ombro): Apenas se o volume final for no máximo 1 mL.',
                ),
                const SizedBox(height: 16),
                const Text(
                  '💉 MATERIAIS NECESSÁRIOS:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '• Seringa: 3 mL ou 5 mL com bico Luer-Lok (rosca).',
                ),
                const Text(
                  '• Aspiração: Agulha grossa 18G ou 20G (rosa/verde).',
                ),
                const Text(
                  '• Aplicação: Agulha 25G a 30G (cinza/preta) trocada após aspiração.',
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final nomeFinal = modoNovoMedicamento || _isMix
          ? nomeCtrl.text.trim()
          : nomeSelecionado;
      final intervaloFinal = int.parse(intervaloCtrl.text.replaceAll(',', '.'));

      final categoriaAutomatica = _isMix
          ? 'Mix Esteroides'
          : _identificarCategoriaClinica(nomeFinal!);

      Map<String, dynamic> dados;

      if (_isMix && !modoEdicao) {
        dados = {
          'nome': nomeFinal,
          'quantidade_ampolas': 1,
          'volume_frasco_ml': 1.0,
          'concentracao_mg_ml': 1.0,
          'dose_semanal': calcVolumeMl * 7 / intervaloFinal,
          'unidade_dose': 'mL',
          'intervalo_dias': intervaloFinal,
          'data_inicio': dataInicio.toIso8601String().split('T')[0],
          'hora_aplicacao':
              '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
          'seringa_ui': seringaSelecionada,
          'regiao_rodizio': regiaoSelecionada,
          'detalhes_dose': textoDetalhesDose,
          'categoria_clinica': categoriaAutomatica,
        };
      } else {
        dados = {
          'nome': nomeFinal,
          'quantidade_ampolas':
              int.tryParse(ampolasCtrl.text.replaceAll(',', '.')) ?? 1,
          'volume_frasco_ml':
              double.tryParse(volumeCtrl.text.replaceAll(',', '.')) ?? 1.0,
          'concentracao_mg_ml':
              double.tryParse(concentracaoCtrl.text.replaceAll(',', '.')) ??
              1.0,
          'dose_semanal':
              double.tryParse(doseCtrl.text.replaceAll(',', '.')) ?? 0.0,
          'unidade_dose': unidadeSelecionada,
          'intervalo_dias': tipoFrequencia == 'intervalo' ? intervaloFinal : 1,
          'tipo_frequencia': tipoFrequencia,
          'dias_semana': diasSemanaSelecionados.join(','),
          'data_inicio': dataInicio.toIso8601String().split('T')[0],
          'hora_aplicacao':
              '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
          'seringa_ui': seringaSelecionada,
          'regiao_rodizio': regiaoSelecionada,
          'detalhes_dose': textoDetalhesDose,
          'categoria_clinica': categoriaAutomatica,
        };
      }

      if (modoEdicao) {
        await supabase
            .from('medicamentos')
            .update(dados)
            .eq('id', widget.medicamentoEditado!['id']);

        await supabase.from('cronograma').delete().match({
          'medicamento_id': widget.medicamentoEditado!['id'],
          'status_aplicado': false,
        });
        await atualizarAlarmesNativos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Atualizado! As datas futuras foram limpas. GERE O NOVO CICLO no Cronograma.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        String nomeDigitado = dados['nome'].toString().trim();

        if (nomeDigitado.length < 3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Nome muito curto. Digite o nome completo do medicamento.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final palavrasProibidas = [
          'merda',
          'bosta',
          'caralho',
          'porra',
          'buceta',
          'pica',
          'puta',
          'foda',
          'teste',
        ];
        final nomeMinusculo = nomeDigitado.toLowerCase();
        for (var palavra in palavrasProibidas) {
          if (nomeMinusculo.contains(palavra)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Termo não permitido. Utilize apenas nomes de medicamentos.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }

        nomeDigitado =
            nomeDigitado[0].toUpperCase() + nomeDigitado.substring(1);
        dados['nome'] = nomeDigitado;

        final usuarioId = supabase.auth.currentUser!.id;
        dados['user_id'] = usuarioId;

        await supabase.from('medicamentos').insert(dados);

        if (_isMix && !modoEdicao) {
          for (var baseMed in medicamentosBaseMix) {
            await supabase
                .from('cronograma')
                .delete()
                .eq('medicamento_id', baseMed['id']);
            await supabase
                .from('medicamentos')
                .update({'nome': '[Oculto] ${baseMed['nome']}'})
                .eq('id', baseMed['id']);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => carregando = false);
  }

  Future<void> _arquivarTratamento() async {
    setState(() => carregando = true);
    try {
      final mixNome = widget.medicamentoEditado!['nome'].toString();

      await supabase.from('cronograma').delete().match({
        'medicamento_id': widget.medicamentoEditado!['id'],
        'status_aplicado': false,
      });

      await supabase
          .from('medicamentos')
          .update({'nome': '[Arquivado] $mixNome'})
          .eq('id', widget.medicamentoEditado!['id']);

      await atualizarAlarmesNativos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tratamento Encerrado. O histórico foi guardado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          modoEdicao ? t.formulario.titulo_editar : t.formulario.titulo_novo,
        ),
        backgroundColor: modoEdicao
            ? Colors.orange[800]
            : const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _isMix
                        ? TextFormField(
                            controller: nomeCtrl,
                            decoration: InputDecoration(
                              labelText: t.formulario.campo_mix, // 👇 Traduzido
                              border: const OutlineInputBorder(),
                            ),
                            readOnly: true,
                          )
                        : (modoNovoMedicamento
                              ? TextFormField(
                                  controller: nomeCtrl,
                                  decoration: InputDecoration(
                                    labelText: t
                                        .formulario
                                        .campo_medicamento, // 👇 Traduzido
                                    border: const OutlineInputBorder(),
                                  ),
                                  readOnly: modoEdicao,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Obrigatório'
                                      : null,
                                )
                              : Autocomplete<String>(
                                  initialValue: TextEditingValue(
                                    text: nomeSelecionado ?? '',
                                  ),
                                  optionsBuilder: (TextEditingValue texto) {
                                    if (texto.text.isEmpty) {
                                      return listaCatalogo.map(
                                        (e) => e['nome'].toString(),
                                      );
                                    }
                                    return listaCatalogo
                                        .map((e) => e['nome'].toString())
                                        .where(
                                          (opcao) =>
                                              opcao.toLowerCase().contains(
                                                texto.text.toLowerCase(),
                                              ),
                                        );
                                  },
                                  onSelected: (String selecao) {
                                    setState(() => nomeSelecionado = selecao);
                                    _aplicarPreenchimentoSeguro(selecao);
                                  },
                                  fieldViewBuilder:
                                      (
                                        context,
                                        controller,
                                        focusNode,
                                        onFieldSubmitted,
                                      ) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            labelText:
                                                t.formulario.campo_catalogo,
                                            border: const OutlineInputBorder(),
                                            suffixIcon: const Icon(
                                              Icons.search,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Obrigatório';
                                            }
                                            final existe = listaCatalogo.any(
                                              (e) =>
                                                  e['nome'].toString() == val,
                                            );
                                            if (!existe) {
                                              return 'Selecione um item da lista';
                                            }
                                            return null;
                                          },
                                          onChanged: (val) => setState(
                                            () => nomeSelecionado = val,
                                          ),
                                        );
                                      },
                                )),
                  ),
                  if (!modoEdicao &&
                      (!_isMix ||
                          nomeSelecionado != null ||
                          !modoNovoMedicamento)) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 28,
                      ),
                      onPressed: _limparSelecao,
                      tooltip: 'Limpar tudo',
                    ),
                  ],
                ],
              ),
              if (!modoEdicao)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!modoNovoMedicamento)
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          label: Text(
                            t.formulario.btn_novo_catalogo,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _limparSelecao,
                        ),
                      if (modoNovoMedicamento && listaCatalogo.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.list, color: Colors.blue),
                          label: Text(
                            t.formulario.btn_abrir_catalogo,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () =>
                              setState(() => modoNovoMedicamento = false),
                        ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.science, color: Colors.orange),
                        label: Text(
                          t.formulario.btn_criar_mix,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _abrirSeletorDeMix,
                      ),
                    ],
                  ),
                ),
              if (modoEdicao) const SizedBox(height: 16),
              if (_isMix) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.science, color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'MODO MIX ATIVADO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        modoEdicao
                            ? 'Pode alterar o Intervalo, Seringa e Locais livremente. Para alterar as DOSES base, clique em DESMEMBRAR MIX.'
                            : 'O Intervalo, Seringa e Região foram importados automaticamente.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: intervaloCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: t.formulario.campo_intervalo,
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: false,
                  onChanged: (val) => _recalcularEquivalencia(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Obrigatório' : null,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ampolasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qtd. Frascos', // 👈 Rótulo corrigido
                          border: OutlineInputBorder(),
                          isDense: true, // 👈 Espreme o layout
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 14,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: volumeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Vol. (mL)', // 👈 Rótulo corrigido
                          border: OutlineInputBorder(),
                          isDense: true, // 👈 Espreme o layout
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 14,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: concentracaoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onTap: () {
                          if (concentracaoCtrl.text.isEmpty) {
                            _abrirCalculadoraSegura();
                          }
                        },
                        decoration: InputDecoration(
                          labelText:
                              'Conc. (mg/mL)', // 👈 Rótulo corrigido e curto
                          hintText: 'mg/mL',
                          border: const OutlineInputBorder(),
                          isDense: true, // 👈 Espreme o layout
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calculate,
                              color: Colors.blue,
                            ),
                            tooltip: t.formulario_extras.assistente,
                            onPressed: _abrirCalculadoraSegura,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      // 👈 flex: 6 foi removido daqui
                      child: TextFormField(
                        controller: doseCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: t.formulario.campo_dose_semanal,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                        onChanged: (val) => _recalcularEquivalencia(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      // 👈 flex: 4 foi removido daqui
                      child: DropdownButtonFormField<String>(
                        initialValue: unidadeSelecionada,
                        decoration: InputDecoration(
                          labelText: t.formulario.campo_unidade,
                          border: const OutlineInputBorder(),
                        ),
                        items: ['mg', 'mL']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => unidadeSelecionada = val!);
                          _recalcularEquivalencia();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.event_repeat,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Esquema de Aplicação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  tipoFrequencia = 'intervalo';
                                  _recalcularEquivalencia();
                                }),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tipoFrequencia == 'intervalo'
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: tipoFrequencia == 'intervalo'
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    t.formulario.freq_intervalo,
                                    style: TextStyle(
                                      color: tipoFrequencia == 'intervalo'
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  tipoFrequencia = 'dias_semana';
                                  _recalcularEquivalencia();
                                }),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tipoFrequencia == 'dias_semana'
                                        ? const Color(0xFF1E3A8A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: tipoFrequencia == 'dias_semana'
                                        ? [
                                            const BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    t.formulario.freq_dias_semana,
                                    style: TextStyle(
                                      color: tipoFrequencia == 'dias_semana'
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (tipoFrequencia == 'intervalo')
                        TextFormField(
                          controller: intervaloCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: t.formulario.campo_intervalo,
                            hintText: 'Ex: 7 para uma vez por semana',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.sync),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Obrigatório' : null,
                          onChanged: (val) => _recalcularEquivalencia(),
                        )
                      else
                        Center(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [1, 2, 3, 4, 5, 6, 7].map((dia) {
                              final isSelected = diasSemanaSelecionados
                                  .contains(dia);
                              return FilterChip(
                                label: Text(
                                  t.formulario.dias_semana[dia.toString()]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.orange[700],
                                backgroundColor: Colors.grey.shade100,
                                checkmarkColor: Colors.transparent,
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    if (val)
                                      diasSemanaSelecionados.add(dia);
                                    else
                                      diasSemanaSelecionados.remove(dia);
                                    diasSemanaSelecionados.sort();
                                    _recalcularEquivalencia();
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isMix ? Colors.orange[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isMix
                        ? Colors.orange.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      t.formulario.resultado_dose, // 👇 Traduzido
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isMix
                            ? Colors.orange[800]
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      textoDetalhesDose.isEmpty
                          ? t
                                .formulario
                                .resultado_vazio // 👇 Traduzido
                          : textoDetalhesDose,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: seringaSelecionada,
                      decoration: InputDecoration(
                        labelText: t.formulario.campo_seringa, // 👇 Traduzido
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 30,
                          child: Text(t.formulario_extras.seringa_30),
                        ),
                        DropdownMenuItem(
                          value: 50,
                          child: Text(t.formulario_extras.seringa_50),
                        ),
                        DropdownMenuItem(
                          value: 100,
                          child: Text(t.formulario_extras.seringa_100),
                        ),
                        DropdownMenuItem(
                          value: 300,
                          child: Text(t.formulario_extras.seringa_3ml),
                        ),
                        DropdownMenuItem(
                          value: 500,
                          child: Text(t.formulario_extras.seringa_5ml),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          double maxMl = val / 100.0;
                          if (calcVolumeMl > maxMl) {
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
                                  'O volume calculado é de ${calcVolumeMl.toStringAsFixed(2)} mL.\n\nNão é possível selecionar uma seringa de $maxMl mL, pois o líquido irá transbordar.',
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
                            _recalcularEquivalencia();
                          }
                        }
                      },
                      validator: (val) => val == null ? 'Erro' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _abrirSeletorLocais,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t.formulario.campo_locais, // 👇 Traduzido
                          border: const OutlineInputBorder(),
                          errorText: regioesSelecionadasList.isEmpty
                              ? 'Selecione'
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              regioesSelecionadasList.isEmpty
                                  ? t.regioes.nenhum
                                  : t.regioes.selecionados(
                                      qtd: regioesSelecionadasList.length,
                                    ),
                              style: TextStyle(
                                fontSize: 16,
                                color: _isMix ? Colors.grey : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.checklist,
                              color: _isMix ? Colors.grey : Colors.orange,
                            ),
                          ],
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
                    child: InkWell(
                      onTap: () => _escolherData(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t.formulario.campo_data,
                          border: const OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _escolherHora(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t.formulario.campo_hora,
                          border: const OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.access_time, color: Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              carregando
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _guardarMedicamento,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            modoEdicao
                                ? t.formulario.btn_atualizar
                                : t.formulario.btn_guardar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: modoEdicao
                                ? Colors.orange[800]
                                : Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        if (modoEdicao) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _arquivarTratamento,
                            icon: const Icon(
                              Icons.archive,
                              color: Colors.white,
                            ),
                            label: Text(
                              t.formulario.btn_arquivar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CronogramaEcra extends StatefulWidget {
  final Map<String, dynamic> medicamento;
  const CronogramaEcra({super.key, required this.medicamento});
  @override
  State<CronogramaEcra> createState() => _CronogramaEcraState();
}

class _CronogramaEcraState extends State<CronogramaEcra> {
  final supabase = Supabase.instance.client;
  bool carregando = false;

  Widget _formatarTextoDose(String textoOriginal) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'([\d,.]+\s*UI)|(\([^)]+\))');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(textoOriginal)) {
      final matchString = match.group(0)!;
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(text: textoOriginal.substring(lastMatchEnd, match.start)),
        );
      }
      if (matchString.contains('UI')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.deepPurple[700],
            ),
          ),
        );
      } else if (matchString.startsWith('(')) {
        spans.add(
          TextSpan(
            text: matchString,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.teal[800],
            ),
          ),
        );
      }
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < textoOriginal.length) {
      spans.add(TextSpan(text: textoOriginal.substring(lastMatchEnd)));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: spans,
      ),
    );
  }

  Timer? _timerTelaLigada;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _timerTelaLigada = Timer(const Duration(minutes: 5), () {
      WakelockPlus.disable();
    });
  }

  @override
  void dispose() {
    _timerTelaLigada?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<List<dynamic>> obterCronograma() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cache_cronograma_${widget.medicamento['id']}';

    try {
      final conectividade = await Connectivity().checkConnectivity();
      bool semInternet = false;
      semInternet = (conectividade as List).contains(ConnectivityResult.none);

      if (semInternet) {
        final cache = prefs.getString(cacheKey);
        if (cache != null) return jsonDecode(cache);
        return [];
      }

      final resposta = await supabase
          .from('cronograma')
          .select()
          .eq('medicamento_id', widget.medicamento['id'])
          .timeout(const Duration(seconds: 5));
      List<dynamic> doses = List.from(resposta);

      doses.sort((a, b) {
        bool aplicadoA = a['status_aplicado'] == true;
        bool aplicadoB = b['status_aplicado'] == true;

        if (aplicadoA != aplicadoB) return aplicadoA ? 1 : -1;
        DateTime dataA = DateTime.parse(a['data_aplicacao'].toString());
        DateTime dataB = DateTime.parse(b['data_aplicacao'].toString());

        if (!aplicadoA) {
          return dataA.compareTo(dataB);
        } else {
          return dataB.compareTo(dataA);
        }
      });

      await prefs.setString(cacheKey, jsonEncode(doses));
      return doses;
    } catch (e) {
      final cache = prefs.getString(cacheKey);
      if (cache != null) return jsonDecode(cache);
      return [];
    }
  }

  List<String> _obterListaRodizio(String regiaoBase) {
    List<String> pontosFinais = [];
    final regioes = regiaoBase.split(', ');

    for (var r in regioes) {
      if (r.contains('Ventro Glúteo (IM)')) {
        pontosFinais.addAll([
          'Ventro Glúteo Direito (IM)',
          'Ventro Glúteo Esquerdo (IM)',
        ]);
      } else if (r.contains('Vasto')) {
        pontosFinais.addAll([
          'Vasto Lateral Direito (IM)',
          'Vasto Lateral Esquerdo (IM)',
        ]);
      } else if (r.contains('Deltoide (IM)')) {
        pontosFinais.addAll([
          'Deltoide Direito (IM)',
          'Deltoide Esquerdo (IM)',
        ]);
      } else if (r.contains('Glúteo Superior (IM)')) {
        pontosFinais.addAll([
          'Dorso Glúteo Direito (Sup. Ext.IM)',
          'Dorso Glúteo Esquerdo (Sup. Ext.IM)',
        ]);
      } else if (r.contains('Barriga')) {
        pontosFinais.addAll([
          'Barriga Lateral Direita (SC)',
          'Barriga Lateral Esquerda (SC)',
          'Barriga Centro-Superior (SC)',
          'Barriga Centro-Inferior (SC)',
          'Barriga Superior Direita (SC)',
          'Barriga Superior Esquerda (SC)',
          'Barriga Inferior Direita (SC)',
          'Barriga Inferior Esquerda (SC)',
        ]);
      } else if (r.contains('Flanco (SC)')) {
        pontosFinais.addAll([
          'Flanco Dir. Alto A (SC)',
          'Flanco Esq. Alto A (SC)',
          'Flanco Dir. Alto B (SC)',
          'Flanco Esq. Alto B (SC)',
          'Flanco Dir. Alto C (SC)',
          'Flanco Esq. Alto C (SC)',
          'Flanco Dir. Baixo A (SC)',
          'Flanco Esq. Baixo A (SC)',
          'Flanco Dir. Baixo B (SC)',
          'Flanco Esq. Baixo B (SC)',
          'Flanco Dir. Baixo C (SC)',
          'Flanco Esq. Baixo C (SC)',
          'Flanco Dir. Médio A (SC)',
          'Flanco Esq. Médio A (SC)',
          'Flanco Dir. Médio B (SC)',
          'Flanco Esq. Médio B (SC)',
          'Flanco Esq. Médio C (SC)',
          'Flanco Esq. Médio C (SC)',
        ]);
      } else if (r.contains('Perna Anterior (SC)')) {
        pontosFinais.addAll([
          'Coxa Anterior Direita (SC)',
          'Coxa Anterior Esquerda (SC)',
        ]);
      } else if (r.contains('Braço Tríceps (SC)')) {
        pontosFinais.addAll(['Tríceps Direito (SC)', 'Tríceps Esquerdo (SC)']);
      }
    }

    if (pontosFinais.isEmpty) return [regiaoBase];
    return pontosFinais;
  }

  Future<void> _abrirDialogoGeracao() async {
    int opcaoSelecionada = 0;
    final TextEditingController customCtrl = TextEditingController();
    final int intervaloDias =
        int.tryParse(widget.medicamento['intervalo_dias'].toString()) ?? 7;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.date_range, color: Color(0xFF1E3A8A)),
                  SizedBox(width: 8),
                  Text(
                    'Período do Cronograma',
                    style: TextStyle(fontSize: 18, color: Color(0xFF1E3A8A)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<int>(
                      title: const Text('Até acabar o frasco'),
                      value: 0,
                      groupValue: opcaoSelecionada,
                      activeColor: Colors.green,
                      onChanged: (val) => setStateDialog(() {
                        opcaoSelecionada = val!;
                        customCtrl.clear();
                      }),
                    ),
                    RadioListTile<int>(
                      title: const Text('Por Semanas'),
                      subtitle: const Text('Ex: 8 Semanas de ciclo'),
                      value: 1,
                      groupValue: opcaoSelecionada,
                      activeColor: Colors.orange,
                      onChanged: (val) => setStateDialog(() {
                        opcaoSelecionada = val!;
                        customCtrl.clear();
                      }),
                    ),
                    RadioListTile<int>(
                      title: const Text('Por Meses'),
                      subtitle: const Text('Ex: 3 Meses (90 dias)'),
                      value: 2,
                      groupValue: opcaoSelecionada,
                      activeColor: Colors.blue,
                      onChanged: (val) => setStateDialog(() {
                        opcaoSelecionada = val!;
                        customCtrl.clear();
                      }),
                    ),
                    RadioListTile<int>(
                      title: const Text('Por Qtd. de Injeções'),
                      value: 3,
                      groupValue: opcaoSelecionada,
                      activeColor: Colors.purple,
                      onChanged: (val) => setStateDialog(() {
                        opcaoSelecionada = val!;
                        customCtrl.clear();
                      }),
                    ),
                    if (opcaoSelecionada != 0)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 8,
                        ),
                        child: TextField(
                          controller: customCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: opcaoSelecionada == 1
                                ? 'Quantas semanas?'
                                : (opcaoSelecionada == 2
                                      ? 'Quantos meses?'
                                      : 'Quantas injeções?'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    int? limiteDeInjecoes;
                    if (opcaoSelecionada != 0) {
                      int valor = int.tryParse(customCtrl.text) ?? 0;
                      if (valor <= 0) return;
                      if (opcaoSelecionada == 1) {
                        int totalDias = valor * 7;
                        limiteDeInjecoes = (totalDias / intervaloDias).floor();
                      } else if (opcaoSelecionada == 2) {
                        int totalDias = valor * 30;
                        limiteDeInjecoes = (totalDias / intervaloDias).floor();
                      } else if (opcaoSelecionada == 3) {
                        limiteDeInjecoes = valor;
                      }
                      if (limiteDeInjecoes == 0) limiteDeInjecoes = 1;
                    }
                    Navigator.pop(ctx);
                    gerarDoses(limite: limiteDeInjecoes);
                  },
                  child: const Text(
                    'GERAR',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> gerarDoses({int? limite}) async {
    setState(() => carregando = true);
    try {
      String textoDoseAjustada = widget.medicamento['detalhes_dose'] ?? '';
      double doseSemanal = (widget.medicamento['dose_semanal'] as num)
          .toDouble();
      double concentracao = (widget.medicamento['concentracao_mg_ml'] as num)
          .toDouble();

      String tipoFreq = widget.medicamento['tipo_frequencia'] ?? 'intervalo';
      List<int> diasSemana = [];
      if (widget.medicamento['dias_semana'] != null &&
          widget.medicamento['dias_semana'].toString().isNotEmpty) {
        diasSemana = widget.medicamento['dias_semana']
            .toString()
            .split(',')
            .map((e) => int.parse(e))
            .toList();
      }

      int intervalo = widget.medicamento['intervalo_dias'] ?? 1;

      double fator = 0;
      if (tipoFreq == 'dias_semana' && diasSemana.isNotEmpty) {
        fator = doseSemanal / diasSemana.length;
      } else {
        fator = (intervalo == 3)
            ? (doseSemanal / 2)
            : ((doseSemanal / 7) * intervalo);
      }

      double doseMg = fator;
      double volumeMl = doseMg / concentracao;
      double doseUi = volumeMl * 100;

      if (textoDoseAjustada.isEmpty) {
        textoDoseAjustada =
            '${doseMg.toStringAsFixed(2).replaceAll('.', ',')} mg / ${doseUi.toStringAsFixed(2).replaceAll('.', ',')} UI';
      }

      int totalDoses = 20;
      if (!widget.medicamento['nome'].toString().startsWith('Mix')) {
        double volTotal =
            (widget.medicamento['volume_frasco_ml'] as num).toDouble() *
            (widget.medicamento['quantidade_ampolas'] as num).toInt();
        totalDoses = (volTotal / volumeMl).floor();
        if (totalDoses < 1) totalDoses = 1;
      }

      String regiaoBase = widget.medicamento['regiao_rodizio'] ?? 'Barriga';
      List<String> locaisRodizio = _obterListaRodizio(regiaoBase);
      List<dynamic> loteAplicacoes = [];

      int indiceInicial = 0;
      Set<String> locaisOcupadosGlobais = {};

      try {
        final usuarioId = supabase.auth.currentUser!.id;
        final historico = await supabase
            .from('cronograma')
            .select('data_aplicacao, local_aplicacao')
            .eq('user_id', usuarioId)
            .order('data_aplicacao', ascending: false);

        for (var item in historico) {
          String data = item['data_aplicacao'].toString();
          String local = item['local_aplicacao'].toString();
          locaisOcupadosGlobais.add('$data|$local');
        }

        for (var item in historico) {
          String localSalvo = item['local_aplicacao'].toString();
          int indexEncontrado = locaisRodizio.indexOf(localSalvo);
          if (indexEncontrado != -1) {
            indiceInicial = (indexEncontrado + 1) % locaisRodizio.length;
            break;
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar histórico de colisões: $e');
      }

      DateTime dataBase = DateTime.parse(
        widget.medicamento['data_inicio'].toString(),
      );

      DateTime proximoDiaValido(DateTime atual, List<int> diasValidos) {
        DateTime prox = atual.add(const Duration(days: 1));
        while (!diasValidos.contains(prox.weekday)) {
          prox = prox.add(const Duration(days: 1));
        }
        return prox;
      }

      try {
        final ultimoDesteMed = await supabase
            .from('cronograma')
            .select('data_aplicacao')
            .eq('medicamento_id', widget.medicamento['id'])
            .eq('status_aplicado', true)
            .order('data_aplicacao', ascending: false)
            .limit(1);

        if (ultimoDesteMed.isNotEmpty) {
          DateTime ultimaData = DateTime.parse(
            ultimoDesteMed.first['data_aplicacao'].toString(),
          );
          if (tipoFreq == 'dias_semana' && diasSemana.isNotEmpty) {
            dataBase = proximoDiaValido(ultimaData, diasSemana);
          } else {
            dataBase = ultimaData.add(Duration(days: intervalo));
          }
        } else {
          if (tipoFreq == 'dias_semana' && diasSemana.isNotEmpty) {
            if (!diasSemana.contains(dataBase.weekday)) {
              dataBase = proximoDiaValido(
                dataBase.subtract(const Duration(days: 1)),
                diasSemana,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar continuidade: $e');
      }

      String horaStr = widget.medicamento['hora_aplicacao'] ?? '08:00';
      int horaDisp = int.parse(horaStr.split(':')[0]);
      int minDisp = int.parse(horaStr.split(':')[1]);

      for (int i = 0; i < totalDoses; i++) {
        if (limite != null && i >= limite) break;

        String dataIso = dataBase.toIso8601String().split('T')[0];
        String localAtual =
            locaisRodizio[(indiceInicial + i) % locaisRodizio.length];

        int tentativas = 0;
        while (locaisOcupadosGlobais.contains('$dataIso|$localAtual') &&
            tentativas < locaisRodizio.length) {
          indiceInicial++;
          localAtual =
              locaisRodizio[(indiceInicial + i) % locaisRodizio.length];
          tentativas++;
        }

        locaisOcupadosGlobais.add('$dataIso|$localAtual');

        DateTime dataHoraExata = DateTime(
          dataBase.year,
          dataBase.month,
          dataBase.day,
          horaDisp,
          minDisp,
        );

        loteAplicacoes.add({
          'medicamento_id': widget.medicamento['id'],
          'data_aplicacao': dataBase.toIso8601String().split('T')[0],
          'dose_ajustada': textoDoseAjustada,
          'local_aplicacao': localAtual,
          'status_aplicado': false,
        });

        if (tipoFreq == 'dias_semana' && diasSemana.isNotEmpty) {
          dataBase = proximoDiaValido(dataBase, diasSemana);
        } else {
          dataBase = dataBase.add(Duration(days: intervalo));
        }
      }

      final usuarioId = supabase.auth.currentUser!.id;
      for (var aplicacao in loteAplicacoes) {
        aplicacao['user_id'] = usuarioId;
      }

      await supabase.from('cronograma').insert(loteAplicacoes);
      await atualizarAlarmesNativos(); // 👈 Sincroniza apenas as próximas 60 de forma segura

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cronograma gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => carregando = false);
  }

  Future<void> alternarStatusDose(
    Map<String, dynamic> doseClicada,
    List<dynamic> todasDoses,
  ) async {
    bool statusAtual = doseClicada['status_aplicado'] == true;

    if (!statusAtual) {
      final primeiraPendente = todasDoses.firstWhere(
        (d) => d['status_aplicado'] == false,
        orElse: () => null,
      );

      if (primeiraPendente != null &&
          primeiraPendente['id'] != doseClicada['id']) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ação Bloqueada',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              content: const Text(
                'Não é possível pular injeções.\n\nPor favor, conclua a próxima dose pendente (a mais antiga no topo da lista) antes de avançar para datas futuras.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
        return;
      }

      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Confirmar Aplicação',
            style: TextStyle(color: Colors.green),
          ),
          content: Text(
            'Confirma que aplicou a dose de hoje neste exato local?\n\n📍 ${doseClicada['local_aplicacao']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    } else {
      bool? desfazer = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Desfazer Aplicação',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Deseja desmarcar esta aplicação e devolvê-la para a lista de pendentes?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Desfazer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (desfazer != true) return;
    }

    try {
      await supabase
          .from('cronograma')
          .update({'status_aplicado': !statusAtual})
          .eq('id', doseClicada['id']);
      setState(() {});
      atualizarAlarmesNativos(); // 👈 Garante que a fila ande e novos alarmes sejam agendados
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _limparCronograma() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Limpar Cronograma',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Deseja apagar todas as datas agendadas para este medicamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    setState(() => carregando = true);

    try {
      await supabase.from('cronograma').delete().match({
        'medicamento_id': widget.medicamento['id'],
        'status_aplicado': false,
      });
      await atualizarAlarmesNativos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Doses futuras apagadas! O histórico foi preservado.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: obterCronograma(),
      builder: (context, snapshot) {
        final doses = snapshot.data ?? [];
        final temPendentes = doses.any((d) => d['status_aplicado'] == false);
        final estaCarregando =
            snapshot.connectionState == ConnectionState.waiting || carregando;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t.cronograma.titulo(nome: widget.medicamento['nome'].toString()),
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Limpar Cronograma',
                onPressed: _limparCronograma,
              ),
            ],
          ),
          floatingActionButton: (estaCarregando || temPendentes)
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: Colors.green[700],
                  icon: const Icon(Icons.add_alarm, color: Colors.white),
                  label: Text(
                    t.cronograma.btn_gerar_novo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _abrirDialogoGeracao,
                ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[100],
                  child: Text(
                    t.complementos.seringa_intervalo(
                      seringa: widget.medicamento['seringa_ui'],
                      dias: widget.medicamento['intervalo_dias'],
                    ), // 👇 Traduzido
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                Expanded(
                  child: estaCarregando
                      ? const Center(child: CircularProgressIndicator())
                      : doses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t.cronograma.nenhum_gerado,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: _abrirDialogoGeracao,
                                    icon: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      t.cronograma.btn_gerar,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: doses.length,
                          itemBuilder: (context, index) {
                            final dose = doses[index];
                            final partesData = dose['data_aplicacao']
                                .toString()
                                .split('-');
                            final dataFormatada =
                                '${partesData[2]}/${partesData[1]}/${partesData[0]}';
                            final bool isUltimasDuas =
                                index >= doses.length - 2;
                            final bool isPendenteEFinal =
                                isUltimasDuas && !dose['status_aplicado'];

                            Color? corFundo = dose['status_aplicado']
                                ? Colors.green[50]
                                : (isPendenteEFinal
                                      ? Colors.red[100]
                                      : Colors.white);
                            Color corTexto = isPendenteEFinal
                                ? Colors.red[900]!
                                : Colors.black;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              color: corFundo,
                              shape: isPendenteEFinal
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    )
                                  : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                              child: ListTile(
                                onTap: () => alternarStatusDose(dose, doses),
                                leading: Icon(
                                  dose['status_aplicado']
                                      ? Icons.check_circle
                                      : (isPendenteEFinal
                                            ? Icons.warning_amber_rounded
                                            : Icons.circle_outlined),
                                  color: dose['status_aplicado']
                                      ? Colors.green
                                      : (isPendenteEFinal
                                            ? Colors.red
                                            : Colors.grey),
                                  size: 32,
                                ),
                                title: Text(
                                  dataFormatada,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: dose['status_aplicado']
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: dose['status_aplicado']
                                        ? Colors.grey
                                        : corTexto,
                                  ),
                                ),
                                subtitle: dose['status_aplicado']
                                    ? Text(
                                        '${dose['dose_ajustada']}\nLocal: ${dose['local_aplicacao']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _formatarTextoDose(
                                            '${dose['dose_ajustada']}',
                                          ),
                                          Text(
                                            'Local: ${dose['local_aplicacao']}',
                                            style: TextStyle(color: corTexto),
                                          ),
                                        ],
                                      ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VisualizadorImagemEcra extends StatelessWidget {
  final String caminhoImagem;
  final String titulo;
  const VisualizadorImagemEcra({
    super.key,
    required this.caminhoImagem,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.asset(
            caminhoImagem,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  t.visualizador.erro_imagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GuiaFaqEcra extends StatefulWidget {
  final bool obrigatorio;
  const GuiaFaqEcra({super.key, this.obrigatorio = false});
  @override
  State<GuiaFaqEcra> createState() => _GuiaFaqEcraState();
}

class _GuiaFaqEcraState extends State<GuiaFaqEcra> {
  bool _aceitouTermos = false;
  bool _chegouAoFim = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_verificarScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent <= 0) {
        setState(() => _chegouAoFim = true);
      }
    });
  }

  void _verificarScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_chegouAoFim) {
      setState(() => _chegouAoFim = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildExpandableCard({
    required String titulo,
    required Color cor,
    required IconData icone,
    required Widget conteudo,
    Color? corFundo,
  }) {
    if (widget.obrigatorio) {
      return Card(
        color: corFundo ?? Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cor.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icone, color: cor, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              conteudo,
            ],
          ),
        ),
      );
    }
    return Card(
      color: corFundo ?? Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cor.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: cor,
          collapsedIconColor: cor,
          leading: Icon(icone, color: cor, size: 28),
          title: Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 12,
              ),
              child: conteudo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required BuildContext context,
    required String titulo,
    required IconData icone,
    required String caminhoImagem,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icone, color: const Color(0xFF1E3A8A)),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.zoom_in, color: Colors.orange),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisualizadorImagemEcra(
              caminhoImagem: caminhoImagem,
              titulo: titulo,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDicionarioItem(String termo, String definicao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '• $termo: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: definicao),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.obrigatorio,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.obrigatorio,
          title: Text(
            t.guia.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          actions: [
            if (widget.obrigatorio)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: t.guia.tooltip_sair,
                onPressed: () => sairDaConta(context),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.termos_titulo,
                      cor: Colors.orange[900]!,
                      icone: Icons.gavel,
                      conteudo: Text(
                        t.guia_conteudo.termos_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.aviso_titulo,
                      cor: Colors.red[900]!,
                      icone: Icons.warning_amber_rounded,
                      conteudo: Text(
                        t.guia_conteudo.aviso_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.higiene_titulo,
                      cor: Colors.blueGrey[700]!,
                      icone: Icons.clean_hands,
                      conteudo: Text(
                        t.guia_conteudo.higiene_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.como_usar_titulo,
                      cor: const Color(0xFF1E3A8A),
                      icone: Icons.help_center,
                      conteudo: Text(
                        t.guia_conteudo.como_usar_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.cerebro_titulo,
                      cor: Colors.teal[800]!,
                      icone: Icons.biotech,
                      conteudo: Text(
                        t.guia_conteudo.cerebro_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.notificacoes_titulo,
                      cor: Colors.indigo,
                      icone: Icons.notifications_active,
                      conteudo: Text(
                        t.guia_conteudo.notificacoes_texto,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.seringas_titulo,
                      cor: Colors.orange,
                      icone: Icons.vaccines,
                      corFundo: Colors.orange[50],
                      conteudo: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.guia_conteudo.seringas_subtitulo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.seringas_btn,
                            icone: Icons.science_outlined,
                            caminhoImagem: 'assets/regiao/agulhas_seringas.png',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.guia_conteudo.seringas_texto1,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            t.guia_conteudo.seringas_texto2,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.guia_conteudo.seringas_texto3,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            t.guia_conteudo.seringas_texto4,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.mapas_titulo,
                      cor: const Color(0xFF1E3A8A),
                      icone: Icons.map,
                      corFundo: Colors.blue[50],
                      conteudo: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t.guia_conteudo.mapas_alerta_titulo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.guia_conteudo.mapas_alerta_texto,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.guia_conteudo.mapas_subtitulo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.mapas_btn1,
                            icone: Icons.accessibility_new,
                            caminhoImagem: 'assets/regiao/barriga.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.mapas_btn2,
                            icone: Icons.airline_seat_flat_angled,
                            caminhoImagem: 'assets/regiao/flancos.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.mapas_btn3,
                            icone: Icons.directions_run,
                            caminhoImagem: 'assets/regiao/gluteos.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.mapas_btn4,
                            icone: Icons.boy,
                            caminhoImagem:
                                'assets/regiao/coxa_vastolateral.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: t.guia_conteudo.mapas_btn5,
                            icone: Icons.shutter_speed_sharp,
                            caminhoImagem: 'assets/regiao/deltoide.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      titulo: t.guia_conteudo.dicionario_titulo,
                      cor: Colors.purple,
                      icone: Icons.menu_book,
                      corFundo: Colors.purple[50],
                      conteudo: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.guia_conteudo.dicionario_subtitulo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.guia_conteudo.dic_cat1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDicionarioItem(
                            'Shape',
                            'O corpo, a sua condição física atual.',
                          ),
                          _buildDicionarioItem(
                            'BF (Body Fat)',
                            'Percentual de gordura corporal. Quanto menor, mais "seco" e definido fica.',
                          ),
                          _buildDicionarioItem(
                            'Pump',
                            'O inchaço e a sensação de músculo cheio de sangue logo após o exercício.',
                          ),
                          _buildDicionarioItem(
                            'Fibrado / Seco',
                            'Corpo com percentual de gordura muito baixo, mostrando muita definição muscular.',
                          ),
                          _buildDicionarioItem(
                            'Retido',
                            'Corpo inchado por excesso de líquidos, escondendo a definição dos músculos.',
                          ),
                          _buildDicionarioItem(
                            'Mamute / Monstro',
                            'Pessoa extremamente musculosa e forte.',
                          ),
                          _buildDicionarioItem(
                            'Fordo',
                            'Forte e Gordo. Tem muito volume muscular e força bruta, mas o BF é alto e não tem definição.',
                          ),
                          _buildDicionarioItem(
                            'Frango',
                            'Quem foge do treino, pega pouco peso, foca só nos braços ou não tem dedicação.',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.guia_conteudo.dic_cat2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDicionarioItem(
                            'Treinar fofo',
                            'Fazer o exercício sem esforço real, parando muito antes de cansar.',
                          ),
                          _buildDicionarioItem(
                            'Ir até a falha',
                            'Fazer o exercício até o músculo travar e não aguentar mais nenhuma repetição.',
                          ),
                          _buildDicionarioItem(
                            'Bater PR',
                            'Bater o seu recorde pessoal (Personal Record) de carga num exercício.',
                          ),
                          _buildDicionarioItem(
                            'Cardio',
                            'Exercícios aeróbicos (esteira, bicicleta, escada).',
                          ),
                          _buildDicionarioItem(
                            'AEJ',
                            'Aeróbico em Jejum (fazer o cardio logo após acordar, antes da primeira refeição).',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.guia_conteudo.dic_cat3,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDicionarioItem(
                            'Bater os macros',
                            'Atingir a meta exata de proteínas, carboidratos e gorduras do dia.',
                          ),
                          _buildDicionarioItem(
                            'Bulking (ou Off)',
                            'Fase de comer bastante (superávit calórico) para ganhar volume e massa muscular.',
                          ),
                          _buildDicionarioItem(
                            'Cutting',
                            'Fase de comer menos (déficit calórico) para perder gordura e "secar".',
                          ),
                          _buildDicionarioItem(
                            'Ref livre',
                            'Uma refeição fora da dieta (antigo "dia do lixo", mas restrito a apenas uma refeição isolada).',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.guia_conteudo.dic_cat4,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDicionarioItem(
                            'Bateu',
                            'Quando o hormônio ou pré-treino atinge o pico no sangue e os efeitos começam a ser sentidos de forma clara.',
                          ),
                          _buildDicionarioItem(
                            'Inflamou / Empedrou',
                            'Quando o óleo da injeção não é absorvido rapidamente, criando um nódulo rígido e dolorido sob a pele.',
                          ),
                          _buildDicionarioItem(
                            'Blast',
                            'Fase de ataque. Período a usar doses altas e combinadas de esteroides para ganho máximo ou perda extrema num curto espaço de tempo.',
                          ),
                          _buildDicionarioItem(
                            'Cruise',
                            'Fase de cruzeiro (manutenção). Uso de doses baixas para manter os ganhos e deixar os exames de saúde normalizarem.',
                          ),
                          _buildDicionarioItem(
                            'Empilhar (Stack)',
                            'Misturar dois ou mais compostos diferentes na mesma fase (ex: Testosterona + Masteron).',
                          ),
                          _buildDicionarioItem(
                            'Suco / Danone',
                            'Gírias gerais e camufladas para esteroides anabolizantes.',
                          ),
                          _buildDicionarioItem(
                            'Trembo',
                            'Trembolona, um dos anabolizantes mais fortes, perigosos e com severos efectos psicológicos.',
                          ),
                          _buildDicionarioItem(
                            'Fake Natty',
                            'O "falso natural", aquele que usa hormônios mas afirma na internet que conquistou o corpo só com dieta e treino.',
                          ),
                          _buildDicionarioItem(
                            'Bolar / Bolado',
                            'O ato de usar anabolizantes, ou a pessoa que está fisicamente sob o efeito evidente deles.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.obrigatorio)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_chegouAoFim)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              t.guia.aviso_scroll,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _aceitouTermos,
                                activeColor: Colors.green[700],
                                onChanged: _chegouAoFim
                                    ? (val) {
                                        setState(
                                          () => _aceitouTermos = val ?? false,
                                        );
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t.guia.texto_aceite,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _chegouAoFim
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _aceitouTermos
                                ? () async {
                                    final usuarioId = Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser!
                                        .id;
                                    try {
                                      await Supabase.instance.client
                                          .from('aceites_termos')
                                          .insert({'user_id': usuarioId});
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(t.guia.msg_sucesso),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${t.guia.msg_erro}$e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              t.guia.btn_aceitar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.length > newValue.text.length) return newValue;
    final textoLimpo = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String novoTexto = '';
    for (int i = 0; i < textoLimpo.length; i++) {
      if (i == 2 || i == 4) novoTexto += '/';
      novoTexto += textoLimpo[i];
    }
    if (novoTexto.length > 10) novoTexto = novoTexto.substring(0, 10);
    return TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: novoTexto.length),
    );
  }
}

class PerfilEcra extends StatefulWidget {
  final bool obrigatorio;
  const PerfilEcra({super.key, this.obrigatorio = false});
  @override
  State<PerfilEcra> createState() => _PerfilEcraState();
}

class _PerfilEcraState extends State<PerfilEcra> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool carregando = true;

  final nomeCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  String? generoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    dataCtrl.dispose();
    pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final res = await supabase
          .from('perfis')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (res != null) {
        setState(() {
          nomeCtrl.text = res['nome'] ?? '';
          generoSelecionado = res['genero'];

          if (res['peso'] != null) {
            pesoCtrl.text = res['peso'].toString();
          }

          if (res['data_nascimento'] != null) {
            final partes = res['data_nascimento'].toString().split('-');
            if (partes.length == 3) {
              dataCtrl.text = '${partes[2]}/${partes[1]}/${partes[0]}';
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
    setState(() => carregando = false);
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    if (generoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o sexo biológico.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (dataCtrl.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma data de nascimento válida (DD/MM/AAAA).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => carregando = true);
    final userId = supabase.auth.currentUser!.id;

    try {
      final partes = dataCtrl.text.split('/');
      final dataFormatadaBanco = '${partes[2]}-${partes[1]}-${partes[0]}';

      double? pesoNum;
      if (pesoCtrl.text.isNotEmpty) {
        final pesoString = pesoCtrl.text.replaceAll(',', '.');
        pesoNum = double.tryParse(pesoString);
      }

      await supabase.from('perfis').upsert({
        'id': userId,
        'nome': nomeCtrl.text.trim(),
        'genero': generoSelecionado,
        'data_nascimento': dataFormatadaBanco,
        'peso': pesoNum,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => carregando = false);
  }

  Future<void> _escolherData() async {
    DateTime dataInicial = DateTime(1990);
    if (dataCtrl.text.length == 10) {
      try {
        final p = dataCtrl.text.split('/');
        dataInicial = DateTime(
          int.parse(p[2]),
          int.parse(p[1]),
          int.parse(p[0]),
        );
      } catch (_) {}
    }
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
        ),
        child: child!,
      ),
    );
    if (selecionada != null) {
      setState(() {
        dataCtrl.text =
            '${selecionada.day.toString().padLeft(2, '0')}/${selecionada.month.toString().padLeft(2, '0')}/${selecionada.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.obrigatorio,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.obrigatorio,
          title: Text(
            t.perfil.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          actions: [
            if (widget.obrigatorio)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair do App',
                onPressed: () => sairDaConta(context),
              ),
          ],
        ),
        body: SafeArea(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Color(0xFF1E3A8A),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.perfil.dados_biologicos,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.perfil.descricao_biologicos,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nomeCtrl,
                          decoration: InputDecoration(
                            labelText: t.perfil.nome,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: pesoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: t.perfil.peso,
                            hintText: 'Ex: 107.5',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.scale),
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: generoSelecionado,
                          decoration: InputDecoration(
                            labelText: t.perfil.sexo,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.wc),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Masculino',
                              child: Text(t.complementos.masculino),
                            ),
                            DropdownMenuItem(
                              value: 'Feminino',
                              child: Text(t.complementos.feminino),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => generoSelecionado = val),
                          validator: (val) =>
                              val == null ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<AppLocale?>(
                          initialValue: LocaleSettings.currentLocale,
                          decoration: InputDecoration(
                            labelText: t.perfil.idioma,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.language),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppLocale.pt,
                              child: Text('Português'),
                            ),
                            DropdownMenuItem(
                              value: AppLocale.en,
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: AppLocale.es,
                              child: Text('Español'),
                            ),
                          ],
                          onChanged: (AppLocale? novoIdioma) async {
                            if (novoIdioma != null) {
                              LocaleSettings.setLocale(novoIdioma);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'app_locale',
                                novoIdioma.languageTag,
                              );
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: dataCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DataInputFormatter()],
                          decoration: InputDecoration(
                            labelText: t.perfil.data_nascimento,
                            hintText: 'Ex: 15/08/1985',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.cake),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF1E3A8A),
                              ),
                              tooltip: 'Escolher no Calendário',
                              onPressed: _escolherData,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Obrigatório';
                            }
                            if (val.length != 10) return 'Data incompleta';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _salvarPerfil,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            t.perfil.btn_salvar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class BiometriaEcra extends StatefulWidget {
  const BiometriaEcra({super.key});

  @override
  State<BiometriaEcra> createState() => _BiometriaEcraState();
}

class _BiometriaEcraState extends State<BiometriaEcra> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _autenticando = false;
  String _mensagemErro = '';

  @override
  void initState() {
    super.initState();
    _verificarEAutenticar();
  }

  Future<void> _verificarEAutenticar() async {
    setState(() {
      _autenticando = true;
      _mensagemErro = '';
    });

    try {
      final List<BiometricType> biometrias = await auth
          .getAvailableBiometrics();

      if (biometrias.isEmpty) {
        _irParaDashboard();
        return;
      }

      final bool autenticado = await auth.authenticate(
        localizedReason: t.biometria.motivo,
      );

      if (autenticado) {
        _irParaDashboard();
      } else {
        setState(() {
          _autenticando = false;
          _mensagemErro = t.biometria.erro_cancelado;
        });
      }
    } catch (e) {
      setState(() {
        _autenticando = false;
        _mensagemErro = t.biometria.erro_sensor;
      });
    }
  }

  void _irParaDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardEcra()),
    );
  }

  Future<void> _usarSenhaDoApp() async {
    await sairDaConta(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                t.biometria.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.biometria.subtitulo,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              if (_autenticando)
                const CircularProgressIndicator(color: Colors.white)
              else ...[
                if (_mensagemErro.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _mensagemErro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ElevatedButton.icon(
                  onPressed: _verificarEAutenticar,
                  icon: const Icon(Icons.fingerprint, color: Color(0xFF1E3A8A)),
                  label: Text(
                    t.biometria.btn_biometria,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _usarSenhaDoApp,
                  icon: const Icon(Icons.password, color: Colors.white),
                  label: Text(
                    t.biometria.btn_senha,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ], // <-- Colchetes fechados corretamente!
            ],
          ),
        ),
      ),
    );
  }
}
