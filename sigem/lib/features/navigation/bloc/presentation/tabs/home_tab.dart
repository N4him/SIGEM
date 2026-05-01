import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigem/core/api/api_client.dart';
import 'package:sigem/core/api/service_locator.dart';
import 'package:sigem/core/constants/api_constants.dart';
import 'package:sigem/features/admin/data/datasources/presentation/pages/admin_page.dart';
import 'package:sigem/features/attendance/presentation/pages/attendance_page.dart';
import 'package:sigem/features/auth/domain/entities/user_entity.dart';
import 'package:sigem/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sigem/features/auth/presentation/bloc/auth_event.dart';
import 'package:sigem/features/auth/presentation/bloc/auth_state.dart';
import 'package:sigem/features/auth/presentation/pages/login_page.dart';

const _bg      = Color(0xFFF5EDE0);
const _ink     = Color(0xFF1A1A1A);
const _cardWht = Color(0xFFFFFFFF);
const _violet  = Color(0xFF7B6CF5);
const _orange  = Color(0xFFFF8B4C);
const _dark    = Color(0xFF1C1C1E);
const _teal    = Color(0xFF1D7A6B);
const _muted   = Color(0xFF9E9488);

class HomeTab extends StatelessWidget {
  final UserEntity user;
  const HomeTab({super.key, required this.user});

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
        child: SizedBox.expand(
          child: Scaffold(
            backgroundColor: _bg,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _Header(user: user),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroCard(user: user),
                          const SizedBox(height: 24),
                          _buildSectionLabel('Tu Resumen', 'semanal'),
                          const SizedBox(height: 14),
                          const _WeeklySummaryCard(),
                          if (user.isAdmin) ...[
                            const SizedBox(height: 24),
                            _buildSectionLabel('Panel', 'administrador'),
                            const SizedBox(height: 14),
                            _ActionCard(
                              title: 'Panel administrador',
                              subtitle: 'Monitores, reportes y estadísticas',
                              icon: Icons.shield_rounded,
                              color: _teal,
                              badge: 'ADMIN',
                              badgeColor: const Color(0x40FFFFFF),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminPage(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildSectionLabel(String normal, String bold) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          color: _ink,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
        ),
        children: [
          TextSpan(text: '$normal '),
          TextSpan(
            text: bold,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Summary Card ──────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatefulWidget {
  const _WeeklySummaryCard();

  @override
  State<_WeeklySummaryCard> createState() => _WeeklySummaryCardState();
}

class _WeeklySummaryCardState extends State<_WeeklySummaryCard> {
  List<Map<String, dynamic>> _days = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final client = sl<ApiClient>();
      final response = await client.get(ApiConstants.weeklySummary);
      final days = List<Map<String, dynamic>>.from(response.data['days']);
      setState(() {
        _days = days;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: _cardWht,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_violet),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final maxHours = _days.isEmpty
        ? 8.0
        : _days
            .map((d) => (d['hours'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxHours < 1 ? 8.0 : maxHours;
    final totalHours =
        _days.fold(0.0, (sum, d) => sum + (d['hours'] as num).toDouble());
    final workedDays = _days.where((d) => (d['hours'] as num) > 0).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: _cardWht,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A1A1A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: totalHours.toStringAsFixed(1),
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                        ),
                        const TextSpan(
                          text: ' hrs',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _violet.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$workedDays / 5 días',
                  style: const TextStyle(
                    color: _violet,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _days.map((d) {
              final hours = (d['hours'] as num).toDouble();
              final ratio = hours / effectiveMax;
              final isToday = d['is_today'] as bool;
              final absent = hours == 0;
              return _DayBar(
                day: d['day'],
                hours: hours,
                ratio: ratio,
                absent: absent,
                isToday: isToday,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Day Bar ─────────────────────────────────────────────────────────────────

class _DayBar extends StatelessWidget {
  final String day;
  final double hours;
  final double ratio;
  final bool absent;
  final bool isToday;

  const _DayBar({
    required this.day,
    required this.hours,
    required this.ratio,
    required this.absent,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    const trackHeight = 140.0;

    final barColor = absent
        ? Colors.transparent
        : isToday
            ? _orange
            : _violet;

    return SizedBox(
      width: 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
            child: Text(
              absent ? '' : '${hours.toStringAsFixed(1)}h',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isToday ? _violet : _muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 26,
              height: trackHeight,
              child: Stack(
                children: [
                  Container(
                    width: 26,
                    height: trackHeight,
                    color: const Color(0xFFF0EBE3),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: absent ? 0 : ratio.clamp(0.0, 1.0),
                      ),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Container(
                          width: 26,
                          height: trackHeight * value,
                          decoration: BoxDecoration(
                            color: barColor,
                            boxShadow: !absent
                                ? [
                                    BoxShadow(
                                      color: barColor.withOpacity(0.40),
                                      blurRadius: 8,
                                      offset: const Offset(0, -2),
                                    ),
                                  ]
                                : [],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 26,
            child: Center(
              child: isToday
                  ? Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x55FF8B4C),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      day,
                      style: TextStyle(
                        color: absent ? const Color(0xFFCCC5BC) : _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      color: _bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 26,
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
                          fontSize: 30,
                        ),
                      ),
                      TextSpan(text: '$firstName!'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 17,
                ),
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
      height: 300,                            // FIX 1: Stack necesita altura acotada
      decoration: BoxDecoration(
        color: _violet,
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: AssetImage('assets/images/hero_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x667B6CF5),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Círculos decorativos ─────────────────────────────
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

          // FIX 2: Positioned.fill da constraints acotados a la Column
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,   // FIX 3: no expande al infinito
                children: [
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
                  const Text(
                    'Registra para \ncomenzar tu\nmonitoria',
                    style: TextStyle(
                      color: Color(0xA6FFFFFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                 
                  // FIX 4: GestureDetector con child (antes estaba vacío)
                ],
              ),
            ),
          ),
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
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