#!/usr/bin/env bash
# ============================================================
# convert_app_preview.sh
# 将 App Preview 视频转换为 App Store Connect 兼容格式
# Convert App Preview videos to App Store Connect compatible format
#
# Apple 要求:
#   - 视频: H.264 (High Profile)
#   - 音频: AAC-LC, 立体声, 44100 或 48000 Hz
#   - 容器: MOV / MP4
#   - 分辨率: 与设备匹配 (如 1290x2796 for 6.7", 1284x2778 for 6.5")
#   - 时长: 15-30 秒
#   - 帧率: 30 fps
#
# 用法 / Usage:
#   ./scripts/convert_app_preview.sh input.mov
#   ./scripts/convert_app_preview.sh input.mov output.mp4
#   ./scripts/convert_app_preview.sh input.mov output.mp4 --no-audio  (静音)
# ============================================================
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "用法: $0 <input_video> [output_video] [--no-audio]"
  echo "示例: $0 preview_raw.mov preview_appstore.mp4"
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.*}_appstore.mp4}"
NO_AUDIO="${3:-}"

if ! command -v ffmpeg &>/dev/null; then
  echo "❌ 未找到 ffmpeg，请先安装: brew install ffmpeg"
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "❌ 输入文件不存在: $INPUT"
  exit 1
fi

echo "=== App Preview 视频转换 ==="
echo "输入: $INPUT"
echo "输出: $OUTPUT"
echo

# 打印输入视频信息 / Print input video info
echo "--- 输入视频信息 ---"
ffprobe -v quiet -show_entries stream=codec_name,codec_type,width,height,r_frame_rate,sample_rate,channels \
  -of compact "$INPUT" 2>/dev/null || true
echo

if [[ "$NO_AUDIO" == "--no-audio" ]]; then
  echo "⚠️  静音模式: 移除音频轨道"
  ffmpeg -y -i "$INPUT" \
    -an \
    -c:v libx264 -profile:v high -level 4.2 \
    -pix_fmt yuv420p \
    -r 30 \
    -movflags +faststart \
    "$OUTPUT"
else
  # 关键修复: 重新编码音频为 AAC-LC
  # Key fix: Re-encode audio to AAC-LC
  ffmpeg -y -i "$INPUT" \
    -c:v libx264 -profile:v high -level 4.2 \
    -pix_fmt yuv420p \
    -r 30 \
    -c:a aac -b:a 256k -ac 2 -ar 44100 \
    -movflags +faststart \
    "$OUTPUT"
fi

echo
echo "--- 输出视频信息 ---"
ffprobe -v quiet -show_entries stream=codec_name,codec_type,width,height,r_frame_rate,sample_rate,channels \
  -of compact "$OUTPUT" 2>/dev/null || true

# 检查时长 / Check duration
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$OUTPUT" | cut -d. -f1)
if [[ "$DURATION" -lt 15 ]]; then
  echo "⚠️  视频时长 ${DURATION}s，App Store 要求至少 15 秒"
elif [[ "$DURATION" -gt 30 ]]; then
  echo "⚠️  视频时长 ${DURATION}s，App Store 要求最多 30 秒"
else
  echo "✅ 视频时长 ${DURATION}s (符合 15-30 秒要求)"
fi

echo
echo "✅ 转换完成: $OUTPUT"
echo "   现在可以上传到 App Store Connect"
