#!/usr/bin/env python3
"""
生成 Android 启动页 "GO NOMADS" 文字图片
白色文字，透明背景，适配各种屏幕密度
"""

import os

from PIL import Image, ImageDraw, ImageFont

# 输出目录
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DRAWABLE_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")

# Android 各密度尺寸配置 (宽度, 高度, 字体大小)
DENSITIES = {
    "drawable-mdpi": (320, 80, 28),
    "drawable-hdpi": (480, 120, 42),
    "drawable-xhdpi": (640, 160, 56),
    "drawable-xxhdpi": (960, 240, 84),
    "drawable-xxxhdpi": (1280, 320, 112),
}

def generate_splash_logo():
    """生成各密度的启动页文字图片"""
    
    for density, (width, height, font_size) in DENSITIES.items():
        # 创建透明背景图片
        img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # 尝试使用粗体字体
        font = None
        font_paths = [
            "C:/Windows/Fonts/arialbd.ttf",  # Arial Bold
            "C:/Windows/Fonts/calibrib.ttf",  # Calibri Bold
            "C:/Windows/Fonts/segoeui.ttf",  # Segoe UI
            "C:/Windows/Fonts/arial.ttf",
        ]
        
        for fp in font_paths:
            if os.path.exists(fp):
                try:
                    font = ImageFont.truetype(fp, font_size)
                    print(f"使用字体: {fp}")
                    break
                except:
                    continue
        
        if font is None:
            font = ImageFont.load_default()
            print("使用默认字体")
        
        text = "GO NOMADS"
        
        # 获取文字边界框
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # 居中绘制白色文字
        x = (width - text_width) // 2
        y = (height - text_height) // 2
        
        # 白色文字，完全不透明
        draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
        
        # 确保目录存在
        output_dir = os.path.join(DRAWABLE_DIR, density)
        os.makedirs(output_dir, exist_ok=True)
        
        # 保存图片
        output_path = os.path.join(output_dir, "splash_logo.png")
        img.save(output_path, "PNG")
        print(f"已生成: {output_path} ({width}x{height}, 字体{font_size}px)")

if __name__ == "__main__":
    generate_splash_logo()
    print("\n✅ 所有启动页文字图片已生成!")
