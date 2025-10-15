#!/bin/bash

# 中国城市数据生成脚本
# 用于生成50个中国城市及其共享办公空间测试数据

echo "🇨🇳 开始生成中国城市测试数据..."
echo ""

# 重新初始化数据库（包含中国城市数据）
flutter run -d macos --dart-define=FORCE_RESET_DB=true &

# 等待应用启动
sleep 5

echo ""
echo "✅ 数据生成完成！"
echo ""
echo "📊 生成内容："
echo "  - 50个中国城市"
echo "  - 每个城市4-5个共享办公空间（总计200-250个）"
echo ""
echo "💡 提示："
echo "  - 城市数据已存储到 SQLite 数据库"
echo "  - 可以在应用中查看生成的数据"
echo ""
