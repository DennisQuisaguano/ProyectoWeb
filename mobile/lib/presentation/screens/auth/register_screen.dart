import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      nombreCompleto: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      telefono: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
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
        title: const Text('Registro de Estudiante'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crea tu cuenta universitaria',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Únete para descubrir y calificar la gastronomía alrededor de la UTA',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Nombre Completo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Juan Pérez',
                    prefixIcon: Icon(Icons.person_outline, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                    fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(v)) {
                      return 'Solo letras y espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Correo Electrónico',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'estudiante@uta.edu.ec',
                    prefixIcon: Icon(Icons.email_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                    fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Teléfono (Opcional, 10 dígitos)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0991234567',
                    prefixIcon: Icon(Icons.phone_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                    fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                      return 'Debe tener exactamente 10 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Contraseña',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: Icon(Icons.lock_outline, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
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
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Crear Cuenta',
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: isDark ? AppColors.accentBlue : AppColors.primary,
                            fontWeight: FontWeight.bold,
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
