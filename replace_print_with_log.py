#!/usr/bin/env python3
"""
将 Flutter 项目中的 print 语句替换为 log
"""
import os
import re


def process_file(file_path):
    """处理单个文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否包含 print(
    if 'print(' not in content:
        return False
    
    # 检查是否已经导入了 dart:developer
    has_developer_import = "import 'dart:developer'" in content
    
    # 替换 print( 为 log(
    # 需要小心不要替换类似 debugPrint, printError 等
    new_content = re.sub(r'\bprint\(', 'log(', content)
    
    # 如果没有导入 dart:developer，添加导入
    if not has_developer_import and new_content != content:
        # 找到第一个 import 语句的位置
        import_match = re.search(r"^import\s+['\"]", new_content, re.MULTILINE)
        if import_match:
            # 在第一个 import 之前添加 dart:developer 导入
            insert_pos = import_match.start()
            new_content = (
                new_content[:insert_pos] + 
                "import 'dart:developer';\n\n" + 
                new_content[insert_pos:]
            )
        else:
            # 如果没有 import 语句，在文件开头添加
            new_content = "import 'dart:developer';\n\n" + new_content
    
    # 写回文件
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    
    return False


def main():
    """主函数"""
    lib_path = os.path.join(os.path.dirname(__file__), 'lib')
    
    if not os.path.exists(lib_path):
        print(f"Error: {lib_path} does not exist")
        return
    
    modified_files = []
    
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if process_file(file_path):
                    modified_files.append(file_path)
                    print(f"✅ Modified: {file_path}")
    
    print(f"\n总共修改了 {len(modified_files)} 个文件")


if __name__ == '__main__':
    main()
