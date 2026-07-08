import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigem/core/api/service_locator.dart';
import 'package:sigem/core/storage/token_storage.dart';
import 'package:sigem/features/admin/data/datasources/admin_remote_datasource.dart';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'package:sigem/core/utils/web_utils.dart'
    if (dart.library.io) 'package:sigem/core/utils/web_utils_stub.dart';

// ─── Paleta ───────────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF5EDE0);
const _ink     = Color(0xFF1A1A1A);
const _violet  = Color(0xFF7B6CF5);
const _teal    = Color(0xFF1D7A6B);
const _orange  = Color(0xFFFF8B4C);
const _muted   = Color(0xFF9E9488);
const _cardWht = Color(0xFFFFFFFF);
const _border  = Color(0xFFEDE8E0);

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  late AdminRemoteDataSource _dataSource;
  List<Map<String, dynamic>> _records = [];
  bool _loading = false;
  String _selectedFilter = 'all';
  DateTime? _fromDate;
  DateTime? _toDate;
  double _totalHoras = 0;
  int _total = 0;

  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _monitors = [];
  int? _selectedRoomId;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _dataSource = AdminRemoteDataSource(sl());
    _loadFilterOptions();
    _loadReports();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final data = await _dataSource.getFilterOptions();
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(data['rooms'] ?? []);
        _monitors = List<Map<String, dynamic>>.from(data['monitors'] ?? []);
      });
    } catch (_) {}
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final data = await _dataSource.getReports(
        filter: _selectedFilter,
        fromDate: _fromDate?.toIso8601String().split('T').first,
        toDate: _toDate?.toIso8601String().split('T').first,
        roomId: _selectedRoomId,
        userId: _selectedUserId,
      );
      setState(() {
        _records = List<Map<String, dynamic>>.from(data['records'] ?? []);
        _totalHoras = (data['total_horas'] ?? 0).toDouble();
        _total = data['total'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _violet,
            onPrimary: Colors.white,
            surface: _cardWht,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _fromDate = picked;
        else _toDate = picked;
        _selectedFilter = 'custom';
      });
      _loadReports();
    }
  }

  Future<void> _exportCsv() async {
    try {
      final token = await TokenStorage.getAccessToken();
      String url = 'https://eiscapp.univalle.edu.co/sigem/api/admin/reports/?export=csv&filter=$_selectedFilter';
      if (_fromDate != null) url += '&from=${_fromDate!.toIso8601String().split('T').first}';
      if (_toDate != null) url += '&to=${_toDate!.toIso8601String().split('T').first}';
      if (_selectedRoomId != null) url += '&room_id=$_selectedRoomId';
      if (_selectedUserId != null) url += '&user_id=$_selectedUserId';

      final response = await Dio().get(
       url,
       options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.bytes,
      ),
    );

    if (response.data is String &&
        response.data.toString().startsWith('<')) {
      throw Exception("El servidor devolvió HTML en lugar de CSV");
    }
      final bytes = Uint8List.fromList(response.data as List<int>);
      if (kIsWeb) downloadCsv(bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'all';
      _fromDate = null;
      _toDate = null;
      _selectedRoomId = null;
      _selectedUserId = null;
    });
    _loadReports();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Panel de filtros ─────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _cardWht,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A1A1A1A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros rápidos
              Row(
                children: [
                  _QuickFilter(label: 'Todos',   value: 'all',     current: _selectedFilter, onTap: _setFilter),
                  const SizedBox(width: 8),
                  _QuickFilter(label: 'Semanal', value: 'weekly',  current: _selectedFilter, onTap: _setFilter),
                  const SizedBox(width: 8),
                  _QuickFilter(label: 'Mensual', value: 'monthly', current: _selectedFilter, onTap: _setFilter),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: _muted),
                          SizedBox(width: 4),
                          Text('Limpiar',
                              style: TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Rango de fechas + exportar
              Row(
                children: [
                  Expanded(child: _DateButton(date: _fromDate, hint: 'Desde', onTap: () => _pickDate(true))),
                  const SizedBox(width: 8),
                  Expanded(child: _DateButton(date: _toDate, hint: 'Hasta', onTap: () => _pickDate(false))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _exportCsv,
                    child: Container(
                      width: 44,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.download_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filtro sala
              _StyledDropdown<int?>(
                value: _selectedRoomId,
                icon: Icons.meeting_room_outlined,
                hint: 'Todas las salas',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas las salas')),
                  ..._rooms.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['name']))),
                ],
                onChanged: (v) {
                  setState(() => _selectedRoomId = v);
                  _loadReports();
                },
              ),
              const SizedBox(height: 10),

              // Filtro monitor
              _StyledDropdown<String?>(
                value: _selectedUserId,
                icon: Icons.person_outline_rounded,
                hint: 'Todos los monitores',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos los monitores')),
                  ..._monitors.map((m) => DropdownMenuItem(value: m['id'] as String, child: Text(m['name']))),
                ],
                onChanged: (v) {
                  setState(() => _selectedUserId = v);
                  _loadReports();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Tarjetas de resumen ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Registros',
                  value: '$_total',
                  icon: Icons.list_alt_rounded,
                  color: _violet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Horas totales',
                  value: _totalHoras.toStringAsFixed(1),
                  icon: Icons.access_time_rounded,
                  color: _orange,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Lista ────────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_violet),
                    strokeWidth: 2,
                  ),
                )
              : _records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bar_chart_rounded,
                              size: 44, color: _muted),
                          SizedBox(height: 12),
                          Text('Sin registros para este período',
                              style:
                                  TextStyle(color: _muted, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _cardWht,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x081A1A1A),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Foto o placeholder
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: record['foto'] != null &&
                                        record['foto'].isNotEmpty
                                    ? Image.network(
                                        record['foto'],
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _PhotoPlaceholder(),
                                      )
                                    : _PhotoPlaceholder(),
                              ),
                              const SizedBox(width: 14),
                              // Datos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['monitor'] ?? '',
                                      style: const TextStyle(
                                        color: _ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${record['sala']}  ·  ${record['fecha']}',
                                      style: const TextStyle(
                                          color: _muted, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.login_rounded,
                                            size: 12,
                                            color: _teal),
                                        const SizedBox(width: 3),
                                        Text(
                                          record['entrada'] ?? '',
                                          style: const TextStyle(
                                              color: _teal,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.logout_rounded,
                                            size: 12, color: _muted),
                                        const SizedBox(width: 3),
                                        Text(
                                          record['salida'] ?? '',
                                          style: const TextStyle(
                                              color: _muted,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Badge horas
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _violet.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${record['horas']}h',
                                  style: const TextStyle(
                                    color: _violet,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _setFilter(String value) {
    setState(() {
      _selectedFilter = value;
      _fromDate = null;
      _toDate = null;
    });
    _loadReports();
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFFF0EBE3),
      child: const Icon(Icons.no_photography_outlined,
          color: _muted, size: 20),
    );
  }
}

class _QuickFilter extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _QuickFilter({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _ink : const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTime? date;
  final String hint;
  final VoidCallback onTap;

  const _DateButton({
    required this.date,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: _muted),
            const SizedBox(width: 7),
            Text(
              date != null
                  ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}'
                  : hint,
              style: TextStyle(
                color: date != null ? _ink : _muted,
                fontSize: 13,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final IconData icon;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.icon,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: _cardWht,
      style: const TextStyle(color: _ink, fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: _muted),
        filled: true,
        fillColor: const Color(0xFFF0EBE3),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _violet, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _cardWht,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1A1A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}