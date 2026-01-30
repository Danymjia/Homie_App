import 'package:flutter/material.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  String _selectedPlan = 'free'; // Default to free

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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
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
                        '¡Prueba Homie+ gratis!',
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
            // Plans
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Free Plan
                    _buildExpandablePlanCard(
                      id: 'free',
                      title: 'FREE',
                      price: 'Gratis',
                      features: [
                        '3 publicaciones',
                        'anuncios',
                        'sin prioridad',
                      ],
                      isBestValue: false,
                    ),

                    const SizedBox(height: 16),

                    // Premium Monthly
                    _buildExpandablePlanCard(
                      id: 'monthly',
                      title: 'PREMIUM — \$4.99',
                      price: '\$4.99 / mes',
                      features: [
                        'hasta 10 publicaciones',
                        'sin anuncios',
                        'prioridad',
                        'filtros avanzados',
                        'verificación incluida',
                        'auto-boost 24h',
                        '1 boost mensual',
                      ],
                      isBestValue: false,
                    ),

                    const SizedBox(height: 16),

                    // Premium Annual
                    _buildExpandablePlanCard(
                      id: 'annual',
                      title: 'Anual (\$39.99)',
                      price: '\$3.33 / mes',
                      subtitle: '(facturado anualmente)',
                      features: [
                        'Incluye todo lo anterior',
                        'Ahorras 33%',
                      ],
                      isBestValue: true,
                    ),

                    const SizedBox(height: 32),

                    // Extras Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Extras',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85, // Adjust for card height
                      children: [
                        _buildGridExtraItem(
                          title: 'Boost',
                          price: '\$2.49',
                          description: 'Top en tu zona 30min',
                          icon: Icons.flash_on,
                        ),
                        _buildGridExtraItem(
                          title: 'Destacado',
                          price: '\$3.99',
                          description: '1ro en búsquedas (7 días)',
                          icon: Icons.star,
                        ),
                        _buildGridExtraItem(
                          title: '5 Super Likes',
                          price: '\$9.99',
                          description: '¡Diles que te encantan!',
                          icon: Icons.favorite,
                        ),
                        _buildGridExtraItem(
                          title: 'Top 24h',
                          price: '\$4.99',
                          description: 'Visibilidad x24 horas',
                          icon: Icons.trending_up,
                        ),
                        _buildGridExtraItem(
                          title: 'Verificado',
                          price: '\$2.99',
                          description: 'Genera confianza',
                          icon: Icons.verified,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
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

  Widget _buildGridExtraItem({
    required String title,
    required String price,
    required String description,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estamos trabajando en ello'),
            backgroundColor: Color(0xFFE57373),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE57373).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE57373),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFE57373),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandablePlanCard({
    required String id,
    required String title,
    required String price,
    String? subtitle,
    required List<String> features,
    required bool isBestValue,
  }) {
    final isSelected = _selectedPlan == id;
    final isFree = id == 'free';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected && !isFree
                ? const Color(0xFFE57373)
                : Colors.white.withOpacity(0.1),
            width: isSelected && !isFree ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Radio / Check
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isFree ? Colors.grey : const Color(0xFFE57373))
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isFree ? Colors.grey : const Color(0xFFE57373))
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      if (subtitle != null)
                        Text(subtitle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12)),
                    ],
                  ),
                ),
                // Price side
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    if (isBestValue)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE57373).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text("MEJOR",
                            style: TextStyle(
                                color: Color(0xFFE57373),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                  ],
                )
              ],
            ),
            // Expandable Content
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(isFree ? Icons.close : Icons.check,
                          color: isFree
                              ? const Color(0xFFE57373)
                              : const Color(0xFFE57373),
                          size: 16),
                      const SizedBox(width: 8),
                      Text(f,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ]),
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
