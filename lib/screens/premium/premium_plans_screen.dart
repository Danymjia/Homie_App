import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:roomie_app/config/supabase_config.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  
  String _selectedPlan = 'monthly'; // 'monthly' or 'annual'

  Future<void> _handleSubscribe() async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'smart-action',
      body: {'plan': _selectedPlan},
    );

    final checkoutUrl = response.data?['url'];

    if (checkoutUrl == null) {
      throw Exception('Stripe Checkout no disponible');
    }

    // 🔥 Abrir Stripe Checkout
    await launchUrl(
      Uri.parse(checkoutUrl),
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    print("Error detallado: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al iniciar el pago'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.signal_cellular_alt,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Icon(Icons.wifi, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: 1.5708, // 90 degrees
                        child: const Icon(Icons.battery_full,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE57373).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFE57373),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Prueba Roomie+ gratis!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Plans
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Monthly plan (Special offer)
                    GestureDetector(
                      onTap: () => setState(() => _selectedPlan = 'monthly'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE57373),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Banner
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE57373),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'OFERTA ESPECIAL',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Mensual',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _selectedPlan == 'monthly'
                                              ? const Color(0xFFE57373)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _selectedPlan == 'monthly'
                                                ? const Color(0xFFE57373)
                                                : Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: _selectedPlan == 'monthly'
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.black,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'USD 9.99',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Gratis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildFeatureItem('Unlimited Swipes'),
                                  const SizedBox(height: 12),
                                  _buildFeatureItem('See who likes you'),
                                  const SizedBox(height: 12),
                                  _buildFeatureItem('No Ads'),
                                  const SizedBox(height: 12),
                                  _buildFeatureItem('Priority in Chat'),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Gratis los primeros 7 días, luego USD 9.99/mes',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Annual plan
                    GestureDetector(
                      onTap: () => setState(() => _selectedPlan = 'annual'),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _selectedPlan == 'annual'
                                ? const Color(0xFFE57373)
                                : Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Anual',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE57373)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'MEJOR PRECIO',
                                    style: TextStyle(
                                      color: Color(0xFFE57373),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'USD 4.99',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gratis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Terms
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Las funciones pueden cambiar en cualquier momento. El pago se cobrará en tu cuenta de App Store. Tras el período de oferta inicial, las renovaciones se realizan con el precio completo. Tu suscripción se renovará automáticamente hasta que la canceles.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Comenzar prueba gratis',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const BottomNavBar(currentIndex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check,
          color: Color(0xFFE57373),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
