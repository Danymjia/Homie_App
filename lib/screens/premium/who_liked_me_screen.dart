import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WhoLikedMeScreen extends StatelessWidget {
  const WhoLikedMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - En producción vendría de Supabase
    final List<Map<String, dynamic>> likes = [
      {
        'id': '1',
        'name': 'Sarah Thompson',
        'age': 24,
        'profession': 'Software Engineer',
        'photo': 'https://via.placeholder.com/100',
        'apartment': 'Modern Loft, San Francisco',
        'timeAgo': 'Hace 2 horas',
      },
      {
        'id': '2',
        'name': 'James Wilson',
        'age': 28,
        'profession': 'Designer',
        'photo': 'https://via.placeholder.com/100',
        'apartment': 'Cozy Studio Sublet',
        'timeAgo': 'Hace 5 horas',
      },
      {
        'id': '3',
        'name': 'Elena Rodriguez',
        'age': 26,
        'profession': 'Marketing Manager',
        'photo': 'https://via.placeholder.com/100',
        'apartment': 'Bright Loft in Chelsea',
        'timeAgo': 'Ayer',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Quién te dio Like',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: likes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: likes.length,
              itemBuilder: (context, index) {
                final like = likes[index];
                return _buildLikeCard(context, like);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE57373).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Color(0xFFE57373),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no tienes likes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Cuando alguien le dé like a tu perfil, aparecerá aquí.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeCard(BuildContext context, Map<String, dynamic> like) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Photo
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE57373),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    like['photo'] ?? 'https://via.placeholder.com/80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE57373),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE57373),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                '${like['name']}, ${like['age']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                like['profession'] ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.home,
                    color: Color(0xFFE57373),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      like['apartment'] ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                like['timeAgo'] ?? '',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Actions
        Column(
          children: [
            IconButton(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                // Crear match y navegar al chat
                context.push('/match/${like['id']}');
              },
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                // Rechazar like
              },
            ),
          ],
        ),
      ],
    ),
    );
  }
}
