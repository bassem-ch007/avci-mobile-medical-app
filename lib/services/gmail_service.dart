import 'package:url_launcher/url_launcher.dart';

class GmailService {
  Future<void> openGmailCompose({
    required String subject,
    required String body,
  }) async {
    final gmailUri = Uri.https('mail.google.com', '/mail/', {
      'view': 'cm',
      'fs': '1',
      'su': subject,
      'body': body,
    });

    final opened = await launchUrl(
      gmailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      final mailtoUri = Uri(
        scheme: 'mailto',
        queryParameters: {'subject': subject, 'body': body},
      );

      final fallbackOpened = await launchUrl(
        mailtoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!fallbackOpened) {
        throw Exception('Unable to open Gmail or email application');
      }
    }
  }

  String buildEmailBody({
    required String patientName,
    required String fileName,
  }) {
    return '''
  Bonjour,

  Veuillez trouver le rapport médical AVCI du patient $patientName.

  Nom du fichier PDF généré :
  $fileName

  Note :
  Si le navigateur ne joint pas automatiquement le PDF, veuillez télécharger le rapport généré puis l’attacher manuellement à cet e-mail.

  Cordialement.
  ''';
  }
}
