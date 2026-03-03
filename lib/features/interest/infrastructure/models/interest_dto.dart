import 'package:go_nomads_app/features/interest/domain/entities/interest.dart'
    as domain;

/// Interest DTO
class InterestDto {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  InterestDto({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory InterestDto.fromJson(Map<String, dynamic> json) {
    return InterestDto(
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

  domain.Interest toDomain() {
    return domain.Interest(
      id: id,
      name: name,
      category: category,
      description: description,
      icon: icon,
      createdAt: createdAt,
    );
  }
}

/// UserInterest DTO
class UserInterestDto {
  final String id;
  final String userId;
  final String interestId;
  final String interestName;
  final String category;
  final String? icon;
  final String? intensityLevel;
  final DateTime createdAt;

  UserInterestDto({
    required this.id,
    required this.userId,
    required this.interestId,
    required this.interestName,
    required this.category,
    this.icon,
    this.intensityLevel,
    required this.createdAt,
  });

  factory UserInterestDto.fromJson(Map<String, dynamic> json) {
    return UserInterestDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      interestId: json['interestId'] as String,
      interestName: json['interestName'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      intensityLevel: json['intensityLevel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'interestId': interestId,
      'interestName': interestName,
      'category': category,
      'icon': icon,
      'intensityLevel': intensityLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  domain.UserInterest toDomain() {
    return domain.UserInterest(
      id: id,
      userId: userId,
      interestId: interestId,
      interestName: interestName,
      category: category,
      icon: icon,
      intensityLevel: intensityLevel,
      createdAt: createdAt,
    );
  }
}

/// InterestsByCategory DTO
class InterestsByCategoryDto {
  final String category;
  final List<InterestDto> interests;

  InterestsByCategoryDto({
    required this.category,
    required this.interests,
  });

  factory InterestsByCategoryDto.fromJson(Map<String, dynamic> json) {
    return InterestsByCategoryDto(
      category: json['category'] as String,
      interests: (json['interests'] as List)
          .map((interest) =>
              InterestDto.fromJson(interest as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'interests': interests.map((interest) => interest.toJson()).toList(),
    };
  }

  domain.InterestsByCategory toDomain() {
    return domain.InterestsByCategory(
      category: category,
      interests: interests.map((i) => i.toDomain()).toList(),
    );
  }
}

/// AddUserInterestRequest DTO
class AddUserInterestRequestDto {
  final String interestId;
  final String? intensityLevel;

  AddUserInterestRequestDto({
    required this.interestId,
    this.intensityLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestId': interestId,
      'intensityLevel': intensityLevel,
    };
  }

  domain.AddUserInterestRequest toDomain() {
    return domain.AddUserInterestRequest(
      interestId: interestId,
      intensityLevel: intensityLevel,
    );
  }
}
