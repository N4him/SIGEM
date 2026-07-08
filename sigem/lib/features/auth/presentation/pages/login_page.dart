import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigem/features/navigation/bloc/presentation/main_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';

// ─── Paleta ───────────────────────────────────────────────────────────────────
const _bgDark      = Color(0xFF1C1A3A);
const _bgDarkCard  = Color(0xFF2D2B52);
const _violet      = Color(0xFF534AB7);
const _violetLight = Color(0xFFAFA9EC);
const _cream       = Color(0xFFF5EDE0);
const _ink         = Color(0xFF1A1A1A);
const _muted       = Color(0xFF9E9488);
const _border      = Color(0xFFEDE8E0);
const _fieldBg     = Color(0xFFFAFAF8);
const _subText     = Color(0xFF8B89B8);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        backgroundColor: _bgDark,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MainPage(user: state.user),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    const Spacer(),
                    // ── Zona superior: logo + nombre ──────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 28),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _bgDarkCard,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 36,
                              color: _violetLight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'SIGEM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sistema de Gestión de Monitorías',
                            style: TextStyle(
                              color: _subText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Card blanca flotante con bordes redondeados ────────
                    IntrinsicHeight(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Saludo
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Ingresa tus credenciales para continuar',
                              style: TextStyle(color: _muted, fontSize: 13),
                            ),
                            const SizedBox(height: 24),

                            // ── Email ─────────────────────────────────
                            const _FieldLabel(label: 'Correo electrónico'),
                            const SizedBox(height: 6),
                            _InputField(
                              controller: _emailController,
                              hint: 'correo@universidad.edu',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // ── Contraseña ────────────────────────────
                            const _FieldLabel(label: 'Contraseña'),
                            const SizedBox(height: 6),
                            _PasswordField(
                              controller: _passwordController,
                              obscure: _obscurePassword,
                              onToggle: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 20),

                            // ── Botón ingresar ────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                              LoginRequested(
                                                email: _emailController.text
                                                    .trim(),
                                                password:
                                                    _passwordController.text,
                                              ),
                                            );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _violet,
                                  disabledBackgroundColor:
                                      _violet.withOpacity(0.5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Ingresar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final IconData prefixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _ink, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted, fontSize: 15),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Icon(prefixIcon, size: 20, color: _muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _violet, width: 1.5),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _ink, fontSize: 15),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: _muted, fontSize: 15),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, size: 20, color: _muted),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: _muted,
          ),
          onPressed: onToggle,
          splashRadius: 20,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _violet, width: 1.5),
        ),
      ),
    );
  }
}