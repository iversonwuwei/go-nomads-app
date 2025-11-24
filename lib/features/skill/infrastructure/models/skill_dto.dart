import 'package:df_admin_mobile/features/skill/domain/entities/skill.dart'
    as domain;

/// Skill DTO
class SkillDto {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  SkillDto({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory SkillDto.fromJson(Map<String, dynamic> json) {
    return SkillDto(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  domain.Skill toDomain() {
    return domain.Skill(
      id: id,
      name: name,
      category: category,
      description: description,
      icon: icon,
      createdAt: createdAt,
    );
  }
}

/// UserSkill DTO
class UserSkillDto {
  final String id;
  final String userId;
  final String skillId;
  final String skillName;
  final String category;
  final String? icon;
  final String? proficiencyLevel;
  final int? yearsOfExperience;
  final DateTime createdAt;

  UserSkillDto({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.skillName,
    required this.category,
    this.icon,
    this.proficiencyLevel,
    this.yearsOfExperience,
    required this.createdAt,
  });

  factory UserSkillDto.fromJson(Map<String, dynamic> json) {
    return UserSkillDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      skillId: json['skillId'] as String,
      skillName: json['skillName'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'skillId': skillId,
      'skillName': skillName,
      'category': category,
      'icon': icon,
      'proficiencyLevel': proficiencyLevel,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  domain.UserSkill toDomain() {
    return domain.UserSkill(
      id: id,
      userId: userId,
      skillId: skillId,
      skillName: skillName,
      category: category,
      icon: icon,
      proficiencyLevel: proficiencyLevel,
      yearsOfExperience: yearsOfExperience,
      createdAt: createdAt,
    );
  }
}

/// SkillsByCategory DTO
class SkillsByCategoryDto {
  final String category;
  final List<SkillDto> skills;

  SkillsByCategoryDto({
    required this.category,
    required this.skills,
  });

  factory SkillsByCategoryDto.fromJson(Map<String, dynamic> json) {
    return SkillsByCategoryDto(
      category: json['category'] as String,
      skills: (json['skills'] as List)
          .map((skill) => SkillDto.fromJson(skill as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'skills': skills.map((skill) => skill.toJson()).toList(),
    };
  }

  domain.SkillsByCategory toDomain() {
    return domain.SkillsByCategory(
      category: category,
      skills: skills.map((s) => s.toDomain()).toList(),
    );
  }
}

/// AddUserSkillRequest DTO
class AddUserSkillRequestDto {
  final String skillId;
  final String? proficiencyLevel;
  final int? yearsOfExperience;

  AddUserSkillRequestDto({
    required this.skillId,
    this.proficiencyLevel,
    this.yearsOfExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'proficiencyLevel': proficiencyLevel,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  domain.AddUserSkillRequest toDomain() {
    return domain.AddUserSkillRequest(
      skillId: skillId,
      proficiencyLevel: proficiencyLevel,
      yearsOfExperience: yearsOfExperience,
    );
  }
}
