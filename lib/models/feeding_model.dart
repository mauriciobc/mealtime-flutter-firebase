class Feeding {
  final String id;
  final String catId;
  final String householdId;
  final String fedBy; // userId
  final DateTime timestamp;
  final double? portionSize;
  final String? notes;
  final String? foodType;
  final bool wasEaten; // Se o gato realmente comeu

  Feeding({
    required this.id,
    required this.catId,
    required this.householdId,
    required this.fedBy,
    required this.timestamp,
    this.portionSize,
    this.notes,
    this.foodType,
    this.wasEaten = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catId': catId,
      'householdId': householdId,
      'fedBy': fedBy,
      'timestamp': timestamp.toIso8601String(),
      'portionSize': portionSize,
      'notes': notes,
      'foodType': foodType,
      'wasEaten': wasEaten,
    };
  }

  factory Feeding.fromMap(Map<String, dynamic> map) {
    return Feeding(
      id: map['id'] ?? '',
      catId: map['catId'] ?? '',
      householdId: map['householdId'] ?? '',
      fedBy: map['fedBy'] ?? '',
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      portionSize: map['portionSize']?.toDouble(),
      notes: map['notes'],
      foodType: map['foodType'],
      wasEaten: map['wasEaten'] ?? true,
    );
  }

  Feeding copyWith({
    String? id,
    String? catId,
    String? householdId,
    String? fedBy,
    DateTime? timestamp,
    double? portionSize,
    String? notes,
    String? foodType,
    bool? wasEaten,
  }) {
    return Feeding(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      householdId: householdId ?? this.householdId,
      fedBy: fedBy ?? this.fedBy,
      timestamp: timestamp ?? this.timestamp,
      portionSize: portionSize ?? this.portionSize,
      notes: notes ?? this.notes,
      foodType: foodType ?? this.foodType,
      wasEaten: wasEaten ?? this.wasEaten,
    );
  }

  @override
  String toString() {
    return 'Feeding(id: $id, catId: $catId, fedBy: $fedBy, timestamp: $timestamp)';
  }
}

class FeedingStats {
  final int totalFeedings;
  final int successfulFeedings;
  final double averagePortionSize;
  final DateTime? lastFeeding;
  final Map<String, int> feedingsByUser;
  final Map<String, int> feedingsByDayOfWeek;

  FeedingStats({
    required this.totalFeedings,
    required this.successfulFeedings,
    required this.averagePortionSize,
    this.lastFeeding,
    this.feedingsByUser = const {},
    this.feedingsByDayOfWeek = const {},
  });

  double get successRate {
    if (totalFeedings == 0) return 0.0;
    return (successfulFeedings / totalFeedings) * 100;
  }

  int get daysSinceLastFeeding {
    if (lastFeeding == null) return -1;
    return DateTime.now().difference(lastFeeding!).inDays;
  }

  @override
  String toString() {
    return 'FeedingStats(total: $totalFeedings, success: $successfulFeedings, avgPortion: $averagePortionSize)';
  }
}
