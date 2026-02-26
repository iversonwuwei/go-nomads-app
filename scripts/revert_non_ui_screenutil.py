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

用法: python3 scripts/revert_non_ui_screenutil.py [--dry-run]
"""

import re
import sys
from pathlib import Path

LIB_DIR = Path(__file__).resolve().parent.parent / "lib"
DRY_RUN = "--dry-run" in sys.argv

SKIP_SUFFIXES = {".g.dart", ".freezed.dart"}

NUM = r"(\d+(?:\.\d+)?)"

# ============================================================
# 还原规则
# ============================================================
REVERT_RULES = []

def _add(desc, pattern, replacement):
    REVERT_RULES.append((desc, re.compile(pattern), replacement))


# 1. strokeWidth: X.w → X
_add("strokeWidth",
     rf"(\bstrokeWidth\s*:\s*){NUM}\.w\b",
     r"\g<1>\2")

# 2. thickness: X.w → X
_add("thickness",
     rf"(\bthickness\s*:\s*){NUM}\.w\b",
     r"\g<1>\2")

# 3. ImagePicker maxWidth/maxHeight (1920, 1080 等大分辨率值)
# 精准匹配: maxWidth/maxHeight 后跟 1920/1080/2048/4096 等图片分辨率值
_add("ImagePicker maxWidth",
     rf"(\bmaxWidth\s*:\s*)(1920|1080|2048|4096|3840)\.w\b",
     r"\g<1>\2")
_add("ImagePicker maxHeight",
     rf"(\bmaxHeight\s*:\s*)(1920|1080|2048|4096|3840)\.h\b",
     r"\g<1>\2")

# 4. 响应式断点: maxWidth: 600.w / 720.w / 900.w
# 这些是绝对宽度帽值, 不应随屏幕缩放
_add("responsive maxWidth",
     rf"(\bmaxWidth\s*:\s*)(600|720|900|1024|1200)\.w\b",
     r"\g<1>\2")

# 5. Border width: 在 Border/border/Divider 上下文中的小宽度值
# 匹配 width: 0.5.w / 1.w / 1.5.w / 2.w (但不匹配大值如 100.w)
# 使用上下文: border/Border/divider/Divider 前方 150 字符内
# → 简化策略: 直接还原所有 ≤2 的 width.w (因为 width: 1.w 不太可能是 UI 尺寸)
# ⚠️ 不能这样做，因为 SizedBox(width: 1.w) 可能是 spacer
# → 使用更安全的策略: 只还原 Border.all/Border 上下文中的 width
_add("Border.all width",
     rf"(Border\.all\s*\(\s*(?:color\s*:[^,]+,\s*)?width\s*:\s*){NUM}\.w\b",
     r"\g<1>\2")
_add("Border side width",
     rf"(BorderSide\s*\(\s*(?:color\s*:[^,]+,\s*)?width\s*:\s*){NUM}\.w\b",
     r"\g<1>\2")


# ============================================================
# 逐行上下文匹配 - 处理更复杂的 Border width 情况
# ============================================================
def revert_border_width_in_context(content):
    """
    还原在 Border 上下文中的 width: X.w
    例如:
      border: Border.all(
        color: Colors.grey,
        width: 1.w,   ← 这个需要还原
      ),
    """
    changes = 0
    lines = content.split('\n')
    in_border_context = False
    brace_depth = 0

    for i, line in enumerate(lines):
        stripped = line.strip()

        # 检测进入 Border 上下文
        if re.search(r'Border\.(all|only|symmetric)\(|BorderSide\(', stripped):
            in_border_context = True
            brace_depth = 0
            # Count opening parens
            brace_depth += stripped.count('(') - stripped.count(')')

        if in_border_context:
            # 还原 width: X.w 其中 X <= 5
            m = re.search(r'(\bwidth\s*:\s*)(\d+(?:\.\d+)?)\.w\b', line)
            if m:
                val = float(m.group(2))
                if val <= 5:  # 边框宽度通常 ≤ 5
                    new_line = line[:m.start()] + m.group(1) + m.group(2) + line[m.end():]
                    if new_line != line:
                        lines[i] = new_line
                        changes += 1

            brace_depth += stripped.count('(') - stripped.count(')')
            if brace_depth <= 0:
                in_border_context = False

    if changes > 0:
        return '\n'.join(lines), changes
    return content, 0


# ============================================================
# 还原 Divider/Container border 中的 width: X.w (X <= 2)
# 通过上下文检测
# ============================================================
def revert_divider_related(content):
    """还原 Divider(height: X.h) 中不合理的值"""
    changes = 0
    # Divider(height: 1.h) / Divider(height: 0.5.h) → 这些是分割线高度, 应该是固定像素
    pattern = re.compile(r'(Divider\s*\([^)]*?height\s*:\s*)(\d+(?:\.\d+)?)\.h\b')
    new_content, c = pattern.subn(r'\1\2', content)
    changes += c
    return new_content, changes


# ============================================================
# 主逻辑
# ============================================================
def process_file(fp):
    content = fp.read_text(encoding="utf-8")
    original = content
    total_changes = 0
    details = {}

    # 应用正则规则
    for desc, pattern, repl in REVERT_RULES:
        new_content, count = pattern.subn(repl, content)
        if count > 0:
            total_changes += count
            details[desc] = details.get(desc, 0) + count
            content = new_content

    # 上下文感知的边框 width 还原
    content, c = revert_border_width_in_context(content)
    if c > 0:
        total_changes += c
        details["Border context width"] = c

    # Divider height 还原
    content, c = revert_divider_related(content)
    if c > 0:
        total_changes += c
        details["Divider height"] = c

    if content != original and not DRY_RUN:
        fp.write_text(content, encoding="utf-8")

    return total_changes, details


def main():
    if DRY_RUN:
        print("🔍 DRY RUN\n")

    total_files = 0
    modified = 0
    total_changes = 0
    all_details = {}

    for fp in sorted(LIB_DIR.rglob("*.dart")):
        if any(fp.name.endswith(s) for s in SKIP_SUFFIXES):
            continue
        total_files += 1
        c, details = process_file(fp)
        if c > 0:
            modified += 1
            total_changes += c
            rel = fp.relative_to(LIB_DIR)
            print(f"  🔧 {rel} — {c} 处还原")
            for d, cnt in details.items():
                print(f"       {d}: {cnt}")
                all_details[d] = all_details.get(d, 0) + cnt

    print(f"\n{'='*60}")
    print(f"📊 扫描 {total_files} 文件, 修改 {modified} 文件, {total_changes} 处还原")
    print(f"\n📋 类别统计:")
    for d, c in sorted(all_details.items(), key=lambda x: -x[1]):
        print(f"   {d:30s} {c:5d}")
    if DRY_RUN:
        print("\n⚠️  DRY RUN, 未修改文件。")


if __name__ == "__main__":
    main()
