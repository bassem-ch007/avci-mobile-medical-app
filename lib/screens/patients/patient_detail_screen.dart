import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/patient_model.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/info_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_card.dart';
import 'patient_form_screen.dart';
import '../avc/avc_record_list_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<PatientProvider>().getPatientById(widget.patientId);
    });
  }

  Future<void> _editPatient(PatientModel patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PatientFormScreen(patient: patient)),
    );

    if (!mounted) return;
    await context.read<PatientProvider>().getPatientById(widget.patientId);
  }

  Future<void> _deletePatient(PatientModel patient) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete patient',
      message:
          'This will delete the patient and all related AVC dossiers. This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (!confirm) return;

    if (!mounted) return;

    final provider = context.read<PatientProvider>();
    final success = await provider.deletePatient(patient.id!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Patient deleted')));

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Delete failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();
    final patient = provider.selectedPatient;

    return Scaffold(
      appBar: AppBar(title: const Text('Patient details')),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading patient...')
          : patient == null
          ? const Center(child: Text('Patient not found'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SectionCard(
                      title: patient.fullName,
                      subtitle: 'Patient medical identity',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'Full name',
                            value: patient.fullName,
                            icon: Icons.person,
                          ),
                          InfoCard(
                            label: 'Age',
                            value: '${patient.age} years',
                            icon: Icons.cake,
                          ),
                          InfoCard(
                            label: 'Sex',
                            value: patient.sex,
                            icon: Icons.wc,
                          ),
                          InfoCard(
                            label: 'Phone',
                            value: patient.phone?.isNotEmpty == true
                                ? patient.phone!
                                : '-',
                            icon: Icons.phone,
                          ),
                          InfoCard(
                            label: 'Birth date',
                            value: DateHelpers.formatDate(patient.birthDate),
                            icon: Icons.calendar_today,
                          ),
                          InfoCard(
                            label: 'Profession',
                            value: patient.profession?.isNotEmpty == true
                                ? patient.profession!
                                : '-',
                            icon: Icons.work,
                          ),
                          InfoCard(
                            label: 'Marital status',
                            value: patient.maritalStatus ?? '-',
                            icon: Icons.family_restroom,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      title: 'Actions',
                      child: Column(
                        children: [
                          AppButton(
                            label: 'View AVC dossiers',
                            icon: Icons.description,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AvcRecordListScreen(
                                    patientId: patient.id!,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Edit patient',
                            icon: Icons.edit,
                            onPressed: () => _editPatient(patient),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                              ),
                              onPressed: () => _deletePatient(patient),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete patient'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
