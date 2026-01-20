import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PremiumFeaturesScreen extends StatelessWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.expand_more,
                      color: Colors.grey,
                      size: 32,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Icon
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.home_work,
                            color: Color(0xFFE57373),
                            size: 56,
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE57373),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Novedad en Roomie+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Funciones exclusivas, experimentales y previas al lanzamiento.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '4 FUNCIONES NUEVAS AÑADIDAS RECIENTEMENTE',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features
                    Column(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.star,
                          title: 'Match Prioritario',
                          description: 'Tu perfil aparecerá primero en las búsquedas de tu zona.',
                          isNew: true,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.block,
                          title: 'Sin Anuncios',
                          description: 'Navega sin interrupciones y encuentra tu hogar ideal más rápido.',
                          isNew: true,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.all_inclusive,
                          title: 'Swipes Ilimitados',
                          description: 'No te pongas límites. Desliza todo lo que quieras sin restricciones.',
                          isNew: true,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.visibility,
                          title: 'Ver quién te dio Like',
                          description: 'Descubre quién está interesado en ser tu próximo roomie.',
                          isNew: false,
                          onTap: () {
                            context.push('/premium/likes');
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          icon: Icons.palette,
                          title: 'Temas Personalizados',
                          description: 'Dale un toque personal a tu perfil con colores y fondos únicos.',
                          isNew: false,
                          onTap: () {
                            context.push('/premium/themes');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom button
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
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.push('/premium/plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isNew,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNew
              ? const Color(0xFF121212)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNew
                ? const Color(0xFFE57373).withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE57373),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE57373),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NUEVO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else if (onTap != null)
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
