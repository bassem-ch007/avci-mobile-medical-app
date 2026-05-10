import 'package:flutter/material.dart';

import '../models/patient_model.dart';
import '../services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  final PatientService _patientService;

  PatientProvider(this._patientService);

  List<PatientModel> patients = [];
  PatientModel? selectedPatient;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadPatients() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      patients = await _patientService.getAllPatients();
    } catch (e) {
      errorMessage = 'Failed to load patients';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchPatients(String query) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      patients = await _patientService.searchPatients(query);
    } catch (e) {
      errorMessage = 'Search failed';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addPatient(PatientModel patient) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _patientService.addPatient(patient);
      await loadPatients();
      return true;
    } catch (e) {
      errorMessage = 'Failed to add patient';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePatient(PatientModel patient) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _patientService.updatePatient(patient);
      await loadPatients();

      if (patient.id != null) {
        selectedPatient = await _patientService.getPatientById(patient.id!);
      }

      return true;
    } catch (e) {
      errorMessage = 'Failed to update patient';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePatient(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _patientService.deletePatient(id);
      patients.removeWhere((patient) => patient.id == id);

      if (selectedPatient?.id == id) {
        selectedPatient = null;
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete patient';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<PatientModel?> getPatientById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedPatient = await _patientService.getPatientById(id);
    } catch (e) {
      errorMessage = 'Patient not found';
    }

    isLoading = false;
    notifyListeners();

    return selectedPatient;
  }

  Future<int> countPatients() {
    return _patientService.countPatients();
  }
}
