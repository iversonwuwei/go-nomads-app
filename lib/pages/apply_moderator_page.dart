import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/moderator/presentation/controllers/moderator_application_controller.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 申请成为版主页面
class ApplyModeratorPage extends StatefulWidget {
  final City city;

  const ApplyModeratorPage({
    super.key,
    required this.city,
  });

  @override
  State<ApplyModeratorPage> createState() => _ApplyModeratorPageState();
}

class _ApplyModeratorPageState extends State<ApplyModeratorPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _controller = Get.find<ModeratorApplicationController>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _controller.applyForModerator(
        cityId: widget.city.id,
        cityName: widget.city.name,
        reason: _reasonController.text,
      );

      if (mounted) {
        AppToast.success('申请已提交，请等待管理员审核');
        Get.back();
      }
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('申请成为版主'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 城市信息卡片
              _buildCityCard(),
              const SizedBox(height: 32),

              // 版主职责说明
              _buildResponsibilitiesCard(),
              const SizedBox(height: 32),

              // 申请原因输入
              _buildReasonInput(),
              const SizedBox(height: 32),

              // 提交按钮
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '提交申请',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: widget.city.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.city.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: widget.city.imageUrl == null
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : null,
            ),
            child: widget.city.imageUrl == null
                ? Icon(
                    FontAwesomeIcons.city,
                    color: AppColors.accent,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.city.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.city.country ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.userShield,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                '版主职责',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsibilityItem('审核和管理用户提交的内容'),
          _buildResponsibilityItem('维护城市信息的准确性和时效性'),
          _buildResponsibilityItem('回答社区成员的问题'),
          _buildResponsibilityItem('组织线下活动和聚会'),
          _buildResponsibilityItem('处理不当内容和用户举报'),
        ],
      ),
    );
  }

  Widget _buildResponsibilityItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '申请原因 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _reasonController,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: '请说明您申请成为版主的原因，以及您能为社区带来什么...',
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accent, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入申请原因';
            }
            if (value.trim().length < 20) {
              return '申请原因至少需要 20 个字符';
            }
            return null;
          },
        ),
      ],
    );
  }
}
