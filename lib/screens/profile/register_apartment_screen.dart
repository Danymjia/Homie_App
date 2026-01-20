import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterApartmentScreen extends StatefulWidget {
  const RegisterApartmentScreen({super.key});

  @override
  State<RegisterApartmentScreen> createState() => _RegisterApartmentScreenState();
}

class _RegisterApartmentScreenState extends State<RegisterApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Rules
  bool _allowsSmoking = false;
  bool _allowsPets = false;
  bool _allowsAlcohol = false;
  bool _quietHours = false;
  bool _ownLaundry = false;
  
  // Expenses
  bool _includesWater = true;
  bool _includesElectricity = true;
  bool _includesInternet = true;
  bool _includesGas = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Aquí se guardaría en Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Departamento registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
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
              controller: _addressController,
              label: 'Dirección',
              hint: 'Ej. Av. 12 de Octubre',
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

            // House rules
            _buildSectionTitle('Reglas de la Casa'),
            const SizedBox(height: 16),
            _buildRulesGrid(),

            const SizedBox(height: 32),

            // Expenses
            _buildSectionTitle('Gastos Incluidos'),
            const SizedBox(height: 16),
            _buildExpenseItem(
              icon: Icons.water_drop,
              label: 'Agua',
              value: _includesWater,
              color: Colors.blue,
              onChanged: (value) => setState(() => _includesWater = value),
            ),
            const SizedBox(height: 12),
            _buildExpenseItem(
              icon: Icons.bolt,
              label: 'Electricidad',
              value: _includesElectricity,
              color: Colors.amber,
              onChanged: (value) => setState(() => _includesElectricity = value),
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
                child: const Text(
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
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRulesGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _buildRuleCard(
          icon: Icons.smoke_free,
          label: 'No Fumar',
          value: _allowsSmoking,
          onTap: () => setState(() => _allowsSmoking = !_allowsSmoking),
        ),
        _buildRuleCard(
          icon: Icons.pets,
          label: 'No Mascotas',
          value: _allowsPets,
          onTap: () => setState(() => _allowsPets = !_allowsPets),
        ),
        _buildRuleCard(
          icon: Icons.bedtime,
          label: 'Silencio después de 10 PM',
          value: _quietHours,
          onTap: () => setState(() => _quietHours = !_quietHours),
        ),
        _buildRuleCard(
          icon: Icons.local_drink,
          label: 'No Alcohol',
          value: _allowsAlcohol,
          onTap: () => setState(() => _allowsAlcohol = !_allowsAlcohol),
        ),
        _buildRuleCard(
          icon: Icons.local_laundry_service,
          label: 'Lavar ropa propia',
          value: _ownLaundry,
          onTap: () => setState(() => _ownLaundry = !_ownLaundry),
        ),
      ],
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF1A1A1A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? const Color(0xFFFF4B63).withOpacity(0.3) : const Color(0xFF3F3F46),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: value ? Colors.white : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: value ? Colors.white : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
    );
  }
}
