# Supabase Storage RLS 策略配置指南

## 问题描述
图片上传失败，错误信息：
```
StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

## 原因分析
Supabase Storage 默认启用了行级安全策略(RLS)，但没有配置相应的权限策略，导致认证用户无法上传文件。

## 解决方案

### 方法1：使用 SQL 迁移文件（推荐）

1. **在 Supabase 控制台执行 SQL**
   - 打开 Supabase Dashboard
   - 进入 `SQL Editor`
   - 执行 `migrations/20250114_storage_rls_policies.sql` 文件

2. **SQL 文件说明**
   - 创建/更新 `user-uploads` 存储桶（设为 public）
   - 配置 4 个 RLS 策略：
     - 允许认证用户上传文件到自己的文件夹
     - 允许公开读取所有文件
     - 允许用户更新自己的文件
     - 允许用户删除自己的文件

### 方法2：通过 Supabase Dashboard 手动配置

#### Step 1: 创建存储桶
1. 打开 Supabase Dashboard
2. 进入 `Storage` → `Buckets`
3. 如果 `user-uploads` 不存在，点击 `New Bucket`:
   - Name: `user-uploads`
   - Public bucket: ✅ **勾选**（允许公开访问）
   - File size limit: `10 MB`
   - Allowed MIME types: `image/jpeg, image/png, image/gif, image/webp`

#### Step 2: 配置 RLS 策略
1. 进入 `Storage` → `Policies`
2. 选择 `user-uploads` 存储桶
3. 点击 `New Policy` 创建以下策略：

**策略 1: 允许上传**
```sql
Name: Allow authenticated users to upload
Policy command: INSERT
Target roles: authenticated
USING expression: (留空)
WITH CHECK expression:
bucket_id = 'user-uploads' 
AND (storage.foldername(name))[1] = auth.uid()::text
```

**策略 2: 允许公开读取**
```sql
Name: Allow public read access
Policy command: SELECT
Target roles: public
USING expression:
bucket_id = 'user-uploads'
WITH CHECK expression: (留空)
```

**策略 3: 允许更新**
```sql
Name: Allow users to update own files
Policy command: UPDATE
Target roles: authenticated
USING expression:
bucket_id = 'user-uploads'
AND (storage.foldername(name))[1] = auth.uid()::text
WITH CHECK expression:
bucket_id = 'user-uploads'
AND (storage.foldername(name))[1] = auth.uid()::text
```

**策略 4: 允许删除**
```sql
Name: Allow users to delete own files
Policy command: DELETE
Target roles: authenticated
USING expression:
bucket_id = 'user-uploads'
AND (storage.foldername(name))[1] = auth.uid()::text
WITH CHECK expression: (留空)
```

## 策略说明

### 文件路径结构
```
user-uploads/
  ├── {user_id}/           # 用户文件夹
  │   ├── avatar_xxx.jpg   # 头像
  │   ├── image_xxx.png    # 其他图片
  │   └── ...
  └── ...
```

### 安全性
- ✅ 每个用户只能上传/更新/删除自己文件夹下的文件
- ✅ 文件夹名必须是用户的 UUID
- ✅ 所有人都可以读取文件（适合公开内容）
- ✅ 限制文件类型为图片格式
- ✅ 限制文件大小为 10MB

## 验证配置

### 1. 在 SQL Editor 中验证策略
```sql
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
AND schemaname = 'storage'
AND policyname LIKE '%user-uploads%';
```

应该看到 4 个策略。

### 2. 测试上传
在 Flutter 应用中尝试：
- 上传头像
- 上传图片到城市详情
- 验证图片可以正常访问

## 常见问题

### Q1: 仍然报 403 错误
**检查清单：**
- [ ] 确认用户已登录（`auth.uid()` 不为空）
- [ ] 确认文件夹名是用户的 UUID
- [ ] 确认存储桶设为 public
- [ ] 确认 RLS 策略已正确创建

### Q2: 图片无法访问
**检查清单：**
- [ ] 确认存储桶设为 `public`
- [ ] 确认 SELECT 策略的 Target roles 是 `public`
- [ ] 使用 `getPublicUrl()` 而不是 `createSignedUrl()`

### Q3: 其他用户的文件可以被删除
**这是正常的策略设置：**
- 策略限制了只能操作 `auth.uid()` 对应的文件夹
- 即使知道文件 URL，也无法删除其他用户的文件

## 相关文件
- SQL 迁移: `migrations/20250114_storage_rls_policies.sql`
- 上传服务: `lib/services/image_upload_service.dart`
- 辅助函数: `lib/utils/image_upload_helper.dart`

## 参考文档
- [Supabase Storage RLS](https://supabase.com/docs/guides/storage/security/access-control)
- [PostgreSQL RLS Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
