---
applyTo: "lib/**/*.dart"
---

# Flutter App 开发规范

## Harness Engineering 基线
- 本工程默认遵循根目录 `HARNESS_ENGINEERING_CHECKLIST.md`。
- 交付说明默认遵循根目录 `HARNESS_DELIVERY_TEMPLATE.md`。
- 需求实现前先明确页面状态、接口契约、登录态、失败恢复和验证路径。
- 交付时必须说明已验证设备/场景、未验证风险，以及是否影响路由、状态管理或平台差异行为。

## 状态管理：GetX
- 每个 feature 使用独立的 Controller + Binding
- Controller 继承 `GetxController`，使用 `.obs` 响应式变量
- 页面通过 `Get.find<XxxController>()` 获取 controller
- 路由使用 `Get.toNamed()` / `Get.offNamed()`
- 不要混用 Provider/Bloc 等其他状态方案

## 命名约定
- 文件名: snake_case（`city_detail_page.dart`）
- 类名: PascalCase（`CityDetailPage`）
- Controller: `{Feature}Controller`（`CityController`）
- Service: `{Feature}Service`（`CityService`）
- 路由常量: 定义在 `routes/` 目录

## 网络请求
- 使用 Dio 封装的统一 HTTP 客户端
- API 端点常量在 `config/api_config.dart`
- 新端点必须添加到 `ApiConfig` 类中
- 支持 HTTP Method Override（PUT/DELETE via POST）

## 国际化
- ARB 文件在 `l10n/` 目录
- 新增文本必须同时添加中/英文 ARB key
- 使用 `S.of(context).xxx` 或 `AppLocalizations.of(context)!.xxx`

## 目录规范
- 新功能放在 `features/{feature_name}/` 下
- 通用组件放在 `widgets/`
- 工具函数放在 `utils/`
- 数据模型放在 `models/` 或 feature 内部

## 环境切换
- `api_config.dart` 中 `kIsProduction` 控制生产/开发
- `deploymentEnvironment` 控制 docker/k8s/direct 模式
- 开发时真机调试地址: `usePhysicalDevice` + IP 地址

## SignalR
- Hub 连接通过 Gateway 代理
- Chat: `/hubs/chat`
- Meetup: `/hubs/meetup`
- Notification: `/hubs/notification`
