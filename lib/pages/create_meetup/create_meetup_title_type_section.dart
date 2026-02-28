import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMeetupTitleSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupTitleSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.meetupTitle, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _c.titleController,
          decoration: InputDecoration(
            hintText: l10n.enterMeetupTitle,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterTitle;
            }
            return null;
          },
        ),
      ],
    );
  }
}

class CreateMeetupTypeSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupTypeSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.meetupType, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        Obx(() => _c.showCustomTypeInput.value ? _buildCustomTypeInput(context, l10n) : _buildTypeSelector(context, l10n)),
      ],
    );
  }

  Widget _buildCustomTypeInput(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _c.typeController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '输入自定义类型',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterType;
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: const Icon(FontAwesomeIcons.xmark, color: Colors.grey),
          onPressed: _c.cancelCustomType,
          tooltip: '返回选择列表',
        ),
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context, AppLocalizations l10n) {
    return FormField<String>(
      initialValue: _c.selectedType.value,
      validator: (value) {
        if ((value == null || value.isEmpty) && _c.typeController.text.isEmpty) {
          return l10n.pleaseEnterType;
        }
        return null;
      },
      builder: (field) {
        return Obx(() {
          final displayType = _c.selectedType.value;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showTypePicker(context, l10n, field),
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: l10n.meetupTypeHint,
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _c.isLoadingTypes.value
                    ? Padding(
                        padding: EdgeInsets.all(8.w),
                        child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Icon(FontAwesomeIcons.chevronDown, size: 18.r),
                errorText: field.errorText,
              ),
              isEmpty: displayType == null || displayType.isEmpty,
              child: Text(
                displayType ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: displayType == null || displayType.isEmpty
                          ? Theme.of(context).hintColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showTypePicker(BuildContext context, AppLocalizations l10n, FormFieldState<String> field) {
    if (_c.isLoadingTypes.value) {
      AppToast.info(l10n.loading, title: l10n.notice);
      return;
    }

    if (_c.meetupTypes.isEmpty) {
      AppToast.info(l10n.noData, title: l10n.notice);
      return;
    }

    FocusScope.of(context).unfocus();
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final displayOptions = _c.meetupTypes.map((type) => type.getDisplayName(localeCode)).toList();
    final optionsWithCustom = [...displayOptions, '+ 自定义类型'];

    Get.bottomSheet(
      Container(
        height: 300.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
                  Text(l10n.meetupType, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  TextButton(onPressed: () => Get.back(), child: Text(l10n.confirm, style: const TextStyle(color: Color(0xFFFF4458)))),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: optionsWithCustom.length,
                itemBuilder: (context, index) {
                  final option = optionsWithCustom[index];
                  final isSelected = option == _c.selectedType.value;
                  return ListTile(
                    title: Text(option, style: TextStyle(color: isSelected ? const Color(0xFFFF4458) : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    trailing: isSelected ? const Icon(FontAwesomeIcons.check, color: Color(0xFFFF4458)) : null,
                    onTap: () {
                      _c.selectType(option, localeCode, field);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
