import 'package:flutter/material.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../../../core/api/service_locator.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF5EDE0);
const _ink     = Color(0xFF1A1A1A);
const _cardWht = Color(0xFFFFFFFF);
const _violet  = Color(0xFF7B6CF5);
const _orange  = Color(0xFFFF8B4C);
const _dark    = Color(0xFF1C1C1E);
const _teal    = Color(0xFF1D7A6B);
const _green   = Color(0xFF3DC47E);
const _muted   = Color(0xFF9E9488);
const _red     = Color(0xFFE05252);
const _border  = Color(0xFFEDE8E0);
const _greenLight = Color(0xFFEAF3DE);
const _blue    = Color(0xFF2D7EFF);

class MyRecordsPage extends StatefulWidget {
  const MyRecordsPage({super.key});

  @override
State<MyRecordsPage> createState() => _MyRecordsPageState();}

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
      appBar: _buildAppBar(),
      body: FutureBuilder<List<AttendanceEntity>>(
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: _HeroStatsCard(
                  total: records.length,
                  hours: totalHours,
                  thisMonth: thisMonth,
                ),
              ),

              // ── Solo la lista tiene pull-to-refresh ───────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: _violet,
                  backgroundColor: _cardWht,
                  displacement: 20,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: records.length,
                    itemBuilder: (context, index) =>
                        _RecordCard(record: records[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── AppBar (sin flecha ni botón de refresh) ──────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      foregroundColor: _ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 20,
            color: _ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          children: [
            TextSpan(
              text: 'Mis ',
              style: TextStyle(fontWeight: FontWeight.w400, color: _muted),
            ),
            TextSpan(text: 'registros'),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

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
                    borderRadius: BorderRadius.circular(22),
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
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

  // ─── Error State ──────────────────────────────────────────────────────────

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
                borderRadius: BorderRadius.circular(22),
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
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
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
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 8),
                    Text(
                      'Reintentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: _violet,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _violet.withOpacity(0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            right: -20, top: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 30, top: 40,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // Contenido: título izquierda, stats derecha
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tu historial',
                      style: TextStyle(
                        color: Color(0x8DFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'de asistencia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Divisor vertical
              Container(
                width: 1,
                height: 78,
                color: Colors.white.withOpacity(0.18),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              // Stats: jornadas arriba, horas + este mes abajo
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Jornadas — protagonista
                  _BigStat(value: '$total', label: 'Jornadas'),
                  const SizedBox(height: 8),
                  Container(height: 1, width: 100, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 8),
                  // Horas y Este mes lado a lado
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallStat(value: hours.toStringAsFixed(1), label: 'Horas'),
                      Container(
                        width: 1, height: 28,
                        color: Colors.white.withOpacity(0.15),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      _SmallStat(value: '$thisMonth', label: 'Este mes'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Big Stat (jornadas — protagonista) ──────────────────────────────────────

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0x8DFFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Small Stat (horas / este mes) ────────────────────────────────────────────

class _SmallStat extends StatelessWidget {
  final String value;
  final String label;
  const _SmallStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0x8DFFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
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

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isOpen = record.isOpen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardWht,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fecha + badge ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(record.checkIn),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? _green : _border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? 'EN CURSO' : 'CERRADA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isOpen ? Colors.white : _muted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Sala ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _muted.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.meeting_room_rounded,
                    size: 12, color: _muted),
              ),
              const SizedBox(width: 6),
              Text(
                record.roomName,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: _border),
          const SizedBox(height: 14),

          // ── Chips de tiempo + horas ────────────────────────────────────
          Row(
            children: [
              _TimeChip(
                icon: Icons.login_rounded,
                label: 'Entrada',
                time: _formatTime(record.checkIn),
                color: _blue,
              ),
              if (record.checkOut != null) ...[
                const SizedBox(width: 8),
                _TimeChip(
                  icon: Icons.logout_rounded,
                  label: 'Salida',
                  time: _formatTime(record.checkOut!),
                  color: _teal,
                ),
              ],
              const Spacer(),
              if (record.hoursWorked != null)
                _HoursChip(
                  value: record.hoursWorked!.toStringAsFixed(2),
                  isOpen: false,
                )
              else if (isOpen)
                _HoursChip(value: '', isOpen: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Time Chip ────────────────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hours Chip ───────────────────────────────────────────────────────────────

class _HoursChip extends StatelessWidget {
  final String value;
  final bool isOpen;

  const _HoursChip({required this.value, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen ? _orange.withOpacity(0.12) : _greenLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isOpen ? Icons.timelapse_rounded : Icons.access_time_rounded,
            size: 11,
            color: isOpen ? _orange : const Color(0xFF1A9B55),
          ),
          const SizedBox(height: 3),
          Text(
            isOpen ? 'En curso' : '$value h',
            style: TextStyle(
              fontSize: isOpen ? 11 : 14,
              fontWeight: FontWeight.w800,
              color: isOpen ? _orange : const Color(0xFF1A9B55),
              letterSpacing: -0.2,
            ),
          ),
        ],
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