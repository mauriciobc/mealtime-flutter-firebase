class Household {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final String? inviteCode;
  final List<HouseholdMember> members;
  final String? description;

  Household({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.inviteCode,
    this.members = const [],
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'inviteCode': inviteCode,
      'members': members.map((member) => member.toMap()).toList(),
      'description': description,
    };
  }

  factory Household.fromMap(Map<String, dynamic> map) {
    return Household(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      inviteCode: map['inviteCode'],
      members: (map['members'] as List<dynamic>? ?? [])
          .map((member) => HouseholdMember.fromMap(member))
          .toList(),
      description: map['description'],
    );
  }

  Household copyWith({
    String? id,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    String? inviteCode,
    List<HouseholdMember>? members,
    String? description,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
      description: description ?? this.description,
    );
  }

  bool isAdmin(String userId) {
    return members.any(
      (member) => member.userId == userId && member.role == 'admin',
    );
  }

  bool isMember(String userId) {
    return members.any((member) => member.userId == userId);
  }

  @override
  String toString() {
    return 'Household(id: $id, name: $name, members: ${members.length})';
  }
}

class HouseholdMember {
  final String userId;
  final String role; // 'admin' ou 'member'
  final DateTime joinedAt;
  final String? displayName;
  final String? email;

  HouseholdMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'displayName': displayName,
      'email': email,
    };
  }

  factory HouseholdMember.fromMap(Map<String, dynamic> map) {
    return HouseholdMember(
      userId: map['userId'] ?? '',
      role: map['role'] ?? 'member',
      joinedAt: DateTime.parse(
        map['joinedAt'] ?? DateTime.now().toIso8601String(),
      ),
      displayName: map['displayName'],
      email: map['email'],
    );
  }

  HouseholdMember copyWith({
    String? userId,
    String? role,
    DateTime? joinedAt,
    String? displayName,
    String? email,
  }) {
    return HouseholdMember(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'HouseholdMember(userId: $userId, role: $role, displayName: $displayName)';
  }
}
