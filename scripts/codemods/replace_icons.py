#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""批量替换 Flutter Material Icons 为 FontAwesome Icons。"""

from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'


ICON_MAPPINGS = {
    'Icons.home': 'FontAwesomeIcons.house',
    'Icons.person': 'FontAwesomeIcons.user',
    'Icons.person_outline': 'FontAwesomeIcons.user',
    'Icons.settings': 'FontAwesomeIcons.gear',
    'Icons.arrow_back_ios_new': 'FontAwesomeIcons.arrowLeft',
    'Icons.arrow_back_outlined': 'FontAwesomeIcons.arrowLeft',
    'Icons.arrow_back': 'FontAwesomeIcons.arrowLeft',
    'Icons.arrow_forward_ios': 'FontAwesomeIcons.arrowRight',
    'Icons.arrow_forward': 'FontAwesomeIcons.arrowRight',
    'Icons.arrow_forward_rounded': 'FontAwesomeIcons.arrowRight',
    'Icons.arrow_upward': 'FontAwesomeIcons.arrowUp',
    'Icons.arrow_upward_outlined': 'FontAwesomeIcons.arrowUp',
    'Icons.arrow_downward': 'FontAwesomeIcons.arrowDown',
    'Icons.arrow_downward_rounded': 'FontAwesomeIcons.arrowDown',
    'Icons.add': 'FontAwesomeIcons.plus',
    'Icons.add_rounded': 'FontAwesomeIcons.circlePlus',
    'Icons.edit': 'FontAwesomeIcons.pen',
    'Icons.delete_outline': 'FontAwesomeIcons.trash',
    'Icons.delete': 'FontAwesomeIcons.trash',
    'Icons.search': 'FontAwesomeIcons.magnifyingGlass',
    'Icons.close': 'FontAwesomeIcons.xmark',
    'Icons.check': 'FontAwesomeIcons.check',
    'Icons.check_circle_rounded': 'FontAwesomeIcons.circleCheck',
    'Icons.check_circle': 'FontAwesomeIcons.circleCheck',
    'Icons.check_circle_outline': 'FontAwesomeIcons.circleCheck',
    'Icons.check_box': 'FontAwesomeIcons.squareCheck',
    'Icons.star': 'FontAwesomeIcons.star',
    'Icons.star_rate': 'FontAwesomeIcons.star',
    'Icons.favorite': 'FontAwesomeIcons.heart',
    'Icons.favorite_outline': 'FontAwesomeIcons.heart',
    'Icons.location_on': 'FontAwesomeIcons.locationDot',
    'Icons.location_off': 'FontAwesomeIcons.locationDot',
    'Icons.location_city': 'FontAwesomeIcons.city',
    'Icons.location_on_outlined': 'FontAwesomeIcons.locationDot',
    'Icons.calendar_today': 'FontAwesomeIcons.calendar',
    'Icons.image': 'FontAwesomeIcons.image',
    'Icons.image_not_supported': 'FontAwesomeIcons.imagePortrait',
    'Icons.camera_alt': 'FontAwesomeIcons.camera',
    'Icons.photo_library': 'FontAwesomeIcons.images',
    'Icons.add_photo_alternate': 'FontAwesomeIcons.photoFilm',
    'Icons.email_outlined': 'FontAwesomeIcons.envelope',
    'Icons.lock_outline': 'FontAwesomeIcons.lock',
    'Icons.visibility_outlined': 'FontAwesomeIcons.eye',
    'Icons.visibility_off_outlined': 'FontAwesomeIcons.eyeSlash',
    'Icons.refresh': 'FontAwesomeIcons.arrowsRotate',
    'Icons.info_outline': 'FontAwesomeIcons.circleInfo',
    'Icons.info_rounded': 'FontAwesomeIcons.circleInfo',
    'Icons.error_outline': 'FontAwesomeIcons.circleExclamation',
    'Icons.error_rounded': 'FontAwesomeIcons.circleExclamation',
    'Icons.warning_rounded': 'FontAwesomeIcons.triangleExclamation',
    'Icons.warning_amber_rounded': 'FontAwesomeIcons.triangleExclamation',
    'Icons.verified': 'FontAwesomeIcons.circleCheck',
    'Icons.verified_outlined': 'FontAwesomeIcons.circleCheck',
    'Icons.hotel': 'FontAwesomeIcons.hotel',
    'Icons.bed': 'FontAwesomeIcons.bed',
    'Icons.single_bed': 'FontAwesomeIcons.bed',
    'Icons.restaurant': 'FontAwesomeIcons.utensils',
    'Icons.access_time': 'FontAwesomeIcons.clock',
    'Icons.account_balance': 'FontAwesomeIcons.landmark',
    'Icons.ac_unit': 'FontAwesomeIcons.snowflake',
    'Icons.air': 'FontAwesomeIcons.wind',
    'Icons.air_rounded': 'FontAwesomeIcons.wind',
    'Icons.airplane_ticket': 'FontAwesomeIcons.ticketSimple',
    'Icons.attractions': 'FontAwesomeIcons.cameraRetro',
    'Icons.analytics_outlined': 'FontAwesomeIcons.chartLine',
    'Icons.flight_takeoff': 'FontAwesomeIcons.plane',
    'Icons.flight': 'FontAwesomeIcons.plane',
    'Icons.local_airport': 'FontAwesomeIcons.plane',
    'Icons.attach_money': 'FontAwesomeIcons.dollarSign',
    'Icons.wifi': 'FontAwesomeIcons.wifi',
    'Icons.work': 'FontAwesomeIcons.briefcase',
    'Icons.work_outline': 'FontAwesomeIcons.briefcase',
    'Icons.chat_bubble_outline': 'FontAwesomeIcons.message',
    'Icons.share_outlined': 'FontAwesomeIcons.shareNodes',
    'Icons.download_outlined': 'FontAwesomeIcons.download',
    'Icons.map_outlined': 'FontAwesomeIcons.map',
    'Icons.map': 'FontAwesomeIcons.map',
    'Icons.notifications_active': 'FontAwesomeIcons.solidBell',
    'Icons.notifications_outlined': 'FontAwesomeIcons.bell',
    'Icons.language': 'FontAwesomeIcons.globe',
    'Icons.logout': 'FontAwesomeIcons.rightFromBracket',
    'Icons.memory': 'FontAwesomeIcons.microchip',
    'Icons.travel_explore': 'FontAwesomeIcons.earthAmericas',
    'Icons.auto_awesome': 'FontAwesomeIcons.wandMagicSparkles',
    'Icons.place': 'FontAwesomeIcons.locationPin',
    'Icons.place_outlined': 'FontAwesomeIcons.locationPin',
    'Icons.my_location': 'FontAwesomeIcons.locationCrosshairs',
    'Icons.navigation': 'FontAwesomeIcons.compassDrafting',
    'Icons.layers': 'FontAwesomeIcons.layerGroup',
    'Icons.layers_outlined': 'FontAwesomeIcons.layerGroup',
    'Icons.schedule': 'FontAwesomeIcons.clock',
    'Icons.event_note': 'FontAwesomeIcons.noteSticky',
    'Icons.lightbulb_outline': 'FontAwesomeIcons.lightbulb',
    'Icons.tips_and_updates': 'FontAwesomeIcons.lightbulb',
    'Icons.cancel': 'FontAwesomeIcons.ban',
    'Icons.cancel_outlined': 'FontAwesomeIcons.ban',
    'Icons.emoji_events': 'FontAwesomeIcons.trophy',
    'Icons.emoji_events_outlined': 'FontAwesomeIcons.trophy',
    'Icons.admin_panel_settings': 'FontAwesomeIcons.userShield',
    'Icons.explore': 'FontAwesomeIcons.compass',
    'Icons.explore_outlined': 'FontAwesomeIcons.compass',
    'Icons.directions_subway': 'FontAwesomeIcons.trainSubway',
    'Icons.directions_transit': 'FontAwesomeIcons.trainSubway',
    'Icons.directions_bus': 'FontAwesomeIcons.bus',
    'Icons.directions_walk': 'FontAwesomeIcons.personWalking',
    'Icons.people': 'FontAwesomeIcons.users',
    'Icons.people_alt': 'FontAwesomeIcons.userGroup',
    'Icons.square_foot': 'FontAwesomeIcons.rulerCombined',
    'Icons.chevron_right': 'FontAwesomeIcons.chevronRight',
    'Icons.arrow_drop_down': 'FontAwesomeIcons.chevronDown',
    'Icons.privacy_tip_outlined': 'FontAwesomeIcons.userSecret',
    'Icons.near_me': 'FontAwesomeIcons.paperPlane',
    'Icons.done_all': 'FontAwesomeIcons.checkDouble',
    'Icons.account_balance_wallet': 'FontAwesomeIcons.wallet',
    'Icons.code': 'FontAwesomeIcons.code',
    'Icons.business': 'FontAwesomeIcons.building',
    'Icons.link': 'FontAwesomeIcons.link',
    'Icons.hourglass_empty': 'FontAwesomeIcons.hourglass',
    'Icons.apartment': 'FontAwesomeIcons.building',
    'Icons.thumb_up': 'FontAwesomeIcons.thumbsUp',
    'Icons.local_cafe': 'FontAwesomeIcons.mugSaucer',
    'Icons.bolt': 'FontAwesomeIcons.bolt',
    'Icons.style': 'FontAwesomeIcons.paintbrush',
    'Icons.safety_check': 'FontAwesomeIcons.shieldHalved',
    'Icons.nature_people': 'FontAwesomeIcons.tree',
    'Icons.nightlife': 'FontAwesomeIcons.champagneGlasses',
    'Icons.family_restroom': 'FontAwesomeIcons.peopleRoof',
    'Icons.health_and_safety': 'FontAwesomeIcons.heartPulse',
    'Icons.flutter_dash': 'FontAwesomeIcons.rocket',
}

FA_IMPORT = "import 'package:font_awesome_flutter/font_awesome_flutter.dart';"


def process_file(file_path: Path) -> bool:
    """处理单个文件。"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        if 'Icons.' not in content:
            return False

        for icon_key in sorted(ICON_MAPPINGS.keys(), key=len, reverse=True):
            if icon_key in content:
                content = content.replace(icon_key, ICON_MAPPINGS[icon_key])

        if content != original_content:
            if FA_IMPORT not in content:
                if "import 'package:flutter/material.dart';" in content:
                    content = content.replace(
                        "import 'package:flutter/material.dart';",
                        f"import 'package:flutter/material.dart';\n{FA_IMPORT}",
                    )
                elif content.startswith('import '):
                    content = f"{FA_IMPORT}\n{content}"

            file_path.write_text(content, encoding='utf-8', newline='\n')
            return True

        return False

    except Exception as exc:
        print(f"错误处理文件 {file_path.relative_to(PROJECT_ROOT).as_posix()}: {exc}")
        return False


def main() -> None:
    """主函数。"""
    dart_files = [path for path in LIB_DIR.rglob('*.dart') if '.bak' not in str(path)]

    total_files = len(dart_files)
    modified_files = 0

    print(f"找到 {total_files} 个 Dart 文件")
    print('开始处理...')
    print()

    for file_path in dart_files:
        if process_file(file_path):
            modified_files += 1
            print(f"✓ 已修改: {file_path.relative_to(PROJECT_ROOT).as_posix()}")

    print()
    print('=' * 50)
    print(f'总文件数: {total_files}')
    print(f'已修改文件数: {modified_files}')
    print('=' * 50)


if __name__ == '__main__':
    main()
