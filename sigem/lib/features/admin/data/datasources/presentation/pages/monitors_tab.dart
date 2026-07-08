import 'package:flutter/material.dart';
import 'package:sigem/core/api/service_locator.dart';
import 'package:sigem/features/admin/data/datasources/admin_remote_datasource.dart';

// ─── Paleta ───────────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF5EDE0);
const _ink     = Color(0xFF1A1A1A);
const _violet  = Color(0xFF7B6CF5);
const _teal    = Color(0xFF1D7A6B);
const _orange  = Color(0xFFFF8B4C);
const _muted   = Color(0xFF9E9488);
const _cardWht = Color(0xFFFFFFFF);
const _border  = Color(0xFFEDE8E0);
const _fieldBg = Color(0xFFFAFAF8);

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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Diálogo base ──────────────────────────────────────────────────────────
  Future<void> _showStyledDialog({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget content,
    required String confirmLabel,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _cardWht,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del diálogo
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.07),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: content,
              ),
              // Acciones
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF0EBE3),
                            foregroundColor: _muted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            await onConfirm();
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final emailCtrl     = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl  = TextEditingController();
    final phoneCtrl     = TextEditingController();
    final passwordCtrl  = TextEditingController();
    final password2Ctrl = TextEditingController();

    _showStyledDialog(
      title: 'Nuevo monitor',
      subtitle: 'Completa los datos del monitor',
      icon: Icons.person_add_rounded,
      iconColor: _violet,
      confirmLabel: 'Crear',
      confirmColor: _violet,
      content: Column(
        children: [
          _StyledField(controller: firstNameCtrl, label: 'Nombre', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _StyledField(controller: lastNameCtrl, label: 'Apellido', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _StyledField(controller: emailCtrl, label: 'Correo electrónico', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _StyledField(controller: phoneCtrl, label: 'Teléfono', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _StyledField(controller: passwordCtrl, label: 'Contraseña', icon: Icons.lock_outline_rounded, obscure: true),
          const SizedBox(height: 12),
          _StyledField(controller: password2Ctrl, label: 'Confirmar contraseña', icon: Icons.lock_outline_rounded, obscure: true),
          const SizedBox(height: 4),
        ],
      ),
      onConfirm: () async {
        await _dataSource.createMonitor(
          email: emailCtrl.text.trim(),
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          password: passwordCtrl.text,
          password2: password2Ctrl.text,
        );
        _loadMonitors();
        _showSuccess('Monitor creado exitosamente');
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> monitor) {
    final firstNameCtrl = TextEditingController(text: monitor['full_name']?.split(' ').first ?? '');
    final lastNameCtrl  = TextEditingController(text: monitor['full_name']?.split(' ').last ?? '');
    final phoneCtrl     = TextEditingController(text: monitor['phone'] ?? '');

    _showStyledDialog(
      title: 'Editar monitor',
      subtitle: monitor['full_name'] ?? '',
      icon: Icons.edit_rounded,
      iconColor: _teal,
      confirmLabel: 'Guardar',
      confirmColor: _teal,
      content: Column(
        children: [
          _StyledField(controller: firstNameCtrl, label: 'Nombre', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _StyledField(controller: lastNameCtrl, label: 'Apellido', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _StyledField(controller: phoneCtrl, label: 'Teléfono', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 4),
        ],
      ),
      onConfirm: () async {
        await _dataSource.updateMonitor(
          userId: monitor['id'],
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
        );
        _loadMonitors();
        _showSuccess('Monitor actualizado');
      },
    );
  }

  void _showDeleteDialog(Map<String, dynamic> monitor) {
    _showStyledDialog(
      title: 'Eliminar monitor',
      subtitle: 'Esta acción no se puede deshacer',
      icon: Icons.delete_rounded,
      iconColor: Colors.redAccent,
      confirmLabel: 'Eliminar',
      confirmColor: Colors.redAccent,
      content: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar a '),
              TextSpan(
                text: monitor['full_name'] ?? '',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
      ),
      onConfirm: () async {
        await _dataSource.deleteMonitor(monitor['id']);
        _loadMonitors();
        _showSuccess('Monitor eliminado');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        elevation: 0,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text(
          'Nuevo monitor',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_violet),
                strokeWidth: 2,
              ),
            )
          : _monitors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _cardWht,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          size: 32,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sin monitores registrados',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Crea el primero con el botón de abajo',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMonitors,
                  color: _violet,
                  backgroundColor: _cardWht,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: _monitors.length,
                    itemBuilder: (context, index) {
                      final monitor = _monitors[index];
                      final isActive = monitor['is_active'] ?? true;
                      final totalHours = monitor['total_hours'] ?? 0;
                      final name = monitor['full_name'] ?? '?';
                      final initial = name[0].toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _violet.withOpacity(0.12)
                                      : const Color(0xFFF0EBE3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color: isActive ? _violet : _muted,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: _ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      monitor['email'] ?? '',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? _teal.withOpacity(0.10)
                                                : Colors.redAccent.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isActive ? 'Activo' : 'Inactivo',
                                            style: TextStyle(
                                              color: isActive ? _teal : Colors.redAccent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.access_time_rounded,
                                            size: 13, color: _muted),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${totalHours}h',
                                          style: const TextStyle(
                                            color: _muted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Acciones
                              Column(
                                children: [
                                  _ActionButton(
                                    icon: Icons.edit_rounded,
                                    color: _violet,
                                    onTap: () => _showEditDialog(monitor),
                                  ),
                                  const SizedBox(height: 6),
                                  _ActionButton(
                                    icon: Icons.delete_rounded,
                                    color: Colors.redAccent,
                                    onTap: () => _showDeleteDialog(monitor),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              // Switch
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: isActive,
                                  activeColor: _teal,
                                  inactiveThumbColor: _muted,
                                  inactiveTrackColor:
                                      const Color(0xFFEDE8E0),
                                  onChanged: (_) async {
                                    try {
                                      await _dataSource
                                          .toggleUserActive(monitor['id']);
                                      _loadMonitors();
                                    } catch (e) {
                                      _showError('Error al cambiar estado');
                                    }
                                  },
                                ),
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

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _ink, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: _muted),
        filled: true,
        fillColor: _fieldBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _violet, width: 1.5),
        ),
      ),
    );
  }
}