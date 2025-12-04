# PayPal 支付集成完成文档

## 📋 概述

已完成将 PayPal 支付系统集成到 Go-Nomads 项目中。主要工作在服务端完成，Flutter 端只负责简单的 UI 和重定向逻辑。

## 🏗️ 架构设计

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│  .NET Backend   │────▶│   PayPal API    │
│   (Simple UI)   │◀────│  (Core Logic)   │◀────│   (Payment)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 支付流程

1. **用户发起支付** → Flutter 调用 `POST /api/v1/payments/orders`
2. **后端创建订单** → 同时在本地数据库和 PayPal 创建订单
3. **返回支付链接** → Flutter 在外部浏览器打开 PayPal 结账页面
4. **用户完成支付** → PayPal 重定向到 `gonomads://payment/success?token=xxx`
5. **App 处理回调** → Deep Link Handler 捕获并调用后端确认
6. **后端确认支付** → 调用 PayPal Capture API，更新会员状态
7. **显示结果** → Flutter 显示成功/失败对话框

## 📂 文件结构

### 后端 (.NET) - `go-nomads/GoNomads.BFF/`

```
├── Config/
│   └── PayPalSettings.cs                    # PayPal 配置
├── Domain/
│   └── Entities/
│       ├── Order.cs                         # 订单实体
│       └── PaymentTransaction.cs            # 支付交易记录
├── Infrastructure/
│   └── Repositories/
│       ├── IOrderRepository.cs
│       ├── OrderRepository.cs
│       ├── IPaymentTransactionRepository.cs
│       └── PaymentTransactionRepository.cs
├── Services/
│   ├── PayPal/
│   │   ├── IPayPalService.cs
│   │   └── PayPalService.cs                 # PayPal API 集成
│   └── Payment/
│       ├── IPaymentService.cs
│       └── PaymentService.cs                # 业务逻辑
├── Controllers/
│   └── PaymentController.cs                 # REST API
└── DTOs/
    └── PaymentDTOs.cs
```

### Flutter - `df_admin_mobile/lib/`

```
├── features/payment/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── order.dart
│   │   └── repositories/
│   │       └── i_payment_repository.dart
│   ├── infrastructure/
│   │   └── repositories/
│   │       └── payment_repository.dart
│   ├── presentation/
│   │   └── controllers/
│   │       └── payment_state_controller.dart
│   └── application/
│       └── services/
│           └── payment_service.dart
├── core/
│   ├── di/
│   │   └── dependency_injection.dart        # 已更新
│   └── utils/
│       └── deep_link_handler.dart           # Deep Link 处理
└── main.dart                                # 已更新
```

### 数据库迁移

```
migrations/
└── create_payment_tables.sql                # orders 和 payment_transactions 表
```

## 🔧 API 端点

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/api/v1/payments/orders` | 创建订单 |
| POST | `/api/v1/payments/orders/{orderId}/capture` | 确认支付 |
| GET | `/api/v1/payments/orders/{orderId}` | 获取订单详情 |
| GET | `/api/v1/payments/orders` | 获取用户订单列表 |
| POST | `/api/v1/payments/orders/{orderId}/cancel` | 取消订单 |
| POST | `/api/v1/payments/webhooks/paypal` | PayPal Webhook |
| GET | `/api/v1/payments/return` | 支付成功重定向 |
| GET | `/api/v1/payments/cancel` | 支付取消重定向 |

## 🚀 部署步骤

### 1. 数据库迁移

在 Supabase SQL Editor 中执行 `migrations/create_payment_tables.sql`

### 2. 配置 PayPal

1. 登录 [PayPal Developer Dashboard](https://developer.paypal.com/)
2. 创建应用获取 Client ID 和 Client Secret
3. 更新 `appsettings.json`:

```json
{
  "PayPal": {
    "ClientId": "YOUR_PAYPAL_CLIENT_ID",
    "ClientSecret": "YOUR_PAYPAL_CLIENT_SECRET",
    "UseSandbox": true,
    "ReturnUrl": "https://your-api.com/api/v1/payments/return",
    "CancelUrl": "https://your-api.com/api/v1/payments/cancel"
  }
}
```

### 3. 配置 Android Deep Links

在 `android/app/src/main/AndroidManifest.xml` 中添加:

```xml
<activity ...>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="gonomads" android:host="payment" />
    </intent-filter>
</activity>
```

### 4. 配置 iOS Deep Links

在 `ios/Runner/Info.plist` 中添加:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gonomads</string>
        </array>
    </dict>
</array>
```

### 5. Flutter 依赖

```bash
cd df_admin_mobile
flutter pub get
```

### 6. 后端部署

```bash
cd go-nomads/GoNomads.BFF
dotnet publish -c Release
```

## 📱 使用示例

### 升级会员

```dart
// 在会员计划页面点击 "Select Plan" 按钮
// 系统自动调用 PaymentService.startMembershipPayment()
```

### 版主保证金

```dart
final paymentService = Get.find<PaymentService>();
await paymentService.startDepositPayment(amount: 100.0);
```

## 🔒 安全考虑

1. **PayPal Credentials**: 永远不要在客户端暴露 Client Secret
2. **Webhook 验证**: 后端验证 PayPal webhook 签名
3. **订单验证**: 确认支付前验证订单金额与原始订单一致
4. **用户验证**: 所有 API 需要 JWT 认证

## 📊 订单状态

| 状态 | 说明 |
|------|------|
| Pending | 订单已创建，等待支付 |
| Processing | 支付处理中 |
| Completed | 支付成功完成 |
| Failed | 支付失败 |
| Refunded | 已退款 |
| Cancelled | 已取消 |

## 🧪 测试

### 沙盒测试账户

1. 在 PayPal Developer Dashboard 创建沙盒买家账户
2. 设置 `UseSandbox: true`
3. 使用沙盒买家账户完成测试支付

### 测试流程

1. 选择会员计划
2. 确认支付
3. 在 PayPal 沙盒中登录并支付
4. 验证会员状态更新

## ❗ 注意事项

1. 首次运行需要执行数据库迁移
2. PayPal 需要 HTTPS 回调地址（本地开发可用 ngrok）
3. Deep Link 需要在设备上测试（模拟器可能有限制）
4. 生产环境记得将 `UseSandbox` 设为 `false`

## 📝 后续优化

- [ ] 添加 PayPal Webhook 处理
- [ ] 实现订单超时自动取消
- [ ] 添加退款功能
- [ ] 支持更多支付方式
- [ ] 添加支付历史页面
