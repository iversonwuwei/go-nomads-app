#!/usr/bin/env python3
"""
将所有相对路径导入转换为 package 导入。
"""

import os
import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'


def convert_import_path(file_path: Path, import_line: str) -> str:
    """转换单个 import 路径。"""
    match = re.match(r"^import\s+['\"](\.\./.*?\.dart)['\"];?", import_line)
    if not match:
        return import_line

    relative_path = match.group(1)
    file_dir = file_path.relative_to(LIB_DIR).parent.as_posix()

    current_dir = file_dir
    parts = relative_path.split('/')

    for part in parts:
        if part == '..':
            current_dir = os.path.dirname(current_dir) if current_dir else ''
        elif part != '.':
            current_dir = os.path.join(current_dir, part) if current_dir else part

    package_path = current_dir.replace('\\', '/')
    return f"import 'package:go_nomads_app/{package_path}';"


def process_file(file_path: Path) -> bool:
    """处理单个文件。"""
    try:
        lines = file_path.read_text(encoding='utf-8').splitlines(keepends=True)

        modified = False
        new_lines: list[str] = []

        for line in lines:
            stripped = line.strip()
            if stripped.startswith("import '..") or stripped.startswith('import ".."'):
                new_line = convert_import_path(file_path, stripped)
                if new_line != stripped:
                    indent = len(line) - len(line.lstrip())
                    new_lines.append(' ' * indent + new_line + '\n')
                    modified = True
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)

        if modified:
            file_path.write_text(''.join(new_lines), encoding='utf-8', newline='\n')
            print(f'✓ {file_path.relative_to(PROJECT_ROOT).as_posix()}')
            return True
        return False

    except Exception as exc:
        print(f'✗ {file_path.relative_to(PROJECT_ROOT).as_posix()}: {exc}')
        return False


def main() -> None:
    """主函数。"""
    print('开始转换相对路径导入为 package 导入...\n')

    dart_files = sorted(LIB_DIR.rglob('*.dart'))

    updated_count = 0
    for file_path in dart_files:
        if process_file(file_path):
            updated_count += 1

    print(f'\n完成! 共更新了 {updated_count} 个文件')


if __name__ == '__main__':
    main()
