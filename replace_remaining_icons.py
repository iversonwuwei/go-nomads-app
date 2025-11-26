#!/usr/bin/env python3
"""
批量替换剩余的Material Icons为FontAwesome图标
"""

import glob

# 扩展的图标映射表
ICON_MAPPINGS = {
    'Icons.notifications_none': 'FontAwesomeIcons.bell',
    'Icons.group': 'FontAwesomeIcons.userGroup',
    'Icons.flag': 'FontAwesomeIcons.flag',
    'Icons.rate_review': 'FontAwesomeIcons.commentDots',
    'Icons.military_tech': 'FontAwesomeIcons.medal',
    'Icons.history': 'FontAwesomeIcons.clockRotateLeft',
    'Icons.event': 'FontAwesomeIcons.calendarDays',
    'Icons.message': 'FontAwesomeIcons.message',
    'Icons.share': 'FontAwesomeIcons.shareNodes',
    'Icons.laptop': 'FontAwesomeIcons.laptop',
    'Icons.sports': 'FontAwesomeIcons.football',
    'Icons.tune_outlined': 'FontAwesomeIcons.sliders',
    'Icons.grid_view_outlined': 'FontAwesomeIcons.grip',
    'Icons.sort_outlined': 'FontAwesomeIcons.arrowDownWideShort',
    'Icons.event_busy': 'FontAwesomeIcons.calendarXmark',
    'Icons.clear': 'FontAwesomeIcons.xmark',
    'Icons.local_activity': 'FontAwesomeIcons.ticket',
    'Icons.shopping_bag': 'FontAwesomeIcons.bagShopping',
    'Icons.more_horiz': 'FontAwesomeIcons.ellipsis',
    'Icons.send': 'FontAwesomeIcons.paperPlane',
    'Icons.lightbulb': 'FontAwesomeIcons.lightbulb',
    'Icons.visibility': 'FontAwesomeIcons.eye',
    'Icons.chat': 'FontAwesomeIcons.comments',
    'Icons.rocket_launch': 'FontAwesomeIcons.rocket',
    'Icons.devices': 'FontAwesomeIcons.laptop',
    'Icons.trending_up': 'FontAwesomeIcons.chartLine',
    'Icons.timeline': 'FontAwesomeIcons.clockRotateLeft',
    'Icons.groups': 'FontAwesomeIcons.userGroup',
    'Icons.handshake_outlined': 'FontAwesomeIcons.handshake',
    'Icons.sort': 'FontAwesomeIcons.arrowDownShortWide',
    'Icons.sort_by_alpha': 'FontAwesomeIcons.arrowDownAZ',
    'Icons.thermostat': 'FontAwesomeIcons.temperatureHalf',
    'Icons.wc': 'FontAwesomeIcons.restroom',
    'Icons.videocam': 'FontAwesomeIcons.video',
    'Icons.call': 'FontAwesomeIcons.phone',
    'Icons.more_vert': 'FontAwesomeIcons.ellipsisVertical',
    'Icons.notifications_off_outlined': 'FontAwesomeIcons.bellSlash',
    'Icons.block_outlined': 'FontAwesomeIcons.ban',
    'Icons.emoji_emotions_outlined': 'FontAwesomeIcons.faceSmile',
    'Icons.send_rounded': 'FontAwesomeIcons.paperPlane',
    'Icons.mic': 'FontAwesomeIcons.microphone',
    'Icons.public': 'FontAwesomeIcons.earthAmericas',
    'Icons.groups_rounded': 'FontAwesomeIcons.userGroup',
    'Icons.museum': 'FontAwesomeIcons.landmark',
    'Icons.park': 'FontAwesomeIcons.tree',
    'Icons.shopping_cart': 'FontAwesomeIcons.cartShopping',
    'Icons.palette': 'FontAwesomeIcons.palette',
    'Icons.landscape': 'FontAwesomeIcons.mountain',
    'Icons.beach_access': 'FontAwesomeIcons.umbrellaBeach',
    'Icons.temple_buddhist': 'FontAwesomeIcons.placeOfWorship',
    'Icons.nightlight': 'FontAwesomeIcons.moon',
    'Icons.water': 'FontAwesomeIcons.water',
    'Icons.event_outlined': 'FontAwesomeIcons.calendarDays',
    'Icons.museum_outlined': 'FontAwesomeIcons.landmark',
    'Icons.landscape_outlined': 'FontAwesomeIcons.mountain',
    'Icons.spa_outlined': 'FontAwesomeIcons.spa',
    'Icons.interests_outlined': 'FontAwesomeIcons.heart',
    'Icons.keyboard_arrow_down': 'FontAwesomeIcons.chevronDown',
    'Icons.rate_review_outlined': 'FontAwesomeIcons.commentDots',
    'Icons.pending_rounded': 'FontAwesomeIcons.clock',
    'Icons.local_offer': 'FontAwesomeIcons.tag',
    'Icons.update': 'FontAwesomeIcons.arrowsRotate',
    'Icons.directions': 'FontAwesomeIcons.diamondTurnRight',
    'Icons.today': 'FontAwesomeIcons.calendarDay',
    'Icons.date_range': 'FontAwesomeIcons.calendarDays',
    'Icons.calendar_month': 'FontAwesomeIcons.calendarDays',
    'Icons.desk': 'FontAwesomeIcons.chair',
    'Icons.meeting_room': 'FontAwesomeIcons.doorOpen',
    'Icons.volume_down': 'FontAwesomeIcons.volumeLow',
    'Icons.dashboard': 'FontAwesomeIcons.gaugeHigh',
    'Icons.wb_sunny': 'FontAwesomeIcons.sun',
    'Icons.coffee': 'FontAwesomeIcons.mugSaucer',
    'Icons.print': 'FontAwesomeIcons.print',
    'Icons.phone': 'FontAwesomeIcons.phone',
    'Icons.kitchen': 'FontAwesomeIcons.kitchenSet',
    'Icons.local_parking': 'FontAwesomeIcons.squareParking',
    'Icons.shower': 'FontAwesomeIcons.shower',
    'Icons.lock': 'FontAwesomeIcons.lock',
    'Icons.directions_bike': 'FontAwesomeIcons.personBiking',
    'Icons.pets': 'FontAwesomeIcons.paw',
    'Icons.email': 'FontAwesomeIcons.envelope',
    'Icons.comment_outlined': 'FontAwesomeIcons.comment',
    'Icons.cloud_upload': 'FontAwesomeIcons.cloudArrowUp',
    'Icons.mic_none_rounded': 'FontAwesomeIcons.microphone',
    'Icons.volume_off_outlined': 'FontAwesomeIcons.volumeXmark',
    'Icons.exit_to_app': 'FontAwesomeIcons.rightFromBracket',
    'Icons.folder': 'FontAwesomeIcons.folder',
    'Icons.construction': 'FontAwesomeIcons.triangleExclamation',
    'Icons.title': 'FontAwesomeIcons.heading',
    'Icons.contact_phone': 'FontAwesomeIcons.addressBook',
    'Icons.broken_image': 'FontAwesomeIcons.imageSlash',
    'Icons.calculate': 'FontAwesomeIcons.calculator',
    'Icons.chat_outlined': 'FontAwesomeIcons.comments',
}


def process_file(file_path):
    """处理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        needs_fontawesome_import = False
        
        # 替换所有映射的图标
        for material_icon, fontawesome_icon in ICON_MAPPINGS.items():
            if material_icon in content:
                content = content.replace(material_icon, fontawesome_icon)
                needs_fontawesome_import = True
        
        # 如果有替换且没有FontAwesome导入,添加导入
        if needs_fontawesome_import and 'font_awesome_flutter' not in content:
            # 找到import部分并添加
            import_lines = []
            other_lines = []
            in_imports = False
            
            for line in content.split('\n'):
                if line.startswith('import '):
                    in_imports = True
                    import_lines.append(line)
                elif in_imports and line.strip() == '':
                    # 导入结束
                    import_lines.append("import 'package:font_awesome_flutter/font_awesome_flutter.dart';")
                    import_lines.append(line)
                    in_imports = False
                    other_lines = content.split('\n')[len(import_lines):]
                    break
                else:
                    other_lines.append(line)
            
            if in_imports:  # 如果还在导入区
                import_lines.append("import 'package:font_awesome_flutter/font_awesome_flutter.dart';")
                import_lines.append('')
            
            content = '\n'.join(import_lines + other_lines)
        
        # 只有在内容发生变化时才写入
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
                f.write(content)
            print(f'✓ 已更新: {file_path}')
            return True
        return False
        
    except Exception as e:
        print(f'✗ 处理失败 {file_path}: {e}')
        return False


def main():
    """主函数"""
    print('开始批量替换Material Icons...\n')
    
    # 获取所有Dart文件
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    updated_count = 0
    for file_path in dart_files:
        if process_file(file_path):
            updated_count += 1
    
    print(f'\n完成! 共更新了 {updated_count} 个文件')


if __name__ == '__main__':
    main()
