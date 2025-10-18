class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> householdIds;
  final String preferredLanguage;
  final String timezone;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.householdIds = const [],
    this.preferredLanguage = 'pt-BR',
    this.timezone = 'America/Sao_Paulo',
    required this.createdAt,
    required this.lastActiveAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'householdIds': householdIds,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      householdIds: List<String>.from(map['householdIds'] ?? []),
      preferredLanguage: map['preferredLanguage'] ?? 'pt-BR',
      timezone: map['timezone'] ?? 'America/Sao_Paulo',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastActiveAt: DateTime.parse(
        map['lastActiveAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? householdIds,
    String? preferredLanguage,
    String? timezone,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      householdIds: householdIds ?? this.householdIds,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, householdIds: $householdIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
