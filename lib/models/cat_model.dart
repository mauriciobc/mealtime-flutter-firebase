class Cat {
  final String id;
  final String householdId;
  final String name;
  final String? photoUrl;
  final DateTime? birthdate;
  final double? currentWeight;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final List<String>? groups;
  final FeedingSchedule schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cat({
    required this.id,
    required this.householdId,
    required this.name,
    this.photoUrl,
    this.birthdate,
    this.currentWeight,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.groups,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdId': householdId,
      'name': name,
      'photoUrl': photoUrl,
      'birthdate': birthdate?.toIso8601String(),
      'currentWeight': currentWeight,
      'dietaryRestrictions': dietaryRestrictions,
      'medicalNotes': medicalNotes,
      'groups': groups,
      'schedule': schedule.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    return Cat(
      id: map['id'] ?? '',
      householdId: map['householdId'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      birthdate: map['birthdate'] != null 
          ? DateTime.parse(map['birthdate']) 
          : null,
      currentWeight: map['currentWeight']?.toDouble(),
      dietaryRestrictions: map['dietaryRestrictions'],
      medicalNotes: map['medicalNotes'],
      groups: map['groups'] != null 
          ? List<String>.from(map['groups']) 
          : null,
      schedule: FeedingSchedule.fromMap(map['schedule'] ?? {}),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Cat copyWith({
    String? id,
    String? householdId,
    String? name,
    String? photoUrl,
    DateTime? birthdate,
    double? currentWeight,
    String? dietaryRestrictions,
    String? medicalNotes,
    List<String>? groups,
    FeedingSchedule? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cat(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      birthdate: birthdate ?? this.birthdate,
      currentWeight: currentWeight ?? this.currentWeight,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      groups: groups ?? this.groups,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int? get ageInMonths {
    if (birthdate == null) return null;
    final now = DateTime.now();
    final age = now.difference(birthdate!);
    return (age.inDays / 30.44).round();
  }

  @override
  String toString() {
    return 'Cat(id: $id, name: $name, householdId: $householdId)';
  }
}

class FeedingSchedule {
  final String type; // 'interval' ou 'fixed'
  final int? intervalHours; // Para type='interval'
  final List<String>? fixedTimes; // Para type='fixed', ex: ['08:00', '18:00']
  final DateTime? overrideUntil; // Alteração temporária até data
  final bool isActive;

  FeedingSchedule({
    required this.type,
    this.intervalHours,
    this.fixedTimes,
    this.overrideUntil,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'intervalHours': intervalHours,
      'fixedTimes': fixedTimes,
      'overrideUntil': overrideUntil?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      type: map['type'] ?? 'fixed',
      intervalHours: map['intervalHours'],
      fixedTimes: map['fixedTimes'] != null 
          ? List<String>.from(map['fixedTimes']) 
          : null,
      overrideUntil: map['overrideUntil'] != null 
          ? DateTime.parse(map['overrideUntil']) 
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  FeedingSchedule copyWith({
    String? type,
    int? intervalHours,
    List<String>? fixedTimes,
    DateTime? overrideUntil,
    bool? isActive,
  }) {
    return FeedingSchedule(
      type: type ?? this.type,
      intervalHours: intervalHours ?? this.intervalHours,
      fixedTimes: fixedTimes ?? this.fixedTimes,
      overrideUntil: overrideUntil ?? this.overrideUntil,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isOverridden {
    return overrideUntil != null && DateTime.now().isBefore(overrideUntil!);
  }

  @override
  String toString() {
    return 'FeedingSchedule(type: $type, intervalHours: $intervalHours, fixedTimes: $fixedTimes)';
  }
}
