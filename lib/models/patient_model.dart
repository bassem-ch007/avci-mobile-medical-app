import '../core/utils/date_helpers.dart';

class PatientModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String sex;
  final DateTime birthDate;
  final String? profession;
  final String? maritalStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.sex,
    required this.birthDate,
    this.profession,
    this.maritalStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  int get age => DateHelpers.ageFromBirthDate(birthDate);

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as int?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phone: map['phone'] as String?,
      sex: map['sex'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      profession: map['profession'] as String?,
      maritalStatus: map['maritalStatus'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'sex': sex,
      'birthDate': birthDate.toIso8601String(),
      'profession': profession,
      'maritalStatus': maritalStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PatientModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? sex,
    DateTime? birthDate,
    String? profession,
    String? maritalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      profession: profession ?? this.profession,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
