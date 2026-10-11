import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  // Agora extrai o momento exato (Data + Hora) do objeto dataAgendada
  tz.TZDateTime dataHoraDisparo = tz.TZDateTime.from(dataAgendada, tz.local);

  final agora = tz.TZDateTime.now(tz.local);

  if (dataHoraDisparo.isBefore(agora)) {
    if (dataAgendada.year == agora.year &&
        dataAgendada.month == agora.month &&
        dataAgendada.day == agora.day) {
      dataHoraDisparo = agora.add(const Duration(minutes: 1));
    } else {
      // Se for de dias anteriores (passado), ignora o alarme
      return;
    }
  }

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_injetaveis',
    'Lembretes de Injeção',
    channelDescription: 'Canal para avisar sobre os dias de aplicação.',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon', // ÍCONE CORRIGIDO
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

void main() async {
  // Garante que a ligação com o motor nativo está pronta
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();

    // Bypass dinâmico do Fuso Horário
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

    // Inicializa o Supabase (Se falhar aqui por falta de internet, o catch apanha!)
    await Supabase.initialize(
      url: 'https://fdwrcrkjudadnwcqheoq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkd3JjcmtqdWRhZG53Y3FoZW9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2OTUyODUsImV4cCI6MjEwNjI3MTI4NX0.0nzSgxmFp3Tc7PGcMKyBP3cTUrzXlR9mlj3NcVkQFUE',
    );

    // Se tudo correr bem, arranca a aplicação normal
    runApp(const InjetaveisApp());
  } catch (e, stackTrace) {
    debugPrint('Erro fatal na inicialização: $e\n$stackTrace');

    // Impede a tela branca desenhando uma tela de erro de emergência
    runApp(
      MaterialApp(
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
                  const Text(
                    'Falha ao iniciar o aplicativo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verifique a sua ligação à internet e tente novamente. O aplicativo requer internet para sincronizar com o servidor seguro.',
                    textAlign: TextAlign.center,
                  ),
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
        if (session != null) return const DashboardEcra();
        return const LoginEcra();
      },
    );
  }
}

// ==========================================================
// ECRÃ DE LOGIN (COM BRANDING CODEVIBE STUDIO NO RODAPÉ)
// ==========================================================
// ==========================================================
// ECRÃ DE LOGIN (COM LINKS CODEVIBE ATIVOS)
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

  // NOVA FUNÇÃO: Traduz os erros técnicos do Supabase para português amigável
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

  // NOVA FUNÇÃO: Cria um alerta visual moderno e amigável
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

  // MOTOR DE REDIRECIONAMENTO DE LINKS
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
                      const Text(
                        'Controle de Injetáveis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Palavra-passe',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
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
                              child: const Text(
                                'ENTRAR',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                              child: const Text('CRIAR NOVA CONTA'),
                            ),

                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: recuperarSenha,
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
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

              // LINKS CLICÁVEIS (Envolvidos em InkWell)
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
                '© 2025 CodeVibe Studio. Todos os direitos reservados.',
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

  // ==========================================
  // VARIÁVEIS DO CÉREBRO DE EXAMES
  // ==========================================
  DateTime? proximaDataExame;
  List<String> listaExamesSugeridos = [];
  int diasParaExame = 999;
  bool exigeExames = false;

  @override
  void initState() {
    super.initState();
    _pedirPermissaoNotificacoes();
    _carregarResumo();
    _calcularExames(); // Chama a IA de Exames

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarTermos();
    });
  }

  Future<void> _verificarTermos() async {
    final usuarioId = supabase.auth.currentUser?.id;
    if (usuarioId == null) return;
    try {
      final resposta = await supabase
          .from('aceites_termos')
          .select()
          .eq('user_id', usuarioId);
      if (resposta.isEmpty) {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GuiaFaqEcra(obrigatorio: true),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar termos: $e');
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

  // ==========================================
  // O CÉREBRO ANALÍTICO (MOTOR CLÍNICO)
  // ==========================================
  Future<void> _calcularExames() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Busca os dados demográficos (Idade e Sexo)
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('id', userId)
          .maybeSingle();
      String genero = perfil != null && perfil['genero'] != null
          ? perfil['genero']
          : 'Masculino';
      int idade = 30; // Idade padrão segura
      if (perfil != null && perfil['data_nascimento'] != null) {
        DateTime nascimento = DateTime.parse(perfil['data_nascimento']);
        idade = DateTime.now().year - nascimento.year;
      }

      // 2. Busca os tratamentos ativos
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

        // Pega a data do medicamento que começou MAIS TARDE (para o período de adaptação bater certo)
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
        setState(
          () => exigeExames = false,
        ); // Peptídeos leves e vitaminas não ativam este alerta agressivo
        return;
      }

      // 3. Monta o Painel de Sangue Dinâmico
      Set<String> exames = {
        'Hemograma Completo',
        'Perfil Lipídico Completo (HDL, LDL, Triglicerídeos)',
        'Função Hepática (TGO, TGP, Gama-GT)',
      };

      if (isHormonal) {
        exames.addAll(['Testosterona Total e Livre', 'Estradiol (E2)', 'SHBG']);
        if (genero == 'Masculino' && idade >= 40) {
          exames.add('PSA Total e Livre (Próstata)');
        }
      }

      if (isMetabolico) {
        exames.addAll([
          'Glicemia em Jejum',
          'Insulina Basal',
          'Hemoglobina Glicada (HbA1c)',
        ]);
      }

      // 4. Calcula o "Meio Termo" das datas
      final historico = await supabase
          .from('historico_exames')
          .select()
          .eq('user_id', userId)
          .order('data_exame', ascending: false)
          .limit(1);

      DateTime dataAlvo;
      if (historico.isEmpty) {
        // Exame de Calibração (Pico de Empilhamento): 45 dias após começar o tratamento mais novo
        dataAlvo = inicioMaisRecente.add(const Duration(days: 45));
      } else {
        // Exame de Manutenção: 120 dias após o último exame
        DateTime ultimo = DateTime.parse(
          historico.first['data_exame'].toString(),
        );
        dataAlvo = ultimo.add(const Duration(days: 120));
      }

      // Corrige para não pedir exames no passado caso tenha ignorado
      if (dataAlvo.isBefore(DateTime.now())) {
        dataAlvo = DateTime.now();
      }

      setState(() {
        exigeExames = true;
        proximaDataExame = dataAlvo;
        listaExamesSugeridos = exames.toList();

        // Zera as horas para cálculo puro de dias
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

      Navigator.pop(context); // Fecha o painel
      _calcularExames(); // Recalcula a nova data (+120 dias)

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

  void _abrirPainelExames() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.biotech, color: Colors.indigo, size: 32),
                SizedBox(width: 8),
                Text(
                  'Sugestão de Laboratório',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Abaixo está a lista gerada de forma personalizada pelo algoritmo, baseada na sua idade, sexo e tratamentos ativos. Leve-a ao seu médico.',
              style: TextStyle(color: Colors.black87),
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
                onPressed: _registarExameFeito,
                icon: const Icon(Icons.vaccines, color: Colors.white),
                label: const Text(
                  'JÁ COLETEI O SANGUE (REGISTRAR)',
                  style: TextStyle(
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
  }

  Future<void> _carregarResumo() async {
    setState(() => carregando = true);
    try {
      final respProxima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', false)
          .order('data_aplicacao', ascending: true);
      final respUltima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', true)
          .order('data_aplicacao', ascending: false);

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

      if (mounted) {
        setState(() {
          proximasDoses = proximasFiltradas;
          ultimasDoses = ultimasFiltradas;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
    setState(() => carregando = false);
  }

  String _formatarData(String dataIso) {
    final partes = dataIso.split('-');
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Tratamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
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
            onPressed: () async => await supabase.auth.signOut(),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Resumo Clínico',
                    style: TextStyle(
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
                          // ==========================================================
                          // O NOVO CARD INTELIGENTE DE EXAMES
                          // ==========================================================
                          if (exigeExames && proximaDataExame != null)
                            Card(
                              color: diasParaExame <= 0
                                  ? Colors.red[50]
                                  : (diasParaExame <= 15
                                        ? Colors.orange[50]
                                        : Colors.teal[50]),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: diasParaExame <= 0
                                      ? Colors.red
                                      : (diasParaExame <= 15
                                            ? Colors.orange
                                            : Colors.teal),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.biotech,
                                          color: diasParaExame <= 0
                                              ? Colors.red[800]
                                              : (diasParaExame <= 15
                                                    ? Colors.orange[800]
                                                    : Colors.teal[800]),
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            // 👇 ALTERADO PARA "Check-up de Biomarcadores" 👇
                                            diasParaExame <= 0
                                                ? 'Exames Atrasados'
                                                : (diasParaExame <= 15
                                                      ? 'Exames Próximos'
                                                      : 'Check-up de Biomarcadores'),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: diasParaExame <= 0
                                                  ? Colors.red[800]
                                                  : (diasParaExame <= 15
                                                        ? Colors.orange[800]
                                                        : Colors.teal[800]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      // 👇 ALTERADO "controlo" para "controle" e "recolha" para "coleta" 👇
                                      diasParaExame <= 0
                                          ? 'A sua janela ideal de exames de controle já começou! Veja o que solicitar ao seu médico.'
                                          : 'Próxima coleta sugerida em $diasParaExame dias (${proximaDataExame!.day.toString().padLeft(2, '0')}/${proximaDataExame!.month.toString().padLeft(2, '0')}).',
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
                                          foregroundColor: diasParaExame <= 0
                                              ? Colors.red[800]
                                              : Colors.teal[800],
                                          side: BorderSide(
                                            color: diasParaExame <= 0
                                                ? Colors.red[800]!
                                                : Colors.teal[800]!,
                                          ),
                                        ),
                                        child: const Text(
                                          'VER PAINEL SUGERIDO',
                                          style: TextStyle(
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
                          // ==========================================================

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
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.notification_important,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Próxima Aplicação',
                                        style: TextStyle(
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
                                                  : 'Medicamento indisponível',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            Text(
                                              'Data: ${_formatarData(dose['data_aplicacao'])}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Local: ${dose['local_aplicacao']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Dose: ${dose['dose_ajustada']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
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
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Última Aplicação',
                                        style: TextStyle(
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
                                              'Data: ${_formatarData(dose['data_aplicacao'])}',
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
                        _carregarResumo();
                        _calcularExames(); // Atualiza os exames se ele adicionar/remover um medicamento
                      });
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                    label: const Text(
                      'GERIR MEDICAMENTOS',
                      style: TextStyle(
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
    );
  }
}

// ==========================================================
// BANCO DE MEDICAMENTOS
// ==========================================================
class SetupEcra extends StatefulWidget {
  const SetupEcra({super.key});
  @override
  State<SetupEcra> createState() => _SetupEcraState();
}

class _SetupEcraState extends State<SetupEcra> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> obterMedicamentos() async {
    final List<dynamic> res = await supabase
        .from('medicamentos')
        .select()
        .order('criado_em');
    // Filtra a lista para esconder os medicamentos que fazem parte de um Mix
    return res
        .where((m) => !m['nome'].toString().startsWith('[Oculto]'))
        .toList();
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
      // 1. Apaga primeiro as aplicações agendadas para evitar erros de chave estrangeira
      await supabase.from('cronograma').delete().eq('medicamento_id', id);

      // 2. Apaga o medicamento
      await supabase.from('medicamentos').delete().eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Recarrega a lista na tela
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
        title: const Text(
          'Banco de Medicamentos',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        label: const Text(
          'NOVO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          if (medicamentos.isEmpty) {
            return const Center(child: Text('Nenhum medicamento configurado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicamentos.length,
            itemBuilder: (context, index) {
              final med = medicamentos[index];
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
                        ), // <- Este fecho estava em falta
                        const Divider(),
                        if (med['detalhes_dose'] != null &&
                            med['detalhes_dose'].toString().isNotEmpty) ...[
                          Text(
                            'Dose: ${med['detalhes_dose']}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ] else if (med['dose_semanal'] != null &&
                            med['dose_semanal'] > 0) ...[
                          // Plano B: Se os detalhes_dose não existirem, mostra a dose semanal base!
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
                          'Intervalo: A cada ${med['intervalo_dias']} dias',
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
            },
          );
        },
      ),
    );
  }
}

// ==========================================================
// ECRÃ DE CRIAÇÃO (COM ALERTA MÉDICO DE LESÃO)
// ==========================================================
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

  List<Map<String, dynamic>> listaCatalogo = [];
  String? nomeSelecionado;
  bool modoNovoMedicamento = true;
  bool modoEdicao = false;

  bool _isMix = false;
  List<Map<String, dynamic>> medicamentosBaseMix = [];

  final nomeCtrl = TextEditingController();
  final ampolasCtrl = TextEditingController();
  final volumeCtrl = TextEditingController();
  final concentracaoCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final intervaloCtrl = TextEditingController();

  String? categoriaSelecionada; // NOVA VARIÁVEL PARA A CATEGORIA
  String? unidadeSelecionada;
  int? seringaSelecionada;
  String? regiaoSelecionada;
  DateTime dataInicio = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 8, minute: 0); // NOVO ESTADO

  String textoDetalhesDose = '';

  // Váriavel de cálculo real para o Gatilho Preditivo
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
      unidadeSelecionada = widget.medicamentoEditado!['unidade_dose'];
      seringaSelecionada = widget.medicamentoEditado!['seringa_ui'];
      regiaoSelecionada = widget.medicamentoEditado!['regiao_rodizio'];
      dataInicio =
          DateTime.tryParse(widget.medicamentoEditado!['data_inicio']) ??
          DateTime.now();

      // NOVA RECUPERAÇÃO DA HORA
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

    // ==========================================================
    // NOVO: FORÇA O RECÁLCULO IMEDIATO
    // Se estiver a editar um medicamento normal (não-Mix), faz
    // o cálculo automático assim que a tela abre.
    // ==========================================================
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

      List<Map<String, dynamic>> listaProcessada = [];

      for (var item in resposta) {
        String nomeReal = item['nome'].toString();

        // Ignora os Mixes, pois não faz sentido puxar um Mix para dentro do Catálogo
        if (nomeReal.startsWith('Mix')) continue;

        // Se o medicamento estiver oculto, removemos a tag apenas visualmente para o Catálogo
        if (nomeReal.startsWith('[Oculto] ')) {
          nomeReal = nomeReal.replaceFirst('[Oculto] ', '');
          item['nome'] = nomeReal;
        }

        // Adiciona à lista final apenas se esse nome ainda não existir lá
        // (evita duplicatas caso você tenha o mesmo medicamento ativo e oculto)
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
      _isMix = false;
      textoDetalhesDose = '';
      calcVolumeMl = 0.0;
    });
  }

  Future<void> _abrirSeletorDeMix() async {
    // 1. Busca os medicamentos reais configurados no banco do utilizador
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

    // 2. Filtra a lista para não permitir misturar um Mix já existente
    List<Map<String, dynamic>> listaMisturavel =
        List<Map<String, dynamic>>.from(meusMedicamentos)
            .where((m) => !m['nome'].toString().startsWith('Mix'))
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

    List<Map<String, dynamic>> selecionados = List.from(medicamentosBaseMix);

    final resultado = await showDialog<List<Map<String, dynamic>>>(
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
                    // Como os medicamentos do banco têm IDs únicos verdadeiros, a seleção individual funcionará agora!
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

    // Só preenche se o dado existir. Caso contrário, deixa em branco ('')
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

    // Atualiza os dropdowns se a informação vier do Supabase
    if (med['unidade'] != null) {
      setState(() => unidadeSelecionada = med['unidade'].toString());
    }
    if (med['regiao_base'] != null) {
      setState(() => regiaoSelecionada = med['regiao_base'].toString());
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

          // 1. REPLICAÇÃO EXATA DO EXCEL: SE(G2=3;E2/2;(E2/7)*G2)
          double fator = (intervalo == 3)
              ? (dSemanal / 2)
              : ((dSemanal / 7) * intervalo);

          // 2. REPLICAÇÃO EXATA DO EXCEL: Conversão se a unidade for "mL"
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
          calcVolumeMl =
              totalMl; // Guarda o volume total para o Alerta Preditivo
        });
      } catch (e) {}
    } else {
      if (doseCtrl.text.isEmpty ||
          concentracaoCtrl.text.isEmpty ||
          intervaloCtrl.text.isEmpty ||
          unidadeSelecionada == null) {
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
        int intervalo = int.parse(intervaloCtrl.text.replaceAll(',', '.'));

        if (concentracao > 0) {
          setState(() {
            // 1. REPLICAÇÃO EXATA DO EXCEL: SE(G2=3;E2/2;(E2/7)*G2)
            double fator = (intervalo == 3)
                ? (doseSemanal / 2)
                : ((doseSemanal / 7) * intervalo);

            // 2. REPLICAÇÃO EXATA DO EXCEL: Conversão se a unidade for "mL"
            double doseMg = (unidadeSelecionada == 'mL')
                ? (fator * concentracao)
                : fator;

            calcVolumeMl =
                doseMg /
                concentracao; // Guarda o volume para o Alerta Preditivo
            double doseUi = calcVolumeMl * 100;
            textoDetalhesDose =
                '${doseMg.toStringAsFixed(2).replaceAll('.', ',')} mg / ${doseUi.toStringAsFixed(2).replaceAll('.', ',')} UI';
          });
        }
      } catch (e) {}
    }
  }

  Future<void> _abrirCalculadoraSegura() async {
    final querUsar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Preenchimento Seguro',
          style: TextStyle(color: Color(0xFF1E3A8A)),
        ),
        content: const Text(
          'Deseja usar a Calculadora Automática de Rótulo?\n\nIsso evita erros na conversão de medicamentos como a Tirzepatida ou Semaglutida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
          'Calculadora de Rótulo\nPASSO 1 DE 2:',
          style: TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: mgCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Quantos 'mg' totais no rótulo?",
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
            labelText: "Volume em 'mL' da ampola/caneta?",
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

  // ==========================================================
  // MOTOR DE AUTO-CLASSIFICAÇÃO CLÍNICA
  // ==========================================================
  String _identificarCategoriaClinica(String nomeMedicamento) {
    final nome = nomeMedicamento.toLowerCase();

    // 1. Emagrecimento / Síndrome Metabólica
    if (nome.contains('tirzepatida') ||
        nome.contains('semaglutida') ||
        nome.contains('ozempic') ||
        nome.contains('mounjaro') ||
        nome.contains('saxenda') ||
        nome.contains('liraglutida')) {
      return 'GLP-1';
    }
    // 2. Testosterona Base
    else if (nome.contains('testosterona') ||
        nome.contains('durateston') ||
        nome.contains('enantato') ||
        nome.contains('cipionato') ||
        nome.contains('sustanon')) {
      return 'Testosterona Base';
    }
    // 3. Derivados de DHT (Forte impacto lipídico e de próstata)
    else if (nome.contains('masteron') ||
        nome.contains('drostanolona') ||
        nome.contains('primobolan') ||
        nome.contains('oxandrolona') ||
        nome.contains('stanozolol')) {
      return 'Derivado DHT';
    }
    // 4. Derivados 19-Nor (Impacto em Prolactina)
    else if (nome.contains('nandrolona') ||
        nome.contains('deca') ||
        nome.contains('trembolona')) {
      return 'Derivado 19-Nor';
    }
    // 5. Peptídeos de Recuperação/GH
    else if (nome.contains('ghk') ||
        nome.contains('bpc') ||
        nome.contains('tb-500') ||
        nome.contains('tb500') ||
        nome.contains('gh ') ||
        nome.contains('somatropina')) {
      return 'Peptídeos';
    }

    // Se a aplicação não reconhecer, classifica como genérico
    return 'Outros';
  }

  Future<void> _guardarMedicamento() async {
    if (!_formKey.currentState!.validate()) return;

    // ==========================================================
    // ALERTA DE RISCO DE LESÃO - GATILHO PREDITIVO
    // ==========================================================
    if (calcVolumeMl >= 1.0 &&
        (regiaoSelecionada == 'Barriga' || regiaoSelecionada == 'Flanco')) {
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
      return; // Interrompe o salvamento para obrigar o utilizador a alterar a Região
    }

    setState(() => carregando = true);

    try {
      final nomeFinal = modoNovoMedicamento || _isMix
          ? nomeCtrl.text.trim()
          : nomeSelecionado;
      final intervaloFinal = int.parse(intervaloCtrl.text.replaceAll(',', '.'));

      // ==========================================================
      // APLICAÇÃO DA INTELIGÊNCIA AQUI
      // ==========================================================
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
          'categoria_clinica': categoriaAutomatica, // CAMPO INJETADO AQUI
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
          'intervalo_dias': intervaloFinal,
          'data_inicio': dataInicio.toIso8601String().split('T')[0],
          'hora_aplicacao':
              '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
          'seringa_ui': seringaSelecionada,
          'regiao_rodizio': regiaoSelecionada,
          'detalhes_dose': textoDetalhesDose,
          'categoria_clinica': categoriaAutomatica, // CAMPO INJETADO AQUI
        };
      }

      if (modoEdicao) {
        await supabase
            .from('medicamentos')
            .update(dados)
            .eq('id', widget.medicamentoEditado!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicamento atualizado!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // --- INÍCIO DO FILTRO DE QUALIDADE ---
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
        // --- FIM DO FILTRO DE QUALIDADE ---

        // 1. Capturar o ID do utilizador
        final usuarioId = supabase.auth.currentUser!.id;

        // 2. Injetar o ID nos dados que já estavam prontos
        dados['user_id'] = usuarioId;

        // 3. Fazer o insert normal do novo Mix
        await supabase.from('medicamentos').insert(dados);

        // --- NOVA LÓGICA DE LIMPEZA ---
        // Se acabámos de criar um Mix novo, OCULTAMOS os medicamentos base do Banco
        if (_isMix && !modoEdicao) {
          for (var baseMed in medicamentosBaseMix) {
            await supabase
                .from('cronograma')
                .delete()
                .eq('medicamento_id', baseMed['id']);
            // Oculta o medicamento colocando [Oculto] na frente do nome
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

  Future<void> _desmembrarMix() async {
    setState(() => carregando = true);
    try {
      final mixNome = widget.medicamentoEditado!['nome'].toString();

      // 1. Puxar os medicamentos ocultados
      final ocultos = await supabase
          .from('medicamentos')
          .select()
          .like('nome', '[Oculto]%');

      // 2. Retirar a máscara apenas dos medicamentos que fazem parte deste Mix
      for (var o in ocultos) {
        String nomeReal = o['nome'].toString().replaceFirst('[Oculto] ', '');
        if (mixNome.contains(nomeReal)) {
          await supabase
              .from('medicamentos')
              .update({'nome': nomeReal})
              .eq('id', o['id']);
        }
      }

      // 3. Destruir o Mix e o seu cronograma
      await supabase
          .from('cronograma')
          .delete()
          .eq('medicamento_id', widget.medicamentoEditado!['id']);
      await supabase
          .from('medicamentos')
          .delete()
          .eq('id', widget.medicamentoEditado!['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mix desmembrado! Ajuste as doses e crie novamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a tela inicial
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
        title: Text(modoEdicao ? 'Editar Medicamento' : 'Novo Medicamento'),
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
                            decoration: const InputDecoration(
                              labelText: 'Mix Selecionado',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                          )
                        : (modoNovoMedicamento
                              ? TextFormField(
                                  controller: nomeCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Medicamento (Digitar)',
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: modoEdicao,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Obrigatório'
                                      : null,
                                )
                              : Autocomplete<String>(
                                  // ... (código do autocomplete que já existe no seu app)
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
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Catálogo (Pesquisar...)',
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(
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
                          label: const Text(
                            'NOVO',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _limparSelecao,
                        ),
                      // ... (resto dos botões de catálogo e mix)
                      if (modoNovoMedicamento && listaCatalogo.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.list, color: Colors.blue),
                          label: const Text(
                            'CATÁLOGO',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () =>
                              setState(() => modoNovoMedicamento = false),
                        ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.science, color: Colors.orange),
                        label: const Text(
                          'CRIAR MIX',
                          style: TextStyle(
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
                    // Removido o 'const' daqui
                    children: [
                      const Icon(Icons.science, color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'MODO MIX ATIVADO E TRANCADO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        // Adicionado o texto dinâmico aqui
                        modoEdicao
                            ? 'Para alterar as doses originais, clique em DESMEMBRAR MIX no final da página. Isso devolverá os medicamentos ao Banco.'
                            : 'O Intervalo, Seringa e Região foram importados automaticamente dos medicamentos originais para garantir a segurança.',
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
                  decoration: const InputDecoration(
                    labelText: 'Intervalo (dias)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
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
                          labelText: 'Qtd. Ampolas',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                      child: TextFormField(
                        controller: concentracaoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        // --- NOVO GATILHO AUTOMÁTICO AQUI ---
                        onTap: () {
                          // Abre a calculadora automaticamente se for a primeira vez que toca (campo vazio)
                          if (concentracaoCtrl.text.isEmpty) {
                            _abrirCalculadoraSegura();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Concentração (mg/mL)',
                          border: const OutlineInputBorder(),
                          // Mantemos o ícone clicável caso ele queira forçar a
                          // abertura da calculadora depois de já ter preenchido algo
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calculate,
                              color: Colors.blue,
                            ),
                            onPressed: _abrirCalculadoraSegura,
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: intervaloCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Intervalo (dias)',
                          border: OutlineInputBorder(),
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
                      flex: 2,
                      child: TextFormField(
                        controller: doseCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Dose Semanal',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: unidadeSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          border: OutlineInputBorder(),
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
                      'Dose Calculada por Aplicação:',
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
                          ? 'Aguardando valores...'
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
                      decoration: const InputDecoration(
                        labelText: 'Seringa (UI)',
                        border: OutlineInputBorder(),
                      ),
                      items: [30, 50, 100]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('$e UI'),
                            ),
                          )
                          .toList(),
                      onChanged: _isMix
                          ? null
                          : (val) {
                              setState(() => seringaSelecionada = val!);
                              _recalcularEquivalencia();
                            },
                      validator: (val) => val == null ? 'Erro' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: regiaoSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Região Base',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ['Barriga', 'Flanco', 'Glúteo', 'Vasto', 'Deltoide']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: _isMix
                          ? null
                          : (val) => setState(() => regiaoSelecionada = val!),
                      validator: (val) => val == null ? 'Erro' : null,
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
                        decoration: const InputDecoration(
                          labelText: 'Data de Início',
                          border: OutlineInputBorder(),
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
                  const SizedBox(width: 16), // Espaço entre os botões
                  Expanded(
                    child: InkWell(
                      onTap: () => _escolherHora(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora da Aplicação',
                          border: OutlineInputBorder(),
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
                        if (_isMix && modoEdicao)
                          ElevatedButton.icon(
                            onPressed: _desmembrarMix,
                            icon: const Icon(
                              Icons.call_split,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'DESMEMBRAR MIX',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _guardarMedicamento,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              modoEdicao
                                  ? 'ATUALIZAR MEDICAMENTO'
                                  : 'GUARDAR MEDICAMENTO',
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
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// ECRÃ DO CRONOGRAMA (COM ALERTA DE FIM DE ESTOQUE)
// ==========================================================
class CronogramaEcra extends StatefulWidget {
  final Map<String, dynamic> medicamento;
  const CronogramaEcra({super.key, required this.medicamento});
  @override
  State<CronogramaEcra> createState() => _CronogramaEcraState();
}

class _CronogramaEcraState extends State<CronogramaEcra> {
  final supabase = Supabase.instance.client;
  bool carregando = false;

  Future<List<dynamic>> obterCronograma() async {
    return await supabase
        .from('cronograma')
        .select()
        .eq('medicamento_id', widget.medicamento['id'])
        .order('data_aplicacao', ascending: true);
  }

  List<String> _obterListaRodizio(String regiaoBase) {
    if (regiaoBase == 'Barriga') {
      return [
        'Barriga Direito - Meio',
        'Barriga Esquerdo - Meio',
        'Barriga Direito - Cima',
        'Barriga Esquerdo - Cima',
        'Barriga - Cima',
        'Barriga - Baixo',
      ];
    } else if (regiaoBase == 'Flanco') {
      return [
        'Flanco Dir. Alto A',
        'Flanco Esq. Alto A',
        'Flanco Dir. Alto B',
        'Flanco Esq. Alto B',
        'Flanco Dir. Alto C',
        'Flanco Esq. Alto C',
        'Flanco Dir. Baixo A',
        'Flanco Esq. Baixo A',
        'Flanco Dir. Baixo B',
        'Flanco Esq. Baixo B',
        'Flanco Dir. Baixo C',
        'Flanco Esq. Baixo C',
        'Flanco Dir. Médio A',
        'Flanco Esq. Médio A',
        'Flanco Dir. Médio B',
        'Flanco Esq. Médio B',
      ];
    } else if (regiaoBase == 'Glúteo') {
      return [
        'Glúteo Direito - Superior Externo',
        'Glúteo Esquerdo - Superior Externo',
      ];
    } else if (regiaoBase == 'Vasto') {
      return ['Vasto Lateral Direito', 'Vasto Lateral Esquerdo'];
    } else if (regiaoBase == 'Deltoide') {
      return ['Deltoide Direito', 'Deltoide Esquerdo'];
    }
    return [regiaoBase];
  }

  Future<void> _abrirDialogoGeracao() async {
    int opcaoSelecionada = 0; // 0=Tudo, 1=Semanas, 2=Meses, 3=Injeções
    final TextEditingController customCtrl = TextEditingController();

    // Captura o intervalo de dias do medicamento atual
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
                      if (valor <= 0)
                        return; // Bloqueia se estiver vazio ou zero

                      if (opcaoSelecionada == 1) {
                        // Semanas -> converte para dias e divide pelo intervalo
                        int totalDias = valor * 7;
                        limiteDeInjecoes = (totalDias / intervaloDias).floor();
                      } else if (opcaoSelecionada == 2) {
                        // Meses -> converte para dias (aproximado 30) e divide
                        int totalDias = valor * 30;
                        limiteDeInjecoes = (totalDias / intervaloDias).floor();
                      } else if (opcaoSelecionada == 3) {
                        // Injeções exatas
                        limiteDeInjecoes = valor;
                      }

                      // Garante que gera pelo menos 1 injeção se a matemática der zero
                      if (limiteDeInjecoes == 0) limiteDeInjecoes = 1;
                    }

                    Navigator.pop(ctx); // Fecha o pop-up
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
      int intervalo = widget.medicamento['intervalo_dias'];
      double doseMg = (doseSemanal / 7) * intervalo;
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
      List<Map<String, dynamic>> loteAplicacoes = [];

      // ==========================================================
      // NOVO MOTOR: RASTREAMENTO GLOBAL E ANTI-COLISÃO DIÁRIO
      // ==========================================================
      int indiceInicial = 0;
      Set<String> locaisOcupadosGlobais = {};

      try {
        final usuarioId = supabase.auth.currentUser!.id;

        // 1. Carrega todos os agendamentos futuros e passados do utilizador
        final historico = await supabase
            .from('cronograma')
            .select('data_aplicacao, local_aplicacao')
            .eq('user_id', usuarioId)
            .order('data_aplicacao', ascending: false);

        // 2. Regista todas as datas e locais já ocupados num "Calendário Virtual"
        for (var item in historico) {
          String data = item['data_aplicacao'].toString();
          String local = item['local_aplicacao'].toString();
          locaisOcupadosGlobais.add('$data|$local');
        }

        // 3. Encontra o último ponto usado nesta região para não começar do zero
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
      // ==========================================================

      DateTime dataBase = DateTime.parse(
        widget.medicamento['data_inicio'].toString(),
      );

      // LER HORA CONFIGURADA (com fallback para 08:00 por segurança)
      String horaStr = widget.medicamento['hora_aplicacao'] ?? '08:00';
      int horaDisp = int.parse(horaStr.split(':')[0]);
      int minDisp = int.parse(horaStr.split(':')[1]);

      for (int i = 0; i < totalDoses; i++) {
        // TRAVA DE LIMITE
        if (limite != null && i >= limite) {
          break;
        }

        String dataIso = dataBase.toIso8601String().split('T')[0];
        String localAtual =
            locaisRodizio[(indiceInicial + i) % locaisRodizio.length];

        // ==========================================================
        // DESVIO INTELIGENTE DE COLISÃO
        // ==========================================================
        int tentativas = 0;
        // Enquanto o local atual já estiver agendado para aquele exato dia...
        while (locaisOcupadosGlobais.contains('$dataIso|$localAtual') &&
            tentativas < locaisRodizio.length) {
          // ... avança o rodízio forçadamente para o próximo ponto livre daquela região
          indiceInicial++;
          localAtual =
              locaisRodizio[(indiceInicial + i) % locaisRodizio.length];
          tentativas++;
        }

        // Bloqueia este ponto recém-descoberto para ele não ser usado por outra dose
        locaisOcupadosGlobais.add('$dataIso|$localAtual');
        // ==========================================================

        // FUNDIR DATA E HORA AQUI
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

        final int idUnico = dataBase.millisecondsSinceEpoch ~/ 1000 + i;
        await agendarNotificacao(
          idUnico,
          'Dia de Injeção! 💉',
          'Hoje é dia de aplicar ${widget.medicamento['nome']} ($localAtual).',
          dataBase,
        );

        dataBase = dataBase.add(Duration(days: intervalo));
      }

      // 1. Capturar o ID do utilizador
      final usuarioId = supabase.auth.currentUser!.id;

      // 2. Injetar o ID em TODAS as aplicações geradas no lote
      for (var aplicacao in loteAplicacoes) {
        aplicacao['user_id'] = usuarioId;
      }

      // 3. Fazer o insert do lote inteiro
      await supabase.from('cronograma').insert(loteAplicacoes);

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

  Future<void> alternarStatusDose(String idDose, bool statusAtual) async {
    try {
      await supabase
          .from('cronograma')
          .update({'status_aplicado': !statusAtual})
          .eq('id', idDose);
      setState(() {});
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
      await supabase
          .from('cronograma')
          .delete()
          .eq('medicamento_id', widget.medicamento['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cronograma apagado!'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Cronograma: ${widget.medicamento['nome']}'),
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[100],
            child: Text(
              'Seringa: ${widget.medicamento['seringa_ui']} UI | Intervalo: ${widget.medicamento['intervalo_dias']} dias',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: obterCronograma(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    carregando) {
                  return const Center(child: CircularProgressIndicator());
                }
                final doses = snapshot.data ?? [];
                if (doses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Nenhum cronograma gerado ainda.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
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
                              label: const Text(
                                'GERAR CRONOGRAMA',
                                style: TextStyle(
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
                }
                return ListView.builder(
                  itemCount: doses.length,
                  itemBuilder: (context, index) {
                    final dose = doses[index];
                    final partesData = dose['data_aplicacao'].toString().split(
                      '-',
                    );
                    final dataFormatada =
                        '${partesData[2]}/${partesData[1]}/${partesData[0]}';

                    final bool isUltimasDuas = index >= doses.length - 2;
                    final bool isPendenteEFinal =
                        isUltimasDuas && !dose['status_aplicado'];

                    Color? corFundo = dose['status_aplicado']
                        ? Colors.green[50]
                        : (isPendenteEFinal ? Colors.red[100] : Colors.white);
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
                        onTap: () => alternarStatusDose(
                          dose['id'],
                          dose['status_aplicado'],
                        ),
                        leading: Icon(
                          dose['status_aplicado']
                              ? Icons.check_circle
                              : (isPendenteEFinal
                                    ? Icons.warning_amber_rounded
                                    : Icons.circle_outlined),
                          color: dose['status_aplicado']
                              ? Colors.green
                              : (isPendenteEFinal ? Colors.red : Colors.grey),
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
                        subtitle: Text(
                          '${dose['dose_ajustada']}\nLocal: ${dose['local_aplicacao']}',
                          style: TextStyle(
                            color: dose['status_aplicado']
                                ? Colors.grey
                                : corTexto,
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ECRÃ DE GUIA, FAQ E TERMOS DE RESPONSABILIDADE
// ==========================================================

// TELA PARA VISUALIZAR AS IMAGENS COM ZOOM (PINÇA)
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
          panEnabled: true, // Permite mover a imagem
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0, // Zoom de até 4x
          child: Image.asset(
            caminhoImagem,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Imagem não encontrada.\nCertifique-se de adicioná-la no pubspec.yaml',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
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

  Widget _buildSectionCard({
    required String titulo,
    required Color cor,
    required IconData icone,
    required String conteudo,
  }) {
    return Card(
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
            Text(
              conteudo,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisualizadorImagemEcra(
                caminhoImagem: caminhoImagem,
                titulo: titulo,
              ),
            ),
          );
        },
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
          title: const Text(
            'Guia e Termos de Uso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          actions: [
            if (widget.obrigatorio)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair do App',
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ==========================================
                  // 1. BANCO DE IMAGENS DE PONTOS DE APLICAÇÃO
                  // ==========================================
                  Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.map, color: Color(0xFF1E3A8A)),
                              SizedBox(width: 8),
                              Text(
                                'MAPA DE PONTOS DE APLICAÇÃO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Clique na região para visualizar os locais exatos e fazer o rodízio correto:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(),
                          _buildImageButton(
                            context: context,
                            titulo: 'Pontos da Barriga (8 Pontos)',
                            icone: Icons.accessibility_new,
                            caminhoImagem: 'assets/regiao/barriga.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: 'Pontos dos Flancos (9 Pontos)',
                            icone: Icons.airline_seat_flat_angled,
                            caminhoImagem: 'assets/regiao/flancos.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: 'Pontos dos Glúteos ( IM - Quadrante )',
                            icone: Icons.directions_run,
                            caminhoImagem: 'assets/regiao/gluteos.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: 'Pontos da Coxa (Vasto Lateral)',
                            icone: Icons.boy,
                            caminhoImagem:
                                'assets/regiao/coxa_vastolateral.png',
                          ),
                          _buildImageButton(
                            context: context,
                            titulo: 'Pontos do Deltoide (Braço)',
                            icone: Icons.shutter_speed_sharp,
                            caminhoImagem: 'assets/regiao/deltoide.png',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==========================================
                  // 2. GUIA DE SERINGAS E AGULHAS
                  // ==========================================
                  Card(
                    color: Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.vaccines, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'GUIA DE SERINGAS E AGULHAS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Entenda o material adequado para cada aplicação:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(),
                          _buildImageButton(
                            context: context,
                            titulo: 'Visualizar Agulhas e Seringas',
                            icone: Icons.science_outlined,
                            caminhoImagem: 'assets/regiao/agulhas_seringas.png',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '💉 AGULHAS RECOMENDADAS:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '• Subcutânea (SC - Gordura): Agulhas curtas e finas, ex: 13x0.45mm ou 13x0.3mm (marrom/cinza). Aplicada em ângulo de 90° ou 45° dependendo do tecido adiposo.\n'
                            '• Intramuscular (IM - Músculo): Agulhas longas para alcançar o músculo, ex: 25x0.7mm ou 30x0.7mm (preta/azul) e para volumes maiores 25x0.8mm (verde). Aplicar em ângulo de 90°.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '🧪 SERINGAS E ESCALAS:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '• Seringas de Insulina (100 UI = 1 mL): Escala detalhada. 10 UI equivalem a 0.1 mL. Ideal para microdoses subcutâneas de alta precisão.\n'
                            '• Seringas de 3 mL ou 5 mL: Usadas para aplicações intramusculares que requerem maior volume de diluente ou óleo.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==========================================
                  // 3. NOVA SEÇÃO: INTELIGÊNCIA CLÍNICA
                  // ==========================================
                  _buildSectionCard(
                    titulo: '🧬 INTELIGÊNCIA CLÍNICA E EXAMES',
                    cor: Colors.teal[800]!,
                    icone: Icons.biotech,
                    conteudo:
                        'O aplicativo possui um Motor Analítico Preditivo de segurança:\n\n'
                        '• Meu Perfil (Ícone Superior): Preencha o seu sexo biológico e data de nascimento. Estes dados cruzam com os seus tratamentos para gerar painéis de exames precisos (ex: sugerir PSA apenas para homens acima de 40 anos).\n\n'
                        '• Auto-Classificação: Ao registar um medicamento, o motor identifica a família clínica (ex: Derivado DHT, Análogo GLP-1, Peptídeo) e prepara o protocolo de risco e controle laboratorial.\n\n'
                        '• Check-up de Biomarcadores: O algoritmo calcula a janela de "steady state" (estabilidade sanguínea). O alerta de primeira coleta surge 45 dias após o início de um novo tratamento. Após registar essa coleta, os exames de manutenção passarão a ser solicitados a cada 120 dias.',
                  ),
                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titulo: '🚨 AVISO MÉDICO IMPORTANTE',
                    cor: Colors.red[900]!,
                    icone: Icons.warning_amber_rounded,
                    conteudo:
                        'Este aplicativo é exclusivamente uma ferramenta de apoio logístico e matemático. ELE NÃO SUBSTITUI A ORIENTAÇÃO MÉDICA.\n\n'
                        '• O aplicativo não receita, não prescreve e não recomenda tratamentos.\n'
                        '• Em caso de dor extrema, febre, vermelhidão intensa, inchaço, falta de ar ou qualquer mal-estar após uma aplicação, PROCURE UMA EMERGÊNCIA HOSPITALAR IMEDIATAMENTE ou contacte o seu médico.\n'
                        '• Nunca inicie ou altere dosagens sem o conhecimento e autorização do seu profissional de saúde.',
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    titulo: '⚖️ TERMOS DE RESPONSABILIDADE',
                    cor: Colors.orange[900]!,
                    icone: Icons.gavel,
                    conteudo:
                        'Ao utilizar o Controle Injetáveis, o usuário declara estar plenamente ciente de que:\n\n'
                        '1. O usuário assume TOTAL e exclusiva responsabilidade pelas doses inseridas, misturas (Mix) criadas e aplicações realizadas.\n'
                        '2. Os desenvolvedores (CodeVibe Studio) NÃO se responsabilizam por erros de preenchimento, cálculos equivocados gerados por introdução de dados incorretos ou danos à saúde.\n'
                        '3. A lista do "Check-up de Biomarcadores" é uma sugestão puramente matemática baseada em protocolos de redução de danos. NÃO tem valor de pedido médico oficial.\n'
                        '4. O utilizador isenta os criadores do aplicativo de qualquer complicação clínica ou responsabilidade legal decorrente do uso da ferramenta.',
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    titulo: '🧼 HIGIENE E ASSEPSIA',
                    cor: Colors.blueGrey[700]!,
                    icone: Icons.clean_hands,
                    conteudo:
                        'A falta de higiene pode causar infecções graves e abcessos. Siga rigorosamente:\n\n'
                        '• Lave as mãos com água e sabão antes de tocar nos materiais.\n'
                        '• Limpe a borracha do bujão com algodão e Álcool 70%.\n'
                        '• Faça a assepsia da pele com Álcool 70% e deixe secar naturalmente antes de perfurar.\n'
                        '• Utilize APENAS seringas e agulhas estéreis, de uso único (descartáveis).\n'
                        '• Descarte o material perfurocortante em recipiente rígido adequado (Descarpack).',
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    titulo: '📱 COMO USAR O APLICATIVO',
                    cor: const Color(0xFF1E3A8A),
                    icone: Icons.help_center,
                    conteudo:
                        '• Banco de Medicamentos: Comece por aqui. Cadastre os seus frascos preenchendo a Concentração (mg/mL) e a Dose Semanal.\n\n'
                        '• Calculadora Segura: Ao clicar no campo "Concentração", o app abre uma calculadora que divide os "mg totais" pelos "mL totais" do rótulo.\n\n'
                        '• Criar Mix: Permite agrupar medicamentos na mesma injeção. Eles precisam estar configurados com o mesmo "Intervalo" e "Região Base".\n\n'
                        '• Desmembrar Mix: Caso queira alterar a dose de apenas 1 composto da sua mistura, use esta opção para libertá-los de volta ao Banco.\n\n'
                        '• Gerar Cronograma: Gere datas "Até o frasco acabar" ou "Apenas 1 Mês" (ideal se você faz aumento gradativo de doses). O app automaticamente desviará agendamentos que colidam na mesma região e dia.',
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _aceitouTermos,
                              activeColor: Colors.green[700],
                              onChanged: (val) {
                                setState(() => _aceitouTermos = val ?? false);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Declaro que li as instruções, estou ciente dos riscos médicos e aceito os Termos de Responsabilidade e Isenção.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
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
                                    // 1. Grava o aceite oficialmente na nuvem (Supabase)
                                    await Supabase.instance.client
                                        .from('aceites_termos')
                                        .insert({'user_id': usuarioId});

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Termos aceitos e registrados. Uso liberado!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                      Navigator.pop(
                                        context,
                                      ); // Libera a entrada no App
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao registrar: $e',
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
                          child: const Text(
                            'ESTOU CIENTE E ACEITO',
                            style: TextStyle(
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
    );
  }
}

// ==========================================================
// FORMATADOR AUTOMÁTICO DE DATA (MÁSCARA DD/MM/AAAA)
// ==========================================================

class DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permite que o utilizador apague livremente (BackSpace)
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }

    // Remove tudo o que não for número
    final textoLimpo = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String novoTexto = '';

    for (int i = 0; i < textoLimpo.length; i++) {
      // Adiciona a barra (/) automaticamente após o dia e o mês
      if (i == 2 || i == 4) {
        novoTexto += '/';
      }
      novoTexto += textoLimpo[i];
    }

    // Limita rigidamente a 10 caracteres para não ultrapassar DD/MM/AAAA
    if (novoTexto.length > 10) novoTexto = novoTexto.substring(0, 10);

    return TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: novoTexto.length),
    );
  }
}

// ==========================================================
// ECRÃ DE PERFIL DO UTILIZADOR (INTELIGÊNCIA DEMOGRÁFICA)
// ==========================================================
class PerfilEcra extends StatefulWidget {
  const PerfilEcra({super.key});

  @override
  State<PerfilEcra> createState() => _PerfilEcraState();
}

class _PerfilEcraState extends State<PerfilEcra> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool carregando = true;

  final nomeCtrl = TextEditingController();
  final dataCtrl = TextEditingController(); // Novo controlador "inteligente"
  String? generoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
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
          if (res['data_nascimento'] != null) {
            // Converte de AAAA-MM-DD (Base de Dados) para DD/MM/AAAA (Ecrã)
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

    // Valida se a data está completa
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
      // Converte de DD/MM/AAAA (Ecrã) para AAAA-MM-DD (Base de Dados)
      final partes = dataCtrl.text.split('/');
      final dataFormatadaBanco = '${partes[2]}-${partes[1]}-${partes[0]}';

      await supabase.from('perfis').upsert({
        'id': userId,
        'nome': nomeCtrl.text.trim(),
        'genero': generoSelecionado,
        'data_nascimento': dataFormatadaBanco,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil biológico atualizado com sucesso!'),
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

    // Se já tiver algo digitado, o calendário tenta abrir logo no ano correto
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
        // Preenche o campo de texto automaticamente no formato perfeito se o utilizador usar o calendário
        dataCtrl.text =
            '${selecionada.day.toString().padLeft(2, '0')}/${selecionada.month.toString().padLeft(2, '0')}/${selecionada.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: carregando
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
                    const Text(
                      'Dados Biológicos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Estas informações são essenciais para que o aplicativo cruze a sua idade e sexo biológico, gerando painéis de exames clínicos precisos e totalmente seguros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: generoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Sexo Biológico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Masculino', 'Feminino']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => generoSelecionado = val),
                      validator: (val) => val == null ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    // ==========================================================
                    // NOVO CAMPO MISTO (DIGITAÇÃO INTELIGENTE + CALENDÁRIO)
                    // ==========================================================
                    TextFormField(
                      controller: dataCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [DataInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Data de Nascimento (DD/MM/AAAA)',
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
                        if (val == null || val.isEmpty) return 'Obrigatório';
                        if (val.length != 10) return 'Data incompleta';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: _salvarPerfil,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'SALVAR PERFIL',
                        style: TextStyle(
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
    );
  }
}
