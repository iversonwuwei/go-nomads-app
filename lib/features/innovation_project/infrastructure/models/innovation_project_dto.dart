import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';

/// 创新项目数据传输对象
class InnovationProjectDto {
  final int id;
  final String projectName;
  final String elevatorPitch;
  final String problem;
  final String solution;
  final String targetAudience;
  final String productType;
  final String keyFeatures;
  final String competitiveAdvantage;
  final String businessModel;
  final String marketOpportunity;
  final String currentStatus;
  final List<TeamMemberDto> team;
  final String ask;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;

  InnovationProjectDto({
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
    this.updatedAt,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.viewCount,
    this.likeCount,
    this.commentCount,
  });

  factory InnovationProjectDto.fromJson(Map<String, dynamic> json) {
    return InnovationProjectDto(
      id: json['id'] as int,
      projectName: json['projectName'] as String,
      elevatorPitch: json['elevatorPitch'] as String,
      problem: json['problem'] as String,
      solution: json['solution'] as String,
      targetAudience: json['targetAudience'] as String,
      productType: json['productType'] as String,
      keyFeatures: json['keyFeatures'] as String,
      competitiveAdvantage: json['competitiveAdvantage'] as String,
      businessModel: json['businessModel'] as String,
      marketOpportunity: json['marketOpportunity'] as String,
      currentStatus: json['currentStatus'] as String,
      team: (json['team'] as List<dynamic>)
          .map((e) => TeamMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      ask: json['ask'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      userId: json['userId'] as int,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      viewCount: json['viewCount'] as int?,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
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
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }

  InnovationProject toDomain() {
    return InnovationProject(
      id: id,
      projectName: projectName,
      elevatorPitch: elevatorPitch,
      problem: problem,
      solution: solution,
      targetAudience: targetAudience,
      productType: productType,
      keyFeatures: keyFeatures,
      competitiveAdvantage: competitiveAdvantage,
      businessModel: businessModel,
      marketOpportunity: marketOpportunity,
      currentStatus: currentStatus,
      team: team.map((e) => e.toDomain()).toList(),
      ask: ask,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      viewCount: viewCount,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}

/// 团队成员数据传输对象
class TeamMemberDto {
  final String name;
  final String role;
  final String description;

  TeamMemberDto({
    required this.name,
    required this.role,
    required this.description,
  });

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
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

  TeamMember toDomain() {
    return TeamMember(
      name: name,
      role: role,
      description: description,
    );
  }
}
