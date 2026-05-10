import '../core/utils/sqlite_helpers.dart';

class AvcRecordModel {
  final int? id;
  final int patientId;

  final String? origin;
  final String? socialStatus;
  final int? previousMrsScore;
  final String? coverageType;
  final String? laterality;

  final bool hypertension;
  final bool diabetes;
  final bool hyperlipidemia;
  final bool smoking;
  final bool previousStroke;
  final bool noKnownHistory;
  final String? currentTreatments;

  final DateTime? avcDate;
  final String? avcTime;
  final bool wakeUpStroke;
  final String? transportMethod;
  final int? symptomToArrivalDelayMinutes;

  final double? glycemia;
  final int? systolicBloodPressure;
  final int? diastolicBloodPressure;
  final int? nihssScore;
  final int? glasgowScore;

  final String? imagingType;
  final DateTime? imagingDateTime;
  final bool arterialOcclusionDetected;
  final int? aspectScore;

  final bool intravenousThrombolysis;
  final String? thrombolysisDrug;
  final bool thrombectomy;
  final String? interventionTime;

  final int? nihssEndIntervention;
  final int? nihss24h;
  final int? nihssExit;
  final int? hospitalizationDurationDays;
  final bool death;

  final DateTime createdAt;
  final DateTime updatedAt;

  AvcRecordModel({
    this.id,
    required this.patientId,
    this.origin,
    this.socialStatus,
    this.previousMrsScore,
    this.coverageType,
    this.laterality,
    this.hypertension = false,
    this.diabetes = false,
    this.hyperlipidemia = false,
    this.smoking = false,
    this.previousStroke = false,
    this.noKnownHistory = false,
    this.currentTreatments,
    this.avcDate,
    this.avcTime,
    this.wakeUpStroke = false,
    this.transportMethod,
    this.symptomToArrivalDelayMinutes,
    this.glycemia,
    this.systolicBloodPressure,
    this.diastolicBloodPressure,
    this.nihssScore,
    this.glasgowScore,
    this.imagingType,
    this.imagingDateTime,
    this.arterialOcclusionDetected = false,
    this.aspectScore,
    this.intravenousThrombolysis = false,
    this.thrombolysisDrug,
    this.thrombectomy = false,
    this.interventionTime,
    this.nihssEndIntervention,
    this.nihss24h,
    this.nihssExit,
    this.hospitalizationDurationDays,
    this.death = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvcRecordModel.fromMap(Map<String, dynamic> map) {
    return AvcRecordModel(
      id: map['id'] as int?,
      patientId: map['patientId'] as int,
      origin: map['origin'] as String?,
      socialStatus: map['socialStatus'] as String?,
      previousMrsScore: map['previousMrsScore'] as int?,
      coverageType: map['coverageType'] as String?,
      laterality: map['laterality'] as String?,
      hypertension: SqliteHelpers.intToBool(map['hypertension']),
      diabetes: SqliteHelpers.intToBool(map['diabetes']),
      hyperlipidemia: SqliteHelpers.intToBool(map['hyperlipidemia']),
      smoking: SqliteHelpers.intToBool(map['smoking']),
      previousStroke: SqliteHelpers.intToBool(map['previousStroke']),
      noKnownHistory: SqliteHelpers.intToBool(map['noKnownHistory']),
      currentTreatments: map['currentTreatments'] as String?,
      avcDate: SqliteHelpers.stringToDate(map['avcDate']),
      avcTime: map['avcTime'] as String?,
      wakeUpStroke: SqliteHelpers.intToBool(map['wakeUpStroke']),
      transportMethod: map['transportMethod'] as String?,
      symptomToArrivalDelayMinutes: map['symptomToArrivalDelayMinutes'] as int?,
      glycemia: (map['glycemia'] as num?)?.toDouble(),
      systolicBloodPressure: map['systolicBloodPressure'] as int?,
      diastolicBloodPressure: map['diastolicBloodPressure'] as int?,
      nihssScore: map['nihssScore'] as int?,
      glasgowScore: map['glasgowScore'] as int?,
      imagingType: map['imagingType'] as String?,
      imagingDateTime: SqliteHelpers.stringToDate(map['imagingDateTime']),
      arterialOcclusionDetected: SqliteHelpers.intToBool(
        map['arterialOcclusionDetected'],
      ),
      aspectScore: map['aspectScore'] as int?,
      intravenousThrombolysis: SqliteHelpers.intToBool(
        map['intravenousThrombolysis'],
      ),
      thrombolysisDrug: map['thrombolysisDrug'] as String?,
      thrombectomy: SqliteHelpers.intToBool(map['thrombectomy']),
      interventionTime: map['interventionTime'] as String?,
      nihssEndIntervention: map['nihssEndIntervention'] as int?,
      nihss24h: map['nihss24h'] as int?,
      nihssExit: map['nihssExit'] as int?,
      hospitalizationDurationDays: map['hospitalizationDurationDays'] as int?,
      death: SqliteHelpers.intToBool(map['death']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'origin': origin,
      'socialStatus': socialStatus,
      'previousMrsScore': previousMrsScore,
      'coverageType': coverageType,
      'laterality': laterality,
      'hypertension': SqliteHelpers.boolToInt(hypertension),
      'diabetes': SqliteHelpers.boolToInt(diabetes),
      'hyperlipidemia': SqliteHelpers.boolToInt(hyperlipidemia),
      'smoking': SqliteHelpers.boolToInt(smoking),
      'previousStroke': SqliteHelpers.boolToInt(previousStroke),
      'noKnownHistory': SqliteHelpers.boolToInt(noKnownHistory),
      'currentTreatments': currentTreatments,
      'avcDate': SqliteHelpers.nullableDateToString(avcDate),
      'avcTime': avcTime,
      'wakeUpStroke': SqliteHelpers.boolToInt(wakeUpStroke),
      'transportMethod': transportMethod,
      'symptomToArrivalDelayMinutes': symptomToArrivalDelayMinutes,
      'glycemia': glycemia,
      'systolicBloodPressure': systolicBloodPressure,
      'diastolicBloodPressure': diastolicBloodPressure,
      'nihssScore': nihssScore,
      'glasgowScore': glasgowScore,
      'imagingType': imagingType,
      'imagingDateTime': SqliteHelpers.nullableDateToString(imagingDateTime),
      'arterialOcclusionDetected': SqliteHelpers.boolToInt(
        arterialOcclusionDetected,
      ),
      'aspectScore': aspectScore,
      'intravenousThrombolysis': SqliteHelpers.boolToInt(
        intravenousThrombolysis,
      ),
      'thrombolysisDrug': thrombolysisDrug,
      'thrombectomy': SqliteHelpers.boolToInt(thrombectomy),
      'interventionTime': interventionTime,
      'nihssEndIntervention': nihssEndIntervention,
      'nihss24h': nihss24h,
      'nihssExit': nihssExit,
      'hospitalizationDurationDays': hospitalizationDurationDays,
      'death': SqliteHelpers.boolToInt(death),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
