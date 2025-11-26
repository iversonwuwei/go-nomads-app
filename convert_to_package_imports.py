#!/usr/bin/env python3
"""
将所有相对路径导入转换为package导入
"""

import glob
import os
import re


def convert_import_path(file_path, import_line):
    """转换单个import路径"""
    # 匹配相对路径导入
    match = re.match(r"^import\s+['\"](\.\./.*?\.dart)['\"];?", import_line)
    if not match:
        return import_line
    
    relative_path = match.group(1)
    
    # 获取文件所在目录相对于lib的路径
    lib_index = file_path.find('lib')
    if lib_index == -1:
        return import_line
    
    file_dir = os.path.dirname(file_path[lib_index + 4:])  # +4 跳过 'lib' 和 分隔符
    
    # 解析相对路径
    current_dir = file_dir
    parts = relative_path.split('/')
    
    for part in parts:
        if part == '..':
            # 向上一级
            if current_dir:
                current_dir = os.path.dirname(current_dir)
        elif part != '.':
            # 向下或文件名
            if current_dir:
                current_dir = os.path.join(current_dir, part)
            else:
                current_dir = part
    
    # 转换为package路径
    package_path = current_dir.replace('\\', '/')
    
    # 构造新的import语句
    new_import = f"import 'package:df_admin_mobile/{package_path}';"
    
    return new_import


def process_file(file_path):
    """处理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("import '..") or stripped.startswith('import ".."'):
                new_line = convert_import_path(file_path, stripped)
                if new_line != stripped:
                    # 保持原有缩进
                    indent = len(line) - len(line.lstrip())
                    new_lines.append(' ' * indent + new_line + '\n')
                    modified = True
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
        
        if modified:
            with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
                f.writelines(new_lines)
            print(f'✓ {file_path}')
            return True
        return False
        
    except Exception as e:
        print(f'✗ {file_path}: {e}')
        return False


def main():
    """主函数"""
    print('开始转换相对路径导入为package导入...\n')
    
    # 获取所有Dart文件
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    updated_count = 0
    for file_path in dart_files:
        if process_file(file_path):
            updated_count += 1
    
    print(f'\n完成! 共更新了 {updated_count} 个文件')


if __name__ == '__main__':
    main()
