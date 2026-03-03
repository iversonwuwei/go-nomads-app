#!/usr/bin/env python3
"""
批量替换所有 Get.snackbar 和 ScaffoldMessenger Snackbar 为 AppToast
"""
import re
from pathlib import Path


def has_app_toast_import(content: str) -> bool:
    """检查文件是否已有 AppToast 导入"""
    return "import 'package:go_nomads_app/widgets/app_toast.dart';" in content

def add_app_toast_import(content: str) -> str:
    """添加 AppToast 导入到文件中"""
    if has_app_toast_import(content):
        return content
    
    # 找到最后一个 import 语句的位置
    import_pattern = r"^import\s+['\"].*?['\"];?\s*$"
    lines = content.split('\n')
    last_import_idx = -1
    
    for idx, line in enumerate(lines):
        if re.match(import_pattern, line.strip()):
            last_import_idx = idx
    
    if last_import_idx >= 0:
        # 在最后一个 import 之后插入 AppToast import
        lines.insert(last_import_idx + 1, "import 'package:go_nomads_app/widgets/app_toast.dart';")
        return '\n'.join(lines)
    
    return content

def replace_get_snackbar(content: str) -> tuple[str, int]:
    """
    替换 Get.snackbar 调用为 AppToast
    返回: (修改后的内容, 替换次数)
    """
    count = 0
    
    # 先处理多行的 Get.snackbar，匹配跨越多行的情况
    # 模式: Get.snackbar(\n  'title',\n  'message',\n  ...)
    multiline_pattern = r"Get\.snackbar\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*(?:,\s*[^)]+)?\s*\)"
    
    def multiline_replacer(match):
        nonlocal count
        title = match.group(1)
        message = match.group(2)
        
        count += 1
        if title in ['成功', 'Success', '✅']:
            return f"AppToast.success('{message}')"
        elif title in ['警告', 'Warning', '⚠️']:
            return f"AppToast.warning('{message}')"
        elif title in ['信息', 'Info', 'ℹ️']:
            return f"AppToast.info('{message}')"
        else:
            return f"AppToast.error('{message}')"
    
    content = re.sub(multiline_pattern, multiline_replacer, content, flags=re.DOTALL)
    
    # 再处理单行的 Get.snackbar，带 backgroundColor 参数的
    single_pattern = r"Get\.snackbar\(['\"]([^'\"]+)['\"]\s*,\s*([^,)]+)(?:,\s*backgroundColor:[^)]+)?\)"
    
    def single_replacer(match):
        nonlocal count
        title = match.group(1)
        message = match.group(2).strip()
        
        count += 1
        if title in ['成功', 'Success', '✅']:
            return f"AppToast.success({message})"
        elif title in ['警告', 'Warning', '⚠️']:
            return f"AppToast.warning({message})"
        elif title in ['信息', 'Info', 'ℹ️']:
            return f"AppToast.info({message})"
        else:
            return f"AppToast.error({message})"
    
    content = re.sub(single_pattern, single_replacer, content)
    
    return content, count

def replace_scaffold_messenger_snackbar(content: str) -> tuple[str, int]:
    """
    替换 ScaffoldMessenger.of(context).showSnackBar 为 AppToast
    返回: (修改后的内容, 替换次数)
    """
    count = 0
    
    # 匹配 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('message')))
    pattern = r"ScaffoldMessenger\.of\([^)]+\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(['\"]([^'\"]+)['\"]\)\s*\)\s*\)"
    
    def replacer(match):
        nonlocal count
        message = match.group(1)
        count += 1
        return f"AppToast.info('{message}')"
    
    content = re.sub(pattern, replacer, content)
    
    return content, count

def process_file(file_path: Path) -> dict:
    """处理单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        content = original_content
        
        # 检查文件是否包含 Snackbar 相关代码
        if 'Get.snackbar' not in content and 'ScaffoldMessenger' not in content:
            return {
                'file': str(file_path),
                'status': 'skipped',
                'reason': 'No Snackbar found'
            }
        
        # 添加 AppToast 导入
        content = add_app_toast_import(content)
        
        # 替换 Get.snackbar
        content, get_snackbar_count = replace_get_snackbar(content)
        
        # 替换 ScaffoldMessenger snackbar
        content, scaffold_count = replace_scaffold_messenger_snackbar(content)
        
        total_replacements = get_snackbar_count + scaffold_count
        
        if total_replacements == 0:
            return {
                'file': str(file_path),
                'status': 'skipped',
                'reason': 'No replacements needed'
            }
        
        # 写回文件
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return {
            'file': str(file_path),
            'status': 'success',
            'get_snackbar_count': get_snackbar_count,
            'scaffold_count': scaffold_count,
            'total': total_replacements
        }
    
    except Exception as e:
        return {
            'file': str(file_path),
            'status': 'error',
            'error': str(e)
        }

def main():
    """主函数"""
    # 获取 lib 目录
    lib_dir = Path('lib')
    
    if not lib_dir.exists():
        print("错误: 找不到 lib 目录")
        return
    
    # 查找所有 .dart 文件
    dart_files = list(lib_dir.rglob('*.dart'))
    
    print(f"找到 {len(dart_files)} 个 Dart 文件")
    print("开始处理...\n")
    
    results = []
    for file_path in dart_files:
        result = process_file(file_path)
        results.append(result)
        
        if result['status'] == 'success':
            print(f"✅ {result['file']}: 替换了 {result['total']} 处")
        elif result['status'] == 'error':
            print(f"❌ {result['file']}: {result['error']}")
    
    # 统计结果
    success_count = sum(1 for r in results if r['status'] == 'success')
    total_replacements = sum(r.get('total', 0) for r in results)
    error_count = sum(1 for r in results if r['status'] == 'error')
    
    print(f"\n{'='*60}")
    print("处理完成!")
    print(f"成功处理: {success_count} 个文件")
    print(f"总替换次数: {total_replacements}")
    print(f"错误: {error_count} 个文件")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
