import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomie_app/screens/map/location_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:roomie_app/services/apartment_service.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';

class RegisterApartmentScreen extends StatefulWidget {
  const RegisterApartmentScreen({super.key});

  @override
  State<RegisterApartmentScreen> createState() =>
      _RegisterApartmentScreenState();
}

class _RegisterApartmentScreenState extends State<RegisterApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApartmentService _apartmentService = ApartmentService();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isLocationSelected = false;

  // Custom Rules
  // Images
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  // Custom Rules
  final _ruleController = TextEditingController();
  final List<String> _customRules = [];

  // Basic Rules
  bool _noSmoking = false;
  bool _noPets = false;
  bool _noParty = false;
  bool _couplesAllowed = false;

  // Expenses
  bool _includesWater = true;
  bool _includesElectricity = true;
  bool _includesInternet = true;
  bool _includesGas = false;

  final _expenseController = TextEditingController();
  final List<String> _extraExpenses = [];

  @override
  void dispose() {
    _titleController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _ruleController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.length < 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes subir al menos 5 imágenes')),
          );
        }
        return;
      }

      if (!_isLocationSelected || _selectedLocation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Debes seleccionar la ubicación en el mapa')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Collect detailed rules
        final List<String> finalRules = List.from(_customRules);
        if (_noSmoking) finalRules.add('No fumar');
        if (_noPets) finalRules.add('No mascotas');
        if (_noParty) finalRules.add('No fiestas');
        if (_couplesAllowed) finalRules.add('Parejas permitidas');

        // Collect expenses
        final List<String> finalExpenses = List.from(_extraExpenses);
        if (_includesWater) finalExpenses.add('Agua');
        if (_includesElectricity) finalExpenses.add('Electricidad');
        if (_includesInternet) finalExpenses.add('Internet');
        if (_includesGas) finalExpenses.add('Gas');

        await _apartmentService.createApartment(
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          address: _addressController.text,
          city: _cityController.text,
          country: _countryController.text,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          rules: finalRules,
          expenses: finalExpenses,
          images: _selectedImages,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Departamento publicado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          if (e.toString().contains('Has alcanzado el límite')) {
            _showLimitDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Registrar Departamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Basic info
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              label: 'Título',
              hint: 'Ej. Piso en la ciudad',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _countryController,
              label: 'País',
              hint: 'Ej. Ecuador',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cityController,
              label: 'Ciudad',
              hint: 'Ej. Quito',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Dirección o Referencia',
              hint: 'Ej. Av. 12 de Octubre',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _selectLocationOnMap,
                icon: Icon(
                  _isLocationSelected ? Icons.check_circle : Icons.map,
                  color: _isLocationSelected
                      ? Colors.green
                      : const Color(0xFFFF4B63),
                ),
                label: Text(
                  _isLocationSelected
                      ? 'Ubicación Seleccionada'
                      : 'Seleccionar en Mapa',
                  style: TextStyle(
                    color: _isLocationSelected ? Colors.green : Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isLocationSelected
                        ? Colors.green
                        : const Color(0xFF3F3F46),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _priceController,
              label: 'Precio mensual',
              hint: 'Ej. 1200',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
              hint: 'Describe tu departamento...',
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Images
            _buildSectionTitle('Fotos del Departamento'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Column(
                children: [
                  if (_selectedImages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Sube entre 5 y 10 fotos',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(
                                        File(_selectedImages[index].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    color: Colors.black54,
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _pickImages,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF4B63)),
                      ),
                      child: Text(
                        _selectedImages.isEmpty
                            ? 'Seleccionar Imágenes'
                            : 'Agregar más imágenes',
                        style: const TextStyle(color: Color(0xFFFF4B63)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // House rules
            _buildSectionTitle('Reglas de la Casa'),
            const SizedBox(height: 16),
            _buildRuleCheckbox('Prohibido fumar', _noSmoking,
                (v) => setState(() => _noSmoking = v)),
            _buildRuleCheckbox(
                'No mascotas', _noPets, (v) => setState(() => _noPets = v)),
            _buildRuleCheckbox(
                'No fiestas', _noParty, (v) => setState(() => _noParty = v)),
            _buildRuleCheckbox('Se permiten parejas', _couplesAllowed,
                (v) => setState(() => _couplesAllowed = v)),
            const SizedBox(height: 16),
            const Text('Reglas adicionales:',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ruleController,
                    label: '',
                    hint: 'Ej. No fiestas',
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _addRule,
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFFF4B63), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customRules
                  .map((rule) => Chip(
                        label: Text(rule,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF1A1A1A),
                        deleteIcon: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                        onDeleted: () =>
                            setState(() => _customRules.remove(rule)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFF3F3F46)),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 32),

            // Expenses
            _buildSectionTitle('Gastos Incluidos'),
            const SizedBox(height: 16),
            _buildExpenseItem(
              icon: Icons.water_drop,
              label: 'Agua (Obligatorio)',
              value: _includesWater,
              color: Colors.blue,
              onChanged: null, // Immutable
            ),
            const SizedBox(height: 12),
            _buildExpenseItem(
              icon: Icons.bolt,
              label: 'Electricidad (Obligatorio)',
              value: _includesElectricity,
              color: Colors.amber,
              onChanged: null, // Immutable
            ),
            const SizedBox(height: 12),
            _buildExpenseItem(
              icon: Icons.wifi,
              label: 'Internet',
              value: _includesInternet,
              color: Colors.purple,
              onChanged: (value) => setState(() => _includesInternet = value),
            ),
            const SizedBox(height: 12),
            _buildExpenseItem(
              icon: Icons.local_gas_station,
              label: 'Gas',
              value: _includesGas,
              color: Colors.orange,
              onChanged: (value) => setState(() => _includesGas = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gastos Extra',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _expenseController,
                    label: '',
                    hint: 'Ej. Alícuota',
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _addUniqueExpense,
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFFF4B63), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _extraExpenses
                  .map((expense) => Chip(
                        label: Text(expense,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF1A1A1A),
                        deleteIcon: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                        onDeleted: () =>
                            setState(() => _extraExpenses.remove(expense)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFF3F3F46)),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 40),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4B63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Text(
                        'Publicar Departamento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(
          _getSectionIcon(title),
          color: const Color(0xFFFF4B63),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    if (title.contains('Reglas')) return Icons.gavel;
    if (title.contains('Gastos')) return Icons.receipt_long;
    return Icons.info;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
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
              borderSide: const BorderSide(color: Color(0xFFFF4B63), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (!isRequired) return null;
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _addRule() {
    if (_customRules.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 reglas permitidas')),
      );
      return;
    }
    if (_ruleController.text.isNotEmpty) {
      setState(() {
        _customRules.add(_ruleController.text);
        _ruleController.clear();
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _isLocationSelected = true;
      });

      // Reverse geocoding optional (to help user)
      try {
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          result.latitude,
          result.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = '${place.street}, ${place.subLocality}';
          if (_addressController.text.isEmpty) {
            _addressController.text = address;
          }
          if (_cityController.text.isEmpty && place.locality != null) {
            _cityController.text = place.locality!;
          }
          if (_countryController.text.isEmpty && place.country != null) {
            _countryController.text = place.country!;
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }
    }
  }

  void _addUniqueExpense() {
    if (_expenseController.text.isNotEmpty) {
      setState(() {
        _extraExpenses.add(_expenseController.text);
        _expenseController.clear();
      });
    }
  }

  Widget _buildExpenseItem({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
    required ValueChanged<bool>? onChanged, // Nullable for immutable items
  }) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3F3F46)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? const Color(0xFFFF4B63) : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (_selectedImages.length + images.length > 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Máximo 10 imágenes permitidas')),
          );
        }
        return;
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Widget _buildRuleCheckbox(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFFFF4B63),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void _showLimitDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = authProvider.isPremium;
    final limit = isPremium ? 10 : 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Límite alcanzado',
            style: TextStyle(color: Colors.white)),
        content: Text(
          isPremium
              ? 'Has alcanzado el límite máximo de $limit habitaciones.'
              : 'Has alcanzado el límite de $limit habitaciones gratuitas. Mejora a Premium para registrar hasta 10.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (!isPremium)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/premium/plans');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
              ),
              child: const Text('Ser Premium'),
            ),
        ],
      ),
    );
  }
}
