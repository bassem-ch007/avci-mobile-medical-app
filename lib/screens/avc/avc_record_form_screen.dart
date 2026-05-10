import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_helpers.dart';
import '../../core/utils/validators.dart';
import '../../models/avc_record_model.dart';
import '../../providers/avc_record_provider.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/yes_no_field.dart';

class AvcRecordFormScreen extends StatefulWidget {
  final int patientId;
  final AvcRecordModel? record;

  const AvcRecordFormScreen({super.key, required this.patientId, this.record});

  @override
  State<AvcRecordFormScreen> createState() => _AvcRecordFormScreenState();
}

class _AvcRecordFormScreenState extends State<AvcRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  String? _origin;
  String? _socialStatus;
  String? _coverageType;
  String? _laterality;
  String? _transportMethod;
  String? _imagingType;
  String? _thrombolysisDrug;

  bool _hypertension = false;
  bool _diabetes = false;
  bool _hyperlipidemia = false;
  bool _smoking = false;
  bool _previousStroke = false;
  bool _noKnownHistory = false;
  bool _wakeUpStroke = false;
  bool _arterialOcclusionDetected = false;
  bool _intravenousThrombolysis = false;
  bool _thrombectomy = false;
  bool _death = false;

  DateTime? _avcDate;
  DateTime? _imagingDateTime;

  late final TextEditingController _previousMrsController;
  late final TextEditingController _currentTreatmentsController;
  late final TextEditingController _avcTimeController;
  late final TextEditingController _delayController;
  late final TextEditingController _glycemiaController;
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _nihssController;
  late final TextEditingController _glasgowController;
  late final TextEditingController _aspectController;
  late final TextEditingController _interventionTimeController;
  late final TextEditingController _nihssEndController;
  late final TextEditingController _nihss24Controller;
  late final TextEditingController _nihssExitController;
  late final TextEditingController _hospitalizationController;

  bool get _isEditMode => widget.record != null;

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    _origin = record?.origin;
    _socialStatus = record?.socialStatus;
    _coverageType = record?.coverageType;
    _laterality = record?.laterality;
    _transportMethod = record?.transportMethod;
    _imagingType = record?.imagingType;
    _thrombolysisDrug = record?.thrombolysisDrug;

    _hypertension = record?.hypertension ?? false;
    _diabetes = record?.diabetes ?? false;
    _hyperlipidemia = record?.hyperlipidemia ?? false;
    _smoking = record?.smoking ?? false;
    _previousStroke = record?.previousStroke ?? false;
    _noKnownHistory = record?.noKnownHistory ?? false;
    _wakeUpStroke = record?.wakeUpStroke ?? false;
    _arterialOcclusionDetected = record?.arterialOcclusionDetected ?? false;
    _intravenousThrombolysis = record?.intravenousThrombolysis ?? false;
    _thrombectomy = record?.thrombectomy ?? false;
    _death = record?.death ?? false;

    _avcDate = record?.avcDate;
    _imagingDateTime = record?.imagingDateTime;

    _previousMrsController = TextEditingController(
      text: record?.previousMrsScore?.toString() ?? '',
    );
    _currentTreatmentsController = TextEditingController(
      text: record?.currentTreatments ?? '',
    );
    _avcTimeController = TextEditingController(text: record?.avcTime ?? '');
    _delayController = TextEditingController(
      text: record?.symptomToArrivalDelayMinutes?.toString() ?? '',
    );
    _glycemiaController = TextEditingController(
      text: record?.glycemia?.toString() ?? '',
    );
    _systolicController = TextEditingController(
      text: record?.systolicBloodPressure?.toString() ?? '',
    );
    _diastolicController = TextEditingController(
      text: record?.diastolicBloodPressure?.toString() ?? '',
    );
    _nihssController = TextEditingController(
      text: record?.nihssScore?.toString() ?? '',
    );
    _glasgowController = TextEditingController(
      text: record?.glasgowScore?.toString() ?? '',
    );
    _aspectController = TextEditingController(
      text: record?.aspectScore?.toString() ?? '',
    );
    _interventionTimeController = TextEditingController(
      text: record?.interventionTime ?? '',
    );
    _nihssEndController = TextEditingController(
      text: record?.nihssEndIntervention?.toString() ?? '',
    );
    _nihss24Controller = TextEditingController(
      text: record?.nihss24h?.toString() ?? '',
    );
    _nihssExitController = TextEditingController(
      text: record?.nihssExit?.toString() ?? '',
    );
    _hospitalizationController = TextEditingController(
      text: record?.hospitalizationDurationDays?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _previousMrsController.dispose();
    _currentTreatmentsController.dispose();
    _avcTimeController.dispose();
    _delayController.dispose();
    _glycemiaController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _nihssController.dispose();
    _glasgowController.dispose();
    _aspectController.dispose();
    _interventionTimeController.dispose();
    _nihssEndController.dispose();
    _nihss24Controller.dispose();
    _nihssExitController.dispose();
    _hospitalizationController.dispose();
    super.dispose();
  }

  int? _intValue(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  double? _doubleValue(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String? _textValue(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _pickAvcDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _avcDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _avcDate = selected;
      });
    }
  }

  Future<void> _pickImagingDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _imagingDateTime ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _imagingDateTime = selected;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    final record = AvcRecordModel(
      id: widget.record?.id,
      patientId: widget.patientId,
      origin: _origin,
      socialStatus: _socialStatus,
      previousMrsScore: _intValue(_previousMrsController),
      coverageType: _coverageType,
      laterality: _laterality,
      hypertension: _hypertension,
      diabetes: _diabetes,
      hyperlipidemia: _hyperlipidemia,
      smoking: _smoking,
      previousStroke: _previousStroke,
      noKnownHistory: _noKnownHistory,
      currentTreatments: _textValue(_currentTreatmentsController),
      avcDate: _avcDate,
      avcTime: _textValue(_avcTimeController),
      wakeUpStroke: _wakeUpStroke,
      transportMethod: _transportMethod,
      symptomToArrivalDelayMinutes: _intValue(_delayController),
      glycemia: _doubleValue(_glycemiaController),
      systolicBloodPressure: _intValue(_systolicController),
      diastolicBloodPressure: _intValue(_diastolicController),
      nihssScore: _intValue(_nihssController),
      glasgowScore: _intValue(_glasgowController),
      imagingType: _imagingType,
      imagingDateTime: _imagingDateTime,
      arterialOcclusionDetected: _arterialOcclusionDetected,
      aspectScore: _intValue(_aspectController),
      intravenousThrombolysis: _intravenousThrombolysis,
      thrombolysisDrug: _thrombolysisDrug,
      thrombectomy: _thrombectomy,
      interventionTime: _textValue(_interventionTimeController),
      nihssEndIntervention: _intValue(_nihssEndController),
      nihss24h: _intValue(_nihss24Controller),
      nihssExit: _intValue(_nihssExitController),
      hospitalizationDurationDays: _intValue(_hospitalizationController),
      death: _death,
      createdAt: widget.record?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<AvcRecordProvider>();

    final success = _isEditMode
        ? await provider.updateRecord(record)
        : await provider.addRecord(record);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'AVC dossier updated' : 'AVC dossier created',
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Operation failed')),
      );
    }
  }

  void _continue() {
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
    } else {
      _save();
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _dateSelector({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        child: Text(
          value == null ? 'Select date' : DateHelpers.formatDate(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvcRecordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit AVC dossier' : 'Create AVC dossier'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: provider.isLoading ? null : _continue,
              onStepCancel: provider.isLoading ? null : _cancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(_currentStep == 6 ? 'Save' : 'Next'),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Previous'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Epidemiological data'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      AppDropdownField(
                        label: 'Origin',
                        value: _origin,
                        items: const ['Urbaine', 'Rurale', 'Autre'],
                        onChanged: (value) => setState(() => _origin = value),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField(
                        label: 'Social status',
                        value: _socialStatus,
                        items: const ['Actif', 'Retraité', 'Sans activité'],
                        onChanged: (value) =>
                            setState(() => _socialStatus = value),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _previousMrsController,
                        label: 'Previous mRS score',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            Validators.score(value, 'mRS score', 0, 5),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField(
                        label: 'Coverage type',
                        value: _coverageType,
                        items: const ['Sans carnet', 'Indigent', 'Assuré'],
                        onChanged: (value) =>
                            setState(() => _coverageType = value),
                      ),
                      const SizedBox(height: 12),
                      AppDropdownField(
                        label: 'Laterality',
                        value: _laterality,
                        items: const ['Droitier', 'Gaucher'],
                        onChanged: (value) =>
                            setState(() => _laterality = value),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Medical history'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      YesNoField(
                        label: 'Hypertension',
                        value: _hypertension,
                        onChanged: (v) => setState(() => _hypertension = v),
                      ),
                      YesNoField(
                        label: 'Diabetes',
                        value: _diabetes,
                        onChanged: (v) => setState(() => _diabetes = v),
                      ),
                      YesNoField(
                        label: 'Hyperlipidemia',
                        value: _hyperlipidemia,
                        onChanged: (v) => setState(() => _hyperlipidemia = v),
                      ),
                      YesNoField(
                        label: 'Smoking',
                        value: _smoking,
                        onChanged: (v) => setState(() => _smoking = v),
                      ),
                      YesNoField(
                        label: 'Previous AVC/AIT',
                        value: _previousStroke,
                        onChanged: (v) => setState(() => _previousStroke = v),
                      ),
                      YesNoField(
                        label: 'No known history',
                        value: _noKnownHistory,
                        onChanged: (v) => setState(() => _noKnownHistory = v),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _currentTreatmentsController,
                        label: 'Current treatments',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Pre-hospital phase'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      _dateSelector(
                        label: 'AVC date',
                        value: _avcDate,
                        onTap: _pickAvcDate,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _avcTimeController,
                        label: 'AVC time',
                        hint: 'Example: 14:30',
                      ),
                      YesNoField(
                        label: 'Wake-up stroke',
                        value: _wakeUpStroke,
                        onChanged: (v) => setState(() => _wakeUpStroke = v),
                      ),
                      AppDropdownField(
                        label: 'Transport method',
                        value: _transportMethod,
                        items: const [
                          'SAMU',
                          'Ambulance privée',
                          'Protection civile',
                          'Transport privé',
                          'Transport public',
                          'Autre',
                        ],
                        onChanged: (value) =>
                            setState(() => _transportMethod = value),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _delayController,
                        label: 'Symptoms to arrival delay in minutes',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            Validators.positiveNumber(value, 'Delay'),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Clinical parameters'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    children: [
                      AppTextField(
                        controller: _glycemiaController,
                        label: 'Glycemia',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.positiveNumber(v, 'Glycemia'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _systolicController,
                        label: 'Systolic blood pressure',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.positiveNumber(
                          v,
                          'Systolic blood pressure',
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _diastolicController,
                        label: 'Diastolic blood pressure',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.positiveNumber(
                          v,
                          'Diastolic blood pressure',
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nihssController,
                        label: 'NIHSS score',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.score(v, 'NIHSS', 0, 42),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _glasgowController,
                        label: 'Glasgow score',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.score(v, 'Glasgow', 3, 15),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Imaging'),
                  isActive: _currentStep >= 4,
                  content: Column(
                    children: [
                      AppDropdownField(
                        label: 'Imaging type',
                        value: _imagingType,
                        items: const [
                          'TDM',
                          'TDM + AngioTDM',
                          'IRM',
                          'Other hospital',
                        ],
                        onChanged: (value) =>
                            setState(() => _imagingType = value),
                      ),
                      const SizedBox(height: 12),
                      _dateSelector(
                        label: 'Imaging date',
                        value: _imagingDateTime,
                        onTap: _pickImagingDate,
                      ),
                      const SizedBox(height: 12),
                      YesNoField(
                        label: 'Arterial occlusion detected',
                        value: _arterialOcclusionDetected,
                        onChanged: (v) =>
                            setState(() => _arterialOcclusionDetected = v),
                      ),
                      AppTextField(
                        controller: _aspectController,
                        label: 'ASPECTS score',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.score(v, 'ASPECTS', 0, 10),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Treatment'),
                  isActive: _currentStep >= 5,
                  content: Column(
                    children: [
                      YesNoField(
                        label: 'Intravenous thrombolysis',
                        value: _intravenousThrombolysis,
                        onChanged: (v) =>
                            setState(() => _intravenousThrombolysis = v),
                      ),
                      AppDropdownField(
                        label: 'Thrombolysis drug',
                        value: _thrombolysisDrug,
                        items: const [
                          'Alteplase',
                          'Tenecteplase',
                          'Streptokinase',
                          'Staphylokinase',
                        ],
                        onChanged: (value) =>
                            setState(() => _thrombolysisDrug = value),
                      ),
                      const SizedBox(height: 12),
                      YesNoField(
                        label: 'Thrombectomy',
                        value: _thrombectomy,
                        onChanged: (v) => setState(() => _thrombectomy = v),
                      ),
                      AppTextField(
                        controller: _interventionTimeController,
                        label: 'Intervention time',
                        hint: 'Example: 16:00',
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Evolution'),
                  isActive: _currentStep >= 6,
                  content: Column(
                    children: [
                      AppTextField(
                        controller: _nihssEndController,
                        label: 'NIHSS end intervention',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.score(
                          v,
                          'NIHSS end intervention',
                          0,
                          42,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nihss24Controller,
                        label: 'NIHSS 24h',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.score(v, 'NIHSS 24h', 0, 42),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nihssExitController,
                        label: 'NIHSS exit',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            Validators.score(v, 'NIHSS exit', 0, 42),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _hospitalizationController,
                        label: 'Hospitalization duration in days',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.positiveNumber(
                          v,
                          'Hospitalization duration',
                        ),
                      ),
                      YesNoField(
                        label: 'Death',
                        value: _death,
                        onChanged: (v) => setState(() => _death = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
