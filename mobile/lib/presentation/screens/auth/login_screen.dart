import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../shared/widgets/puni_mascot.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a UTA Food! Sesión iniciada.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mascota Puni en Login
                const Center(
                  child: PuniMascot(
                    mood: PuniMood.waving,
                    size: 110,
                    shadow: true,
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Tu cuenta universitaria',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Ingresa para calificar locales, escribir opiniones y acceder a descuentos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'Correo Electrónico',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'ejemplo@uta.edu.ec',
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                    fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo institucional o personal';
                    if (!v.contains('@')) return 'Ingresa un correo electrónico válido';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                Text(
                  'Contraseña',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    suffixIcon: Semantics(
                      label: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                      button: true,
                      child: IconButton(
                        iconSize: 22,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Ingresar a UTA Food',
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Aún no tienes cuenta? ',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: isDark ? AppColors.accentBlue : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
