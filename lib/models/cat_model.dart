import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ScheduleType { fixedInterval, specificTimes }

class FeedingSchedule {
  final ScheduleType type;
  final int? intervalHours;
  final List<TimeOfDay>? specificTimes;
  final bool isActive;
  final DateTime? lastFed;
  final String? notes;

  FeedingSchedule({
    required this.type,
    this.intervalHours,
    this.specificTimes,
    this.isActive = true,
    this.lastFed,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'intervalHours': intervalHours,
      'specificTimes': specificTimes?.map((time) => '${time.hour}:${time.minute}').toList(),
      'isActive': isActive,
      'lastFed': lastFed != null ? Timestamp.fromDate(lastFed!) : null,
      'notes': notes,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      type: (map['type'] as String) == ScheduleType.specificTimes.toString()
          ? ScheduleType.specificTimes
          : ScheduleType.fixedInterval,
      intervalHours: map['intervalHours'],
      specificTimes: (map['specificTimes'] as List<dynamic>?)
          ?.map((timeStr) {
            final parts = timeStr.split(':');
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          })
          .toList(),
      isActive: map['isActive'] ?? true,
      lastFed: (map['lastFed'] as Timestamp?)?.toDate(),
      notes: map['notes'],
    );
  }
}

class Cat {
  final String id;
  final String name;
  final String? photoUrl;
  final DateTime? birthdate;
  final double? currentWeight;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final List<String>? groups;
  final FeedingSchedule schedule;

  Cat({
    required this.id,
    required this.name,
    this.photoUrl,
    this.birthdate,
    this.currentWeight,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.groups,
    required this.schedule,
  });

  factory Cat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Cat(
      id: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      birthdate: (data['birthdate'] as Timestamp?)?.toDate(),
      currentWeight: (data['currentWeight'] as num?)?.toDouble(),
      dietaryRestrictions: data['dietaryRestrictions'],
      medicalNotes: data['medicalNotes'],
      groups: data['groups'] != null ? List<String>.from(data['groups']) : null,
      schedule: data['schedule'] != null
          ? FeedingSchedule.fromMap(Map<String, dynamic>.from(data['schedule']))
          : FeedingSchedule(type: ScheduleType.fixedInterval, intervalHours: 8),
    );
  }
    factory Cat.fromMap(Map<String, dynamic> data, String id) {
    return Cat(
      id: id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      birthdate: data['birthdate'] != null ? DateTime.parse(data['birthdate']) : null,
      currentWeight: (data['currentWeight'] as num?)?.toDouble(),
      dietaryRestrictions: data['dietaryRestrictions'],
      medicalNotes: data['medicalNotes'],
      groups: data['groups'] != null ? List<String>.from(data['groups']) : null,
      schedule: data['schedule'] != null
          ? FeedingSchedule.fromMap(Map<String, dynamic>.from(data['schedule']))
          : FeedingSchedule(type: ScheduleType.fixedInterval, intervalHours: 8),
    );
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

    factory WeightEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return WeightEntry(
      date: (data['date'] as Timestamp).toDate(),
      weight: (data['weight'] as num).toDouble(),
    );
  }
}
