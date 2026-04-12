#!/usr/bin/env python3
"""
智能转换相对路径导入为 package 导入，支持多行 import 和 as 别名。
"""

import os
import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'


def process_file(file_path: Path) -> bool:
    """处理单个文件。"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        file_relative_path = file_path.relative_to(LIB_DIR)
        file_dir = file_relative_path.parent.as_posix()

        pattern = r"import\s+['\"](\.\./[^'\"]+\.dart)['\"](\s+as\s+\w+)?;"

        def replace_import(match: re.Match[str]) -> str:
            relative_path = match.group(1)
            as_clause = match.group(2) if match.group(2) else ''

            current_dir = file_dir
            parts = relative_path.split('/')

            for part in parts:
                if part == '..':
                    current_dir = os.path.dirname(current_dir).replace('\\', '/') if current_dir else ''
                elif part != '.':
                    if current_dir:
                        current_dir = os.path.join(current_dir, part).replace('\\', '/')
                    else:
                        current_dir = part

            return f"import 'package:go_nomads_app/{current_dir}'{as_clause};"

        content = re.sub(pattern, replace_import, content, flags=re.MULTILINE)

        if content != original_content:
            file_path.write_text(content, encoding='utf-8', newline='\n')
            print(f'✓ {file_path.relative_to(PROJECT_ROOT).as_posix()}')
            return True
        return False

    except Exception as exc:
        print(f'✗ {file_path.relative_to(PROJECT_ROOT).as_posix()}: {exc}')
        return False


def main() -> None:
    """主函数。"""
    print('开始智能转换相对路径导入...\n')

    dart_files = sorted(LIB_DIR.rglob('*.dart'))

    updated_count = 0
    for file_path in dart_files:
        if process_file(file_path):
            updated_count += 1

    print(f'\n完成! 共更新了 {updated_count} 个文件')


if __name__ == '__main__':
    main()
