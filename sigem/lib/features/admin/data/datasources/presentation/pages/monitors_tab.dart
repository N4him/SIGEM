import 'package:flutter/material.dart';
import 'package:sigem/core/api/service_locator.dart';
import 'package:sigem/features/admin/data/datasources/admin_remote_datasource.dart';


class MonitorsTab extends StatefulWidget {
  const MonitorsTab({super.key});

  @override
  State<MonitorsTab> createState() => _MonitorsTabState();
}

class _MonitorsTabState extends State<MonitorsTab> {
  late AdminRemoteDataSource _dataSource;
  List<Map<String, dynamic>> _monitors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = AdminRemoteDataSource(sl());
    _loadMonitors();
  }

  Future<void> _loadMonitors() async {
    setState(() => _loading = true);
    try {
      final monitors = await _dataSource.getMonitors();
      setState(() {
        _monitors = monitors;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Error al cargar monitores');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showCreateDialog() {
    final emailCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final password2Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear monitor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(controller: firstNameCtrl, label: 'Nombre'),
              const SizedBox(height: 12),
              _Field(controller: lastNameCtrl, label: 'Apellido'),
              const SizedBox(height: 12),
              _Field(controller: emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field(controller: phoneCtrl, label: 'Teléfono', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _Field(controller: passwordCtrl, label: 'Contraseña', obscure: true),
              const SizedBox(height: 12),
              _Field(controller: password2Ctrl, label: 'Confirmar contraseña', obscure: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dataSource.createMonitor(
                  email: emailCtrl.text.trim(),
                  firstName: firstNameCtrl.text.trim(),
                  lastName: lastNameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  password: passwordCtrl.text,
                  password2: password2Ctrl.text,
                );
                Navigator.pop(ctx);
                _loadMonitors();
                _showSuccess('Monitor creado exitosamente');
              } catch (e) {
                _showError(e.toString().replaceAll('Exception: ', ''));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> monitor) {
    final firstNameCtrl = TextEditingController(text: monitor['full_name']?.split(' ').first ?? '');
    final lastNameCtrl = TextEditingController(text: monitor['full_name']?.split(' ').last ?? '');
    final phoneCtrl = TextEditingController(text: monitor['phone'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar monitor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Field(controller: firstNameCtrl, label: 'Nombre'),
            const SizedBox(height: 12),
            _Field(controller: lastNameCtrl, label: 'Apellido'),
            const SizedBox(height: 12),
            _Field(controller: phoneCtrl, label: 'Teléfono', keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dataSource.updateMonitor(
                  userId: monitor['id'],
                  firstName: firstNameCtrl.text.trim(),
                  lastName: lastNameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                _loadMonitors();
                _showSuccess('Monitor actualizado');
              } catch (e) {
                _showError(e.toString().replaceAll('Exception: ', ''));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> monitor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar monitor'),
        content: Text('¿Estás seguro de borrar a ${monitor['full_name']}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dataSource.deleteMonitor(monitor['id']);
                Navigator.pop(ctx);
                _loadMonitors();
                _showSuccess('Monitor eliminado');
              } catch (e) {
                _showError(e.toString().replaceAll('Exception: ', ''));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo monitor'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _monitors.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No hay monitores registrados',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMonitors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _monitors.length,
                    itemBuilder: (context, index) {
                      final monitor = _monitors[index];
                      final isActive = monitor['is_active'] ?? true;
                      final totalHours = monitor['total_hours'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isActive
                                    ? const Color(0xFF1565C0)
                                    : Colors.grey.shade300,
                                child: Text(
                                  (monitor['full_name'] ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isActive ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      monitor['full_name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      monitor['email'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$totalHours h acumuladas',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFEBEE),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            isActive ? 'Activo' : 'Inactivo',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isActive
                                                  ? const Color(0xFF2E7D32)
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Acciones
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Color(0xFF1565C0)),
                                onPressed: () => _showEditDialog(monitor),
                                tooltip: 'Editar',
                              ),
                              Switch(
                                value: isActive,
                                activeColor: const Color(0xFF1565C0),
                                onChanged: (_) async {
                                  try {
                                    await _dataSource.toggleUserActive(monitor['id']);
                                    _loadMonitors();
                                  } catch (e) {
                                    _showError('Error al cambiar estado');
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _showDeleteDialog(monitor),
                                tooltip: 'Borrar',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}