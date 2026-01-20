import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/models/compatibility_question_model.dart';
import 'package:roomie_app/services/compatibility_service.dart';

class CompatibilityQuestionnaireScreen extends StatefulWidget {
  const CompatibilityQuestionnaireScreen({super.key});

  @override
  State<CompatibilityQuestionnaireScreen> createState() =>
      _CompatibilityQuestionnaireScreenState();
}

class _CompatibilityQuestionnaireScreenState
    extends State<CompatibilityQuestionnaireScreen> {
  final PageController _pageController = PageController();
  final CompatibilityService _compatibilityService = CompatibilityService();
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _answers = {};
  int _currentPage = 0;
  bool _isLoading = false;
  String _selectedCountry = ''; // No default country
  String? _selectedCity; // Selected city
  List<Map<String, String>> _filteredCities = [];

  // Cities data by country
  final Map<String, List<Map<String, String>>> _citiesByCountry = {
    'Ecuador': [
      {
        'name': 'Quito',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Guayaquil',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Cuenca',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Ambato',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Manta',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
    'Colombia': [
      {
        'name': 'Bogotá',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Medellín',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Cali',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Barranquilla',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Cartagena',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
    'Perú': [
      {
        'name': 'Lima',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Arequipa',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Cusco',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Trujillo',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Chiclayo',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
    'Argentina': [
      {
        'name': 'Buenos Aires',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Córdoba',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Rosario',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Mendoza',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'La Plata',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
    'Chile': [
      {
        'name': 'Santiago',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Valparaíso',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Concepción',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Antofagasta',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Temuco',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
    'México': [
      {
        'name': 'Ciudad de México',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Guadalajara',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Monterrey',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Puebla',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'León',
        'image':
            'https://images.unsplash.com/photo-1578662956409-b3ab5380f83?ixlib=rb-4.0.3&ixid=M3wxLjAbSU&auto=format&fit=crop&w=800&q=80'
      },
    ],
  };

  final List<CompatibilityQuestion> _questions =
      CompatibilityQuestions.getDefaultQuestions();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    final allCities = _citiesByCountry[_selectedCountry] ?? [];

    setState(() {
      _filteredCities = query.isEmpty
          ? allCities
          : allCities
              .where((city) => city['name']!.toLowerCase().contains(query))
              .toList();
    });
  }

  void _selectCountry(String country) {
    setState(() {
      _selectedCountry = country;
      _selectedCity = null;
      _filteredCities = _citiesByCountry[country] ?? [];
    });
    _searchController.clear();

    // Auto-advance to cities page
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentPage < _questions.length + 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
    });

    // Auto-advance to first question
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentPage < _questions.length + 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _selectAnswer(String questionId, String value) {
    setState(() {
      _answers[questionId] = value;
    });

    // Auto-advance after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentPage < _questions.length + 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _submitAnswers() async {
    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu país'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu ciudad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _compatibilityService.saveCompatibilityAnswers(_answers,
          city: _selectedCity, country: _selectedCountry);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCountryOption(String country, String flag) {
    final isSelected = _selectedCountry == country;
    return GestureDetector(
      onTap: () => _selectCountry(country),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE57373).withOpacity(0.2)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE57373) : const Color(0xFF333333),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                country,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Selecciona tu país',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Esto nos ayudará a encontrar roomies compatibles en tu área',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Country options
          Column(
            children: [
              _buildCountryOption('Ecuador', '🇪🇨'),
              _buildCountryOption('Colombia', '🇨🇴'),
              _buildCountryOption('Perú', '🇵🇪'),
              _buildCountryOption('Argentina', '🇦🇷'),
              _buildCountryOption('Chile', '🇨🇱'),
              _buildCountryOption('México', '🇲🇽'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Selecciona tu ciudad en $_selectedCountry',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Busca y selecciona tu ciudad',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar ciudad...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Cities list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = _selectedCity == city['name'];
                return GestureDetector(
                  onTap: () => _selectCity(city['name']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE57373).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE57373)
                            : const Color(0xFF333333),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            city['image']!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF333333),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_city,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city['name']!,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.grey,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seleccionar esta ciudad',
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(CompatibilityQuestion question) {
    final selectedAnswer = _answers[question.id];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Options
          ...question.options.map((option) {
            final isSelected = selectedAnswer == option.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _selectAnswer(question.id, option.value),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE57373).withOpacity(0.2)
                        : const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE57373)
                          : const Color(0xFF2A2A2A),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (option.icon != null)
                        Text(
                          option.icon!,
                          style: const TextStyle(fontSize: 24),
                        ),
                      if (option.icon != null) const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFE57373),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = 2 + _questions.length; // country + cities + questions

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paso ${_currentPage + 1} de $totalPages',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => context.go('/home'),
                          child: const Text(
                            'Saltar',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / totalPages,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFE57373)),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCountrySelectionPage();
                  } else if (index == 1) {
                    return _buildCitySelectionPage();
                  } else {
                    final questionIndex = index - 2;
                    final question = _questions[questionIndex];
                    return _buildQuestionPage(question);
                  }
                },
              ),
            ),

            // Navigation buttons
            if (_currentPage == totalPages - 1)
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Finalizar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
