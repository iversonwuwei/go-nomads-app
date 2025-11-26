import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/pages/maplibre_picker_page.dart';
import 'package:df_admin_mobile/utils/image_upload_helper.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CityPhotoSubmissionPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CityPhotoSubmissionPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CityPhotoSubmissionPage> createState() => _CityPhotoSubmissionPageState();
}

class _CityPhotoSubmissionPageState extends State<CityPhotoSubmissionPage> {
  static const int maxPhotoCount = 10;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationNoteController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _photoUrls = [];

  bool _uploadingImages = false;
  bool _submitting = false;
  String? _uploadStatus;

  // 地图选择的经纬度
  double? _selectedLat;
  double? _selectedLng;

  UserCityContentStateController get _controller => Get.find<UserCityContentStateController>();

  int get _remainingSlots => maxPhotoCount - _photoUrls.length;

  @override
  void dispose() {
    _titleController.dispose();
    _locationNoteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_remainingSlots <= 0) {
      AppToast.info('最多只能上传 $maxPhotoCount 张照片');
      return;
    }

    setState(() {
      _uploadingImages = true;
      _uploadStatus = null;
    });

    try {
      final newUrls = await ImageUploadHelper.pickMultipleAndUpload(
        folder: 'city_photos/${widget.cityId}',
        maxImages: _remainingSlots,
        onProgress: (current, total) {
          setState(() {
            _uploadStatus = '上传进度 $current / $total';
          });
        },
      );

      if (newUrls.isNotEmpty) {
        setState(() {
          _photoUrls.addAll(newUrls);
        });
      }
    } catch (e) {
      AppToast.error('选择照片失败: $e');
    } finally {
      setState(() {
        _uploadingImages = false;
        _uploadStatus = null;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_remainingSlots <= 0) {
      AppToast.info('最多只能上传 $maxPhotoCount 张照片');
      return;
    }

    setState(() {
      _uploadingImages = true;
    });

    try {
      final url = await ImageUploadHelper.captureAndUpload(
        folder: 'city_photos/${widget.cityId}',
      );

      if (url != null) {
        setState(() {
          _photoUrls.add(url);
        });
      }
    } catch (e) {
      AppToast.error('拍照失败: $e');
    } finally {
      setState(() {
        _uploadingImages = false;
      });
    }
  }

  Future<void> _showAddPhotoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.images),
                title: const Text('从相册选择 (可多选)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.camera),
                title: const Text('拍照上传'),
                onTap: () {
                  Navigator.pop(context);
                  _capturePhoto();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.xmark),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
  }

  Future<void> _openMapPicker() async {
    final address = _locationNoteController.text.trim();

    final result = await Get.to<Map<String, dynamic>>(
      () => MapLibrePickerPage(
        initialLatitude: _selectedLat,
        initialLongitude: _selectedLng,
        searchQuery: address,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLat = result['latitude'] as double?;
        _selectedLng = result['longitude'] as double?;

        // 更新地址信息
        final addressText = result['address'] as String? ?? '';
        final nameText = result['name'] as String? ?? '';

        // 优先使用 name，如果为空则使用 address
        final displayText = nameText.isNotEmpty ? nameText : addressText;

        if (displayText.isNotEmpty) {
          _locationNoteController.text = displayText;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photoUrls.isEmpty) {
      AppToast.info('请至少上传一张照片');
      return;
    }

    setState(() {
      _submitting = true;
    });

    final success = await _controller.submitPhotoCollection(
      cityId: widget.cityId,
      title: _titleController.text.trim(),
      imageUrls: _photoUrls,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      locationNote: _locationNoteController.text.trim().isEmpty ? null : _locationNoteController.text.trim(),
      reloadAfterSubmit: true,
    );

    setState(() {
      _submitting = false;
    });

    if (success) {
      AppToast.success('照片已提交');
      Get.back(result: {'uploaded': true});
    } else {
      AppToast.error('提交失败，请稍后再试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        title: Text('上传照片 · ${widget.cityName}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '为数字游民社区分享你在 ${widget.cityName} 的真实体验',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题 / 地点',
                  hintText: '例：北戴河海边日出',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请填写一个标题或地点描述';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationNoteController,
                decoration: InputDecoration(
                  labelText: '位置信息 (可选)',
                  hintText: '街道、地标或更多定位线索',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.locationDot,
                      color: Color(0xFFFF4458),
                      size: 20,
                    ),
                    onPressed: _openMapPicker,
                    tooltip: '在地图上定位',
                  ),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {}); // 更新UI
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述 (可选)',
                  hintText: '简单介绍照片内容、拍摄时间等',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已选择 ${_photoUrls.length} / $maxPhotoCount',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cityPrimary,
                    ),
                    onPressed: _uploadingImages ? null : _showAddPhotoSheet,
                    icon: const Icon(FontAwesomeIcons.photoFilm),
                    label: const Text('添加照片'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_uploadingImages)
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(_uploadStatus ?? '正在上传...'),
                  ],
                ),
              const SizedBox(height: 12),
              _photoUrls.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(FontAwesomeIcons.images, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('还没有照片，点击上方“添加照片”按钮上传'),
                        ],
                      ),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _photoUrls
                          .asMap()
                          .entries
                          .map(
                            (entry) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    entry.value,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(entry.key),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        FontAwesomeIcons.xmark,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.cityPrimary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _uploadingImages || _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(FontAwesomeIcons.cloudArrowUp),
                  label: Text(_submitting ? '提交中...' : '提交'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '提交后后端会通过高德地图自动补齐坐标，成功后你将回到城市详情页，照片会在刷新后展示。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
