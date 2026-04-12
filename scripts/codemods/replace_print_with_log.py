#!/usr/bin/env python3
"""
将 Flutter 项目中的 print 语句替换为 log。
"""

import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
LIB_DIR = PROJECT_ROOT / 'lib'


def process_file(file_path: Path) -> bool:
    """处理单个文件。"""
    content = file_path.read_text(encoding='utf-8')

    if 'print(' not in content:
        return False

    has_developer_import = "import 'dart:developer'" in content
    new_content = re.sub(r'\bprint\(', 'log(', content)

    if not has_developer_import and new_content != content:
        import_match = re.search(r"^import\s+['\"]", new_content, re.MULTILINE)
        if import_match:
            insert_pos = import_match.start()
            new_content = (
                new_content[:insert_pos]
                + "import 'dart:developer';\n\n"
                + new_content[insert_pos:]
            )
        else:
            new_content = "import 'dart:developer';\n\n" + new_content

    if new_content != content:
        file_path.write_text(new_content, encoding='utf-8', newline='\n')
        return True

    return False


def main() -> None:
    """主函数。"""
    if not LIB_DIR.exists():
        print(f'Error: {LIB_DIR} does not exist')
        return

    modified_files: list[Path] = []

    for file_path in LIB_DIR.rglob('*.dart'):
        if process_file(file_path):
            modified_files.append(file_path)
            print(f"✅ Modified: {file_path.relative_to(PROJECT_ROOT).as_posix()}")

    print(f'\n总共修改了 {len(modified_files)} 个文件')


if __name__ == '__main__':
    main()
