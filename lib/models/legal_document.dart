/// 法律文档模型 — 对应后端 LegalDocumentDto
class LegalDocument {
  final String id;
  final String documentType;
  final String version;
  final String language;
  final String title;
  final DateTime effectiveDate;
  final bool isCurrent;
  final List<LegalSection> sections;
  final List<LegalSummary> summary;

  LegalDocument({
    required this.id,
    required this.documentType,
    required this.version,
    required this.language,
    required this.title,
    required this.effectiveDate,
    required this.isCurrent,
    required this.sections,
    required this.summary,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] ?? '',
      documentType: json['documentType'] ?? '',
      version: json['version'] ?? '',
      language: json['language'] ?? '',
      title: json['title'] ?? '',
      effectiveDate: DateTime.tryParse(json['effectiveDate'] ?? '') ?? DateTime.now(),
      isCurrent: json['isCurrent'] ?? false,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => LegalSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: (json['summary'] as List<dynamic>?)
              ?.map((e) => LegalSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 法律文档章节
class LegalSection {
  final String title;
  final String content;

  LegalSection({required this.title, required this.content});

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// 法律文档摘要（首启弹窗用）
class LegalSummary {
  final String icon;
  final String title;
  final String content;

  LegalSummary({required this.icon, required this.title, required this.content});

  factory LegalSummary.fromJson(Map<String, dynamic> json) {
    return LegalSummary(
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
