#!/bin/bash

# iOS 图标生成脚本
# 将 SVG 转换为各种尺寸的 PNG

SVG_FILE="/Users/walden/Workspaces/WaldenProjects/go-nomads-project/go-nomads-app/assets/icon/app_icon.svg"
OUTPUT_DIR="/Users/walden/Workspaces/WaldenProjects/go-nomads-project/go-nomads-app/ios/Runner/Assets.xcassets/AppIcon.appiconset"

# 检查 SVG 文件是否存在
if [ ! -f "$SVG_FILE" ]; then
    echo "错误: SVG 文件不存在: $SVG_FILE"
    exit 1
fi

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 所有需要的尺寸
SIZES=(16 20 29 32 40 48 50 55 57 58 60 64 66 72 76 80 87 88 92 100 102 108 114 120 128 144 152 167 172 180 196 216 234 256 258 512 1024)

echo "开始生成 iOS 图标..."

for size in "${SIZES[@]}"; do
    echo "生成 ${size}x${size} 图标..."
    rsvg-convert -w $size -h $size -b none "$SVG_FILE" -o "$OUTPUT_DIR/${size}.png"
done

# 生成标准命名的图标文件
echo "生成标准命名的图标文件..."
rsvg-convert -w 1024 -h 1024 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-1024x1024@1x.png"
rsvg-convert -w 20 -h 20 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-20x20@1x.png"
rsvg-convert -w 40 -h 40 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-20x20@2x.png"
rsvg-convert -w 60 -h 60 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-20x20@3x.png"
rsvg-convert -w 29 -h 29 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-29x29@1x.png"
rsvg-convert -w 58 -h 58 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-29x29@2x.png"
rsvg-convert -w 87 -h 87 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-29x29@3x.png"
rsvg-convert -w 40 -h 40 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-40x40@1x.png"
rsvg-convert -w 80 -h 80 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-40x40@2x.png"
rsvg-convert -w 120 -h 120 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-40x40@3x.png"
rsvg-convert -w 120 -h 120 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-60x60@2x.png"
rsvg-convert -w 180 -h 180 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-60x60@3x.png"
rsvg-convert -w 76 -h 76 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-76x76@1x.png"
rsvg-convert -w 152 -h 152 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-76x76@2x.png"
rsvg-convert -w 167 -h 167 -b none "$SVG_FILE" -o "$OUTPUT_DIR/Icon-App-83.5x83.5@2x.png"

echo "✅ iOS 图标生成完成!"
echo "输出目录: $OUTPUT_DIR"
