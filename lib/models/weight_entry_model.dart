class WeightEntry {
  final String id;
  final String catId;
  final double weight; // em kg
  final DateTime timestamp;
  final String loggedBy; // userId
  final String? notes;
  final String? measurementType; // 'manual', 'scale', 'vet'

  WeightEntry({
    required this.id,
    required this.catId,
    required this.weight,
    required this.timestamp,
    required this.loggedBy,
    this.notes,
    this.measurementType = 'manual',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catId': catId,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'loggedBy': loggedBy,
      'notes': notes,
      'measurementType': measurementType,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] ?? '',
      catId: map['catId'] ?? '',
      weight: map['weight']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      loggedBy: map['loggedBy'] ?? '',
      notes: map['notes'],
      measurementType: map['measurementType'] ?? 'manual',
    );
  }

  WeightEntry copyWith({
    String? id,
    String? catId,
    double? weight,
    DateTime? timestamp,
    String? loggedBy,
    String? notes,
    String? measurementType,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      weight: weight ?? this.weight,
      timestamp: timestamp ?? this.timestamp,
      loggedBy: loggedBy ?? this.loggedBy,
      notes: notes ?? this.notes,
      measurementType: measurementType ?? this.measurementType,
    );
  }

  @override
  String toString() {
    return 'WeightEntry(id: $id, catId: $catId, weight: ${weight}kg, timestamp: $timestamp)';
  }
}

class WeightGoal {
  final String catId;
  final double? targetWeight;
  final String goalType; // 'lose', 'maintain', 'gain'
  final String? reminderFrequency; // 'daily', 'weekly', 'monthly'
  final DateTime? startDate;
  final DateTime? targetDate;
  final bool isActive;
  final String? notes;

  WeightGoal({
    required this.catId,
    this.targetWeight,
    required this.goalType,
    this.reminderFrequency,
    this.startDate,
    this.targetDate,
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'catId': catId,
      'targetWeight': targetWeight,
      'goalType': goalType,
      'reminderFrequency': reminderFrequency,
      'startDate': startDate?.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
    };
  }

  factory WeightGoal.fromMap(Map<String, dynamic> map) {
    return WeightGoal(
      catId: map['catId'] ?? '',
      targetWeight: map['targetWeight']?.toDouble(),
      goalType: map['goalType'] ?? 'maintain',
      reminderFrequency: map['reminderFrequency'],
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate']) 
          : null,
      targetDate: map['targetDate'] != null 
          ? DateTime.parse(map['targetDate']) 
          : null,
      isActive: map['isActive'] ?? true,
      notes: map['notes'],
    );
  }

  WeightGoal copyWith({
    String? catId,
    double? targetWeight,
    String? goalType,
    String? reminderFrequency,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isActive,
    String? notes,
  }) {
    return WeightGoal(
      catId: catId ?? this.catId,
      targetWeight: targetWeight ?? this.targetWeight,
      goalType: goalType ?? this.goalType,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'WeightGoal(catId: $catId, goalType: $goalType, targetWeight: $targetWeight)';
  }
}

class WeightTrend {
  final List<WeightEntry> entries;
  final double? averageWeight;
  final double? weightChange; // mudança em kg
  final int daysTracked;
  final String trend; // 'increasing', 'decreasing', 'stable'

  WeightTrend({
    required this.entries,
    this.averageWeight,
    this.weightChange,
    required this.daysTracked,
    required this.trend,
  });

  factory WeightTrend.fromEntries(List<WeightEntry> entries) {
    if (entries.isEmpty) {
      return WeightTrend(
        entries: entries,
        daysTracked: 0,
        trend: 'stable',
      );
    }

    // Ordenar por timestamp
    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final weights = sortedEntries.map((e) => e.weight).toList();
    final averageWeight = weights.reduce((a, b) => a + b) / weights.length;
    
    double weightChange = 0.0;
    String trend = 'stable';
    
    if (weights.length > 1) {
      weightChange = weights.last - weights.first;
      if (weightChange > 0.1) {
        trend = 'increasing';
      } else if (weightChange < -0.1) {
        trend = 'decreasing';
      }
    }

    final daysTracked = sortedEntries.isNotEmpty
        ? DateTime.now().difference(sortedEntries.first.timestamp).inDays + 1
        : 0;

    return WeightTrend(
      entries: sortedEntries,
      averageWeight: averageWeight,
      weightChange: weightChange,
      daysTracked: daysTracked,
      trend: trend,
    );
  }

  @override
  String toString() {
    return 'WeightTrend(entries: ${entries.length}, trend: $trend, change: ${weightChange}kg)';
  }
}
