#!/usr/bin/env python3
"""
flutter_screenutil 全量自动适配脚本 v2

修复 v1 的问题:
  1. 正则回溯导致数字被切分 (如 12 → 1.r2.r) → 使用 (?![\d.]) 防回溯
  2. 关键字前缀重叠 (Radius.circular ⊂ BorderRadius.circular) → 使用 \b + lookbehind
  3. const 表达式不能使用运行时扩展 → 自动移除 const
  4. 非 UI 参数被误转换 → 排除 maxLines/flex/opacity/duration 等

用法: python3 scripts/codemods/apply_screenutil.py [--dry-run]
"""

import re
import sys
from pathlib import Path

# ============================================================================
# 配置
# ============================================================================
PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'
SCREENUTIL_IMPORT = "import 'package:flutter_screenutil/flutter_screenutil.dart';"

SKIP_DIRS = {'generated', '.dart_tool', 'build'}
SKIP_FILE_SUFFIXES = {'.g.dart', '.freezed.dart'}

DRY_RUN = '--dry-run' in sys.argv

# ============================================================================
# 正则构建
# ============================================================================
NUM = r"(\d+(?:\.\d+)?)"
NO_TRAIL = r"(?![\d.])"

PATTERNS = []


def _add(desc, regex, group_idx, suffix):
    PATTERNS.append((desc, re.compile(regex), group_idx, suffix))


_add('fontSize', rf"(\bfontSize\s*:\s*){NUM}{NO_TRAIL}", 2, 'sp')
_add('letterSpacing', rf"(\bletterSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'sp')
_add('wordSpacing', rf"(\bwordSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'sp')
_add('SizedBox width', rf"(SizedBox\s*\(\s*width\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('SizedBox height', rf"(SizedBox\s*\(\s*height\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('EdgeInsets.all', rf"(EdgeInsets\.all\s*\(\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('horizontal', rf"(\bhorizontal\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('vertical', rf"(\bvertical\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('left', rf"(\bleft\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('right', rf"(\bright\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('top', rf"(\btop\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('bottom', rf"(\bbottom\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('BorderRadius.circular', rf"(BorderRadius\.circular\s*\(\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('Radius.circular', rf"((?<!Border)Radius\.circular\s*\(\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('height', rf"(\bheight\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('width', rf"(\bwidth\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('maxHeight', rf"(\bmaxHeight\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('minHeight', rf"(\bminHeight\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('maxWidth', rf"(\bmaxWidth\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('minWidth', rf"(\bminWidth\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('size', rf"(\bsize\s*:\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('iconSize', rf"(\biconSize\s*:\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('thickness', rf"(\bthickness\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('strokeWidth', rf"(\bstrokeWidth\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('blurRadius', rf"(\bblurRadius\s*:\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('spreadRadius', rf"(\bspreadRadius\s*:\s*){NUM}{NO_TRAIL}", 2, 'r')
_add('spacing', rf"(\bspacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('runSpacing', rf"(\brunSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('mainAxisSpacing', rf"(\bmainAxisSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('crossAxisSpacing', rf"(\bcrossAxisSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('indent', rf"(\bindent\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('endIndent', rf"(\bendIndent\s*:\s*){NUM}{NO_TRAIL}", 2, 'w')
_add('toolbarHeight', rf"(\btoolbarHeight\s*:\s*){NUM}{NO_TRAIL}", 2, 'h')
_add('Offset', rf"(Offset\s*\(\s*){NUM}{NO_TRAIL}", 2, 'w')

# ============================================================================
# const 移除
# ============================================================================
SCREENUTIL_EXT = re.compile(r"\d\.(?:w|h|sp|r)\b")


def remove_const_from_adapted(content):
    """移除包含 screenutil 扩展的表达式中的 const 关键字。"""
    const_re = re.compile(r"\bconst\b")
    removals = []

    for match in const_re.finditer(content):
        cs = match.start()
        ce = match.end()
        after = content[ce:]
        paren_m = re.search(r"[\s\w.<>?,]*?([({\[])", after)
        if not paren_m:
            continue

        open_char = paren_m.group(1)
        close_char = {'(': ')', '[': ']', '{': '}'}[open_char]
        open_pos = ce + paren_m.end() - 1

        depth = 1
        pos = open_pos + 1
        in_str = False
        str_ch = None
        while pos < len(content) and depth > 0:
            current = content[pos]
            if in_str:
                if current == str_ch and (pos == 0 or content[pos - 1] != '\\'):
                    in_str = False
            else:
                if current in ("'", '"'):
                    in_str = True
                    str_ch = current
                elif current == open_char:
                    depth += 1
                elif current == close_char:
                    depth -= 1
            pos += 1

        if depth != 0:
            continue

        expr = content[open_pos:pos]
        if SCREENUTIL_EXT.search(expr):
            trail = 0
            while ce + trail < len(content) and content[ce + trail] == ' ':
                trail += 1
            removals.append((cs, ce + trail))

    for start, end in reversed(removals):
        content = content[:start] + content[end:]

    return content


def should_skip(fp):
    rel = fp.relative_to(LIB_DIR)
    if any(part in SKIP_DIRS for part in rel.parts):
        return True
    return any(fp.name.endswith(suffix) for suffix in SKIP_FILE_SUFFIXES)


def add_import(content):
    if 'flutter_screenutil' in content:
        return content
    lines = content.split('\n')
    last_imp = -1
    for index, line in enumerate(lines):
        if line.strip().startswith('import '):
            last_imp = index
    if last_imp == -1:
        return SCREENUTIL_IMPORT + '\n' + content
    lines.insert(last_imp + 1, SCREENUTIL_IMPORT)
    return '\n'.join(lines)


def process_file(fp):
    stats = {'file': str(fp.relative_to(LIB_DIR)), 'changes': 0, 'patterns': {}}
    content = fp.read_text(encoding='utf-8')
    original = content

    for desc, pattern, group_idx, suffix in PATTERNS:
        def _replace(match, _s=suffix, _g=group_idx):
            num_str = match.group(_g)
            try:
                if float(num_str) == 0:
                    return match.group(0)
            except ValueError:
                return match.group(0)
            return f"{match.group(1)}{num_str}.{_s}"

        new_content, count = pattern.subn(_replace, content)
        if count > 0:
            stats['changes'] += count
            stats['patterns'][desc] = count
            content = new_content

    if content != original:
        content = remove_const_from_adapted(content)
        content = add_import(content)
        if not DRY_RUN:
            fp.write_text(content, encoding='utf-8')

    return stats


def main():
    if DRY_RUN:
        print('🔍 DRY RUN — 不会修改文件\n')

    total = 0
    modified = 0
    changes = 0
    pat_totals = {}

    for fp in sorted(LIB_DIR.rglob('*.dart')):
        if should_skip(fp):
            continue
        total += 1
        stats = process_file(fp)
        if stats['changes'] > 0:
            modified += 1
            changes += stats['changes']
            print(f"  ✅ {stats['file']} — {stats['changes']} 处替换")
            for pattern_name, count in stats['patterns'].items():
                pat_totals[pattern_name] = pat_totals.get(pattern_name, 0) + count

    print(f"\n{'=' * 60}")
    print(f'📊 扫描 {total} 文件, 修改 {modified} 文件, {changes} 处替换')
    print('\n📋 模式统计:')
    for pattern_name, count in sorted(pat_totals.items(), key=lambda item: -item[1]):
        print(f'   {pattern_name:30s} {count:5d}')
    if DRY_RUN:
        print('\n⚠️  DRY RUN, 未修改文件。')


if __name__ == '__main__':
    main()