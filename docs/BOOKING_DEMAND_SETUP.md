# Booking Demand Setup

当前架构已经调整为服务端代理模式：Flutter 只调用内部 AccommodationService，由 AccommodationService 再调用 Booking Demand API。

## Current Flow

- Flutter 城市酒店列表调用内部 `/hotels` 接口。
- Flutter 会把 `cityId`、`cityName`、`countryName`、`latitude`、`longitude` 传给 AccommodationService。
- AccommodationService 会尝试融合 Booking Demand 和内部社区酒店，而不是让第三方结果覆盖内部结果。
- 如果 Booking 未配置、超时、返回异常或解析失败，AccommodationService 会自动回退到内部酒店库，不影响接口可用性。

## Fallback Contract

- `/hotels` 始终优先保证可用，第三方失败不会让整个接口报错。
- `/hotels` 列表响应现在包含：
  - `externalDataStatus`: `not_requested` / `disabled` / `live` / `unavailable`
  - `partialExternalData`: 是否发生了“预期会查第三方，但第三方失败，所以只回了部分数据”的情况
  - `externalDataMessage`: 可选说明文本，方便 Flutter 或日志做提示
- 每个 hotel 项还包含：
  - `source`: `community` 或 `booking`
  - `externalStatus`: `internal` / `live` / `unavailable`
- `/hotels/{id}` 对社区酒店继续正常返回；对 `booking_` 外部酒店，若第三方详情失败，则返回空结果，由 Flutter 保留列表页传入的已有基础数据展示。

## Backend Configuration

在 AccommodationService 的配置文件中设置 `BookingDemand`：

```json
{
  "BookingDemand": {
    "Enabled": true,
    "UseSandbox": true,
    "Token": "your_booking_token",
    "AffiliateId": "your_affiliate_id",
    "DefaultBookerCountry": "US",
    "DefaultCurrency": "USD"
  }
}
```

相关文件：

- `go-nomads-backend/src/Services/AccommodationService/AccommodationService/appsettings.json`
- `go-nomads-backend/src/Services/AccommodationService/AccommodationService/appsettings.Development.json`

## Notes

- Booking Demand API 需要 `Authorization: Bearer <token>` 和 `X-Affiliate-Id`。
- 当前后端使用城市名称加经纬度做搜索，默认入住日期为当前日期后 7 天，默认住 1 晚。
- AccommodationService 已支持外部酒店 ID，例如 `booking_123456`，Flutter 详情页仍然通过内部 `/hotels/{id}` 获取数据。
- 不要把 Booking Demand 设计成硬依赖。即使后续正式开通，也必须保持“第三方失败只影响外部增量，不影响主流程”的降级策略。