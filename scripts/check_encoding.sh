#!/bin/bash

# Flutter 项目编码检查和修复脚本
# 用于检测和修复 Dart 文件中的中文字符编码问题

echo "🔍 开始检查 Flutter 项目中的编码问题..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查乱码字符
echo -e "\n${YELLOW}1. 检查乱码字符 (�)...${NC}"
GARBLED_FILES=$(grep -r "�" lib/ --include="*.dart" 2>/dev/null | wc -l)

if [ "$GARBLED_FILES" -gt 0 ]; then
    echo -e "${RED}❌ 发现 $GARBLED_FILES 处乱码${NC}"
    echo "包含乱码的文件："
    grep -r "�" lib/ --include="*.dart" -l 2>/dev/null
    echo -e "\n${YELLOW}建议：使用 UTF-8 编码保存所有 Dart 文件${NC}"
else
    echo -e "${GREEN}✅ 未发现乱码字符${NC}"
fi

# 检查文件编码
echo -e "\n${YELLOW}2. 检查文件编码...${NC}"
NON_UTF8_COUNT=0
for file in $(find lib -name "*.dart" 2>/dev/null); do
    if ! file "$file" | grep -q "UTF-8"; then
        echo -e "${RED}❌ 非 UTF-8 编码: $file${NC}"
        ((NON_UTF8_COUNT++))
    fi
done

if [ "$NON_UTF8_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ 所有文件都是 UTF-8 编码${NC}"
else
    echo -e "${RED}❌ 发现 $NON_UTF8_COUNT 个非 UTF-8 文件${NC}"
fi

# 检查 BOM (Byte Order Mark)
echo -e "\n${YELLOW}3. 检查 BOM 标记...${NC}"
BOM_COUNT=0
for file in $(find lib -name "*.dart" 2>/dev/null); do
    if [ -f "$file" ]; then
        # 检查文件开头是否有 UTF-8 BOM (EF BB BF)
        if hexdump -n 3 -e '3/1 "%02X"' "$file" 2>/dev/null | grep -q "EFBBBF"; then
            echo -e "${YELLOW}⚠️  发现 BOM: $file${NC}"
            ((BOM_COUNT++))
        fi
    fi
done

if [ "$BOM_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ 未发现 BOM 标记${NC}"
else
    echo -e "${YELLOW}⚠️  发现 $BOM_COUNT 个文件包含 BOM${NC}"
    echo "建议：移除 BOM 以避免潜在的编码问题"
fi

# 总结
echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ 编码检查完成！${NC}"

if [ "$GARBLED_FILES" -gt 0 ] || [ "$NON_UTF8_COUNT" -gt 0 ] || [ "$BOM_COUNT" -gt 0 ]; then
    echo -e "\n${RED}发现编码问题，建议修复：${NC}"
    echo "1. 使用 UTF-8 (无 BOM) 编码保存所有文件"
    echo "2. 在 VS Code 中设置："
    echo "   - Files: Encoding → UTF-8"
    echo "   - Files: Auto Guess Encoding → true"
    echo "3. 使用以下命令转换编码："
    echo "   find lib -name '*.dart' -exec iconv -f GBK -t UTF-8 {} -o {}.tmp \\; -exec mv {}.tmp {} \\;"
    exit 1
else
    echo -e "${GREEN}✅ 所有文件编码正常！${NC}"
    exit 0
fi
