#!/bin/bash

echo "🔄 重新初始化数据库并运行应用..."
echo ""

# 停止所有运行中的 Flutter 进程
echo "🛑 停止现有的 Flutter 进程..."
pkill -f "flutter" || true
sleep 2

# 清理构建缓存
echo "🧹 清理构建缓存..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 运行应用（数据库会自动重新初始化，因为 forceReset: true）
echo ""
echo "🚀 启动应用..."
echo "📊 请查看控制台输出，确认城市数量"
echo ""
flutter run | grep -E "(城市|Database|初始化|插入|总共|DEBUG)"
