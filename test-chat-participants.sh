#!/bin/bash

# 测试事件关注者API（用于聊天室参与者功能）
# 用法: ./test-chat-participants.sh [event_id]

EVENT_ID=${1:-00000000-0000-0000-0000-000000000001}
BASE_URL="http://localhost:5000"
API_VERSION="/api/v1"

echo "🧪 测试事件关注者API (聊天室参与者)"
echo "========================================="
echo "事件ID: $EVENT_ID"
echo "API地址: ${BASE_URL}${API_VERSION}/events/${EVENT_ID}/followers"
echo ""

# 测试GET请求
echo "📡 发送GET请求..."
curl -X GET \
  "${BASE_URL}${API_VERSION}/events/${EVENT_ID}/followers" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\n\n📊 HTTP状态码: %{http_code}\n" \
  -s | jq '.'

echo ""
echo "💡 提示："
echo "   - FollowerResponse 包含: id, eventId, userId, followedAt, notificationEnabled"
echo "   - 前端需要根据 userId 调用用户服务获取详细信息"
echo "   - 聊天室ID到事件ID的映射:"
echo "     room_bangkok → 00000000-0000-0000-0000-000000000001"
echo "     room_chiangmai → 00000000-0000-0000-0000-000000000002"
echo ""
echo "✅ 测试完成"

