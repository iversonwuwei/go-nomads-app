/// 城市版主模型
class CityModerator {
  final String id;
  final String cityId;
  final String userId;
  final ModeratorUser user;
  final bool canEditCity;
  final bool canManageCoworks;
  final bool canManageCosts;
  final bool canManageVisas;
  final bool canModerateChats;
  final String? assignedBy;
  final DateTime assignedAt;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CityModerator({
    required this.id,
    required this.cityId,
    required this.userId,
    required this.user,
    this.canEditCity = true,
    this.canManageCoworks = true,
    this.canManageCosts = true,
    this.canManageVisas = true,
    this.canModerateChats = true,
    this.assignedBy,
    required this.assignedAt,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityModerator.fromJson(Map<String, dynamic> json) {
    return CityModerator(
      id: json['id'] as String,
      cityId: json['cityId'] as String,
      userId: json['userId'] as String,
      user: ModeratorUser.fromJson(json['user'] as Map<String, dynamic>),
      canEditCity: json['canEditCity'] as bool? ?? true,
      canManageCoworks: json['canManageCoworks'] as bool? ?? true,
      canManageCosts: json['canManageCosts'] as bool? ?? true,
      canManageVisas: json['canManageVisas'] as bool? ?? true,
      canModerateChats: json['canModerateChats'] as bool? ?? true,
      assignedBy: json['assignedBy'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'userId': userId,
      'user': user.toJson(),
      'canEditCity': canEditCity,
      'canManageCoworks': canManageCoworks,
      'canManageCosts': canManageCosts,
      'canManageVisas': canManageVisas,
      'canModerateChats': canModerateChats,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 版主用户信息
class ModeratorUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  ModeratorUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'moderator',
  });

  factory ModeratorUser.fromJson(Map<String, dynamic> json) {
    return ModeratorUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'moderator',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }
}
