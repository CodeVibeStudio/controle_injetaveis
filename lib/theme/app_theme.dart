import 'package:flutter/material.dart';

class AppColors {
  // Fundos e Superfícies
  static const Color background = Color(0xFF0A0F1C); // Fundo principal profundo
  static const Color surface = Color(0xFF121A2B); // Cartões padrão
  static const Color surfaceHighlight = Color(
    0xFF162442,
  ); // Card destaque (Próxima aplicação)
  static const Color surfaceInner = Color(
    0xFF0C1220,
  ); // Caixas internas e inputs
  static const Color navBarBg = Color(0xFF0D1424); // Fundo do menu inferior

  // Bordas
  static const Color border = Color(0xFF1E293B);
  static const Color borderHighlight = Color(0xFF283E6A);

  // Ações e Destaques
  static const Color primary = Color(
    0xFF7AA2F7,
  ); // Botão principal / links / ativo
  static const Color primaryDarkText = Color(
    0xFF0A0F1C,
  ); // Texto dentro do botão primário
  static const Color navPillActive = Color(
    0xFF1B2B4B,
  ); // Pílula do ícone ativo no menu

  // Semânticas (Clínicas)
  static const Color success = Color(
    0xFF34D399,
  ); // Aplicações realizadas / check
  static const Color warning = Color(
    0xFFF59E0B,
  ); // Aviso educativo / coleta hoje
  static const Color warningBg = Color(
    0xFF261E14,
  ); // Fundo sutil do banner de aviso
  static const Color error = Color(0xFFF87171);

  // Textos
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class AppTextStyles {
  /// Use para doses (mg, UI), datas e contadores — mantém alinhamento clínico perfeito
  static const TextStyle tabularNumber = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle brandEyebrow = TextStyle(
    color: AppColors.primary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: 'PlusJakartaSans',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryDarkText,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        secondary: AppColors.success,
        error: AppColors.error,
      ),

      // AppBar limpa e integrada ao fundo
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),

      // Cartões silenciosos com borda sutil
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Inputs escuros preenchidos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInner,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Botão Principal (estilo "Gerenciar medicamentos" / "+ Adicionar medicamento")
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryDarkText,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Botão Secundário (Outline discreto)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderHighlight, width: 1.2),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      // Divisores sutis
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 24,
      ),

      // Dialogs escuros
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
