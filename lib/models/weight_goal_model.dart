import 'package:cloud_firestore/cloud_firestore.dart';

class WeightGoal {
  final String catId;
  final double? targetWeight;
  final String goalType;
  final String? reminderFrequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  WeightGoal({
    required this.catId,
    this.targetWeight,
    required this.goalType,
    this.reminderFrequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  factory WeightGoal.fromMap(Map<String, dynamic> map) {
    return WeightGoal(
      catId: map['catId'],
      targetWeight: map['targetWeight']?.toDouble(),
      goalType: map['goalType'],
      reminderFrequency: map['reminderFrequency'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catId': catId,
      'targetWeight': targetWeight,
      'goalType': goalType,
      'reminderFrequency': reminderFrequency,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
    };
  }
}
