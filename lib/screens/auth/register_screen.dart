import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        int.tryParse(_ageController.text) ?? 0,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Registro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEB6B6B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.roofing,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Crea tu perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Encuentra al compañero de cuarto ideal en nuestra comunidad.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre completo',
                              placeholder: 'Ej. Juan Pérez',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu nombre completo';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              placeholder: 'ejemplo@correo.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu correo electrónico';
                                }
                                if (!value.contains('@')) {
                                  return 'Correo electrónico inválido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Age
                            _buildTextField(
                              controller: _ageController,
                              label: 'Edad',
                              placeholder: 'Ej. 25',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu edad';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 18) {
                                  return 'Debes ser mayor de 18 años';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password
                            _buildPasswordField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              placeholder: 'Mínimo 8 caracteres',
                              obscureText: _obscurePassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (value.length < 8) {
                                  return 'La contraseña debe tener al menos 8 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar contraseña',
                              placeholder: 'Repite tu contraseña',
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirma tu contraseña';
                                }
                                if (value != _passwordController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Terms checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFFEB6B6B),
                                  checkColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF525252),
                                    width: 2,
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _acceptTerms = !_acceptTerms;
                                      });
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(text: 'Acepto los '),
                                          TextSpan(
                                            text: 'términos y condiciones',
                                            style: TextStyle(
                                              color: Color(0xFFEB6B6B),
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Register button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEB6B6B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Crear Cuenta',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login link
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: '¿Ya tienes una cuenta? '),
                              TextSpan(
                                text: 'Iniciar sesión',
                                style: TextStyle(
                                  color: Color(0xFFEB6B6B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEB6B6B),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFFEB6B6B).withOpacity(0.7),
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEB6B6B),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
