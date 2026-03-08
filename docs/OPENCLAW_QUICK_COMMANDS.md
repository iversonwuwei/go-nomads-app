# OpenClaw Quick Commands

Go Nomads 工作区最常用的 8 条命令。

## 1. 分析 Flutter 页面

```bash
openclaw agent --agent gonomads-app --message "请分析 lib/pages/travel_plan/travel_plan_page.dart 的页面职责、状态来源和两个实现风险。"
```

## 2. 分析 Flutter 控制器

```bash
openclaw agent --agent gonomads-app --message "请分析 lib/pages/travel_plan/travel_plan_page_controller.dart 的初始化流程、异步生成流程和错误处理路径。"
```

## 3. 分析 Web 前端配置

```bash
openclaw agent --agent gonomads-web --message "请阅读 package.json 和 next.config.ts，总结前端技术栈、构建方式和性能相关配置。"
```

## 4. 分析 Admin 前端配置

```bash
openclaw agent --agent gonomads-admin --message "请阅读 package.json 和 next.config.ts，总结后台管理前端的技术栈和职责。"
```

## 5. 分析 Backend 服务

```bash
openclaw agent --agent gonomads-backend --message "请分析 src/Services/AIService/AIService/Program.cs，说明依赖注册、Qwen 接入和外部依赖。"
```

## 6. 做结构化输出

```bash
openclaw agent --agent gonomads-app --message "请总结 lib/pages/travel_plan/travel_plan_page.dart" --json
```

## 7. 固定调试会话

```bash
openclaw agent --agent gonomads-app --session-id travel-plan-debug --message "请记住我们正在排查 travel_plan 页面"
```

## 8. 打开控制台

```bash
openclaw dashboard
```

## 说明

- `gonomads-app`：Flutter 客户端
- `gonomads-web`：Next.js 用户前端
- `gonomads-admin`：Next.js 管理后台
- `gonomads-backend`：.NET 微服务后端
- 更完整模板见 `docs/OPENCLAW_PROMPT_TEMPLATES.md`