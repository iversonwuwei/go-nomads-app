import 'dart:convert';
import 'dart:io';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/models/innovation_project_dto.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/repositories/innovation_project_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddInnovationPageController extends GetxController {
  final InnovationProject? project;

  AddInnovationPageController({this.project});

  bool get isEditMode => project != null;

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;
  final RxString generatingStatus = ''.obs;

  // Basic Info
  final projectNameController = TextEditingController();
  final elevatorPitchController = TextEditingController();
  final Rx<File?> coverImage = Rx<File?>(null);
  final Rx<String?> coverImageUrl = Rx<String?>(null);

  // Problem & Solution
  final problemController = TextEditingController();
  final solutionController = TextEditingController();

  // Market Positioning
  final targetAudienceController = TextEditingController();
  final productTypeController = TextEditingController();
  final keyFeaturesController = TextEditingController();

  // Competition & Business
  final competitiveAdvantageController = TextEditingController();
  final businessModelController = TextEditingController();
  final marketOpportunityController = TextEditingController();

  // Progress & Needs
  final currentStatusController = TextEditingController();
  final askController = TextEditingController();

  // Team
  final RxList<TeamMemberDto> teamMembers = <TeamMemberDto>[].obs;

  // AI Image Generation
  final RxBool isGeneratingImage = false.obs;
  final aiPromptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (isEditMode) {
      _initEditData();
    }
  }

  void _initEditData() {
    final p = project!;
    projectNameController.text = p.projectName;
    elevatorPitchController.text = p.elevatorPitch;
    problemController.text = p.problem;
    solutionController.text = p.solution;
    targetAudienceController.text = p.targetAudience;
    productTypeController.text = p.productType;
    keyFeaturesController.text = p.keyFeatures;
    competitiveAdvantageController.text = p.competitiveAdvantage;
    businessModelController.text = p.businessModel;
    marketOpportunityController.text = p.marketOpportunity;
    currentStatusController.text = p.currentStatus;
    askController.text = p.ask;
    coverImageUrl.value = p.imageUrl;

    teamMembers.value = p.team
        .map((m) => TeamMemberDto(name: m.name, role: m.role, description: m.description))
        .toList();
  }

  @override
  void onClose() {
    projectNameController.dispose();
    elevatorPitchController.dispose();
    problemController.dispose();
    solutionController.dispose();
    targetAudienceController.dispose();
    productTypeController.dispose();
    keyFeaturesController.dispose();
    competitiveAdvantageController.dispose();
    businessModelController.dispose();
    marketOpportunityController.dispose();
    currentStatusController.dispose();
    askController.dispose();
    aiPromptController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        coverImage.value = File(image.path);
        coverImageUrl.value = null;
      }
    } catch (e) {
      AppToast.error('图片选择失败: $e');
    }
  }

  Future<void> generateImageWithAI(String prompt) async {
    if (prompt.isEmpty) {
      AppToast.error('请输入图片描述');
      return;
    }

    isGeneratingImage.value = true;
    generatingStatus.value = '正在初始化 AI 服务...';

    try {
      final tokenService = TokenStorageService();
      final accessToken = await tokenService.getAccessToken();
      final baseUrl = ApiConfig.currentApiBaseUrl;
      final url = '$baseUrl/ai/images/generate';

      generatingStatus.value = '正在发送请求到 AI 服务...';

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'prompt': prompt,
              'size': '1280*720',
              'style': '<auto>',
              'count': 1,
              'bucket': 'city-photos',
              'pathPrefix': 'innovation-covers',
            }),
          )
          .timeout(const Duration(seconds: 120), onTimeout: () => throw Exception('请求超时，请稍后重试'));

      generatingStatus.value = 'AI 正在创作图片...';

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic>? images = data['data']?['images'];
        final imageUrl = images?.isNotEmpty == true ? images![0]['url'] as String? : null;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          generatingStatus.value = '图片生成成功，正在加载...';
          coverImageUrl.value = imageUrl;
          coverImage.value = null;
          AppToast.success('图片生成成功');
        } else {
          AppToast.error('生成图片失败，未返回图片地址');
        }
      } else {
        String errorMessage = '生成图片失败';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}
        AppToast.error('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      AppToast.error('生成图片失败: $e');
    } finally {
      isGeneratingImage.value = false;
      generatingStatus.value = '';
    }
  }

  void removeImage() {
    coverImage.value = null;
    coverImageUrl.value = null;
  }

  void addTeamMember(TeamMemberDto member) {
    teamMembers.add(member);
  }

  void updateTeamMember(TeamMemberDto oldMember, TeamMemberDto newMember) {
    final index = teamMembers.indexWhere((m) => m.id == oldMember.id || (m.name == oldMember.name && m.role == oldMember.role));
    if (index >= 0) {
      teamMembers[index] = newMember;
    }
  }

  void removeTeamMember(TeamMemberDto member) {
    teamMembers.removeWhere((m) => m.id == member.id || (m.name == member.name && m.role == member.role));
  }

  Future<bool> submitForm(BuildContext context, {required bool isEditMode}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!formKey.currentState!.validate()) return false;

    isSubmitting.value = true;

    try {
      final httpService = Get.find<HttpService>();
      final repository = InnovationProjectRepository(httpService);

      String? finalImageUrl = coverImageUrl.value;
      if (coverImage.value != null) {
        AppToast.info('正在上传封面图片...');
        finalImageUrl = await _uploadCoverImage(coverImage.value!);
        if (finalImageUrl == null) {
          AppToast.error('封面图片上传失败');
          return false;
        }
      }

      if (isEditMode) {
        final projectId = project!.uuid ?? project!.id.toString();
        final updateData = {
          'title': projectNameController.text.trim(),
          'description': elevatorPitchController.text.trim(),
          'elevatorPitch': elevatorPitchController.text.trim(),
          'problem': problemController.text.trim().isNotEmpty ? problemController.text.trim() : null,
          'solution': solutionController.text.trim().isNotEmpty ? solutionController.text.trim() : null,
          'targetAudience': targetAudienceController.text.trim().isNotEmpty ? targetAudienceController.text.trim() : null,
          'productType': productTypeController.text.trim().isNotEmpty ? productTypeController.text.trim() : null,
          'keyFeatures': keyFeaturesController.text.trim().isNotEmpty ? keyFeaturesController.text.trim() : null,
          'competitiveAdvantage': competitiveAdvantageController.text.trim().isNotEmpty ? competitiveAdvantageController.text.trim() : null,
          'businessModel': businessModelController.text.trim().isNotEmpty ? businessModelController.text.trim() : null,
          'marketOpportunity': marketOpportunityController.text.trim().isNotEmpty ? marketOpportunityController.text.trim() : null,
          'ask': askController.text.trim().isNotEmpty ? askController.text.trim() : null,
          'imageUrl': finalImageUrl,
          'team': teamMembers.map((m) => m.toJson()).toList(),
        };

        final result = await repository.updateProject(projectId, updateData);
        switch (result) {
          case Success(:final data):
            DataEventBus.instance.emit(DataChangedEvent(
              entityType: 'innovation_project',
              entityId: data.uuid ?? data.id.toString(),
              version: DateTime.now().millisecondsSinceEpoch,
              changeType: DataChangeType.updated,
            ));
            AppToast.success(l10n.updateSuccess);
            return true;
          case Failure(:final exception):
            AppToast.error('${l10n.updateFailed}: ${exception.message}');
            return false;
        }
      } else {
        final request = CreateInnovationRequest(
          title: projectNameController.text.trim(),
          description: elevatorPitchController.text.trim(),
          elevatorPitch: elevatorPitchController.text.trim(),
          problem: problemController.text.trim().isNotEmpty ? problemController.text.trim() : null,
          solution: solutionController.text.trim().isNotEmpty ? solutionController.text.trim() : null,
          targetAudience: targetAudienceController.text.trim().isNotEmpty ? targetAudienceController.text.trim() : null,
          productType: productTypeController.text.trim().isNotEmpty ? productTypeController.text.trim() : null,
          keyFeatures: keyFeaturesController.text.trim().isNotEmpty ? keyFeaturesController.text.trim() : null,
          competitiveAdvantage: competitiveAdvantageController.text.trim().isNotEmpty ? competitiveAdvantageController.text.trim() : null,
          businessModel: businessModelController.text.trim().isNotEmpty ? businessModelController.text.trim() : null,
          marketOpportunity: marketOpportunityController.text.trim().isNotEmpty ? marketOpportunityController.text.trim() : null,
          ask: askController.text.trim().isNotEmpty ? askController.text.trim() : null,
          stage: 'idea',
          imageUrl: finalImageUrl,
          isPublic: true,
          team: teamMembers.isNotEmpty ? teamMembers.toList() : null,
        );

        final result = await repository.createProject(request);
        switch (result) {
          case Success(:final data):
            DataEventBus.instance.emit(DataChangedEvent(
              entityType: 'innovation_project',
              entityId: data.uuid ?? data.id.toString(),
              version: DateTime.now().millisecondsSinceEpoch,
              changeType: DataChangeType.created,
            ));
            AppToast.success(l10n.projectCreatedSuccessfully);
            return true;
          case Failure(:final exception):
            AppToast.error('${l10n.creationFailed}: ${exception.message}');
            return false;
        }
      }
    } catch (e) {
      AppToast.error('${l10n.creationFailed}: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> _uploadCoverImage(File imageFile) async {
    try {
      final uploadService = ImageUploadService();
      return await uploadService.uploadImage(
        imageFile: imageFile,
        bucket: 'city-photos',
        folder: 'innovation-covers',
        compress: true,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
    } catch (e) {
      debugPrint('❌ 上传图片异常: $e');
      return null;
    }
  }
}
