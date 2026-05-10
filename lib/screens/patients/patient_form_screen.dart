import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/patient_model.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_text_field.dart';

class PatientFormScreen extends StatefulWidget {
  final PatientModel? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _professionController;

  String? _sex;
  String? _maritalStatus;
  DateTime? _birthDate;

  bool get _isEditMode => widget.patient != null;

  @override
  void initState() {
    super.initState();

    final patient = widget.patient;

    _firstNameController = TextEditingController(
      text: patient?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: patient?.lastName ?? '');
    _phoneController = TextEditingController(text: patient?.phone ?? '');
    _professionController = TextEditingController(
      text: patient?.profession ?? '',
    );

    _sex = patient?.sex;
    _maritalStatus = patient?.maritalStatus;
    _birthDate = patient?.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 50),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Birth date is required')));
      return;
    }

    final now = DateTime.now();

    final patient = PatientModel(
      id: widget.patient?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      sex: _sex!,
      birthDate: _birthDate!,
      profession: _professionController.text.trim().isEmpty
          ? null
          : _professionController.text.trim(),
      maritalStatus: _maritalStatus,
      createdAt: widget.patient?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<PatientProvider>();

    final success = _isEditMode
        ? await provider.updatePatient(patient)
        : await provider.addPatient(patient);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Patient updated' : 'Patient added'),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Operation failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit patient' : 'Add patient')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _firstNameController,
                          label: 'First name',
                          validator: (value) =>
                              Validators.requiredText(value, 'First name'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _lastNameController,
                          label: 'Last name',
                          validator: (value) =>
                              Validators.requiredText(value, 'Last name'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 14),
                        AppDropdownField(
                          label: 'Sex',
                          value: _sex,
                          items: const ['Homme', 'Femme'],
                          onChanged: (value) {
                            setState(() {
                              _sex = value;
                            });
                          },
                          validator: (value) =>
                              Validators.requiredText(value, 'Sex'),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: _pickBirthDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Birth date',
                              suffixIcon: Icon(Icons.calendar_month),
                            ),
                            child: Text(
                              _birthDate == null
                                  ? 'Select birth date'
                                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _professionController,
                          label: 'Profession',
                        ),
                        const SizedBox(height: 14),
                        AppDropdownField(
                          label: 'Marital status',
                          value: _maritalStatus,
                          items: const [
                            'Célibataire',
                            'Marié(e)',
                            'Divorcé(e)',
                            'Veuf/Veuve',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _maritalStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        AppButton(
                          label: _isEditMode
                              ? 'Update patient'
                              : 'Save patient',
                          onPressed: _submit,
                          isLoading: provider.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
