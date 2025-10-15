#!/bin/bash

# 数据库初始化脚本
# 用于创建和初始化 SQLite 数据库

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗄️  SQLite 数据库初始化工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 Flutter 是否可用
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未找到，请先安装 Flutter"
    exit 1
fi

echo "📋 选择操作："
echo ""
echo "  1. 初始化数据库（首次使用）"
echo "  2. 重置数据库（清空并重新初始化）"
echo "  3. 运行应用（自动初始化）"
echo "  0. 退出"
echo ""

read -p "请选择 (0-3): " choice

case $choice in
    1)
        echo ""
        echo "🚀 开始初始化数据库..."
        echo ""
        echo "数据库将在应用启动时自动创建和初始化"
        echo "请稍等片刻..."
        echo ""
        flutter run --dart-define=DB_INIT=true
        ;;
    2)
        echo ""
        echo "⚠️  警告：这将删除所有现有数据！"
        read -p "确认重置数据库？(y/N): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            echo ""
            echo "🔄 重置数据库..."
            echo ""
            flutter run --dart-define=DB_RESET=true
        else
            echo ""
            echo "❌ 已取消操作"
        fi
        ;;
    3)
        echo ""
        echo "📱 启动应用..."
        echo ""
        echo "数据库将在应用启动时自动初始化（如果尚未初始化）"
        echo ""
        flutter run
        ;;
    0)
        echo ""
        echo "👋 再见！"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 操作完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
