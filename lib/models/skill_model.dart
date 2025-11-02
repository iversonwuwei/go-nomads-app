/// 技能模型
class Skill {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    try {
      return Skill(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing Skill from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
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
}

/// 用户技能模型
class UserSkill {
  final String id;
  final String userId;
  final String skillId;
  final String skillName;
  final String category;
  final String? icon;
  final String? proficiencyLevel; // beginner, intermediate, advanced, expert
  final int? yearsOfExperience;
  final DateTime createdAt;

  UserSkill({
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

  factory UserSkill.fromJson(Map<String, dynamic> json) {
    return UserSkill(
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
}

/// 按类别分组的技能
class SkillsByCategory {
  final String category;
  final List<Skill> skills;

  SkillsByCategory({
    required this.category,
    required this.skills,
  });

  factory SkillsByCategory.fromJson(Map<String, dynamic> json) {
    try {
      return SkillsByCategory(
        category: json['category'] as String,
        skills: (json['skills'] as List)
            .map((skill) => Skill.fromJson(skill as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing SkillsByCategory from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'skills': skills.map((skill) => skill.toJson()).toList(),
    };
  }
}

/// 添加用户技能请求
class AddUserSkillRequest {
  final String skillId;
  final String? proficiencyLevel;
  final int? yearsOfExperience;

  AddUserSkillRequest({
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
}
