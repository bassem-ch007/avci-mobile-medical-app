import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddPatient() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PatientFormScreen()));
  }

  void _openPatientDetails(int patientId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patientId: patientId),
      ),
    );
  }

  Future<void> _search(String value) async {
    await context.read<PatientProvider>().searchPatients(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            onPressed: _openAddPatient,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add patient',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPatient,
        icon: const Icon(Icons.add),
        label: const Text('Add patient'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _search,
                  decoration: const InputDecoration(
                    labelText: 'Search by name or phone',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  const Expanded(
                    child: LoadingView(message: 'Loading patients...'),
                  )
                else if (provider.patients.isEmpty)
                  const Expanded(
                    child: EmptyState(
                      title: 'No patients found',
                      message:
                          'Add your first patient to start creating AVC dossiers.',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.patients.length,
                      itemBuilder: (context, index) {
                        final patient = provider.patients[index];

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(patient.fullName),
                            subtitle: Text(
                              '${patient.age} years • ${patient.sex}'
                              '${patient.phone == null || patient.phone!.isEmpty ? '' : ' • ${patient.phone}'}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              if (patient.id != null) {
                                _openPatientDetails(patient.id!);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
