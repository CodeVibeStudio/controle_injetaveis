import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ==========================================================
// MOTOR DE NOTIFICAÇÕES
// ==========================================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> agendarNotificacao(
  int id,
  String titulo,
  String corpo,
  DateTime dataAgendada,
) async {
  final dataHoraDisparo = tz.TZDateTime.from(
    DateTime(dataAgendada.year, dataAgendada.month, dataAgendada.day, 8, 0),
    tz.local,
  );

  if (dataHoraDisparo.isBefore(tz.TZDateTime.now(tz.local))) return;

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

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

  runApp(const InjetaveisApp());
}

class InjetaveisApp extends StatelessWidget {
  const InjetaveisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Injetáveis',
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

  Future<void> entrar() async {
    setState(() => carregando = true);
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => carregando = false);
  }

  Future<void> recuperarSenha() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, digite o seu email para recuperar a senha.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => carregando = true);
    try {
      await supabase.auth.resetPasswordForEmail(emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperação enviado!'),
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
                        'Sistema Injetáveis',
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
  Map<String, dynamic>? proximaDose;
  Map<String, dynamic>? ultimaDose;

  @override
  void initState() {
    super.initState();
    _pedirPermissaoNotificacoes();
    _carregarResumo();
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

  Future<void> _carregarResumo() async {
    setState(() => carregando = true);
    try {
      final respProxima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', false)
          .order('data_aplicacao', ascending: true)
          .limit(1);
      final respUltima = await supabase
          .from('cronograma')
          .select('*, medicamentos(nome)')
          .eq('status_aplicado', true)
          .order('data_aplicacao', ascending: false)
          .limit(1);
      if (mounted) {
        setState(() {
          if (respProxima.isNotEmpty) proximaDose = respProxima.first;
          if (respUltima.isNotEmpty) ultimaDose = respUltima.first;
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
            icon: const Icon(Icons.logout),
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
                          if (proximaDose != null) ...[
                            Text(
                              proximaDose!['medicamentos'] != null
                                  ? proximaDose!['medicamentos']['nome']
                                        .toString()
                                  : 'Medicamento indisponível',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data: ${_formatarData(proximaDose!['data_aplicacao'])}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Local: ${proximaDose!['local_aplicacao']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text('Dose: ${proximaDose!['dose_ajustada']}'),
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
                          if (ultimaDose != null) ...[
                            Text(
                              ultimaDose!['medicamentos']['nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Data: ${_formatarData(ultimaDose!['data_aplicacao'])}',
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
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetupEcra(),
                        ),
                      ).then((_) => _carregarResumo());
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
    return await supabase.from('medicamentos').select().order('criado_em');
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

  String? unidadeSelecionada;
  int? seringaSelecionada;
  String? regiaoSelecionada;
  DateTime dataInicio = DateTime.now();

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

      if (widget.medicamentoEditado!['detalhes_dose'] != null) {
        textoDetalhesDose = widget.medicamentoEditado!['detalhes_dose'];
      }

      if (nomeCtrl.text.startsWith('Mix:')) _isMix = true;
    }

    doseCtrl.addListener(_recalcularEquivalencia);
    concentracaoCtrl.addListener(_recalcularEquivalencia);
    intervaloCtrl.addListener(_recalcularEquivalencia);
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
      // Chama a função SQL segura em vez de ler a tabela diretamente
      final resposta = await supabase.rpc('obter_nomes_unicos');

      setState(() {
        listaCatalogo = List<Map<String, dynamic>>.from(resposta)
            .where((m) => !m['nome'].toString().startsWith('Mix'))
            .toList();
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
    if (listaCatalogo.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos 2 medicamentos primeiro para criar um Mix.',
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
                  itemCount: listaCatalogo.length,
                  itemBuilder: (context, index) {
                    final med = listaCatalogo[index];
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
          'seringa_ui': seringaSelecionada,
          'regiao_rodizio': regiaoSelecionada,
          'detalhes_dose': textoDetalhesDose,
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
          'seringa_ui': seringaSelecionada,
          'regiao_rodizio': regiaoSelecionada,
          'detalhes_dose': textoDetalhesDose,
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

        // Regra 1: Tamanho mínimo (impede abreviações como "A" ou "Tz")
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
          return; // Aborta a gravação
        }

        // Regra 2: Filtro Anti-Palavrões
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
            return; // Aborta a gravação
          }
        }

        // Regra 3: Padronização (Primeira letra sempre Maiúscula)
        nomeDigitado =
            nomeDigitado[0].toUpperCase() + nomeDigitado.substring(1);

        // Atualiza o dado limpo para ser enviado
        dados['nome'] = nomeDigitado;
        // --- FIM DO FILTRO DE QUALIDADE ---
        // 1. Capturar o ID do utilizador
        final usuarioId = supabase.auth.currentUser!.id;

        // 2. Injetar o ID nos dados que já estavam prontos
        dados['user_id'] = usuarioId;

        // 3. Fazer o insert normal
        await supabase.from('medicamentos').insert(dados);

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
                              : DropdownButtonFormField<String>(
                                  isExpanded:
                                      true, // Garante que não ultrapassa a tela
                                  initialValue: nomeSelecionado,
                                  decoration: const InputDecoration(
                                    labelText: 'Catálogo (Selecionar)',
                                    border: OutlineInputBorder(),
                                  ),
                                  // Forçamos a tipagem exata da lista aqui:
                                  items: listaCatalogo
                                      .map<DropdownMenuItem<String>>((e) {
                                        return DropdownMenuItem<String>(
                                          value: e['nome'].toString(),
                                          child: Text(
                                            e['nome'].toString(),
                                            overflow: TextOverflow.ellipsis, // Corta textos grandes com "..."
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => nomeSelecionado = val!);
                                    _aplicarPreenchimentoSeguro(val!);
                                  },
                                  validator: (val) =>
                                      val == null ? 'Obrigatório' : null,
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
                  child: const Column(
                    children: [
                      Icon(Icons.science, color: Colors.orange, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'MODO MIX ATIVADO E TRANCADO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'O Intervalo, Seringa e Região foram importados automaticamente dos medicamentos originais para garantir a segurança.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
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
                        decoration: InputDecoration(
                          labelText: 'Concentração (mg/mL)',
                          border: const OutlineInputBorder(),
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
              InkWell(
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
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
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

  Future<void> gerarDoses() async {
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

      DateTime dataBase = DateTime.parse(
        widget.medicamento['data_inicio'].toString(),
      );

      for (int i = 0; i < totalDoses; i++) {
        String localAtual = locaisRodizio[i % locaisRodizio.length];

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
                              onPressed: gerarDoses,
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
