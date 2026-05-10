class DatabaseTables {
  static const String users = 'users';
  static const String patients = 'patients';
  static const String avcRecords = 'avc_records';

  static const String createUsersTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullName TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      createdAt TEXT NOT NULL
    )
  ''';

  static const String createPatientsTable = '''
    CREATE TABLE patients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstName TEXT NOT NULL,
      lastName TEXT NOT NULL,
      phone TEXT,
      sex TEXT NOT NULL,
      birthDate TEXT NOT NULL,
      profession TEXT,
      maritalStatus TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
  ''';

  static const String createAvcRecordsTable = '''
    CREATE TABLE avc_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patientId INTEGER NOT NULL,

      origin TEXT,
      socialStatus TEXT,
      previousMrsScore INTEGER,
      coverageType TEXT,
      laterality TEXT,

      hypertension INTEGER NOT NULL DEFAULT 0,
      diabetes INTEGER NOT NULL DEFAULT 0,
      hyperlipidemia INTEGER NOT NULL DEFAULT 0,
      smoking INTEGER NOT NULL DEFAULT 0,
      previousStroke INTEGER NOT NULL DEFAULT 0,
      noKnownHistory INTEGER NOT NULL DEFAULT 0,
      currentTreatments TEXT,

      avcDate TEXT,
      avcTime TEXT,
      wakeUpStroke INTEGER NOT NULL DEFAULT 0,
      transportMethod TEXT,
      symptomToArrivalDelayMinutes INTEGER,

      glycemia REAL,
      systolicBloodPressure INTEGER,
      diastolicBloodPressure INTEGER,
      nihssScore INTEGER,
      glasgowScore INTEGER,

      imagingType TEXT,
      imagingDateTime TEXT,
      arterialOcclusionDetected INTEGER NOT NULL DEFAULT 0,
      aspectScore INTEGER,

      intravenousThrombolysis INTEGER NOT NULL DEFAULT 0,
      thrombolysisDrug TEXT,
      thrombectomy INTEGER NOT NULL DEFAULT 0,
      interventionTime TEXT,

      nihssEndIntervention INTEGER,
      nihss24h INTEGER,
      nihssExit INTEGER,
      hospitalizationDurationDays INTEGER,
      death INTEGER NOT NULL DEFAULT 0,

      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,

      FOREIGN KEY (patientId) REFERENCES patients(id) ON DELETE CASCADE
    )
  ''';
}
