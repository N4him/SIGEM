import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigem/features/admin/data/datasources/presentation/pages/admin_page.dart';
import 'package:sigem/features/attendance/presentation/pages/my_records_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';

const _bg      = Color(0xFFF5EDE0);
const _ink     = Color(0xFF1A1A1A);
const _cardWht = Color(0xFFFFFFFF);
const _violet  = Color(0xFF7B6CF5);
const _orange  = Color(0xFFFF8B4C);
const _dark    = Color(0xFF1C1C1E);
const _teal    = Color(0xFF1D7A6B);
const _muted   = Color(0xFF9E9488);

class HomePage extends StatelessWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
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
        child: Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────
                _Header(user: user),

                // ── Scrollable content ────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroCard(user: user),
                        const SizedBox(height: 16),
                        _buildStatsRow(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(user.isAdmin ? 3 : 2),
                        const SizedBox(height: 14),
                        _ActionCard(
                          title: 'Registrar asistencia',
                          subtitle: 'Check-in y check-out de tu jornada',
                          icon: Icons.fingerprint_rounded,
                          color: _dark,
                          badge: 'HOY',
                          badgeColor: _orange,
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AttendancePage(user: user))),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: 'Mis registros',
                          subtitle: 'Ver historial de jornadas',
                          icon: Icons.calendar_month_rounded,
                          color: _violet,
                          badge: 'VER',
                          badgeColor: const Color(0x40FFFFFF),
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MyRecordsPage())),
                        ),
                        if (user.isAdmin) ...[
                          const SizedBox(height: 12),
                          _ActionCard(
                            title: 'Panel administrador',
                            subtitle: 'Monitores, reportes y estadísticas',
                            icon: Icons.shield_rounded,
                            color: _teal,
                            badge: 'ADMIN',
                            badgeColor: const Color(0x40FFFFFF),
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminPage())),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Bottom Nav ────────────────────────────────────────
                _buildBottomNav(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_rounded,
            iconColor: _orange,
            label: 'Horas hoy',
            value: '0',
            unit: 'hrs',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.event_available_rounded,
            iconColor: _violet,
            label: 'Esta semana',
            value: '0',
            unit: 'días',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              color: _ink,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.4,
            ),
            children: [
              TextSpan(text: 'Acciones '),
              TextSpan(
                text: 'rápidas',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D1A1A1A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(icon: Icons.home_rounded, active: true),
          _NavItem(icon: Icons.calendar_today_rounded),
          _NavItem(icon: Icons.fingerprint_rounded),
          _NavItem(icon: Icons.insert_chart_outlined_rounded),
          _NavItem(icon: Icons.settings_outlined),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final UserEntity user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final firstName = user.firstName;
    final role = user.role.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      color: _bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x2E7B6CF5),
              border: Border.all(color: const Color(0x597B6CF5), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: _violet, size: 26),
          ),
          const SizedBox(width: 14),

          // Nombre + rol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Hola, ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: _muted,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(text: '$firstName!'),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          // Notificaciones
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _cardWht,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x121A1A1A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: _ink, size: 20),
          ),
          const SizedBox(width: 8),

          // Logout
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => ctx.read<AuthBloc>().add(LogoutRequested()),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x401A1A1A),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final UserEntity user;
  const _HeroCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _violet,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x667B6CF5),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            right: -24,
            top: -36,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x127B6CF5),
              ),
            ),
          ),
          Positioned(
            right: 36,
            top: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x0FFFFFFF),
              ),
            ),
          ),
          // Contenido
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge estado
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x2EFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5A623),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sin jornada activa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'Comienza\ntu jornada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Registra tu entrada para comenzar',
                style: TextStyle(
                  color: Color(0xA6FFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // Botón CTA
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendancePage(user: user),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar entrada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardWht,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A1A1A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit,
                    style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x21FFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      )),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0x21FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _NavItem({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? _orange : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: active ? Colors.white : Colors.white54,
        size: 22,
      ),
    );
  }
}