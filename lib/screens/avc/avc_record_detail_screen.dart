import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/avc_record_model.dart';
import '../../providers/avc_record_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/info_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_card.dart';
import 'avc_record_form_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../services/gmail_service.dart';
import '../../services/pdf_service.dart';

class AvcRecordDetailScreen extends StatefulWidget {
  final int recordId;

  const AvcRecordDetailScreen({super.key, required this.recordId});

  @override
  State<AvcRecordDetailScreen> createState() => _AvcRecordDetailScreenState();
}

class _AvcRecordDetailScreenState extends State<AvcRecordDetailScreen> {
  final PdfService _pdfService = PdfService();
  final GmailService _gmailService = GmailService();
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<AvcRecordProvider>().getRecordById(widget.recordId);
    });
  }

  Future<void> _generatePdf(AvcRecordModel record) async {
    try {
      final patientProvider = context.read<PatientProvider>();
      final authProvider = context.read<AuthProvider>();

      final patient = await patientProvider.getPatientById(record.patientId);

      if (!mounted) return;

      if (patient == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Patient not found')));
        return;
      }

      final bytes = await _pdfService.generateAvcReport(
        doctor: authProvider.currentUser,
        patient: patient,
        record: record,
      );

      await _pdfService.previewPdf(bytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to generate PDF')));
    }
  }

  Future<void> _sendByGmail(AvcRecordModel record) async {
    try {
      final patientProvider = context.read<PatientProvider>();
      final authProvider = context.read<AuthProvider>();

      final patient = await patientProvider.getPatientById(record.patientId);

      if (!mounted) return;

      if (patient == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Patient not found')));
        return;
      }

      final bytes = await _pdfService.generateAvcReport(
        doctor: authProvider.currentUser,
        patient: patient,
        record: record,
      );

      final fileName = _pdfService.buildFileName(
        patient: patient,
        record: record,
      );

      await _pdfService.previewPdf(bytes);

      await _gmailService.openGmailCompose(
        subject: 'Rapport Médical AVCI - ${patient.fullName}',
        body: _gmailService.buildEmailBody(
          patientName: patient.fullName,
          fileName: fileName,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gmail opened. Attach the generated PDF manually if the browser did not attach it.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to open Gmail')));
    }
  }

  Future<void> _editRecord(AvcRecordModel record) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AvcRecordFormScreen(patientId: record.patientId, record: record),
      ),
    );

    if (!mounted) return;
    await context.read<AvcRecordProvider>().getRecordById(widget.recordId);
  }

  Future<void> _deleteRecord(AvcRecordModel record) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete AVC dossier',
      message: 'This AVC dossier will be permanently deleted.',
      confirmText: 'Delete',
    );

    if (!confirm) return;
    if (!mounted) return;

    final provider = context.read<AvcRecordProvider>();
    final success = await provider.deleteRecord(record.id!, record.patientId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AVC dossier deleted')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Delete failed')),
      );
    }
  }

  String _yesNo(bool value) => value ? 'Yes' : 'No';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvcRecordProvider>();
    final record = provider.selectedRecord;

    return Scaffold(
      appBar: AppBar(title: const Text('AVC dossier details')),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading AVC dossier...')
          : record == null
          ? const Center(child: Text('AVC dossier not found'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SectionCard(
                      title: 'Dossier summary',
                      subtitle:
                          'Created on ${DateHelpers.formatDate(record.createdAt)}',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'Origin',
                            value: record.origin ?? '-',
                            icon: Icons.location_city,
                          ),
                          InfoCard(
                            label: 'Social status',
                            value: record.socialStatus ?? '-',
                            icon: Icons.badge,
                          ),
                          InfoCard(
                            label: 'Previous mRS score',
                            value: record.previousMrsScore?.toString() ?? '-',
                            icon: Icons.assessment,
                          ),
                          InfoCard(
                            label: 'Laterality',
                            value: record.laterality ?? '-',
                            icon: Icons.front_hand,
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Medical history',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'Hypertension',
                            value: _yesNo(record.hypertension),
                          ),
                          InfoCard(
                            label: 'Diabetes',
                            value: _yesNo(record.diabetes),
                          ),
                          InfoCard(
                            label: 'Hyperlipidemia',
                            value: _yesNo(record.hyperlipidemia),
                          ),
                          InfoCard(
                            label: 'Smoking',
                            value: _yesNo(record.smoking),
                          ),
                          InfoCard(
                            label: 'Previous stroke',
                            value: _yesNo(record.previousStroke),
                          ),
                          InfoCard(
                            label: 'Current treatments',
                            value: record.currentTreatments ?? '-',
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Pre-hospital phase',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'AVC date',
                            value: DateHelpers.formatDate(record.avcDate),
                          ),
                          InfoCard(
                            label: 'AVC time',
                            value: record.avcTime ?? '-',
                          ),
                          InfoCard(
                            label: 'Wake-up stroke',
                            value: _yesNo(record.wakeUpStroke),
                          ),
                          InfoCard(
                            label: 'Transport method',
                            value: record.transportMethod ?? '-',
                          ),
                          InfoCard(
                            label: 'Delay',
                            value: record.symptomToArrivalDelayMinutes == null
                                ? '-'
                                : '${record.symptomToArrivalDelayMinutes} min',
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Initial clinical parameters',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'Glycemia',
                            value: record.glycemia?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'Blood pressure',
                            value:
                                '${record.systolicBloodPressure?.toString() ?? '-'}/${record.diastolicBloodPressure?.toString() ?? '-'} mmHg',
                          ),
                          InfoCard(
                            label: 'NIHSS score',
                            value: record.nihssScore?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'Glasgow score',
                            value: record.glasgowScore?.toString() ?? '-',
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Imaging and treatment',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'Imaging type',
                            value: record.imagingType ?? '-',
                          ),
                          InfoCard(
                            label: 'ASPECTS score',
                            value: record.aspectScore?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'Occlusion detected',
                            value: _yesNo(record.arterialOcclusionDetected),
                          ),
                          InfoCard(
                            label: 'Thrombolysis',
                            value: _yesNo(record.intravenousThrombolysis),
                          ),
                          InfoCard(
                            label: 'Drug',
                            value: record.thrombolysisDrug ?? '-',
                          ),
                          InfoCard(
                            label: 'Thrombectomy',
                            value: _yesNo(record.thrombectomy),
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Evolution',
                      child: Column(
                        children: [
                          InfoCard(
                            label: 'NIHSS end intervention',
                            value:
                                record.nihssEndIntervention?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'NIHSS 24h',
                            value: record.nihss24h?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'NIHSS exit',
                            value: record.nihssExit?.toString() ?? '-',
                          ),
                          InfoCard(
                            label: 'Hospitalization duration',
                            value: record.hospitalizationDurationDays == null
                                ? '-'
                                : '${record.hospitalizationDurationDays} days',
                          ),
                          InfoCard(label: 'Death', value: _yesNo(record.death)),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Actions',
                      child: Column(
                        children: [
                          AppButton(
                            label: 'Edit AVC dossier',
                            icon: Icons.edit,
                            onPressed: () => _editRecord(record),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Generate PDF',
                            icon: Icons.picture_as_pdf,
                            onPressed: () => _generatePdf(record),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Email report',
                            icon: Icons.email,
                            onPressed: () => _sendByGmail(record),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                              ),
                              onPressed: () => _deleteRecord(record),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete AVC dossier'),
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
