/// Innovation Project Model
/// 创意项目模型
class InnovationProject {
  final String id;
  final String projectName; // 项目名称
  final String elevatorPitch; // 一句话定位
  final String problem; // 要解决的问题
  final String solution; // 解决方案
  final String targetAudience; // 目标用户
  final String productType; // 产品形态
  final List<String> keyFeatures; // 核心功能
  final String competitiveAdvantage; // 竞争优势
  final String businessModel; // 商业模式
  final String marketOpportunity; // 市场潜力
  final String currentStatus; // 当前进展
  final List<TeamMember> team; // 团队介绍
  final String ask; // 所需支持
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final String? imageUrl; // 项目封面图
  final String creatorId; // 创建者ID
  final String creatorName; // 创建者姓名

  InnovationProject({
    required this.id,
    required this.projectName,
    required this.elevatorPitch,
    required this.problem,
    required this.solution,
    required this.targetAudience,
    required this.productType,
    required this.keyFeatures,
    required this.competitiveAdvantage,
    required this.businessModel,
    required this.marketOpportunity,
    required this.currentStatus,
    required this.team,
    required this.ask,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    required this.creatorId,
    required this.creatorName,
  });

  factory InnovationProject.fromJson(Map<String, dynamic> json) {
    return InnovationProject(
      id: json['id'] as String,
      projectName: json['projectName'] as String,
      elevatorPitch: json['elevatorPitch'] as String,
      problem: json['problem'] as String,
      solution: json['solution'] as String,
      targetAudience: json['targetAudience'] as String,
      productType: json['productType'] as String,
      keyFeatures: (json['keyFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      competitiveAdvantage: json['competitiveAdvantage'] as String,
      businessModel: json['businessModel'] as String,
      marketOpportunity: json['marketOpportunity'] as String,
      currentStatus: json['currentStatus'] as String,
      team: (json['team'] as List<dynamic>)
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      ask: json['ask'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'elevatorPitch': elevatorPitch,
      'problem': problem,
      'solution': solution,
      'targetAudience': targetAudience,
      'productType': productType,
      'keyFeatures': keyFeatures,
      'competitiveAdvantage': competitiveAdvantage,
      'businessModel': businessModel,
      'marketOpportunity': marketOpportunity,
      'currentStatus': currentStatus,
      'team': team.map((e) => e.toJson()).toList(),
      'ask': ask,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }
}

/// Team Member Model
/// 团队成员模型
class TeamMember {
  final String name;
  final String role; // 角色/职位
  final String description; // 个人简介

  TeamMember({
    required this.name,
    required this.role,
    required this.description,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['name'] as String,
      role: json['role'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'description': description,
    };
  }
}
