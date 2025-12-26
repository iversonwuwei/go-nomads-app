import 'dart:convert';
import 'dart:io';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/models/innovation_project_dto.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/repositories/innovation_project_repository.dart';
import 'package:df_admin_mobile/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Add Innovation Project Page
/// 添加创意项目页面（支持编辑模式）
class AddInnovationPage extends StatefulWidget {
  /// 编辑模式下传入的项目数据，null 表示创建新项目
  final InnovationProject? project;

  const AddInnovationPage({super.key, this.project});

  /// 是否为编辑模式
  bool get isEditMode => project != null;

  @override
  State<AddInnovationPage> createState() => _AddInnovationPageState();
}

class _AddInnovationPageState extends State<AddInnovationPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  // AI 生成状态
  final RxString _generatingStatus = ''.obs;

  // 基本信息
  final _projectNameController = TextEditingController();
  final _elevatorPitchController = TextEditingController();
  File? _coverImage;
  String? _coverImageUrl; // AI 生成的图片 URL

  // 问题与解决方案
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();

  // 市场定位
  final _targetAudienceController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _keyFeaturesController = TextEditingController(); // 多行,逗号分隔

  // 竞争与商业
  final _competitiveAdvantageController = TextEditingController();
  final _businessModelController = TextEditingController();
  final _marketOpportunityController = TextEditingController();

  // 进展与团队
  final _currentStatusController = TextEditingController();
  final _askController = TextEditingController();

  // 团队成员列表
  final RxList<TeamMemberDto> _teamMembers = <TeamMemberDto>[].obs;

  final ImagePicker _picker = ImagePicker();

  // AI 图片生成状态
  final RxBool _isGeneratingImage = false.obs;
  final _aiPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，初始化表单数据
    if (widget.isEditMode) {
      _initEditData();
    }
  }

  /// 初始化编辑数据
  void _initEditData() {
    final project = widget.project!;
    _projectNameController.text = project.projectName;
    _elevatorPitchController.text = project.elevatorPitch;
    _problemController.text = project.problem;
    _solutionController.text = project.solution;
    _targetAudienceController.text = project.targetAudience;
    _productTypeController.text = project.productType;
    _keyFeaturesController.text = project.keyFeatures;
    _competitiveAdvantageController.text = project.competitiveAdvantage;
    _businessModelController.text = project.businessModel;
    _marketOpportunityController.text = project.marketOpportunity;
    _currentStatusController.text = project.currentStatus;
    _askController.text = project.ask;
    _coverImageUrl = project.imageUrl;

    // 初始化团队成员
    _teamMembers.value = project.team
        .map((m) => TeamMemberDto(
              name: m.name,
              role: m.role,
              description: m.description,
            ))
        .toList();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _elevatorPitchController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _targetAudienceController.dispose();
    _productTypeController.dispose();
    _keyFeaturesController.dispose();
    _competitiveAdvantageController.dispose();
    _businessModelController.dispose();
    _marketOpportunityController.dispose();
    _currentStatusController.dispose();
    _askController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
          _coverImageUrl = null; // 清除 AI 生成的图片
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error('${l10n.imageSelectionFailed}: $e');
      }
    }
  }

  /// AI 生成封面图片
  Future<void> _generateImageWithAI(String prompt) async {
    if (prompt.isEmpty) {
      AppToast.error('请输入图片描述');
      return;
    }

    _isGeneratingImage.value = true;
    _generatingStatus.value = '正在初始化 AI 服务...';

    try {
      final tokenService = TokenStorageService();
      final accessToken = await tokenService.getAccessToken();
      final baseUrl = ApiConfig.currentApiBaseUrl;
      final url = '$baseUrl/ai/images/generate';

      debugPrint('🎨 [AI Image] 开始生成图片');
      debugPrint('🎨 [AI Image] URL: $url');
      debugPrint('🎨 [AI Image] Prompt: $prompt');

      _generatingStatus.value = '正在发送请求到 AI 服务...';

      // 调用 AI 图片生成 API (通义万象)
      // 图片生成需要较长时间，设置 120 秒超时
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'prompt': prompt,
          'size': '1280*720', // 横版封面图
          'style': '<auto>',
          'count': 1,
          'bucket': 'city-photos', // 使用已有的 bucket
          'pathPrefix': 'innovation-covers', // 使用子目录区分
        }),
      )
          .timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception('请求超时，请稍后重试');
        },
      );

      debugPrint('🎨 [AI Image] Response status: ${response.statusCode}');
      debugPrint('🎨 [AI Image] Response body: ${response.body}');

      _generatingStatus.value = 'AI 正在创作图片...';

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 后端返回结构: { success: true, data: { images: [{ url: "..." }] } }
        final List<dynamic>? images = data['data']?['images'];
        final imageUrl = images?.isNotEmpty == true ? images![0]['url'] as String? : null;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          _generatingStatus.value = '图片生成成功，正在加载...';
          setState(() {
            _coverImageUrl = imageUrl;
            _coverImage = null; // 清除本地图片
          });
          AppToast.success('图片生成成功');
        } else {
          debugPrint('🎨 [AI Image] 未返回图片地址: $data');
          AppToast.error('生成图片失败，未返回图片地址');
        }
      } else {
        String errorMessage = '生成图片失败';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          debugPrint('🎨 [AI Image] 错误详情: $errorData');
        } catch (_) {
          debugPrint('🎨 [AI Image] 无法解析错误响应: ${response.body}');
        }
        AppToast.error('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('🎨 [AI Image] 异常: $e');
      AppToast.error('生成图片失败: $e');
    } finally {
      _isGeneratingImage.value = false;
      _generatingStatus.value = '';
    }
  }

  /// 处理 AI 生成按钮点击 - 检查会员权限
  void _handleAIGenerateClick() {
    debugPrint('🔐 [AI Generate] Checking membership...');

    // 检查会员状态
    if (!Get.isRegistered<MembershipStateController>()) {
      debugPrint('❌ [AI Generate] MembershipStateController not registered');
      AppToast.error('会员服务不可用，请稍后再试');
      return;
    }

    final membershipController = Get.find<MembershipStateController>();
    final canUseAI = membershipController.canUseAI;
    final isPaidMember = membershipController.isPaidMember;

    debugPrint('🔐 [AI Generate] canUseAI: $canUseAI, isPaidMember: $isPaidMember');

    // 检查是否为付费会员或有 AI 使用权限
    if (canUseAI || isPaidMember) {
      debugPrint('✅ [AI Generate] User has access, showing AI dialog');
      _showAIGenerateDialog();
    } else {
      debugPrint('🚫 [AI Generate] User needs membership, showing upgrade dialog');
      _showMembershipRequiredDialog();
    }
  }

  /// 显示需要升级会员的对话框
  void _showMembershipRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部装饰
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 背景装饰
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(25),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(20),
                          ),
                        ),
                      ),
                      // 图标
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // 内容区域
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    children: [
                      const Text(
                        'AI 图片生成',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '会员专属功能',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 功能介绍
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withAlpha(15),
                              const Color(0xFFA78BFA).withAlpha(10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              Icons.image_rounded,
                              '输入描述自动生成封面',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              Icons.style_rounded,
                              '多种风格模板可选',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              Icons.high_quality_rounded,
                              '高清图片一键下载',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Get.toNamed(AppRoutes.membershipPlan);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.crown, size: 16),
                              SizedBox(width: 8),
                              Text(
                                '升级会员解锁',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          '稍后再说',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建功能项
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: Colors.green.shade400,
        ),
      ],
    );
  }

  /// 显示 AI 生成图片对话框
  void _showAIGenerateDialog() {
    final l10n = AppLocalizations.of(context)!;
    _aiPromptController.clear();

    // 预设一些提示词模板
    final promptTemplates = [
      '一个现代化的科技创业项目封面，蓝色渐变背景，极简风格',
      '创新与科技结合的抽象图像，充满活力的色彩',
      '数字化转型概念图，展现连接与协作',
      '绿色环保主题的创业项目封面，自然与科技融合',
    ];

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('AI 生成封面'),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _aiPromptController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '请描述您想要的封面图片...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '快速模板：',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: promptTemplates.map((template) {
                  return InkWell(
                    onTap: () {
                      _aiPromptController.text = template;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        template.length > 20 ? '${template.substring(0, 20)}...' : template,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          Obx(() => ElevatedButton.icon(
                onPressed: _isGeneratingImage.value
                    ? null
                    : () {
                        Get.back();
                        _generateImageWithAI(_aiPromptController.text);
                      },
                icon: _isGeneratingImage.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_isGeneratingImage.value ? '生成中...' : '生成'),
              )),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      final l10n = AppLocalizations.of(context)!;

      // 获取 HttpService 实例
      final httpService = Get.find<HttpService>();
      final repository = InnovationProjectRepository(httpService);

      // 处理封面图片
      String? finalImageUrl = _coverImageUrl;

      // 如果有本地图片，需要先上传
      if (_coverImage != null) {
        AppToast.info('正在上传封面图片...');
        finalImageUrl = await _uploadCoverImage(_coverImage!);
        if (finalImageUrl == null) {
          AppToast.error('封面图片上传失败');
          return;
        }
      }

      if (widget.isEditMode) {
        // 编辑模式 - 更新项目
        final projectId = widget.project!.uuid ?? widget.project!.id.toString();
        final updateData = {
          'title': _projectNameController.text.trim(),
          'description': _elevatorPitchController.text.trim(),
          'elevatorPitch': _elevatorPitchController.text.trim(),
          'problem': _problemController.text.trim().isNotEmpty ? _problemController.text.trim() : null,
          'solution': _solutionController.text.trim().isNotEmpty ? _solutionController.text.trim() : null,
          'targetAudience':
              _targetAudienceController.text.trim().isNotEmpty ? _targetAudienceController.text.trim() : null,
          'productType': _productTypeController.text.trim().isNotEmpty ? _productTypeController.text.trim() : null,
          'keyFeatures': _keyFeaturesController.text.trim().isNotEmpty ? _keyFeaturesController.text.trim() : null,
          'competitiveAdvantage': _competitiveAdvantageController.text.trim().isNotEmpty
              ? _competitiveAdvantageController.text.trim()
              : null,
          'businessModel':
              _businessModelController.text.trim().isNotEmpty ? _businessModelController.text.trim() : null,
          'marketOpportunity':
              _marketOpportunityController.text.trim().isNotEmpty ? _marketOpportunityController.text.trim() : null,
          'ask': _askController.text.trim().isNotEmpty ? _askController.text.trim() : null,
          'imageUrl': finalImageUrl,
          // 始终发送 team 字段，让后端知道是否需要更新团队成员
          'team': _teamMembers.map((m) => m.toJson()).toList(),
        };

        debugPrint('🚀 [更新项目] 开始提交...');
        debugPrint('🚀 [更新项目] ID: $projectId');
        debugPrint('🚀 [更新项目] 请求数据: $updateData');

        final result = await repository.updateProject(projectId, updateData);

        switch (result) {
          case Success(:final data):
            debugPrint('✅ [更新项目] 成功! ID: ${data.uuid}');
            AppToast.success(l10n.updateSuccess);
            if (mounted) {
              Navigator.pop(context, true); // 返回 true 通知父页面刷新数据
            }
          case Failure(:final exception):
            debugPrint('❌ [更新项目] 失败: $exception');
            AppToast.error('${l10n.updateFailed}: ${exception.message}');
        }
      } else {
        // 创建模式
        final request = CreateInnovationRequest(
          title: _projectNameController.text.trim(),
          description: _elevatorPitchController.text.trim(),
          elevatorPitch: _elevatorPitchController.text.trim(),
          problem: _problemController.text.trim().isNotEmpty ? _problemController.text.trim() : null,
          solution: _solutionController.text.trim().isNotEmpty ? _solutionController.text.trim() : null,
          targetAudience:
              _targetAudienceController.text.trim().isNotEmpty ? _targetAudienceController.text.trim() : null,
          productType: _productTypeController.text.trim().isNotEmpty ? _productTypeController.text.trim() : null,
          keyFeatures: _keyFeaturesController.text.trim().isNotEmpty ? _keyFeaturesController.text.trim() : null,
          competitiveAdvantage: _competitiveAdvantageController.text.trim().isNotEmpty
              ? _competitiveAdvantageController.text.trim()
              : null,
          businessModel: _businessModelController.text.trim().isNotEmpty ? _businessModelController.text.trim() : null,
          marketOpportunity:
              _marketOpportunityController.text.trim().isNotEmpty ? _marketOpportunityController.text.trim() : null,
          ask: _askController.text.trim().isNotEmpty ? _askController.text.trim() : null,
          stage: 'idea', // 默认为初始阶段
          imageUrl: finalImageUrl,
          isPublic: true,
          team: _teamMembers.isNotEmpty ? _teamMembers.toList() : null,
        );

        debugPrint('🚀 [创建项目] 开始提交...');
        debugPrint('🚀 [创建项目] 标题: ${request.title}');
        debugPrint('🚀 [创建项目] 请求数据: ${request.toJson()}');

        // 调用 Repository 创建项目
        final result = await repository.createProject(request);

        switch (result) {
          case Success(:final data):
            debugPrint('✅ [创建项目] 成功! ID: ${data.id}');
            AppToast.success(l10n.projectCreatedSuccessfully);
            if (mounted) {
              Navigator.pop(context, true); // 返回 true 通知父页面刷新数据
            }
          case Failure(:final exception):
            debugPrint('❌ [创建项目] 失败: $exception');
            AppToast.error('${l10n.creationFailed}: ${exception.message}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [提交项目] 异常: $e');
      debugPrint('❌ [提交项目] 堆栈: $stackTrace');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error('${l10n.creationFailed}: $e');
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 上传封面图片到 Supabase Storage
  Future<String?> _uploadCoverImage(File imageFile) async {
    try {
      final uploadService = ImageUploadService();

      // 上传到 city-photos bucket 的 innovation-covers 文件夹
      final imageUrl = await uploadService.uploadImage(
        imageFile: imageFile,
        bucket: 'city-photos',
        folder: 'innovation-covers',
        compress: true,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      debugPrint('✅ 封面图片上传成功: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('❌ 上传图片异常: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        title: Text(widget.isEditMode ? l10n.editProject : l10n.createInnovationProject),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部说明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withAlpha(51),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.circleInfo,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.shareYourInnovation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 1. 基本信息
              _buildSectionTitle(
                icon: FontAwesomeIcons.rocket,
                title: l10n.basicInformation,
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _projectNameController,
                label: l10n.projectName,
                hint: l10n.projectNameHint,
                icon: FontAwesomeIcons.heading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterProjectName;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _elevatorPitchController,
                label: l10n.elevatorPitch,
                hint: l10n.elevatorPitchHint,
                icon: FontAwesomeIcons.message,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterElevatorPitch;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 项目封面
              _buildImagePicker(),

              const SizedBox(height: 32),

              // 2. 问题与解决方案
              _buildSectionTitle(
                icon: FontAwesomeIcons.lightbulb,
                title: l10n.problemAndSolution,
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _problemController,
                label: l10n.problem,
                hint: l10n.problemHint,
                icon: FontAwesomeIcons.circleExclamation,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseDescribeProblem;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _solutionController,
                label: l10n.solution,
                hint: l10n.solutionHint,
                icon: FontAwesomeIcons.circleCheck,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseDescribeSolution;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 3. 市场定位
              _buildSectionTitle(
                icon: FontAwesomeIcons.users,
                title: l10n.marketPositioning,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _targetAudienceController,
                label: l10n.targetAudience,
                hint: l10n.targetAudienceHint,
                icon: FontAwesomeIcons.users,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseDescribeTargetAudience;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _productTypeController,
                label: l10n.productType,
                hint: l10n.productTypeHint,
                icon: FontAwesomeIcons.laptop,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _keyFeaturesController,
                label: l10n.keyFeatures,
                hint: l10n.keyFeaturesHint,
                icon: FontAwesomeIcons.star,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterKeyFeatures;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 4. 竞争与商业
              _buildSectionTitle(
                icon: FontAwesomeIcons.chartLine,
                title: l10n.competitionAndBusiness,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _competitiveAdvantageController,
                label: l10n.competitiveAdvantage,
                hint: l10n.competitiveAdvantageHint,
                icon: FontAwesomeIcons.trophy,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _businessModelController,
                label: l10n.businessModel,
                hint: l10n.businessModelHint,
                icon: FontAwesomeIcons.dollarSign,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _marketOpportunityController,
                label: l10n.marketOpportunity,
                hint: l10n.marketOpportunityHint,
                icon: FontAwesomeIcons.chartLine,
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // 5. 进展与需求
              _buildSectionTitle(
                icon: FontAwesomeIcons.clockRotateLeft,
                title: l10n.progressAndNeeds,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _currentStatusController,
                label: l10n.currentStatus,
                hint: l10n.currentStatusHint,
                icon: FontAwesomeIcons.flag,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseDescribeCurrentStatus;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _askController,
                label: l10n.ask,
                hint: l10n.askHint,
                icon: FontAwesomeIcons.handshake,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseSpecifyNeeds;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 6. 团队信息 (可选)
              _buildSectionTitle(
                icon: FontAwesomeIcons.userGroup,
                title: '${l10n.teamInformation} (${l10n.optional})',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),

              // 团队成员列表
              _buildTeamMembersSection(l10n),

              const SizedBox(height: 40),

              // 提交按钮
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting.value ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.publishProject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildImagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 根据屏幕宽度计算图片预览高度
    final previewHeight = isMobile ? 180.0 : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            const Icon(FontAwesomeIcons.image, size: 20, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Text(
              l10n.projectCover,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${l10n.optional})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 图片预览区域 - 点击打开选择菜单
        GestureDetector(
          onTap: _showImageSourceBottomSheet,
          child: Container(
            height: previewHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: _buildImagePreview(previewHeight),
          ),
        ),
      ],
    );
  }

  /// 显示图片来源选择底部抽屉 - 现代设计
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖动指示器
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 28),
                // 标题区域
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '选择封面图片',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '为你的项目添加一张吸引眼球的封面',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // 选项卡片 - 网格布局
                Row(
                  children: [
                    // 相册选项
                    Expanded(
                      child: _buildModernOptionCard(
                        icon: Icons.photo_library_rounded,
                        title: '相册',
                        subtitle: '从本地选择',
                        gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // AI 生成选项
                    Expanded(
                      child: _buildModernOptionCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'AI 生成',
                        subtitle: '智能创作',
                        gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        onTap: () {
                          Navigator.pop(context);
                          _handleAIGenerateClick();
                        },
                        isPremium: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建现代风格选项卡片
  Widget _buildModernOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 图标容器
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                // Premium 标签
                if (isPremium)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            // 副标题
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片预览区域
  Widget _buildImagePreview(double height) {
    final l10n = AppLocalizations.of(context)!;

    // 优先显示本地图片，其次是 AI 生成的图片 URL
    if (_coverImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _coverImage!,
              fit: BoxFit.cover,
            ),
          ),
          _buildRemoveButton(),
          _buildImageSourceBadge('本地图片', Icons.folder),
        ],
      );
    } else if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _coverImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('图片加载失败', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildRemoveButton(),
          _buildImageSourceBadge('AI 生成', Icons.auto_awesome),
        ],
      );
    } else {
      // 空状态占位
      return Obx(() => _isGeneratingImage.value
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 渐变动画圆环
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF8B5CF6).withAlpha(77),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 主标题
                  const Text(
                    'AI 正在创作中',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 动态状态
                  Obx(() => Text(
                        _generatingStatus.value.isNotEmpty ? _generatingStatus.value : '请稍候...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.photoFilm,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.clickToSelectCover,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.recommendedSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ));
    }
  }

  /// 构建团队成员区域
  Widget _buildTeamMembersSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已添加的团队成员列表
        Obx(() => _teamMembers.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(FontAwesomeIcons.userGroup, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noTeamMembersAdded,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: _teamMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  return _buildTeamMemberCard(member, index, l10n);
                }).toList(),
              )),

        const SizedBox(height: 12),

        // 添加团队成员按钮
        InkWell(
          onTap: () => _showAddTeamMemberDialog(l10n),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8B5CF6),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.plus, size: 16, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text(
                  l10n.addTeamMember,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建单个团队成员卡片
  Widget _buildTeamMemberCard(TeamMemberDto member, int index, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像占位
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 成员信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (member.isFounder == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.founder,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (member.description != null && member.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // 操作按钮
          PopupMenuButton<String>(
            icon: Icon(FontAwesomeIcons.ellipsisVertical, size: 16, color: Colors.grey[400]),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditTeamMemberDialog(member, index, l10n);
              } else if (value == 'delete') {
                _teamMembers.removeAt(index);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.pen, size: 14),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示添加团队成员对话框
  void _showAddTeamMemberDialog(AppLocalizations l10n) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    final isFounder = false.obs;

    Get.dialog(
      AlertDialog(
        title: Text(l10n.addTeamMember),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.name} *',
                  hintText: l10n.enterMemberName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: '${l10n.role} *',
                  hintText: l10n.enterMemberRole,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.enterMemberDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Obx(() => CheckboxListTile(
                    title: Text(l10n.markAsFounder),
                    value: isFounder.value,
                    onChanged: (value) => isFounder.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(l10n.error, l10n.pleaseEnterMemberName);
                return;
              }
              if (roleController.text.trim().isEmpty) {
                Get.snackbar(l10n.error, l10n.pleaseEnterMemberRole);
                return;
              }

              final member = TeamMemberDto(
                name: nameController.text.trim(),
                role: roleController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                isFounder: isFounder.value,
              );
              _teamMembers.add(member);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: Text(l10n.add, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 显示编辑团队成员对话框
  void _showEditTeamMemberDialog(TeamMemberDto member, int index, AppLocalizations l10n) {
    final nameController = TextEditingController(text: member.name);
    final roleController = TextEditingController(text: member.role);
    final descriptionController = TextEditingController(text: member.description);
    final isFounder = member.isFounder.obs;

    Get.dialog(
      AlertDialog(
        title: Text(l10n.editTeamMember),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.name} *',
                  hintText: l10n.enterMemberName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: '${l10n.role} *',
                  hintText: l10n.enterMemberRole,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.enterMemberDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Obx(() => CheckboxListTile(
                    title: Text(l10n.markAsFounder),
                    value: isFounder.value,
                    onChanged: (value) => isFounder.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(l10n.error, l10n.pleaseEnterMemberName);
                return;
              }
              if (roleController.text.trim().isEmpty) {
                Get.snackbar(l10n.error, l10n.pleaseEnterMemberRole);
                return;
              }

              final updatedMember = TeamMemberDto(
                id: member.id,
                userId: member.userId,
                name: nameController.text.trim(),
                role: roleController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                avatarUrl: member.avatarUrl,
                isFounder: isFounder.value,
              );
              _teamMembers[index] = updatedMember;
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 构建删除按钮
  Widget _buildRemoveButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        onPressed: () {
          setState(() {
            _coverImage = null;
            _coverImageUrl = null;
          });
        },
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withAlpha(128),
        ),
        icon: const Icon(
          FontAwesomeIcons.xmark,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 构建图片来源标签
  Widget _buildImageSourceBadge(String label, IconData icon) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
