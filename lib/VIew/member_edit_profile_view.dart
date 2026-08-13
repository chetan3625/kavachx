import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_profile_controller.dart';

class MemberEditProfileView extends StatefulWidget {
  const MemberEditProfileView({super.key});

  @override
  State<MemberEditProfileView> createState() => _MemberEditProfileViewState();
}

class _MemberEditProfileViewState extends State<MemberEditProfileView> {
  final MemberProfileController controller =
      Get.find<MemberProfileController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedFitnessGoal;
  DateTime? _selectedDob;

  // Helper to ensure initial values exist in the dropdown list
  String? _getValidDropdownValue(String? rawValue, List<String> allowedItems) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;

    final normalized = rawValue.trim().toLowerCase();
    for (final item in allowedItems) {
      if (item.toLowerCase() == normalized) {
        return item; // Return matching item with exact case
      }
    }
    return null; // Return null if value isn't in items list
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: controller.name);
    _phoneController = TextEditingController(text: controller.phone);
    _emergencyContactController = TextEditingController(
      text: controller.emergencyContact,
    );
    _medicalConditionsController = TextEditingController(
      text: controller.medicalConditions,
    );
    _heightController = TextEditingController(
      text: controller.heightCm > 0
          ? controller.heightCm.toStringAsFixed(0)
          : '',
    );
    _weightController = TextEditingController(
      text: controller.currentWeightKg > 0
          ? controller.currentWeightKg.toStringAsFixed(1)
          : '',
    );
    _targetWeightController = TextEditingController(
      text: controller.targetWeightKg > 0
          ? controller.targetWeightKg.toStringAsFixed(1)
          : '',
    );

    // Safely assign dropdown values matching allowed lists
    _selectedGender = _getValidDropdownValue(controller.gender, const [
      'Male',
      'Female',
      'Other',
    ]);
    _selectedBloodGroup = _getValidDropdownValue(controller.bloodGroup, const [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ]);
    _selectedFitnessGoal = _getValidDropdownValue(
      controller.fitnessGoal,
      const [
        'Weight Loss',
        'Muscle Gain',
        'Endurance',
        'Flexibility',
        'General Fitness',
      ],
    );

    if (controller.dateOfBirth.isNotEmpty) {
      _selectedDob = DateTime.tryParse(controller.dateOfBirth);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF3B30),
              surface: Color(0xFF1C1C22),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'medicalConditions': _medicalConditionsController.text.trim(),
        'gender': _selectedGender ?? '',
        'bloodGroup': _selectedBloodGroup ?? '',
        'fitnessGoal': _selectedFitnessGoal ?? '',
        'heightCm': double.tryParse(_heightController.text.trim()) ?? 0,
        'currentWeightKg': double.tryParse(_weightController.text.trim()) ?? 0,
        'targetWeightKg':
            double.tryParse(_targetWeightController.text.trim()) ?? 0,
        if (_selectedDob != null)
          'dateOfBirth': _selectedDob!.toIso8601String(),
      };
      controller.updateProfile(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full Name'),
              _buildTextField(_nameController, 'Enter full name'),
              const SizedBox(height: 16),

              _buildLabel('Phone Number'),
              _buildTextField(
                _phoneController,
                'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of Birth Selector
              _buildLabel('Date of Birth'),
              GestureDetector(
                onTap: _pickDateOfBirth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDob != null
                            ? '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'
                            : 'Select Date of Birth',
                        style: TextStyle(
                          color: _selectedDob != null
                              ? Colors.white
                              : const Color(0xFF3F3F46),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFFFF3B30),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gender'),
                        _buildDropdown(
                          value: _selectedGender,
                          items: const ['Male', 'Female', 'Other'],
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                          hint: 'Select',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Blood Group'),
                        _buildDropdown(
                          value: _selectedBloodGroup,
                          items: const [
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'AB+',
                            'AB-',
                            'O+',
                            'O-',
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedBloodGroup = val),
                          hint: 'Select',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Fitness Goal'),
              _buildDropdown(
                value: _selectedFitnessGoal,
                items: const [
                  'Weight Loss',
                  'Muscle Gain',
                  'Endurance',
                  'Flexibility',
                  'General Fitness',
                ],
                onChanged: (val) => setState(() => _selectedFitnessGoal = val),
                hint: 'Select fitness goal',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Height (cm)'),
                        _buildTextField(
                          _heightController,
                          '175',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Weight (kg)'),
                        _buildTextField(
                          _weightController,
                          '70.0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Target (kg)'),
                        _buildTextField(
                          _targetWeightController,
                          '65.0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Emergency Contact'),
              _buildTextField(
                _emergencyContactController,
                'Emergency contact phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildLabel('Medical Conditions (Optional)'),
              _buildTextField(
                _medicalConditionsController,
                'Describe any medical conditions',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA1A1AA),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3F3F46)),
        filled: true,
        fillColor: const Color(0xFF1C1C22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    // Extra safety: double check value is in items list
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1C1C22),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3F3F46)),
        filled: true,
        fillColor: const Color(0xFF1C1C22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
