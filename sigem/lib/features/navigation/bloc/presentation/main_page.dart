import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigem/features/auth/domain/entities/user_entity.dart';
import 'package:sigem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sigem/features/auth/presentation/bloc/auth_state.dart';
import 'package:sigem/features/auth/presentation/pages/login_page.dart';
import 'package:sigem/features/navigation/bloc/navigation_bloc.dart';
import 'package:sigem/features/navigation/bloc/navigation_event.dart';
import 'package:sigem/features/navigation/bloc/navigation_state.dart';
import 'package:sigem/features/navigation/bloc/presentation/tabs/admin_tab.dart';
import 'package:sigem/features/navigation/bloc/presentation/tabs/attendance_tab.dart';
import 'package:sigem/features/navigation/bloc/presentation/tabs/home_tab.dart';
import 'package:sigem/features/navigation/bloc/presentation/tabs/my_records_tab.dart';


// ─── Palette ──────────────────────────────────────────────────────────────────
const _bg   = Color(0xFFF5EDE0);
const _ink  = Color(0xFF1A1A1A);
const _orange = Color(0xFFFF8B4C);
const _teal    = Color(0xFF1D7A6B);

class MainPage extends StatelessWidget {
  final UserEntity user;
  const MainPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
  buildWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
  builder: (context, navState) {
            final tabs = _buildTabs(user);
            final navItems = _buildNavItems(user);

            return Scaffold(
              backgroundColor: _bg,
              // En MainPage — reemplaza el body del Scaffold
body: _LazyIndexedStack(
  currentIndex: navState.currentIndex,
  children: tabs,
),
              bottomNavigationBar: _BottomNav(
                currentIndex: navState.currentIndex,
                items: navItems,
                onTap: (index) => context
                    .read<NavigationBloc>()
                    .add(NavigationTabChanged(index)),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTabs(UserEntity user) {
    return [
      HomeTab(user: user),
      AttendanceTab(user: user),
      MyRecordsTab(),
      if (user.isAdmin) AdminTab(),
    ];
  }

  List<_NavItemData> _buildNavItems(UserEntity user) {
    return [
      _NavItemData(icon: Icons.home_rounded),
      _NavItemData(icon: Icons.fingerprint_rounded),
      _NavItemData(icon: Icons.calendar_month_rounded),
      if (user.isAdmin)
        _NavItemData(icon: Icons.shield_rounded),
    ];
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  const _NavItemData({required this.icon});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 44,
              decoration: BoxDecoration(
                color: isActive ? _teal : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: isActive ? Colors.white : Colors.white54,
                    size: 30,
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 2),

                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}



class _LazyIndexedStack extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const _LazyIndexedStack({
    required this.currentIndex,
    required this.children,
  });

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.generate(
      widget.children.length,
      (i) => i == widget.currentIndex,
    );
  }

  @override
  void didUpdateWidget(_LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      if (!_activated[widget.currentIndex]) {
        setState(() => _activated[widget.currentIndex] = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.currentIndex,
      children: List.generate(widget.children.length, (i) {
        if (!_activated[i]) {
          return const SizedBox.shrink();
        }
        return widget.children[i];
      }),
    );
  }
}