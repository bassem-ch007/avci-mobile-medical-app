import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/avc_record_provider.dart';
import 'services/auth_service.dart';
import 'services/patient_service.dart';
import 'services/avc_record_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..checkSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientProvider(PatientService()),
        ),
        ChangeNotifierProvider(
          create: (_) => AvcRecordProvider(AvcRecordService()),
        ),
      ],
      child: const AvciMedicalApp(),
    ),
  );
}
