#!/usr/bin/env python3
"""
批量替换所有 Get.snackbar 和 ScaffoldMessenger Snackbar 为 AppToast。
"""

import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'


def has_app_toast_import(content: str) -> bool:
    """检查文件是否已有 AppToast 导入。"""
    return "import 'package:go_nomads_app/widgets/app_toast.dart';" in content


def add_app_toast_import(content: str) -> str:
    """添加 AppToast 导入到文件中。"""
    if has_app_toast_import(content):
        return content

    import_pattern = r"^import\s+['\"].*?['\"];?\s*$"
    lines = content.split('\n')
    last_import_idx = -1

    for idx, line in enumerate(lines):
        if re.match(import_pattern, line.strip()):
            last_import_idx = idx

    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, "import 'package:go_nomads_app/widgets/app_toast.dart';")
        return '\n'.join(lines)

    return content


def replace_get_snackbar(content: str) -> tuple[str, int]:
    """替换 Get.snackbar 调用为 AppToast。"""
    count = 0
    multiline_pattern = r"Get\.snackbar\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*(?:,\s*[^)]+)?\s*\)"

    def multiline_replacer(match: re.Match[str]) -> str:
        nonlocal count
        title = match.group(1)
        message = match.group(2)
        count += 1
        if title in ['成功', 'Success', '✅']:
            return f"AppToast.success('{message}')"
        if title in ['警告', 'Warning', '⚠️']:
            return f"AppToast.warning('{message}')"
        if title in ['信息', 'Info', 'ℹ️']:
            return f"AppToast.info('{message}')"
        return f"AppToast.error('{message}')"

    content = re.sub(multiline_pattern, multiline_replacer, content, flags=re.DOTALL)

    single_pattern = r"Get\.snackbar\(['\"]([^'\"]+)['\"]\s*,\s*([^,)]+)(?:,\s*backgroundColor:[^)]+)?\)"

    def single_replacer(match: re.Match[str]) -> str:
        nonlocal count
        title = match.group(1)
        message = match.group(2).strip()
        count += 1
        if title in ['成功', 'Success', '✅']:
            return f'AppToast.success({message})'
        if title in ['警告', 'Warning', '⚠️']:
            return f'AppToast.warning({message})'
        if title in ['信息', 'Info', 'ℹ️']:
            return f'AppToast.info({message})'
        return f'AppToast.error({message})'

    content = re.sub(single_pattern, single_replacer, content)
    return content, count


def replace_scaffold_messenger_snackbar(content: str) -> tuple[str, int]:
    """替换 ScaffoldMessenger.of(context).showSnackBar 为 AppToast。"""
    count = 0
    pattern = r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(['\"]([^'\"]+)['\"]\)\s*\)\s*\)"

    def replacer(match: re.Match[str]) -> str:
        nonlocal count
        message = match.group(1)
        count += 1
        return f"AppToast.info('{message}')"

    content = re.sub(pattern, replacer, content)
    return content, count


def process_file(file_path: Path) -> dict:
    """处理单个文件。"""
    try:
        original_content = file_path.read_text(encoding='utf-8')
        content = original_content

        if 'Get.snackbar' not in content and 'ScaffoldMessenger' not in content:
            return {'file': str(file_path), 'status': 'skipped', 'reason': 'No Snackbar found'}

        content = add_app_toast_import(content)
        content, get_snackbar_count = replace_get_snackbar(content)
        content, scaffold_count = replace_scaffold_messenger_snackbar(content)

        total_replacements = get_snackbar_count + scaffold_count
        if total_replacements == 0:
            return {'file': str(file_path), 'status': 'skipped', 'reason': 'No replacements needed'}

        file_path.write_text(content, encoding='utf-8', newline='\n')

        return {
            'file': str(file_path),
            'status': 'success',
            'get_snackbar_count': get_snackbar_count,
            'scaffold_count': scaffold_count,
            'total': total_replacements,
        }

    except Exception as exc:
        return {'file': str(file_path), 'status': 'error', 'error': str(exc)}


def main() -> None:
    """主函数。"""
    if not LIB_DIR.exists():
        print('错误: 找不到 lib 目录')
        return

    dart_files = list(LIB_DIR.rglob('*.dart'))

    print(f'找到 {len(dart_files)} 个 Dart 文件')
    print('开始处理...\n')

    results = []
    for file_path in dart_files:
        result = process_file(file_path)
        results.append(result)

        if result['status'] == 'success':
            rel_path = Path(result['file']).relative_to(PROJECT_ROOT).as_posix()
            print(f"✅ {rel_path}: 替换了 {result['total']} 处")
        elif result['status'] == 'error':
            rel_path = Path(result['file']).relative_to(PROJECT_ROOT).as_posix()
            print(f"❌ {rel_path}: {result['error']}")

    success_count = sum(1 for result in results if result['status'] == 'success')
    total_replacements = sum(result.get('total', 0) for result in results)
    error_count = sum(1 for result in results if result['status'] == 'error')

    print(f"\n{'=' * 60}")
    print('处理完成!')
    print(f'成功处理: {success_count} 个文件')
    print(f'总替换次数: {total_replacements}')
    print(f'错误: {error_count} 个文件')
    print(f"{'=' * 60}")


if __name__ == '__main__':
    main()
