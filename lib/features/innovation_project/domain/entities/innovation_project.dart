/// 创新项目领域实体
class InnovationProject {
  final int id;
  final String? uuid; // 原始 UUID 字符串
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
  final List<TeamMember> team;
  final String ask;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final String? imageUrl; // 项目封面图
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final bool isLiked; // 当前用户是否点赞
  final bool canEdit; // 当前用户是否可以编辑

  const InnovationProject({
    required this.id,
    this.uuid,
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
    this.imageUrl,
    this.viewCount,
    this.likeCount,
    this.commentCount,
    this.isLiked = false,
    this.canEdit = false,
  });

  /// 复制并更新 isLiked 状态
  InnovationProject copyWithLiked(bool liked) {
    return InnovationProject(
      id: id,
      uuid: uuid,
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
      team: team,
      ask: ask,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      imageUrl: imageUrl,
      viewCount: viewCount,
      likeCount: liked ? (likeCount ?? 0) + 1 : (likeCount ?? 1) - 1,
      commentCount: commentCount,
      isLiked: liked,
      canEdit: canEdit,
    );
  }

  /// 是否有团队成员
  bool get hasTeam => team.isNotEmpty;

  /// 团队规模
  int get teamSize => team.length;

  /// 是否为初创阶段
  bool get isEarlyStage =>
      currentStatus.toLowerCase().contains('idea') ||
      currentStatus.toLowerCase().contains('mvp') ||
      currentStatus.toLowerCase().contains('prototype');

  /// 是否为成熟项目
  bool get isMatureProject =>
      currentStatus.toLowerCase().contains('growth') ||
      currentStatus.toLowerCase().contains('scale') ||
      currentStatus.toLowerCase().contains('established');

  /// 是否最近更新(7天内)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inDays <= 7;
  }

  /// 是否受欢迎(基于点赞和评论数)
  bool get isPopular {
    final totalEngagement = (likeCount ?? 0) + (commentCount ?? 0);
    return totalEngagement > 10;
  }

  /// 项目完整度评分(0-100)
  double get completenessScore {
    int score = 0;
    if (elevatorPitch.isNotEmpty) score += 10;
    if (problem.isNotEmpty) score += 10;
    if (solution.isNotEmpty) score += 10;
    if (targetAudience.isNotEmpty) score += 10;
    if (productType.isNotEmpty) score += 10;
    if (keyFeatures.isNotEmpty) score += 10;
    if (competitiveAdvantage.isNotEmpty) score += 10;
    if (businessModel.isNotEmpty) score += 10;
    if (marketOpportunity.isNotEmpty) score += 10;
    if (team.isNotEmpty) score += 10;
    return score.toDouble();
  }

  /// 是否有足够的商业模式说明
  bool get hasBusinessModelClarity => businessModel.isNotEmpty && businessModel.length > 50;
}

/// 团队成员领域实体
class TeamMember {
  final String name;
  final String role;
  final String description;

  const TeamMember({
    required this.name,
    required this.role,
    required this.description,
  });

  /// 是否为创始人角色
  bool get isFounder => role.toLowerCase().contains('founder') || role.toLowerCase().contains('创始人');

  /// 是否为技术角色
  bool get isTechnicalRole =>
      role.toLowerCase().contains('developer') ||
      role.toLowerCase().contains('engineer') ||
      role.toLowerCase().contains('cto') ||
      role.toLowerCase().contains('开发') ||
      role.toLowerCase().contains('技术');

  /// 是否为商业角色
  bool get isBusinessRole =>
      role.toLowerCase().contains('ceo') ||
      role.toLowerCase().contains('coo') ||
      role.toLowerCase().contains('business') ||
      role.toLowerCase().contains('运营') ||
      role.toLowerCase().contains('商务');
}
