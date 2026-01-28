import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:roomie_app/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isPremium = authProvider.isPremium;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            const Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Premium Section
            _buildSection(
              context,
              children: [
                if (isPremium) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primaryColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle,
                            color: theme.primaryColor, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Ya eres Premium',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Disfrutas de todos los beneficios exclusivos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsButton(
                    context,
                    label: 'Cancelar Suscripción',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Para cancelar, visita la tienda de aplicaciones.'),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Mejora tu cuenta para obtener beneficios exclusivos como temas personalizados y más visualizaciones.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/premium/plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Obtener Premium'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSection(
              context,
              title: 'Soporte y Ayuda',
              icon: Icons.help_outline,
              children: [
                _buildSettingsButton(
                  context,
                  label: 'Contactar Soporte',
                  icon: Icons.support_agent,
                  onTap: () => context.push('/settings/contact'),
                ),
                const SizedBox(height: 12),
                _buildSettingsButton(
                  context,
                  label: 'Reportar un Usuario',
                  icon: Icons.person_off,
                  onTap: () => context.push('/settings/report-user'),
                ),
                const SizedBox(height: 12),
                _buildSettingsButton(
                  context,
                  label: 'Reportar un Problema',
                  icon: Icons.bug_report,
                  onTap: () => context.push('/settings/report-problem'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions Section
            _buildSection(
              context,
              title: 'Acciones de Cuenta',
              icon: Icons.manage_accounts,
              children: [
                _buildSettingsButton(
                  context,
                  label: 'Cerrar Sesión',
                  icon: Icons.logout,
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {String? title, IconData? icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && icon != null) ...[
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onTap,
      Color? color}) {
    final theme = Theme.of(context);
    final buttonColor = color ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: buttonColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: buttonColor.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: _isLoggingOut
                ? null
                : () async {
                    final scaffoldContext = context;
                    Navigator.pop(dialogContext);

                    setState(() => _isLoggingOut = true);

                    try {
                      await _authService.signOut();
                      if (mounted) {
                        scaffoldContext.go('/login');
                      }
                    } catch (e) {
                      debugPrint('Error al cerrar sesión: $e');
                      if (mounted) {
                        scaffoldContext.go('/login');
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoggingOut = false);
                      }
                    }
                  },
            child: Text(
              'Cerrar sesión',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
