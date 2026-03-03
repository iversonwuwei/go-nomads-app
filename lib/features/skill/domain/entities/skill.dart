/// Skill Domain Entity - 技能
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

  // Business logic methods
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasIcon => icon != null && icon!.isNotEmpty;
}

/// UserSkill Domain Entity - 用户技能
class UserSkill {
  final String id;
  final String userId;
  final String skillId;
  final String skillName;
  final String category;
  final String? icon;
  final String? proficiencyLevel;
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

  // Business logic methods
  bool get isBeginner => proficiencyLevel?.toLowerCase() == 'beginner';
  bool get isIntermediate => proficiencyLevel?.toLowerCase() == 'intermediate';
  bool get isAdvanced => proficiencyLevel?.toLowerCase() == 'advanced';
  bool get isExpert => proficiencyLevel?.toLowerCase() == 'expert';

  bool get hasExperience => yearsOfExperience != null && yearsOfExperience! > 0;

  bool get isExperienced =>
      yearsOfExperience != null && yearsOfExperience! >= 5;
}

/// SkillsByCategory Value Object - 按类别分组的技能
class SkillsByCategory {
  final String category;
  final List<Skill> skills;

  SkillsByCategory({
    required this.category,
    required this.skills,
  });

  // Business logic methods
  bool get hasSkills => skills.isNotEmpty;
  int get count => skills.length;
}

/// AddUserSkillRequest Value Object - 添加用户技能请求
class AddUserSkillRequest {
  final String skillId;
  final String? proficiencyLevel;
  final int? yearsOfExperience;

  AddUserSkillRequest({
    required this.skillId,
    this.proficiencyLevel,
    this.yearsOfExperience,
  });
}
