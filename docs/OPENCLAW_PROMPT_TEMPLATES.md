# OpenClaw Prompt Templates

适用于 Go Nomads 多项目工作区的常用 OpenClaw 命令模板。

## Agent 列表

- `gonomads-app`：Flutter 客户端
- `gonomads-web`：Next.js 用户前端
- `gonomads-admin`：Next.js 管理后台
- `gonomads-backend`：.NET 微服务后端

## Flutter App

### 分析页面职责

```bash
openclaw agent --agent gonomads-app --message "请分析 lib/pages/travel_plan/travel_plan_page.dart 的页面职责、状态来源、主要子组件和两个实现风险。"
```

### 分析控制器数据流

```bash
openclaw agent --agent gonomads-app --message "请分析 lib/pages/travel_plan/travel_plan_page_controller.dart 的初始化流程、异步生成流程、GetX 监听器和错误处理路径。"
```

### 比较两个文件的职责边界

```bash
openclaw agent --agent gonomads-app --message "请比较 lib/pages/travel_plan/travel_plan_page.dart 和 lib/pages/travel_plan/travel_plan_page_controller.dart 的职责边界，并指出哪些逻辑适合继续下沉。"
```

### 排查 OpenClaw 集成点

```bash
openclaw agent --agent gonomads-app --message "请阅读 lib/services/openclaw_research_service.dart、lib/pages/travel_plan/travel_plan_page_controller.dart、lib/pages/travel_plan/travel_plan_page.dart，说明 OpenClaw 在 Flutter 端的接入链路。"
```

## Web Frontend

### 总结前端技术栈

```bash
openclaw agent --agent gonomads-web --message "请阅读 package.json 和 next.config.ts，总结这个前端项目的技术栈、构建方式和运行特征。"
```

### 分析某个页面的数据流

```bash
openclaw agent --agent gonomads-web --message "请分析 src/app 下城市详情相关页面的路由结构、数据获取方式和组件拆分。"
```

### 排查构建配置

```bash
openclaw agent --agent gonomads-web --message "请检查 next.config.ts、biome.json、package.json，说明会影响构建、静态资源和性能优化的关键配置。"
```

## Admin Frontend

### 总结管理后台结构

```bash
openclaw agent --agent gonomads-admin --message "请阅读 package.json 和 next.config.ts，并总结这个后台管理前端的技术栈、目标用户和运行角色。"
```

### 分析后台某模块

```bash
openclaw agent --agent gonomads-admin --message "请分析 src 下用户管理相关模块，说明页面入口、状态管理和 API 依赖。"
```

## Backend

### 总结整体架构

```bash
openclaw agent --agent gonomads-backend --message "请基于当前工作区总结 go-nomads-backend 的微服务结构，并重点说明 Gateway、AIService、MessageService 的角色。"
```

### 分析 AIService

```bash
openclaw agent --agent gonomads-backend --message "请分析 src/Services/AIService/AIService/Program.cs，说明依赖注册、Qwen 接入方式、缓存和消息队列相关配置。"
```

### 追踪接口调用链

```bash
openclaw agent --agent gonomads-backend --message "请追踪旅行计划生成从 API 入口到 AIService 的调用链，列出控制器、应用服务、仓储和外部依赖。"
```

## 通用技巧

### 用 JSON 输出

```bash
openclaw agent --agent gonomads-app --message "请总结 lib/pages/travel_plan/travel_plan_page.dart" --json
```

### 增加推理时间

```bash
openclaw agent --agent gonomads-backend --message "请分析 AIService 的 Qwen 接入链路" --thinking low --timeout 120
```

### 固定会话连续追问

```bash
openclaw agent --agent gonomads-app --session-id travel-plan-debug --message "请记住我们正在排查 travel_plan 页面"
```

### 打开控制台

```bash
openclaw dashboard
```