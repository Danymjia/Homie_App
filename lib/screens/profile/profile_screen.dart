import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomie_app/services/auth_service.dart';
import 'package:roomie_app/services/storage_service.dart';
import 'package:roomie_app/widgets/bottom_nav_bar.dart';
import 'package:roomie_app/widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  String? _profilePhotoUrl;
  bool _isLoading = true;

  // Profile data from Supabase
  String _fullName = 'Cargando...';
  String _email = '';
  int _age = 0;

  // Editable profile information
  String _aboutMe = '';
  String? _location;
  List<String> _lifestyleTags = [];
  List<String> _includedExpenses = ['WiFi', 'Water', 'Electricity'];
  List<String> _houseRules = ['No smoking inside', 'Quiet hours after 10 PM'];
  bool _hasApartments = false;

  // Controllers
  late TextEditingController _aboutMeController;

  @override
  void initState() {
    super.initState();
    _aboutMeController = TextEditingController(text: _aboutMe);
    _loadProfileData();
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  // Load profile data from Supabase
  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _fullName = response['full_name'] ?? 'Usuario';
          _email = response['email'] ?? '';
          _age = response['age'] ?? 0;
          _profilePhotoUrl = response['photo_url'];
          _lifestyleTags = List<String>.from(response['lifestyle_tags'] ?? []);
          _aboutMe = response['bio'] ?? '';
          _location = response['location'];
          _isLoading = false;
        });
        _aboutMeController.text = _aboutMe;
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Elegir de la galería',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadPhoto(isCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Tomar foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadPhoto(isCamera: true);
              },
            ),
            if (_profilePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _deletePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto({required bool isCamera}) async {
    try {
      final file = isCamera
          ? await _storageService.pickImageFromCamera()
          : await _storageService.pickImageFromGallery();

      if (file != null) {
        final url = await _storageService.uploadProfilePhoto(file);
        if (url != null && mounted) {
          setState(() => _profilePhotoUrl = url);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    try {
      await _storageService.deleteProfilePhoto();
      if (mounted) {
        setState(() => _profilePhotoUrl = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Edit lifestyle tags
  void _editLifestyleTags() {
    final suggestions = [
      'No fumador',
      'Madrugador',
      'Noctámbulo',
      'Sin mascotas',
      'Amigable con mascotas',
      'Sociable',
      'Tranquilo',
      'Limpieza extrema',
      'Organizado',
      'Estudiante',
      'Profesional',
      'Trabajo remoto',
      'Amante de la música',
      'Entusiasta del fitness',
      'Vegetariano',
      'Amante de la cocina',
      'Minimalista',
      'Amante de los libros'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Editar Preferencias',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((suggestion) {
                final isSelected = _lifestyleTags.contains(suggestion);
                return FilterChip(
                  label: Text(suggestion),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _lifestyleTags.add(suggestion);
                      } else {
                        _lifestyleTags.remove(suggestion);
                      }
                    });
                  },
                  backgroundColor: isSelected
                      ? const Color(0xFFE57373)
                      : const Color(0xFF2A2A2A),
                  labelStyle:
                      TextStyle(color: isSelected ? Colors.white : Colors.grey),
                  selectedColor: const Color(0xFFE57373),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await _saveLifestyleTags();
                  Navigator.pop(context);
                  await _loadProfileData();
                },
                child: const Text('Guardar',
                    style: TextStyle(color: Color(0xFFE57373)))),
          ],
        ),
      ),
    );
  }

  // Edit about me
  void _editAboutMe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Sobre Mí',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _aboutMeController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cuéntanos sobre ti...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE57373)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _aboutMe = _aboutMeController.text);
              await _saveAboutMe();
              Navigator.pop(context);
            },
            child: const Text('Guardar',
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );
  }

  // Save methods
  Future<void> _saveLifestyleTags() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('profiles')
          .update({'lifestyle_tags': _lifestyleTags}).eq('id', user.id);
    } catch (e) {
      debugPrint('Error saving lifestyle tags: $e');
    }
  }

  Future<void> _saveAboutMe() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('profiles')
          .update({'bio': _aboutMe}).eq('id', user.id);
    } catch (e) {
      debugPrint('Error saving about me: $e');
    }
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis intereses',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            IconButton(
              onPressed: _editLifestyleTags,
              icon: const Icon(Icons.edit, color: Colors.grey, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_lifestyleTags.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFFE57373), size: 32),
                const SizedBox(height: 8),
                const Text(
                  'No tienes preferencias agregadas',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Agrega tus intereses para encontrar compatibilidad',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _lifestyleTags.map((tag) => _buildTag(tag)).toList(),
          ),
      ],
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sobre Mí',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            IconButton(
              onPressed: _editAboutMe,
              icon: const Icon(Icons.edit, color: Colors.grey, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_aboutMe.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFFE57373), size: 32),
                const SizedBox(height: 8),
                const Text(
                  'No has agregado información sobre ti',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Toca el ícono de editar para agregar tu descripción',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        else
          Text(
            _aboutMe,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        const SizedBox(height: 16),
        // Logout button
        ElevatedButton.icon(
          onPressed: () => _showLogoutDialog(),
          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
          label: const Text('Cerrar sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE57373),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
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
                    // Guarda el contexto del scaffold ANTES de cerrar el diálogo
                    final scaffoldContext = context;
                    
                    // Cierra el diálogo usando su propio contexto
                    Navigator.pop(dialogContext);

                    setState(() => _isLoggingOut = true);

                    try {
                      await _authService.signOut();

                      // Usa el contexto del scaffold guardado
                      if (mounted) {
                        scaffoldContext.go('/login');
                      }
                    } catch (e) {
                      print('Error al cerrar sesión: $e');
                      if (mounted) {
                        scaffoldContext.go('/login');
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoggingOut = false);
                      }
                    }
                  },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Color(0xFFE57373)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentSection() {
    if (!_hasApartments) {
      // Show message when no apartments
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis habitaciones',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.home_work_outlined,
                  color: Color(0xFFE57373),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tienes habitaciones publicadas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Publica tu primera habitación para encontrar roomies compatibles',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/register-apartment'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Agregar habitación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Show existing apartments (placeholder for now)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis habitaciones',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE57373).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFE57373).withOpacity(0.2),
                ),
              ),
              child: const Text(
                'ACTIVO',
                style: TextStyle(
                  color: Color(0xFFE57373),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF1A1A1A),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://cf.bstatic.com/xdata/images/hotel/max1024x768/697485066.webp?k=a7685b9db668687c8f029981e28fca7f6094b3500041660120aa8cb0c3f29331&o=',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cozy Modern Loft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.payments,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '\$550/mo • San Luis',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 48, right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        color: const Color(0xFFE57373),
        backgroundColor: const Color(0xFF1A1A1A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile info
              Column(
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoOptions(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 4,
                            ),
                          ),
                          child: ProfileAvatar(
                            imageUrl: _profilePhotoUrl,
                            name: _fullName,
                            size: 96,
                            borderRadius: 50,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4B63),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLoading ? 'Cargando...' : '$_fullName, $_age',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  if (_location != null && _location!.isNotEmpty)
                    Text(
                      _location!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Quito, Ecuador',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/register-apartment'),
                      icon: const Icon(Icons.add_home, size: 28),
                      label: const Text(
                        'Agregar Habitación',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/home'),
                      icon: const Icon(Icons.person_search,
                          size: 28, color: Color(0xFFFF4B63)),
                      label: const Text(
                        'Buscar Roomie',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3F3F46)),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Premium section
              GestureDetector(
                onTap: () => context.push('/premium/features'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE57373).withOpacity(0.2),
                        const Color(0xFFE57373).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE57373).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE57373), Color(0xFFEF9A9A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Roomie+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Desbloquea funciones exclusivas',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFE57373),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Lifestyle tags
              _buildLifestyleSection(),

              const SizedBox(height: 32),

              // Listing section
              _buildApartmentSection(),

              const SizedBox(height: 32),

              // About me
              _buildAboutMeSection(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3F3F46)),
      ),
      child: const Icon(
        Icons.add_photo_alternate,
        color: Colors.grey,
      ),
    );
  }
}