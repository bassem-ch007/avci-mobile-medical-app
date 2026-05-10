import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/patient_model.dart';

class PatientService {
  final AppDatabase _database = AppDatabase.instance;

  Future<List<PatientModel>> getAllPatients() async {
    final result = await _database.query(
      DatabaseTables.patients,
      orderBy: 'updatedAt DESC',
    );

    return result.map(PatientModel.fromMap).toList();
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return getAllPatients();
    }

    final result = await _database.rawQuery(
      '''
      SELECT * FROM ${DatabaseTables.patients}
      WHERE firstName LIKE ?
         OR lastName LIKE ?
         OR phone LIKE ?
      ORDER BY updatedAt DESC
      ''',
      ['%$cleanQuery%', '%$cleanQuery%', '%$cleanQuery%'],
    );

    return result.map(PatientModel.fromMap).toList();
  }

  Future<PatientModel?> getPatientById(int id) async {
    final result = await _database.query(
      DatabaseTables.patients,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return PatientModel.fromMap(result.first);
  }

  Future<int> addPatient(PatientModel patient) async {
    return _database.insert(DatabaseTables.patients, patient.toMap());
  }

  Future<void> updatePatient(PatientModel patient) async {
    if (patient.id == null) {
      throw Exception('Patient ID is required');
    }

    await _database.update(
      DatabaseTables.patients,
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<void> deletePatient(int id) async {
    await _database.delete(
      DatabaseTables.patients,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countPatients() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.patients}',
    );

    return result.first['count'] as int;
  }
}
