# 城市照片批量上传改造完成

## ✨ 目标

- 上传照片前跳转到专用页面，填写标题/地点信息
- 支持一次性上传最多 10 张照片
- 提交后回到城市照片 Tab 并自动刷新
- 后端收到请求后使用高德地图 (AMap) 反查坐标，补齐 `latitude/longitude`

---

## 📱 前端实现

- 新增 `CityPhotoSubmissionPage`：
  - 表单字段：标题（必填）、位置信息备注（选填）、描述（选填）
  - 图片管理：支持相册多选 (`ImageUploadHelper.pickMultipleAndUpload`) 与拍照上传
  - 状态提示：显示上传进度、可删除已选照片
  - 提交成功后 `Get.back(result: {'uploaded': true})`
- `CityDetailPage` Photos Tab 入口：
  - FAB 改为跳转新页面
  - 返回结果为成功时自动 `loadCityPhotos`
- `UserCityContentStateController`：
  - 新增 `submitPhotoCollection` 方法，调用批量上传 use case
- 依赖注入：注册 `SubmitCityPhotosUseCase`

---

## 🧠 数据结构

`UserCityPhoto` & DTO 增加以下字段（可空）：

- `placeName`
- `address`
- `latitude`
- `longitude`

这些字段由后端填充，前端仅负责透传。

---

## 🔌 API 设计

### Endpoint

```text
POST /api/v1/cities/{cityId}/user-content/photos/batch
```

### Request Body

```json
{
  "title": "北戴河海边日出",
  "description": "11 月份 6:30 的日出，气温 5℃",
  "locationNote": "河北秦皇岛北戴河鸽子窝公园旁",
  "imageUrls": [
    "https://supabase.co/storage/v1/object/public/user-uploads/city_photos/...jpg",
    "https://supabase.co/storage/v1/object/public/user-uploads/city_photos/...jpg"
  ]
}
```

> `imageUrls` 已由前端上传到 Supabase，最多 10 条。

### Response

- 成功：返回创建的照片列表（数组或 `{ items: [...] }` 均可）
- 每条记录需包含新增的坐标字段，用于后续展示

### 后端逻辑建议

1. 根据 `title` / `locationNote` 调用 AMap 地理编码服务获取坐标
2. 将 `latitude` / `longitude`、`placeName`、`address` 写入照片记录
3. 返回创建成功的 `UserCityPhoto` DTO 列表

---

## ✅ 提交后体验

1. 用户完成表单 → 点击提交
2. 前端调用批量 API，展示加载状态
3. 成功后返回 Photos Tab，触发 `loadCityPhotos`
4. 新照片按照返回顺序插入列表（含坐标信息）

---

## 🧪 验证建议

- [ ] 上传 <10 张 & =10 张的情况
- [ ] 只拍照、不填位置信息的情况（后端需容错）
- [ ] 后端返回异常时前端提示
- [ ] 新增坐标字段在 `UserCityPhoto` 中可被后续模块使用（如未来地图展示）
