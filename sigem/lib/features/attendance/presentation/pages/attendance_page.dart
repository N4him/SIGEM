import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../data/models/room_model.dart';
import '../../../../core/api/service_locator.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

const _bg     = Color(0xFFF5EDE0);
const _card   = Color(0xFFFFFFFF);
const _ink    = Color(0xFF1A1A1A);
const _muted  = Color(0xFF9E9488);
const _border = Color(0xFFEDE5D8);
const _violet = Color(0xFF7B6CF5);
const _orange = Color(0xFFFF8B4C);
const _teal   = Color(0xFF1D7A6B);
const _red    = Color(0xFFE05252);
const _green  = Color(0xFF3DC47E);
const _dark   = Color(0xFF1C1C1E);

class AttendancePage extends StatefulWidget {
  final UserEntity user;
  const AttendancePage({super.key, required this.user});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with TickerProviderStateMixin {
  File? _photo;
  Position? _position;
  bool _hasOpenRecord = false;
  String _statusText = 'Sin jornada activa';
  bool _loadingInitial = true;

  List<RoomModel> _rooms = [];
  RoomModel? _selectedRoom;
  bool _loadingRooms = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_checkOpenRecord(), _loadRooms()]);
  }

  Future<void> _loadRooms() async {
    try {
      final dataSource = RoomRemoteDataSource(sl());
      final rooms = await dataSource.getRooms();
      setState(() {
        _rooms = rooms;
        if (rooms.isNotEmpty) _selectedRoom = rooms.first;
        _loadingRooms = false;
      });
    } catch (e) {
      setState(() => _loadingRooms = false);
    }
  }

  Future<void> _checkOpenRecord() async {
    try {
      final dataSource = AttendanceRemoteDataSource(sl());
      final records = await dataSource.getMyRecords();
      final openRecord = records.where((r) => r.isOpen).toList();
      setState(() {
        _hasOpenRecord = openRecord.isNotEmpty;
        if (_hasOpenRecord) {
          _statusText = 'Activa desde ${_formatTime(openRecord.first.checkIn)}';
        }
        _loadingInitial = false;
      });
    } catch (e) {
      setState(() => _loadingInitial = false);
    }
  }

  Future<void> _getLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) { _showError('Permiso de ubicación denegado'); return; }
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _position = position);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) { _showError('Permiso de cámara denegado'); return; }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1280);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: _red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: _teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loadingInitial || _loadingRooms
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_violet),
                          strokeWidth: 2.5,
                        ),
                      )
                    : BlocConsumer<AttendanceBloc, AttendanceState>(
                        listener: (context, state) {
                          if (state is CheckInSuccess) {
                            setState(() {
                              _hasOpenRecord = true;
                              _statusText = 'Activa desde ${_formatTime(state.record.checkIn)}';
                              _position = null;
                            });
                            _showSuccess('Check-in registrado exitosamente');
                          } else if (state is CheckOutSuccess) {
                            setState(() {
                              _hasOpenRecord = false;
                              _statusText = 'Sin jornada activa';
                              _position = null;
                              _photo = null;
                            });
                            _showSuccess('Check-out registrado. Horas: ${state.record.hoursWorked?.toStringAsFixed(2) ?? '0'}');
                          } else if (state is AttendanceError) {
                            _showError(state.message);
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AttendanceLoading;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeroCard(),
                                const SizedBox(height: 32),
                                if (!_hasOpenRecord) ...[
                                  _buildRoadmap(context),
                                  const SizedBox(height: 32),
                                  _buildCheckinButton(context, isLoading),
                                ] else ...[
                                  _buildCheckoutRoadmap(context),
                                  const SizedBox(height: 32),
                                  _buildCheckoutButton(context, isLoading),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final isActive = _hasOpenRecord;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: _bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: const Text(
              'Asistencia',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -0.6),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? _teal : _dark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? _teal : _dark).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Container(
                    width: isActive ? 8 * _pulseAnim.value + 2 : 8,
                    height: isActive ? 8 * _pulseAnim.value + 2 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? _green : _orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'EN CURSO' : 'LIBRE',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Card ────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    final isActive = _hasOpenRecord;
    final heroColor = isActive ? _teal : _dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
      decoration: BoxDecoration(
        color: heroColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: heroColor.withOpacity(0.45),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -50,
            child: Container(
              width: 200, height: 200,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x0FFFFFFF)),
            ),
          ),
          Positioned(
            right: 50, top: 80,
            child: Container(
              width: 110, height: 110,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x08FFFFFF)),
            ),
          ),
          Positioned(
            left: -20, bottom: -30,
            child: Container(
              width: 130, height: 130,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x07FFFFFF)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? '● Jornada en progreso' : '○ Sin jornada activa',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isActive ? 'Jornada\nen curso' : 'Registra\ntu jornada',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isActive
                    ? _statusText
                    : 'Selecciona tu sala y comparte\ntu ubicación para comenzar',
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Roadmap Check-in ─────────────────────────────────────────────────────

  Widget _buildRoadmap(BuildContext context) {
    final step1Done = _selectedRoom != null;
    final step2Done = _position != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: _ink, fontWeight: FontWeight.w400, letterSpacing: -0.4),
            children: [
              TextSpan(text: 'Registrar '),
              TextSpan(text: 'entrada', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _RoadmapDot(done: step1Done, color: _violet),
                _RoadmapLine(done: step1Done),
                _RoadmapDot(done: step2Done, color: _teal),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _RoadmapCard(
                    title: 'Seleccionar sala',
                    subtitle: step1Done
                        ? _selectedRoom!.name
                        : 'Elige el espacio donde vas a trabajar hoy',
                    icon: Icons.meeting_room_rounded,
                    color: _violet,
                    done: step1Done,
                    onTap: () => _showRoomBottomSheet(context),
                  ),
                  const SizedBox(height: 16),
                  _RoadmapCard(
                    title: 'Ubicación GPS',
                    subtitle: step2Done
                        ? '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                        : 'Confirma que estás en el lugar de trabajo',
                    icon: Icons.my_location_rounded,
                    color: _teal,
                    done: step2Done,
                    onTap: _getLocation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Botón Check-in (centrado, fuera del roadmap) ─────────────────────────

  Widget _buildCheckinButton(BuildContext context, bool isLoading) {
    final allDone = _selectedRoom != null && _position != null;
    return _PrimaryButton(
      label: 'Registrar entrada',
      icon: Icons.login_rounded,
      color: _dark,
      accentColor: _orange,
      enabled: !isLoading && allDone,
      isLoading: isLoading,
      onPressed: () {
        context.read<AttendanceBloc>().add(CheckInRequested(
          roomId: _selectedRoom!.id,
          latitude: _position!.latitude,
          longitude: _position!.longitude,
        ));
      },
    );
  }

  // ─── Roadmap Check-out ────────────────────────────────────────────────────

  Widget _buildCheckoutRoadmap(BuildContext context) {
    final step1Done = _photo != null;
    final step2Done = _position != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: _ink, fontWeight: FontWeight.w400, letterSpacing: -0.4),
            children: [
              TextSpan(text: 'Registrar '),
              TextSpan(text: 'salida', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _RoadmapDot(done: step1Done, color: _orange),
                _RoadmapLine(done: step1Done),
                _RoadmapDot(done: step2Done, color: _teal),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _RoadmapCard(
                    title: 'Foto de evidencia',
                    subtitle: step1Done
                        ? 'Foto capturada correctamente'
                        : 'Toma una foto del lugar antes de salir',
                    icon: Icons.camera_alt_rounded,
                    color: _orange,
                    done: step1Done,
                    onTap: _takePhoto,
                  ),
                  const SizedBox(height: 16),
                  _RoadmapCard(
                    title: 'Ubicación GPS',
                    subtitle: step2Done
                        ? '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'
                        : 'Confirma tu posición actual para el cierre',
                    icon: Icons.my_location_rounded,
                    color: _teal,
                    done: step2Done,
                    onTap: _getLocation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Botón Check-out (centrado, fuera del roadmap) ────────────────────────

  Widget _buildCheckoutButton(BuildContext context, bool isLoading) {
    final allDone = _photo != null && _position != null;
    return _PrimaryButton(
      label: 'Registrar salida',
      icon: Icons.logout_rounded,
      color: _teal,
      accentColor: _green,
      enabled: !isLoading && allDone,
      isLoading: isLoading,
      onPressed: () {
        context.read<AttendanceBloc>().add(CheckOutRequested(
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          photoPath: _photo!.path,
        ));
      },
    );
  }

  // ─── Room Bottom Sheet ────────────────────────────────────────────────────

  void _showRoomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 20, color: _ink, letterSpacing: -0.4),
                children: [
                  const TextSpan(text: 'Seleccionar ', style: TextStyle(fontWeight: FontWeight.w400)),
                  const TextSpan(text: 'sala', style: TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(
                    text: '  ${_rooms.length}',
                    style: const TextStyle(fontSize: 14, color: _muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._rooms.map((room) {
              final isSelected = _selectedRoom?.id == room.id;
              return GestureDetector(
                onTap: () { setState(() => _selectedRoom = room); Navigator.pop(context); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? _violet : _card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isSelected
                        ? [BoxShadow(color: _violet.withOpacity(0.30), blurRadius: 14, offset: const Offset(0, 5))]
                        : [BoxShadow(color: _ink.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0x2EFFFFFF) : const Color(0x1A7B6CF5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(Icons.meeting_room_rounded,
                            color: isSelected ? Colors.white : _violet, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.name, style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14,
                                color: isSelected ? Colors.white : _ink)),
                            Text(room.location, style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? const Color(0xA6FFFFFF) : _muted)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 26, height: 26,
                          decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Roadmap Dot ──────────────────────────────────────────────────────────────

class _RoadmapDot extends StatelessWidget {
  final bool done;
  final Color color;
  const _RoadmapDot({required this.done, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : const Color(0xFFFFFFFF),
        border: Border.all(color: done ? color : const Color(0xFFCCC5BC), width: 2.5),
        boxShadow: done
            ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 3))]
            : [],
      ),
      child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 15) : null,
    );
  }
}

// ─── Roadmap Line ─────────────────────────────────────────────────────────────

class _RoadmapLine extends StatelessWidget {
  final bool done;
  final bool faint;
  const _RoadmapLine({required this.done, this.faint = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 2.5,
      height: 116,
      decoration: BoxDecoration(
        color: done
            ? (faint ? const Color(0xFFCCC5BC) : _violet)
            : const Color(0xFFDDD6CE),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─── Roadmap Card ─────────────────────────────────────────────────────────────

class _RoadmapCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool done;
  final VoidCallback onTap;

  const _RoadmapCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: done ? color : _card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: done ? color.withOpacity(0.30) : const Color(0x0D1A1A1A),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: done ? const Color(0x2EFFFFFF) : color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                done ? Icons.check_rounded : icon,
                color: done ? Colors.white : color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: done ? Colors.white : _ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: done ? const Color(0xA6FFFFFF) : _muted,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? const Color(0x2EFFFFFF) : const Color(0x0D1A1A1A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                color: done ? Colors.white : _muted,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: enabled ? color : _border,
          borderRadius: BorderRadius.circular(22),
          boxShadow: enabled
              ? [BoxShadow(color: color.withOpacity(0.38), blurRadius: 24, offset: const Offset(0, 10))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isLoading
              ? [const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))]
              : [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: enabled ? accentColor.withOpacity(0.20) : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 19, color: enabled ? Colors.white : _muted),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: enabled ? Colors.white : _muted,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}