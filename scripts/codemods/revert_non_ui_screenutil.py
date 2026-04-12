#!/usr/bin/env python3
"""
revert_non_ui_screenutil.py

还原不应使用 screenutil 的参数:
  1. strokeWidth: X.w → X   (线条粗细, 不随屏幕缩放)
  2. thickness: X.w → X     (Divider 厚度)
  3. ImagePicker maxWidth/maxHeight 1920.w/1080.h → 1920/1080 (图片分辨率)
  4. 响应式断点 maxWidth: 600.w/720.w/900.w → 600/720/900
  5. Border width 0.5.w / 1.w / 1.5.w / 2.w → 还原 (细边框不缩放)
  6. Offset dy in BoxShadow → 检查并修复

用法: python3 scripts/codemods/revert_non_ui_screenutil.py [--dry-run]
"""

import re
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'
DRY_RUN = '--dry-run' in sys.argv

SKIP_SUFFIXES = {'.g.dart', '.freezed.dart'}
NUM = r"(\d+(?:\.\d+)?)"

REVERT_RULES = []


def _add(desc, pattern, replacement):
    REVERT_RULES.append((desc, re.compile(pattern), replacement))


_add('strokeWidth', rf"(\bstrokeWidth\s*:\s*){NUM}\.w\b", r"\g<1>\2")
_add('thickness', rf"(\bthickness\s*:\s*){NUM}\.w\b", r"\g<1>\2")
_add('ImagePicker maxWidth', rf"(\bmaxWidth\s*:\s*)(1920|1080|2048|4096|3840)\.w\b", r"\g<1>\2")
_add('ImagePicker maxHeight', rf"(\bmaxHeight\s*:\s*)(1920|1080|2048|4096|3840)\.h\b", r"\g<1>\2")
_add('responsive maxWidth', rf"(\bmaxWidth\s*:\s*)(600|720|900|1024|1200)\.w\b", r"\g<1>\2")
_add('Border.all width', rf"(Border\.all\s*\(\s*(?:color\s*:[^,]+,\s*)?width\s*:\s*){NUM}\.w\b", r"\g<1>\2")
_add('Border side width', rf"(BorderSide\s*\(\s*(?:color\s*:[^,]+,\s*)?width\s*:\s*){NUM}\.w\b", r"\g<1>\2")


def revert_border_width_in_context(content):
    """还原在 Border 上下文中的 width: X.w。"""
    changes = 0
    lines = content.split('\n')
    in_border_context = False
    brace_depth = 0

    for index, line in enumerate(lines):
        stripped = line.strip()
        if re.search(r'Border\.(all|only|symmetric)\(|BorderSide\(', stripped):
            in_border_context = True
            brace_depth = stripped.count('(') - stripped.count(')')

        if in_border_context:
            match = re.search(r'(\bwidth\s*:\s*)(\d+(?:\.\d+)?)\.w\b', line)
            if match:
                val = float(match.group(2))
                if val <= 5:
                    new_line = line[:match.start()] + match.group(1) + match.group(2) + line[match.end():]
                    if new_line != line:
                        lines[index] = new_line
                        changes += 1

            brace_depth += stripped.count('(') - stripped.count(')')
            if brace_depth <= 0:
                in_border_context = False

    return ('\n'.join(lines), changes) if changes > 0 else (content, 0)


def revert_divider_related(content):
    """还原 Divider(height: X.h) 中不合理的值。"""
    pattern = re.compile(r'(Divider\s*\([^)]*?height\s*:\s*)(\d+(?:\.\d+)?)\.h\b')
    new_content, count = pattern.subn(r'\1\2', content)
    return new_content, count


def process_file(fp):
    content = fp.read_text(encoding='utf-8')
    original = content
    total_changes = 0
    details = {}

    for desc, pattern, replacement in REVERT_RULES:
        new_content, count = pattern.subn(replacement, content)
        if count > 0:
            total_changes += count
            details[desc] = details.get(desc, 0) + count
            content = new_content

    content, count = revert_border_width_in_context(content)
    if count > 0:
        total_changes += count
        details['Border context width'] = count

    content, count = revert_divider_related(content)
    if count > 0:
        total_changes += count
        details['Divider height'] = count

    if content != original and not DRY_RUN:
        fp.write_text(content, encoding='utf-8')

    return total_changes, details


def main():
    if DRY_RUN:
        print('🔍 DRY RUN\n')

    total_files = 0
    modified = 0
    total_changes = 0
    all_details = {}

    for fp in sorted(LIB_DIR.rglob('*.dart')):
        if any(fp.name.endswith(suffix) for suffix in SKIP_SUFFIXES):
            continue
        total_files += 1
        changes, details = process_file(fp)
        if changes > 0:
            modified += 1
            total_changes += changes
            print(f"  🔧 {fp.relative_to(LIB_DIR)} — {changes} 处还原")
            for desc, count in details.items():
                print(f'       {desc}: {count}')
                all_details[desc] = all_details.get(desc, 0) + count

    print(f"\n{'=' * 60}")
    print(f'📊 扫描 {total_files} 文件, 修改 {modified} 文件, {total_changes} 处还原')
    print('\n📋 类别统计:')
    for desc, count in sorted(all_details.items(), key=lambda item: -item[1]):
        print(f'   {desc:30s} {count:5d}')
    if DRY_RUN:
        print('\n⚠️  DRY RUN, 未修改文件。')


if __name__ == '__main__':
    main()