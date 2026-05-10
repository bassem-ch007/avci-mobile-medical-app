import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/avc_record_model.dart';

class AvcRecordService {
  final AppDatabase _database = AppDatabase.instance;

  Future<List<AvcRecordModel>> getRecordsByPatientId(int patientId) async {
    final result = await _database.query(
      DatabaseTables.avcRecords,
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'updatedAt DESC',
    );

    return result.map(AvcRecordModel.fromMap).toList();
  }

  Future<AvcRecordModel?> getRecordById(int id) async {
    final result = await _database.query(
      DatabaseTables.avcRecords,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return AvcRecordModel.fromMap(result.first);
  }

  Future<int> addRecord(AvcRecordModel record) async {
    return _database.insert(DatabaseTables.avcRecords, record.toMap());
  }

  Future<void> updateRecord(AvcRecordModel record) async {
    if (record.id == null) {
      throw Exception('AVC record ID is required');
    }

    await _database.update(
      DatabaseTables.avcRecords,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(int id) async {
    await _database.delete(
      DatabaseTables.avcRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countRecords() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.avcRecords}',
    );

    return result.first['count'] as int;
  }
}
