import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';

/// 创新项目数据传输对象（匹配后端API响应）
class InnovationProjectDto {
  final String id;
  final String title;
  final String description;
  final String? elevatorPitch;
  final String? problem;
  final String? solution;
  final String? targetAudience;
  final String? productType;
  final String? keyFeatures;
  final String? competitiveAdvantage;
  final String? businessModel;
  final String? marketOpportunity;
  final String? ask;
  final String creatorId;
  final String? creatorName;
  final String? creatorAvatar;
  final String? category;
  final String stage;
  final List<String>? tags;
  final String? imageUrl;
  final List<String>? images;
  final String? videoUrl;
  final String? demoUrl;
  final String? githubUrl;
  final String? websiteUrl;
  final int teamSize;
  final List<TeamMemberDto> team;
  final List<String>? lookingFor;
  final List<String>? skillsNeeded;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final bool isFeatured;
  final bool isPublic;
  final bool isLiked;
  final bool canEdit;
  final DateTime createdAt;
  final DateTime updatedAt;

  InnovationProjectDto({
    required this.id,
    required this.title,
    required this.description,
    this.elevatorPitch,
    this.problem,
    this.solution,
    this.targetAudience,
    this.productType,
    this.keyFeatures,
    this.competitiveAdvantage,
    this.businessModel,
    this.marketOpportunity,
    this.ask,
    required this.creatorId,
    this.creatorName,
    this.creatorAvatar,
    this.category,
    this.stage = 'idea',
    this.tags,
    this.imageUrl,
    this.images,
    this.videoUrl,
    this.demoUrl,
    this.githubUrl,
    this.websiteUrl,
    this.teamSize = 1,
    this.team = const [],
    this.lookingFor,
    this.skillsNeeded,
    this.likeCount = 0,
    this.viewCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.isPublic = true,
    this.isLiked = false,
    this.canEdit = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InnovationProjectDto.fromJson(Map<String, dynamic> json) {
    return InnovationProjectDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      elevatorPitch: json['elevatorPitch'] as String?,
      problem: json['problem'] as String?,
      solution: json['solution'] as String?,
      targetAudience: json['targetAudience'] as String?,
      productType: json['productType'] as String?,
      keyFeatures: json['keyFeatures'] as String?,
      competitiveAdvantage: json['competitiveAdvantage'] as String?,
      businessModel: json['businessModel'] as String?,
      marketOpportunity: json['marketOpportunity'] as String?,
      ask: json['ask'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String?,
      creatorAvatar: json['creatorAvatar'] as String?,
      category: json['category'] as String?,
      stage: json['stage'] as String? ?? 'idea',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      demoUrl: json['demoUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      teamSize: json['teamSize'] as int? ?? 1,
      team: (json['team'] as List<dynamic>?)?.map((e) => TeamMemberDto.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      lookingFor: (json['lookingFor'] as List<dynamic>?)?.map((e) => e as String).toList(),
      skillsNeeded: (json['skillsNeeded'] as List<dynamic>?)?.map((e) => e as String).toList(),
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? true,
      isLiked: json['isLiked'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// 安全解析日期时间
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'elevatorPitch': elevatorPitch,
      'problem': problem,
      'solution': solution,
      'targetAudience': targetAudience,
      'productType': productType,
      'keyFeatures': keyFeatures,
      'competitiveAdvantage': competitiveAdvantage,
      'businessModel': businessModel,
      'marketOpportunity': marketOpportunity,
      'ask': ask,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'category': category,
      'stage': stage,
      'tags': tags,
      'imageUrl': imageUrl,
      'images': images,
      'videoUrl': videoUrl,
      'demoUrl': demoUrl,
      'githubUrl': githubUrl,
      'websiteUrl': websiteUrl,
      'teamSize': teamSize,
      'team': team.map((e) => e.toJson()).toList(),
      'lookingFor': lookingFor,
      'skillsNeeded': skillsNeeded,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'commentCount': commentCount,
      'isFeatured': isFeatured,
      'isPublic': isPublic,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  InnovationProject toDomain() {
    return InnovationProject(
      id: id.hashCode,
      uuid: id, // 保留原始 UUID
      projectName: title,
      elevatorPitch: elevatorPitch ?? '',
      problem: problem ?? '',
      solution: solution ?? '',
      targetAudience: targetAudience ?? '',
      productType: productType ?? '',
      keyFeatures: keyFeatures ?? '',
      competitiveAdvantage: competitiveAdvantage ?? '',
      businessModel: businessModel ?? '',
      marketOpportunity: marketOpportunity ?? '',
      currentStatus: stage,
      team: team.map((e) => e.toDomain()).toList(),
      ask: ask ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: creatorId.hashCode,
      creatorUuid: creatorId, // 保留创建者的原始 UUID
      userName: creatorName,
      userAvatar: creatorAvatar,
      imageUrl: imageUrl,
      viewCount: viewCount,
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
      canEdit: canEdit,
    );
  }
}

/// 创新项目列表项 DTO（简化版）
class InnovationListItemDto {
  final String id;
  final String title;
  final String? elevatorPitch;
  final String? productType;
  final String? keyFeatures;
  final String? category;
  final String stage;
  final String? imageUrl;
  final String creatorId;
  final String? creatorName;
  final String? creatorAvatar;
  final int teamSize;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final bool isFeatured;
  final bool isLiked;
  final bool canEdit;
  final DateTime createdAt;

  InnovationListItemDto({
    required this.id,
    required this.title,
    this.elevatorPitch,
    this.productType,
    this.keyFeatures,
    this.category,
    this.stage = 'idea',
    this.imageUrl,
    required this.creatorId,
    this.creatorName,
    this.creatorAvatar,
    this.teamSize = 1,
    this.likeCount = 0,
    this.viewCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.isLiked = false,
    this.canEdit = false,
    required this.createdAt,
  });

  factory InnovationListItemDto.fromJson(Map<String, dynamic> json) {
    return InnovationListItemDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      elevatorPitch: json['elevatorPitch'] as String?,
      productType: json['productType'] as String?,
      keyFeatures: json['keyFeatures'] as String?,
      category: json['category'] as String?,
      stage: json['stage'] as String? ?? 'idea',
      imageUrl: json['imageUrl'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String?,
      creatorAvatar: json['creatorAvatar'] as String?,
      teamSize: json['teamSize'] as int? ?? 1,
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isLiked: json['isLiked'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  /// 安全解析日期时间
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return DateTime.now();
    }
  }

  InnovationProject toSimpleDomain() {
    return InnovationProject(
      id: id.hashCode,
      uuid: id, // 保留原始 UUID
      projectName: title,
      elevatorPitch: elevatorPitch ?? '',
      problem: '',
      solution: '',
      targetAudience: '',
      productType: productType ?? '',
      keyFeatures: keyFeatures ?? '',
      competitiveAdvantage: '',
      businessModel: '',
      marketOpportunity: '',
      currentStatus: stage,
      team: [],
      ask: '',
      createdAt: createdAt,
      updatedAt: null,
      userId: creatorId.hashCode,
      creatorUuid: creatorId, // 保留创建者的原始 UUID
      userName: creatorName,
      userAvatar: creatorAvatar,
      imageUrl: imageUrl,
      viewCount: viewCount,
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
      canEdit: canEdit,
    );
  }
}

/// 团队成员数据传输对象
class TeamMemberDto {
  final String? id;
  final String? userId;
  final String name;
  final String role;
  final String? description;
  final String? avatarUrl;
  final bool isFounder;

  TeamMemberDto({
    this.id,
    this.userId,
    required this.name,
    required this.role,
    this.description,
    this.avatarUrl,
    this.isFounder = false,
  });

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isFounder: json['isFounder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'role': role,
      'description': description,
      'avatarUrl': avatarUrl,
      'isFounder': isFounder,
    };
  }

  TeamMember toDomain() {
    return TeamMember(
      name: name,
      role: role,
      description: description ?? '',
    );
  }
}

/// 创建创新项目请求 DTO
class CreateInnovationRequest {
  final String title;
  final String description;
  final String? elevatorPitch;
  final String? problem;
  final String? solution;
  final String? targetAudience;
  final String? productType;
  final String? keyFeatures;
  final String? competitiveAdvantage;
  final String? businessModel;
  final String? marketOpportunity;
  final String? ask;
  final String? category;
  final String stage;
  final List<String>? tags;
  final String? imageUrl;
  final List<String>? images;
  final String? videoUrl;
  final String? demoUrl;
  final String? githubUrl;
  final String? websiteUrl;
  final List<String>? lookingFor;
  final List<String>? skillsNeeded;
  final bool isPublic;
  final List<TeamMemberDto>? team;

  CreateInnovationRequest({
    required this.title,
    required this.description,
    this.elevatorPitch,
    this.problem,
    this.solution,
    this.targetAudience,
    this.productType,
    this.keyFeatures,
    this.competitiveAdvantage,
    this.businessModel,
    this.marketOpportunity,
    this.ask,
    this.category,
    this.stage = 'idea',
    this.tags,
    this.imageUrl,
    this.images,
    this.videoUrl,
    this.demoUrl,
    this.githubUrl,
    this.websiteUrl,
    this.lookingFor,
    this.skillsNeeded,
    this.isPublic = true,
    this.team,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'elevatorPitch': elevatorPitch,
      'problem': problem,
      'solution': solution,
      'targetAudience': targetAudience,
      'productType': productType,
      'keyFeatures': keyFeatures,
      'competitiveAdvantage': competitiveAdvantage,
      'businessModel': businessModel,
      'marketOpportunity': marketOpportunity,
      'ask': ask,
      'category': category,
      'stage': stage,
      'tags': tags,
      'imageUrl': imageUrl,
      'images': images,
      'videoUrl': videoUrl,
      'demoUrl': demoUrl,
      'githubUrl': githubUrl,
      'websiteUrl': websiteUrl,
      'lookingFor': lookingFor,
      'skillsNeeded': skillsNeeded,
      'isPublic': isPublic,
      'team': team?.map((e) => e.toJson()).toList(),
    };
  }
}
