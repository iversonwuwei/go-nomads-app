import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

/// Add Innovation Project Page
/// 添加创意项目页面
class AddInnovationPage extends StatefulWidget {
  const AddInnovationPage({super.key});

  @override
  State<AddInnovationPage> createState() => _AddInnovationPageState();
}

class _AddInnovationPageState extends State<AddInnovationPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  // 基本信息
  final _projectNameController = TextEditingController();
  final _elevatorPitchController = TextEditingController();
  File? _coverImage;

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
  final _teamMembersController = TextEditingController(); // JSON 格式或逐个添加
  final _askController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

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
    _teamMembersController.dispose();
    _askController.dispose();
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
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error('${l10n.imageSelectionFailed}: $e');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      // 处理核心功能列表
      // final keyFeatures = _keyFeaturesController.text
      //     .split(',')
      //     .map((e) => e.trim())
      //     .where((e) => e.isNotEmpty)
      //     .toList();

      // 这里应该调用 API 保存项目
      // TODO: 实现项目保存逻辑，使用表单数据包括 keyFeatures
      // 暂时只显示成功消息
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.success(l10n.projectCreatedSuccessfully);
        Navigator.pop(context, true); // 返回 true 通知父页面刷新数据
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error('${l10n.creationFailed}: $e');
      }
    } finally {
      _isSubmitting.value = false;
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
        title: Text(l10n.createInnovationProject),
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
                      Icons.info_outline,
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
                icon: Icons.rocket_launch,
                title: l10n.basicInformation,
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _projectNameController,
                label: l10n.projectName,
                hint: l10n.projectNameHint,
                icon: Icons.title,
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
                icon: Icons.chat_bubble_outline,
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
                icon: Icons.lightbulb_outline,
                title: l10n.problemAndSolution,
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _problemController,
                label: l10n.problem,
                hint: l10n.problemHint,
                icon: Icons.error_outline,
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
                icon: Icons.check_circle_outline,
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
                icon: Icons.people_outline,
                title: l10n.marketPositioning,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _targetAudienceController,
                label: l10n.targetAudience,
                hint: l10n.targetAudienceHint,
                icon: Icons.people,
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
                icon: Icons.devices,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _keyFeaturesController,
                label: l10n.keyFeatures,
                hint: l10n.keyFeaturesHint,
                icon: Icons.star_outline,
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
                icon: Icons.trending_up,
                title: l10n.competitionAndBusiness,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _competitiveAdvantageController,
                label: l10n.competitiveAdvantage,
                hint: l10n.competitiveAdvantageHint,
                icon: Icons.emoji_events,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _businessModelController,
                label: l10n.businessModel,
                hint: l10n.businessModelHint,
                icon: Icons.attach_money,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _marketOpportunityController,
                label: l10n.marketOpportunity,
                hint: l10n.marketOpportunityHint,
                icon: Icons.analytics_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // 5. 进展与需求
              _buildSectionTitle(
                icon: Icons.timeline,
                title: l10n.progressAndNeeds,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _currentStatusController,
                label: l10n.currentStatus,
                hint: l10n.currentStatusHint,
                icon: Icons.flag,
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
                icon: Icons.handshake_outlined,
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
                icon: Icons.groups,
                title: '${l10n.teamInformation} (${l10n.optional})',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _teamMembersController,
                label: l10n.teamMembers,
                hint: l10n.teamMembersHint,
                icon: Icons.people,
                maxLines: 6,
              ),

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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, size: 20, color: Color(0xFF8B5CF6)),
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
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: _coverImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _coverImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _coverImage = null;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withAlpha(128),
                          ),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
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
                  ),
          ),
        ),
      ],
    );
  }
}
