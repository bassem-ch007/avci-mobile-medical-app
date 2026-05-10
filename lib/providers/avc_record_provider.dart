import 'package:flutter/material.dart';

import '../models/avc_record_model.dart';
import '../services/avc_record_service.dart';

class AvcRecordProvider extends ChangeNotifier {
  final AvcRecordService _avcRecordService;

  AvcRecordProvider(this._avcRecordService);

  List<AvcRecordModel> records = [];
  AvcRecordModel? selectedRecord;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRecordsForPatient(int patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      records = await _avcRecordService.getRecordsByPatientId(patientId);
    } catch (e) {
      errorMessage = 'Failed to load AVC records';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<AvcRecordModel?> getRecordById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedRecord = await _avcRecordService.getRecordById(id);
    } catch (e) {
      errorMessage = 'AVC record not found';
    }

    isLoading = false;
    notifyListeners();

    return selectedRecord;
  }

  Future<bool> addRecord(AvcRecordModel record) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _avcRecordService.addRecord(record);
      await loadRecordsForPatient(record.patientId);
      return true;
    } catch (e) {
      errorMessage = 'Failed to add AVC record';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecord(AvcRecordModel record) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _avcRecordService.updateRecord(record);
      await loadRecordsForPatient(record.patientId);

      if (record.id != null) {
        selectedRecord = await _avcRecordService.getRecordById(record.id!);
      }

      return true;
    } catch (e) {
      errorMessage = 'Failed to update AVC record';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecord(int id, int patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _avcRecordService.deleteRecord(id);
      await loadRecordsForPatient(patientId);

      if (selectedRecord?.id == id) {
        selectedRecord = null;
      }

      return true;
    } catch (e) {
      errorMessage = 'Failed to delete AVC record';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<int> countRecords() {
    return _avcRecordService.countRecords();
  }
}
