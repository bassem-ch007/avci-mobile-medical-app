import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/avc_record_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/section_card.dart';
import '../patients/patient_form_screen.dart';
import '../patients/patient_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<Map<String, int>> _loadStats() async {
    final patientProvider = context.read<PatientProvider>();
    final avcRecordProvider = context.read<AvcRecordProvider>();

    final patientCount = await patientProvider.countPatients();
    final recordCount = await avcRecordProvider.countRecords();

    return {'patients': patientCount, 'records': recordCount};
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  Future<void> _openPatientList() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PatientListScreen()));

    if (!mounted) return;
    await _refreshStats();
  }

  Future<void> _openAddPatient() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PatientFormScreen()));

    if (!mounted) return;
    await _refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AVCI Medical Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionCard(
                  title: 'Welcome, ${user?.fullName ?? 'Doctor'}',
                  subtitle:
                      'Offline medical workspace for AVCI patient follow-up',
                  child: const Text(
                    'Manage patients, create structured AVC dossiers, generate PDF reports, and share reports by email.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                FutureBuilder<Map<String, int>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    final patients = snapshot.data?['patients'] ?? 0;
                    final records = snapshot.data?['records'] ?? 0;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 650;

                        if (isSmall) {
                          return Column(
                            children: [
                              _StatCard(
                                title: 'Patients',
                                value: patients.toString(),
                                icon: Icons.people_alt,
                              ),
                              const SizedBox(height: 12),
                              _StatCard(
                                title: 'AVC dossiers',
                                value: records.toString(),
                                icon: Icons.description,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Patients',
                                value: patients.toString(),
                                icon: Icons.people_alt,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'AVC dossiers',
                                value: records.toString(),
                                icon: Icons.description,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Main actions',
                  subtitle: 'Fast access to the most important medical tasks',
                  child: Column(
                    children: [
                      AppButton(
                        label: 'View patients',
                        icon: Icons.people,
                        onPressed: _openPatientList,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Add patient',
                        icon: Icons.person_add,
                        onPressed: _openAddPatient,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
