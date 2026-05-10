import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../providers/avc_record_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'avc_record_detail_screen.dart';
import 'avc_record_form_screen.dart';

class AvcRecordListScreen extends StatefulWidget {
  final int patientId;

  const AvcRecordListScreen({super.key, required this.patientId});

  @override
  State<AvcRecordListScreen> createState() => _AvcRecordListScreenState();
}

class _AvcRecordListScreenState extends State<AvcRecordListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<AvcRecordProvider>().loadRecordsForPatient(widget.patientId);
    });
  }

  Future<void> _openAddRecord() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvcRecordFormScreen(patientId: widget.patientId),
      ),
    );

    if (!mounted) return;
    await context.read<AvcRecordProvider>().loadRecordsForPatient(
      widget.patientId,
    );
  }

  Future<void> _openRecordDetails(int recordId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvcRecordDetailScreen(recordId: recordId),
      ),
    );

    if (!mounted) return;
    await context.read<AvcRecordProvider>().loadRecordsForPatient(
      widget.patientId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvcRecordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AVC dossiers'),
        actions: [
          IconButton(
            onPressed: _openAddRecord,
            icon: const Icon(Icons.add),
            tooltip: 'Add AVC dossier',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRecord,
        icon: const Icon(Icons.add),
        label: const Text('Add dossier'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: provider.isLoading
                ? const LoadingView(message: 'Loading AVC dossiers...')
                : provider.records.isEmpty
                ? const EmptyState(
                    title: 'No AVC dossiers',
                    message: 'Create the first AVC dossier for this patient.',
                  )
                : ListView.builder(
                    itemCount: provider.records.length,
                    itemBuilder: (context, index) {
                      final record = provider.records[index];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.description, color: Colors.white),
                          ),
                          title: Text('AVC dossier #${record.id ?? '-'}'),
                          subtitle: Text(
                            'Created: ${DateHelpers.formatDate(record.createdAt)}'
                            ' • NIHSS: ${record.nihssScore?.toString() ?? '-'}'
                            ' • Imaging: ${record.imagingType ?? '-'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (record.id != null) {
                              _openRecordDetails(record.id!);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
