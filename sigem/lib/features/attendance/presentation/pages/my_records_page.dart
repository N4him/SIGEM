import 'package:flutter/material.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../../core/api/service_locator.dart';

const _bg           = Color(0xFFF5EDE0);
const _ink          = Color(0xFF1A1A1A);
const _cardWht      = Color(0xFFFFFFFF);
const _violet       = Color(0xFF534AB7);
const _violetText   = Color(0xFFFFFFFF);
const _violetMuted  = Color(0xFFAFA9EC);
const _violetSubtle = Color(0xFFCECBF6);
const _violetDiv    = Color(0x1FFFFFFF);
const _muted        = Color(0xFF9E9488);
const _red          = Color(0xFFE05252);
const _border       = Color(0xFFEDE8E0);
const _green        = Color(0xFF3B6D11);
const _greenBg      = Color(0xFFEAF3DE);
const _teal         = Color(0xFF0F6E56);
const _blue         = Color(0xFF185FA5);

class MyRecordsPage extends StatefulWidget {
  const MyRecordsPage({super.key});

  @override
  State<MyRecordsPage> createState() => _MyRecordsPageState();
}

class _MyRecordsPageState extends State<MyRecordsPage> {
  late Future<List<AttendanceEntity>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    final dataSource = AttendanceRemoteDataSource(sl());
    _recordsFuture = dataSource.getMyRecords();
  }

  Future<void> _refresh() async {
    setState(() => _loadRecords());
    await _recordsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FutureBuilder<List<AttendanceEntity>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_violet),
                  strokeWidth: 2.5,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            final records = snapshot.data ?? [];
            if (records.isEmpty) return _buildEmpty();

            final totalHours = records
                .where((r) => r.hoursWorked != null)
                .fold(0.0, (sum, r) => sum + (r.hoursWorked ?? 0));

            final thisMonth = records
                .where((r) => r.checkIn.month == DateTime.now().month)
                .length;

            return RefreshIndicator(
              onRefresh: _refresh,
              color: _violet,
              backgroundColor: _cardWht,
              displacement: 20,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Título sin eyebrow de mes ─────────────────
                          const Text(
                            'Mis registros',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${records.length} jornadas en total',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Hero card con color violeta ────────────────
                          _HeroStatsCard(
                            total: records.length,
                            hours: totalHours,
                            thisMonth: thisMonth,
                          ),
                          const SizedBox(height: 24),

                          // ── Etiqueta historial ────────────────────────
                          const Text(
                            'HISTORIAL',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _RecordCard(record: records[index]),
                        childCount: records.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: _violet,
      backgroundColor: _cardWht,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _violet.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      size: 32, color: _violet),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sin registros aún',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tus jornadas aparecerán aquí',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: _red),
            ),
            const SizedBox(height: 18),
            const Text(
              'Algo salió mal',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _loadRecords()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Reintentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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

// ─── Hero Stats Card ──────────────────────────────────────────────────────────

class _HeroStatsCard extends StatelessWidget {
  final int total;
  final double hours;
  final int thisMonth;

  const _HeroStatsCard({
    required this.total,
    required this.hours,
    required this.thisMonth,
  });

  String _currentMonthYear() {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1].toUpperCase()} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: _violet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eyebrow: mes actual (dentro de la card) ───────────────────
          Text(
            _currentMonthYear(),
            style: const TextStyle(
              color: _violetMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Total jornadas',
            style: TextStyle(
              color: _violetSubtle,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          // ── Número grande ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  color: _violetText,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'jornadas',
                style: TextStyle(
                  color: _violetMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Divisor ───────────────────────────────────────────────────
          const Divider(color: _violetDiv, height: 1, thickness: 1),

          const SizedBox(height: 14),

          // ── Dos métricas ──────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    label: 'Horas trabajadas',
                    value: hours.toStringAsFixed(1),
                    unit: 'h',
                  ),
                ),
                const VerticalDivider(
                  color: _violetDiv,
                  width: 32,
                  thickness: 1,
                ),
                Expanded(
                  child: _HeroStat(
                    label: 'Este mes',
                    value: '$thisMonth',
                    unit: 'jornadas',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _violetMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: _violetText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _violetMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Record Card ──────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final AttendanceEntity record;
  const _RecordCard({required this.record});

  String _formatDate(DateTime dt) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

  @override
  Widget build(BuildContext context) {
    final isOpen = record.isOpen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardWht,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          // ── Encabezado ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(record.checkIn),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.roomName,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isOpen ? _greenBg : _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOpen) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        isOpen ? 'En curso' : 'Cerrada',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOpen ? _green : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divisor ───────────────────────────────────────────────────
          const Divider(color: _border, height: 1, thickness: 1),

          // ── Cuerpo: entrada | salida | duración ───────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _TimeBlock(
                    label: 'Entrada',
                    value: _formatTime(record.checkIn),
                    valueColor: _blue,
                  ),
                ),
                const VerticalDivider(color: _border, width: 1, thickness: 1),
                Expanded(
                  child: _TimeBlock(
                    label: 'Salida',
                    value: record.checkOut != null
                        ? _formatTime(record.checkOut!)
                        : '—',
                    valueColor: record.checkOut != null ? _teal : _muted,
                    dimmed: record.checkOut == null,
                  ),
                ),
                const VerticalDivider(color: _border, width: 1, thickness: 1),
                Expanded(
                  child: _DurationBlock(
                    hours: record.hoursWorked,
                    isOpen: isOpen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Time Block ───────────────────────────────────────────────────────────────

class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool dimmed;

  const _TimeBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: dimmed ? 14 : 16,
              fontWeight: dimmed ? FontWeight.w400 : FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Duration Block ───────────────────────────────────────────────────────────

class _DurationBlock extends StatelessWidget {
  final double? hours;
  final bool isOpen;

  const _DurationBlock({required this.hours, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DURACIÓN',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          isOpen
              ? const Text(
                  'En curso',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(text: hours?.toStringAsFixed(2) ?? '—'),
                      const TextSpan(
                        text: ' h',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}