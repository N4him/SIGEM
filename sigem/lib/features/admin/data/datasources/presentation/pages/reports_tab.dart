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

  // Filtros por sala y monitor
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
    } catch (e) {
      // silencioso
    }
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
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _selectedFilter = 'custom';
      });
      _loadReports();
    }
  }

  Future<void> _exportCsv() async {
    try {
      final token = await TokenStorage.getAccessToken();
      String url = 'http://127.0.0.1:8000/api/admin/reports/?export=csv&filter=$_selectedFilter';
      if (_fromDate != null) {
        url += '&from=${_fromDate!.toIso8601String().split('T').first}';
      }
      if (_toDate != null) {
        url += '&to=${_toDate!.toIso8601String().split('T').first}';
      }
      if (_selectedRoomId != null) {
        url += '&room_id=$_selectedRoomId';
      }
      if (_selectedUserId != null) {
        url += '&user_id=$_selectedUserId';
      }

      final response = await Dio().get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      final bytes = Uint8List.fromList(response.data as List<int>);

      if (kIsWeb) {
  downloadCsv(bytes);
}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtros
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros rápidos de tiempo
              Row(
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _selectedFilter == 'all',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'all';
                        _fromDate = null;
                        _toDate = null;
                      });
                      _loadReports();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Semanal',
                    selected: _selectedFilter == 'weekly',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'weekly';
                        _fromDate = null;
                        _toDate = null;
                      });
                      _loadReports();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Mensual',
                    selected: _selectedFilter == 'monthly',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'monthly';
                        _fromDate = null;
                        _toDate = null;
                      });
                      _loadReports();
                    },
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rango de fechas
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _fromDate != null
                                  ? _formatDate(_fromDate!)
                                  : 'Desde',
                              style: TextStyle(
                                color: _fromDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _toDate != null
                                  ? _formatDate(_toDate!)
                                  : 'Hasta',
                              style: TextStyle(
                                color: _toDate != null
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.download),
                    tooltip: 'Exportar CSV',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filtro por sala
              DropdownButtonFormField<int?>(
                value: _selectedRoomId,
                decoration: InputDecoration(
                  labelText: 'Filtrar por sala',
                  prefixIcon: const Icon(Icons.room, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Todas las salas')),
                  ..._rooms.map((room) => DropdownMenuItem(
                        value: room['id'] as int,
                        child: Text(room['name']),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedRoomId = value);
                  _loadReports();
                },
              ),
              const SizedBox(height: 12),

              // Filtro por monitor
              DropdownButtonFormField<String?>(
                value: _selectedUserId,
                decoration: InputDecoration(
                  labelText: 'Filtrar por monitor',
                  prefixIcon: const Icon(Icons.person, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Todos los monitores')),
                  ..._monitors.map((monitor) => DropdownMenuItem(
                        value: monitor['id'] as String,
                        child: Text(monitor['name']),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedUserId = value);
                  _loadReports();
                },
              ),
            ],
          ),
        ),

        // Resumen
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Total registros',
                value: '$_total',
                icon: Icons.list_alt,
              ),
              _StatItem(
                label: 'Horas totales',
                value: _totalHoras.toStringAsFixed(1),
                icon: Icons.access_time,
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _records.isEmpty
                  ? const Center(
                      child: Text('No hay registros para este período',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (record['foto'] != null &&
                                  record['foto'].isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    record['foto'],
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey),
                                  ),
                                )
                              else
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.no_photography,
                                      color: Colors.grey, size: 20),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(record['monitor'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${record['sala']} — ${record['fecha']}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                    Text(
                                        '${record['entrada']} → ${record['salida']}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${record['horas']}h',
                                  style: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}