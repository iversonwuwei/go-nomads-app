#!/usr/bin/env python3
"""
flutter_screenutil 全量自动适配脚本 v2

修复 v1 的问题:
  1. 正则回溯导致数字被切分 (如 12 → 1.r2.r) → 使用 (?![\\d.]) 防回溯
  2. 关键字前缀重叠 (Radius.circular ⊂ BorderRadius.circular) → 使用 \\b + lookbehind
  3. const 表达式不能使用运行时扩展 → 自动移除 const
  4. 非 UI 参数被误转换 → 排除 maxLines/flex/opacity/duration 等

用法: python3 scripts/apply_screenutil.py [--dry-run]
"""

import os
import re
import sys
from pathlib import Path

# ============================================================================
# 配置
# ============================================================================
LIB_DIR = Path(__file__).resolve().parent.parent / "lib"
SCREENUTIL_IMPORT = "import 'package:flutter_screenutil/flutter_screenutil.dart';"

SKIP_DIRS = {"generated", ".dart_tool", "build"}
SKIP_FILE_SUFFIXES = {".g.dart", ".freezed.dart"}

DRY_RUN = "--dry-run" in sys.argv

# ============================================================================
# 正则构建
# ============================================================================
NUM = r"(\d+(?:\.\d+)?)"
# 核心修复: 匹配完整数字后, 下一个字符不能是数字或小数点(防回溯切分)
NO_TRAIL = r"(?![\d.])"

PATTERNS = []


def _add(desc, regex, group_idx, suffix):
    PATTERNS.append((desc, re.compile(regex), group_idx, suffix))


# ---------- 文字相关 → .sp ----------
_add("fontSize",
     rf"(\bfontSize\s*:\s*){NUM}{NO_TRAIL}", 2, "sp")
_add("letterSpacing",
     rf"(\bletterSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, "sp")
_add("wordSpacing",
     rf"(\bwordSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, "sp")

# ---------- SizedBox → .w / .h ----------
_add("SizedBox width",
     rf"(SizedBox\s*\(\s*width\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("SizedBox height",
     rf"(SizedBox\s*\(\s*height\s*:\s*){NUM}{NO_TRAIL}", 2, "h")

# ---------- EdgeInsets → .w / .h ----------
_add("EdgeInsets.all",
     rf"(EdgeInsets\.all\s*\(\s*){NUM}{NO_TRAIL}", 2, "w")
_add("horizontal",
     rf"(\bhorizontal\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("vertical",
     rf"(\bvertical\s*:\s*){NUM}{NO_TRAIL}", 2, "h")
_add("left",
     rf"(\bleft\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("right",
     rf"(\bright\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("top",
     rf"(\btop\s*:\s*){NUM}{NO_TRAIL}", 2, "h")
_add("bottom",
     rf"(\bbottom\s*:\s*){NUM}{NO_TRAIL}", 2, "h")

# ---------- BorderRadius / Radius → .r ----------
_add("BorderRadius.circular",
     rf"(BorderRadius\.circular\s*\(\s*){NUM}{NO_TRAIL}", 2, "r")
# ⚠️ 负向回顾: 不匹配 BorderRadius.circular 内部
_add("Radius.circular",
     rf"((?<!Border)Radius\.circular\s*\(\s*){NUM}{NO_TRAIL}", 2, "r")

# ---------- 通用尺寸 → .h / .w ----------
# ⚠️ 使用 \b 防止 height 匹配进 maxHeight/minHeight/toolbarHeight
_add("height",
     rf"(\bheight\s*:\s*){NUM}{NO_TRAIL}", 2, "h")
_add("width",
     rf"(\bwidth\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("maxHeight",
     rf"(\bmaxHeight\s*:\s*){NUM}{NO_TRAIL}", 2, "h")
_add("minHeight",
     rf"(\bminHeight\s*:\s*){NUM}{NO_TRAIL}", 2, "h")
_add("maxWidth",
     rf"(\bmaxWidth\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("minWidth",
     rf"(\bminWidth\s*:\s*){NUM}{NO_TRAIL}", 2, "w")

# ---------- Icon / 通用 size → .r ----------
_add("size",
     rf"(\bsize\s*:\s*){NUM}{NO_TRAIL}", 2, "r")
_add("iconSize",
     rf"(\biconSize\s*:\s*){NUM}{NO_TRAIL}", 2, "r")

# ---------- 边框 / 阴影 → .r / .w ----------
_add("thickness",
     rf"(\bthickness\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("strokeWidth",
     rf"(\bstrokeWidth\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("blurRadius",
     rf"(\bblurRadius\s*:\s*){NUM}{NO_TRAIL}", 2, "r")
_add("spreadRadius",
     rf"(\bspreadRadius\s*:\s*){NUM}{NO_TRAIL}", 2, "r")

# ---------- 间距 ----------
_add("spacing",
     rf"(\bspacing\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("runSpacing",
     rf"(\brunSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("mainAxisSpacing",
     rf"(\bmainAxisSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("crossAxisSpacing",
     rf"(\bcrossAxisSpacing\s*:\s*){NUM}{NO_TRAIL}", 2, "w")

# ---------- Divider ----------
_add("indent",
     rf"(\bindent\s*:\s*){NUM}{NO_TRAIL}", 2, "w")
_add("endIndent",
     rf"(\bendIndent\s*:\s*){NUM}{NO_TRAIL}", 2, "w")

# ---------- AppBar ----------
_add("toolbarHeight",
     rf"(\btoolbarHeight\s*:\s*){NUM}{NO_TRAIL}", 2, "h")

# ---------- Offset(dx, dy) ----------
_add("Offset",
     rf"(Offset\s*\(\s*){NUM}{NO_TRAIL}", 2, "w")


# ============================================================================
# const 移除
# ============================================================================
SCREENUTIL_EXT = re.compile(r"\d\.(?:w|h|sp|r)\b")


def remove_const_from_adapted(content):
    """移除包含 screenutil 扩展的表达式中的 const 关键字。"""
    const_re = re.compile(r"\bconst\b")
    removals = []

    for m in const_re.finditer(content):
        cs = m.start()
        ce = m.end()

        # const 后面找到开始括号
        after = content[ce:]
        paren_m = re.search(r"[\s\w.<>?,]*?([(\[{])", after)
        if not paren_m:
            continue

        open_char = paren_m.group(1)
        close_char = {"(": ")", "[": "]", "{": "}"}[open_char]
        open_pos = ce + paren_m.end() - 1

        # 括号匹配
        depth = 1
        pos = open_pos + 1
        in_str = False
        str_ch = None
        while pos < len(content) and depth > 0:
            c = content[pos]
            if in_str:
                if c == str_ch and (pos == 0 or content[pos - 1] != "\\"):
                    in_str = False
            else:
                if c in ("'", '"'):
                    in_str = True
                    str_ch = c
                elif c == open_char:
                    depth += 1
                elif c == close_char:
                    depth -= 1
            pos += 1

        if depth != 0:
            continue

        expr = content[open_pos:pos]
        if SCREENUTIL_EXT.search(expr):
            # 计算要移除的 const + 后续空格
            trail = 0
            while ce + trail < len(content) and content[ce + trail] == " ":
                trail += 1
            removals.append((cs, ce + trail))

    if not removals:
        return content

    # 从后向前移除, 防止偏移
    for start, end in reversed(removals):
        content = content[:start] + content[end:]

    return content


# ============================================================================
# 文件处理
# ============================================================================
def should_skip(fp):
    rel = fp.relative_to(LIB_DIR)
    parts = rel.parts
    if any(p in SKIP_DIRS for p in parts):
        return True
    name = fp.name
    return any(name.endswith(s) for s in SKIP_FILE_SUFFIXES)


def add_import(content):
    if "flutter_screenutil" in content:
        return content
    lines = content.split("\n")
    last_imp = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("import "):
            last_imp = i
    if last_imp == -1:
        return SCREENUTIL_IMPORT + "\n" + content
    lines.insert(last_imp + 1, SCREENUTIL_IMPORT)
    return "\n".join(lines)


def process_file(fp):
    stats = {"file": str(fp.relative_to(LIB_DIR)), "changes": 0, "patterns": {}}
    content = fp.read_text(encoding="utf-8")
    original = content

    for desc, pattern, group_idx, suffix in PATTERNS:
        def _replace(m, _s=suffix, _g=group_idx):
            num_str = m.group(_g)
            try:
                if float(num_str) == 0:
                    return m.group(0)
            except ValueError:
                return m.group(0)
            return f"{m.group(1)}{num_str}.{_s}"

        new_content, count = pattern.subn(_replace, content)
        if count > 0:
            stats["changes"] += count
            stats["patterns"][desc] = count
            content = new_content

    if content != original:
        content = remove_const_from_adapted(content)
        content = add_import(content)
        if not DRY_RUN:
            fp.write_text(content, encoding="utf-8")

    return stats


def main():
    if DRY_RUN:
        print("🔍 DRY RUN — 不会修改文件\n")

    total = 0
    modified = 0
    changes = 0
    pat_totals = {}

    for fp in sorted(LIB_DIR.rglob("*.dart")):
        if should_skip(fp):
            continue
        total += 1
        s = process_file(fp)
        if s["changes"] > 0:
            modified += 1
            changes += s["changes"]
            print(f"  ✅ {s['file']} — {s['changes']} 处替换")
            for p, c in s["patterns"].items():
                pat_totals[p] = pat_totals.get(p, 0) + c

    print(f"\n{'=' * 60}")
    print(f"📊 扫描 {total} 文件, 修改 {modified} 文件, {changes} 处替换")
    print(f"\n📋 模式统计:")
    for p, c in sorted(pat_totals.items(), key=lambda x: -x[1]):
        print(f"   {p:30s} {c:5d}")
    if DRY_RUN:
        print(f"\n⚠️  DRY RUN, 未修改文件。")


if __name__ == "__main__":
    main()
