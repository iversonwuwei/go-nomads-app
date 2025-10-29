#!/bin/bash

# 快速测试流式接口 - 简化版
# 用法: ./quick-stream-test.sh [cityName] [duration]

CITY_NAME=${1:-"北京"}
DURATION=${2:-2}

echo "🚀 测试流式接口: $CITY_NAME ${DURATION}天游"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

curl -N -X POST http://localhost:5000/api/v1/ai/travel-plan/stream \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d "{
    \"cityId\": \"test\",
    \"cityName\": \"$CITY_NAME\",
    \"cityImage\": \"https://example.com/test.jpg\",
    \"duration\": $DURATION,
    \"budget\": \"medium\",
    \"travelStyle\": \"culture\",
    \"interests\": [\"美食\", \"历史\"]
  }" 2>/dev/null | while IFS= read -r line; do
    if [[ $line == data:* ]]; then
        # 提取 JSON 数据
        json_data="${line#data: }"
        
        # 解析事件类型和消息
        event_type=$(echo "$json_data" | jq -r '.type' 2>/dev/null)
        message=$(echo "$json_data" | jq -r '.payload.message' 2>/dev/null)
        progress=$(echo "$json_data" | jq -r '.payload.progress' 2>/dev/null)
        
        # 根据事件类型显示不同颜色
        case "$event_type" in
            "start")
                echo "▶ [开始] $message"
                ;;
            "analyzing")
                echo "⚙ [分析] $message ($progress%)"
                ;;
            "generating")
                echo "⚡ [生成] $message ($progress%)"
                ;;
            "complete")
                echo "✓ [完成] $message ($progress%)"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎉 旅行计划生成成功!"
                ;;
            "error")
                echo "✗ [错误] $message"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "❌ 生成失败，请检查后端日志"
                ;;
            *)
                echo "📨 [$event_type] $message"
                ;;
        esac
    fi
done

echo ""
echo "测试完成!"
