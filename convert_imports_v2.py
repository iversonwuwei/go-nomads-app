#!/usr/bin/env python3
"""
智能转换相对路径导入为package导入,支持多行import和as别名
"""

import glob
import os
import re


def process_file(file_path):
    """处理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 获取文件相对于lib的路径
        lib_index = file_path.find('lib')
        if lib_index == -1:
            return False
        
        file_relative_path = file_path[lib_index + 4:]  # +4 跳过 'lib' 和分隔符
        file_dir = os.path.dirname(file_relative_path).replace('\\', '/')
        
        # 匹配相对路径导入(包括多行的情况)
        # 支持: import '../xxx.dart';
        # 支持: import '../xxx.dart' as alias;
        # 支持: import '../xxx.dart'\n    as alias;
        pattern = r"import\s+['\"](\.\./[^'\"]+\.dart)['\"](\s+as\s+\w+)?;"
        
        def replace_import(match):
            relative_path = match.group(1)
            as_clause = match.group(2) if match.group(2) else ''
            
            # 解析相对路径
            current_dir = file_dir
            parts = relative_path.split('/')
            
            for part in parts:
                if part == '..':
                    # 向上一级
                    if current_dir:
                        parent = os.path.dirname(current_dir)
                        current_dir = parent.replace('\\', '/')
                    else:
                        current_dir = ''
                elif part != '.':
                    # 向下或文件名
                    if current_dir:
                        current_dir = os.path.join(current_dir, part).replace('\\', '/')
                    else:
                        current_dir = part
            
            # 构造新的import语句
            package_path = current_dir
            new_import = f"import 'package:df_admin_mobile/{package_path}'{as_clause};"
            
            return new_import
        
        # 替换所有匹配的import
        content = re.sub(pattern, replace_import, content, flags=re.MULTILINE)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
                f.write(content)
            print(f'✓ {file_path}')
            return True
        return False
        
    except Exception as e:
        print(f'✗ {file_path}: {e}')
        return False


def main():
    """主函数"""
    print('开始智能转换相对路径导入...\n')
    
    # 获取所有Dart文件
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    updated_count = 0
    for file_path in dart_files:
        if process_file(file_path):
            updated_count += 1
    
    print(f'\n完成! 共更新了 {updated_count} 个文件')


if __name__ == '__main__':
    main()
