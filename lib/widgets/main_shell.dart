import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../i18n/translations.g.dart';

class MainShell extends StatefulWidget {
  final Widget inicioPage;
  final Widget tratamentoPage;
  final Widget ferramentasPage;
  final Widget perfilPage;

  const MainShell({
    super.key,
    required this.inicioPage,
    required this.tratamentoPage,
    required this.ferramentasPage,
    required this.perfilPage,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _ferramentasKey = 0;

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (index == 2) {
        _ferramentasKey++;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      widget.inicioPage,
      widget.tratamentoPage,
      KeyedSubtree(
        key: ValueKey('ferramentas_$_ferramentasKey'),
        child: widget.ferramentasPage,
      ),
      widget.perfilPage,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBarBg,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 68,
              indicatorColor: AppColors.navPillActive,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTap,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: t.navegacao.inicio,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today_rounded),
                  label: t.navegacao.tratamento,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calculate_outlined),
                  selectedIcon: const Icon(Icons.calculate_rounded),
                  label: t.navegacao.ferramentas,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: t.navegacao.perfil,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
