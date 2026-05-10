import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/utils/date_helpers.dart';
import '../models/avc_record_model.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';

class PdfService {
  Future<Uint8List> generateAvcReport({
    required UserModel? doctor,
    required PatientModel patient,
    required AvcRecordModel record,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            _header(),
            pw.SizedBox(height: 16),
            _doctorInfo(doctor),
            pw.SizedBox(height: 14),
            _patientInfo(patient),
            pw.SizedBox(height: 14),
            _section(
              title: 'Données épidémiologiques',
              rows: [
                ['Origine', record.origin ?? '-'],
                ['Statut social', record.socialStatus ?? '-'],
                [
                  'Score mRS antérieur',
                  record.previousMrsScore?.toString() ?? '-',
                ],
                ['Couverture sociale', record.coverageType ?? '-'],
                ['Latéralité', record.laterality ?? '-'],
              ],
            ),
            _section(
              title: 'Antécédents médicaux',
              rows: [
                ['Hypertension', _yesNo(record.hypertension)],
                ['Diabète', _yesNo(record.diabetes)],
                ['Hyperlipidémie', _yesNo(record.hyperlipidemia)],
                ['Tabagisme', _yesNo(record.smoking)],
                ['AVC/AIT antérieur', _yesNo(record.previousStroke)],
                ['Pas d’antécédents connus', _yesNo(record.noKnownHistory)],
                ['Traitements en cours', record.currentTreatments ?? '-'],
              ],
            ),
            _section(
              title: 'Phase pré-hospitalière',
              rows: [
                ['Date AVC', DateHelpers.formatDate(record.avcDate)],
                ['Heure AVC', record.avcTime ?? '-'],
                ['AVC du réveil', _yesNo(record.wakeUpStroke)],
                ['Moyen de transport', record.transportMethod ?? '-'],
                [
                  'Délai symptômes-arrivée',
                  record.symptomToArrivalDelayMinutes == null
                      ? '-'
                      : '${record.symptomToArrivalDelayMinutes} min',
                ],
              ],
            ),
            _section(
              title: 'Paramètres cliniques initiaux',
              rows: [
                ['Glycémie', record.glycemia?.toString() ?? '-'],
                [
                  'Pression artérielle',
                  '${record.systolicBloodPressure?.toString() ?? '-'}/${record.diastolicBloodPressure?.toString() ?? '-'} mmHg',
                ],
                ['Score NIHSS', record.nihssScore?.toString() ?? '-'],
                ['Score Glasgow', record.glasgowScore?.toString() ?? '-'],
              ],
            ),
            _section(
              title: 'Imagerie',
              rows: [
                ['Type imagerie', record.imagingType ?? '-'],
                [
                  'Date imagerie',
                  DateHelpers.formatDate(record.imagingDateTime),
                ],
                [
                  'Occlusion artérielle détectée',
                  _yesNo(record.arterialOcclusionDetected),
                ],
                ['Score ASPECTS', record.aspectScore?.toString() ?? '-'],
              ],
            ),
            _section(
              title: 'Traitement',
              rows: [
                [
                  'Thrombolyse intraveineuse',
                  _yesNo(record.intravenousThrombolysis),
                ],
                ['Médicament', record.thrombolysisDrug ?? '-'],
                ['Thrombectomie', _yesNo(record.thrombectomy)],
                ['Heure intervention', record.interventionTime ?? '-'],
              ],
            ),
            _section(
              title: 'Évolution',
              rows: [
                [
                  'NIHSS fin intervention',
                  record.nihssEndIntervention?.toString() ?? '-',
                ],
                ['NIHSS à 24h', record.nihss24h?.toString() ?? '-'],
                ['NIHSS sortie', record.nihssExit?.toString() ?? '-'],
                [
                  'Durée hospitalisation',
                  record.hospitalizationDurationDays == null
                      ? '-'
                      : '${record.hospitalizationDurationDays} jours',
                ],
                ['Décès', _yesNo(record.death)],
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Rapport généré le ${DateHelpers.formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> previewPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  String buildFileName({
    required PatientModel patient,
    required AvcRecordModel record,
  }) {
    final patientName = patient.fullName.replaceAll(' ', '_');
    final recordId = record.id?.toString() ?? 'new';

    return 'rapport_avci_${patientName}_dossier_$recordId.pdf';
  }

  pw.Widget _header() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rapport Médical AVCI',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Dossier clinique AVC ischémique',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _doctorInfo(UserModel? doctor) {
    return _section(
      title: 'Médecin',
      rows: [
        ['Nom', doctor?.fullName ?? '-'],
        ['Email', doctor?.email ?? '-'],
      ],
    );
  }

  pw.Widget _patientInfo(PatientModel patient) {
    return _section(
      title: 'Identité du patient',
      rows: [
        ['Nom complet', patient.fullName],
        ['Téléphone', patient.phone ?? '-'],
        ['Sexe', patient.sex],
        ['Date de naissance', DateHelpers.formatDate(patient.birthDate)],
        ['Âge', '${patient.age} ans'],
        ['Profession', patient.profession ?? '-'],
        ['Statut matrimonial', patient.maritalStatus ?? '-'],
      ],
    );
  }

  pw.Widget _section({
    required String title,
    required List<List<String>> rows,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const ['Champ', 'Valeur'],
            data: rows,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.all(6),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
          ),
        ],
      ),
    );
  }

  String _yesNo(bool value) {
    return value ? 'Oui' : 'Non';
  }
}
