#!/bin/bash

SRC="/Users/walden/Downloads/snapshots/1768744179.png"
OUTPUT_DIR="/Users/walden/Workspaces/WaldenProjects/go-nomads-project/go-nomads-app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_DIR="/Users/walden/Workspaces/WaldenProjects/go-nomads-project/go-nomads-app/android/app/src/main/res"

echo "使用参考图片生成 iOS 图标..."

for size in 16 20 29 32 40 48 50 55 57 58 60 64 66 72 76 80 87 88 92 100 102 108 114 120 128 144 152 167 172 180 196 216 234 256 258 512 1024; do
    echo "生成 ${size}x${size}..."
    sips -z $size $size "$SRC" --out "$OUTPUT_DIR/${size}.png" > /dev/null 2>&1
done

echo "生成标准命名文件..."
sips -z 1024 1024 "$SRC" --out "$OUTPUT_DIR/Icon-App-1024x1024@1x.png" > /dev/null 2>&1
sips -z 20 20 "$SRC" --out "$OUTPUT_DIR/Icon-App-20x20@1x.png" > /dev/null 2>&1
sips -z 40 40 "$SRC" --out "$OUTPUT_DIR/Icon-App-20x20@2x.png" > /dev/null 2>&1
sips -z 60 60 "$SRC" --out "$OUTPUT_DIR/Icon-App-20x20@3x.png" > /dev/null 2>&1
sips -z 29 29 "$SRC" --out "$OUTPUT_DIR/Icon-App-29x29@1x.png" > /dev/null 2>&1
sips -z 58 58 "$SRC" --out "$OUTPUT_DIR/Icon-App-29x29@2x.png" > /dev/null 2>&1
sips -z 87 87 "$SRC" --out "$OUTPUT_DIR/Icon-App-29x29@3x.png" > /dev/null 2>&1
sips -z 40 40 "$SRC" --out "$OUTPUT_DIR/Icon-App-40x40@1x.png" > /dev/null 2>&1
sips -z 80 80 "$SRC" --out "$OUTPUT_DIR/Icon-App-40x40@2x.png" > /dev/null 2>&1
sips -z 120 120 "$SRC" --out "$OUTPUT_DIR/Icon-App-40x40@3x.png" > /dev/null 2>&1
sips -z 120 120 "$SRC" --out "$OUTPUT_DIR/Icon-App-60x60@2x.png" > /dev/null 2>&1
sips -z 180 180 "$SRC" --out "$OUTPUT_DIR/Icon-App-60x60@3x.png" > /dev/null 2>&1
sips -z 76 76 "$SRC" --out "$OUTPUT_DIR/Icon-App-76x76@1x.png" > /dev/null 2>&1
sips -z 152 152 "$SRC" --out "$OUTPUT_DIR/Icon-App-76x76@2x.png" > /dev/null 2>&1
sips -z 167 167 "$SRC" --out "$OUTPUT_DIR/Icon-App-83.5x83.5@2x.png" > /dev/null 2>&1

echo "生成 Android 图标..."
sips -z 48 48 "$SRC" --out "$ANDROID_DIR/mipmap-mdpi/go_nomads.png" > /dev/null 2>&1
sips -z 72 72 "$SRC" --out "$ANDROID_DIR/mipmap-hdpi/go_nomads.png" > /dev/null 2>&1
sips -z 96 96 "$SRC" --out "$ANDROID_DIR/mipmap-xhdpi/go_nomads.png" > /dev/null 2>&1
sips -z 144 144 "$SRC" --out "$ANDROID_DIR/mipmap-xxhdpi/go_nomads.png" > /dev/null 2>&1
sips -z 192 192 "$SRC" --out "$ANDROID_DIR/mipmap-xxxhdpi/go_nomads.png" > /dev/null 2>&1

echo "✅ iOS 和 Android 图标生成完成!"
