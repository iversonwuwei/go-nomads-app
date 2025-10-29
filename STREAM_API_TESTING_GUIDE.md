# 流式接口测试指南

## 什么是流式接口（SSE）？

Server-Sent Events (SSE) 是一种服务器向客户端推送实时数据的技术。与普通 HTTP 请求不同，SSE 连接会保持打开状态，服务器可以持续发送多个事件。

## 为什么普通 API 工具看不到结果？

- **Postman/Insomnia 等工具**：默认等待完整响应后才显示，不适合测试流式接口
- **浏览器开发者工具**：可以看到响应，但需要特殊设置
- **推荐工具**：curl、专用 SSE 客户端、或我们提供的测试脚本

## 测试方法

### 方法 1：使用 curl（推荐）

```bash
# -N 参数关闭缓冲，实时显示流式响应
curl -N -X POST http://localhost:5000/api/v1/ai/travel-plan/stream \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "cityId": "beijing",
    "cityName": "北京",
    "cityImage": "https://example.com/beijing.jpg",
    "duration": 2,
    "budget": "medium",
    "travelStyle": "culture",
    "interests": ["历史", "美食"]
  }'
```

**预期输出**（实时流式显示）：
```
data: {"type":"start","payload":{"message":"开始生成旅行计划...","progress":0}}

data: {"type":"analyzing","payload":{"message":"正在分析您的需求...","progress":10}}

data: {"type":"generating","payload":{"message":"AI 正在生成行程安排...","progress":30}}

data: {"type":"complete","payload":{"message":"生成完成!","progress":100,"plan":{...}}}
```

### 方法 2：使用我们的测试脚本（最推荐）

```bash
# 交互式选择测试用例
./test-travel-plan-stream.sh

# 运行指定测试（带详细输出）
./test-travel-plan-stream.sh -v test-001-basic

# 测试完整参数
./test-travel-plan-stream.sh test-002-full-params

# 列出所有测试用例
./test-travel-plan-stream.sh -l

# 运行所有测试
./test-travel-plan-stream.sh -a
```

**优势**：
- ✅ 彩色输出，易于阅读
- ✅ 实时进度显示
- ✅ 自动解析和验证 SSE 事件
- ✅ 统计信息（事件数、耗时等）
- ✅ 预定义的测试场景

### 方法 3：使用 Postman（需要配置）

1. 创建新请求
2. 设置为 **POST** 方法
3. URL: `http://localhost:5000/api/v1/ai/travel-plan/stream`
4. Headers:
   - `Content-Type: application/json`
   - `Accept: text/event-stream`
5. Body (raw JSON):
   ```json
   {
     "cityId": "beijing",
     "cityName": "北京",
     "cityImage": "https://example.com/beijing.jpg",
     "duration": 2,
     "budget": "medium",
     "travelStyle": "culture",
     "interests": ["历史", "美食"]
   }
   ```
6. **重要**：点击 Send 后，切换到 **"Response > Body > Stream"** 标签页

### 方法 4：在浏览器中测试（JavaScript）

创建一个简单的 HTML 文件：

```html
<!DOCTYPE html>
<html>
<head>
    <title>测试流式接口</title>
</head>
<body>
    <h1>AI 旅行计划生成测试</h1>
    <button onclick="testStream()">开始测试</button>
    <pre id="output"></pre>

    <script>
        async function testStream() {
            const output = document.getElementById('output');
            output.textContent = '正在连接...\n';

            try {
                const response = await fetch('http://localhost:5000/api/v1/ai/travel-plan/stream', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'text/event-stream'
                    },
                    body: JSON.stringify({
                        cityId: 'beijing',
                        cityName: '北京',
                        cityImage: 'https://example.com/beijing.jpg',
                        duration: 2,
                        budget: 'medium',
                        travelStyle: 'culture',
                        interests: ['历史', '美食']
                    })
                });

                const reader = response.body.getReader();
                const decoder = new TextDecoder();

                while (true) {
                    const { done, value } = await reader.read();
                    if (done) break;

                    const chunk = decoder.decode(value);
                    const lines = chunk.split('\n');

                    for (const line of lines) {
                        if (line.startsWith('data: ')) {
                            const data = JSON.parse(line.substring(6));
                            output.textContent += `[${data.type}] ${data.payload.message} (${data.payload.progress}%)\n`;
                        }
                    }
                }
            } catch (error) {
                output.textContent += `错误: ${error.message}\n`;
            }
        }
    </script>
</body>
</html>
```

## SSE 事件类型说明

| 事件类型 | 说明 | progress | 示例 payload |
|---------|------|----------|-------------|
| `start` | 开始生成 | 0 | `{"message":"开始生成旅行计划...","progress":0}` |
| `analyzing` | 正在分析 | 10 | `{"message":"正在分析您的需求...","progress":10}` |
| `generating` | 正在生成 | 30-90 | `{"message":"AI 正在生成行程...","progress":50}` |
| `complete` | 生成完成 | 100 | `{"message":"生成完成!","progress":100,"plan":{...}}` |
| `error` | 发生错误 | 0 | `{"message":"生成失败: ...","progress":0}` |

## 常见问题

### Q: 为什么我在 Postman 中看不到任何响应？
**A**: Postman 默认等待完整响应。请确保：
1. 切换到 "Response > Body > **Stream**" 标签页
2. 或者使用 curl/我们的测试脚本

### Q: 响应显示乱码怎么办？
**A**: SSE 使用 UTF-8 编码。如果看到类似 `\u5F00\u59CB` 的内容，这是 Unicode 转义序列，可以：
```bash
# curl 输出通过 jq 美化
curl -N ... | while read line; do
    echo "$line" | sed 's/data: //' | jq -r '.payload.message'
done
```

### Q: 连接超时怎么办？
**A**: 流式接口可能需要较长时间（AI 生成）。确保：
1. curl: 不设置超时或设置较长超时
2. 代码: `connectTimeout >= 30s`, `receiveTimeout >= 5min`

### Q: 如何知道流式响应已结束？
**A**: 
- 收到 `complete` 或 `error` 事件
- 连接关闭（curl 自动退出）
- 无新数据超过超时时间

## 测试用例快速参考

| ID | 场景 | 用途 |
|---|---|---|
| `test-001-basic` | 北京3天游 | 基础功能测试 |
| `test-002-full-params` | 上海5天游 | 完整参数测试 |
| `test-003-budget-low` | 成都2天游 | 低预算测试 |
| `test-004-adventure` | 丽江7天游 | 冒险风格测试 |
| `test-005-single-day` | 苏州1天游 | 最短时长测试 |
| `test-006-max-duration` | 西藏30天游 | 最长时长测试 |

## 调试技巧

### 1. 查看原始流式数据
```bash
curl -N ... | tee stream_output.txt
```

### 2. 只看进度信息
```bash
curl -N ... | grep '"type":"' | jq -r '.payload.message + " (" + (.payload.progress|tostring) + "%)"'
```

### 3. 计时测试
```bash
time curl -N ...
```

### 4. 保存完整响应并美化
```bash
curl -N ... > response.txt
cat response.txt | grep '^data:' | sed 's/^data: //' | jq .
```

## 下一步

1. ✅ 使用 `./test-travel-plan-stream.sh` 快速测试
2. ✅ 观察流式事件的实时输出
3. ✅ 检查后端日志排查 DeepSeek API 问题
4. ✅ 在 Flutter 应用中测试（客户端已修复）

---

**提示**: 如果后端 DeepSeek API 报错（如当前的 "response ended prematurely"），这是 AI 服务的问题，与流式接口本身无关。流式传输部分已经正常工作（你能看到 start/analyzing/generating 事件）。
