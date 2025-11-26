# Flutter 图片上传到 Supabase Storage 完整实现

## 📋 实现概述

已完成 Flutter 直连 Supabase Storage 的图片上传功能，包括：
- ✅ Supabase 配置管理
- ✅ 图片上传服务（支持压缩、进度回调）
- ✅ 便捷的工具类和 Widget
- ✅ 完整的错误处理

## 📂 文件结构

```
lib/
├── config/
│   └── supabase_config.dart           # Supabase 配置
├── services/
│   └── image_upload_service.dart      # 核心上传服务
└── utils/
    └── image_upload_helper.dart       # 便捷工具类和 Widget
```

## 🚀 使用指南

### 1. 配置 Supabase

在 `lib/config/supabase_config.dart` 中配置你的 Supabase 凭证：

```dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key-here';
  
  // 其他配置已预设好
}
```

### 2. 初始化（在 main.dart 中）

```dart
import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/image_upload_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Supabase
  if (SupabaseConfig.isConfigured) {
    await ImageUploadService().initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
  
  runApp(const MyApp());
}
```

### 3. 基础用法示例

#### 方式一：使用便捷工具类

```dart
import 'package:flutter/material.dart';
import '../utils/image_upload_helper.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // 显示选择对话框（相机/相册）
        final url = await ImageUploadHelper.showImageSourceDialog(
          context,
          bucket: 'user-uploads',
          folder: 'my-photos',
        );
        
        if (url != null) {
          print('上传成功: $url');
          // 保存 URL 到数据库或状态管理
        }
      },
      child: const Text('上传图片'),
    );
  }
}
```

#### 方式二：直接使用服务类

```dart
import 'dart:io';
import '../services/image_upload_service.dart';

Future<void> uploadImage(File imageFile) async {
  final service = ImageUploadService();
  
  try {
    final url = await service.uploadImage(
      imageFile: imageFile,
      bucket: 'user-uploads',
      compress: true,
      quality: 85,
      onProgress: (sent, total) {
        print('进度: ${(sent / total * 100).toInt()}%');
      },
    );
    
    print('上传成功: $url');
  } catch (e) {
    print('上传失败: $e');
  }
}
```

#### 方式三：使用 Widget

```dart
import '../utils/image_upload_helper.dart';

ImageUploadWidget(
  bucket: 'user-uploads',
  folder: 'photos',
  showProgress: true,
  onUploadSuccess: (url) {
    print('上传成功: $url');
    // 保存 URL
  },
  onUploadError: (error) {
    print('上传失败: $error');
    // 显示错误提示
  },
)
```

### 4. 高级用法

#### 批量上传

```dart
final urls = await ImageUploadHelper.pickMultipleAndUpload(
  bucket: 'user-uploads',
  folder: 'gallery',
  maxImages: 9,
  onProgress: (current, total) {
    print('已上传: $current/$total');
  },
);

print('上传完成: ${urls.length} 张图片');
```

#### 头像上传（优化版）

```dart
final avatarUrl = await ImageUploadHelper.uploadAvatar(context);

if (avatarUrl != null) {
  // 保存头像 URL 到用户资料
  await updateUserAvatar(avatarUrl);
}
```

#### 上传并保存到后端

```dart
final result = await ImageUploadService().uploadAndSaveImage(
  imageFile: imageFile,
  saveEndpoint: '/cities/123/user-content/photos',
  bucket: 'city-photos',
  additionalData: {
    'description': '美丽的风景',
    'tags': ['景点', '旅游'],
  },
);

print('图片 URL: ${result['imageUrl']}');
```

## 🎯 完整示例：添加 Coworking 照片

将以下代码添加到 `add_coworking_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../utils/image_upload_helper.dart';

class AddCoworkingPage extends StatefulWidget {
  @override
  State<AddCoworkingPage> createState() => _AddCoworkingPageState();
}

class _AddCoworkingPageState extends State<AddCoworkingPage> {
  final List<String> _uploadedPhotos = [];
  bool _uploading = false;

  Future<void> _addPhoto() async {
    if (_uploading) return;

    setState(() => _uploading = true);

    try {
      final url = await ImageUploadHelper.showImageSourceDialog(
        context,
        bucket: 'coworking-photos',
        folder: 'submissions',
        compress: true,
      );

      if (url != null) {
        setState(() {
          _uploadedPhotos.add(url);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('照片上传成功')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _addMultiplePhotos() async {
    if (_uploading) return;

    setState(() => _uploading = true);

    try {
      final urls = await ImageUploadHelper.pickMultipleAndUpload(
        bucket: 'coworking-photos',
        folder: 'submissions',
        maxImages: 9,
        compress: true,
        onProgress: (current, total) {
          // 可以显示进度对话框
          print('上传进度: $current/$total');
        },
      );

      if (urls.isNotEmpty) {
        setState(() {
          _uploadedPhotos.addAll(urls);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功上传 ${urls.length} 张照片')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加共享办公空间')),
      body: Column(
        children: [
          // 照片网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _uploadedPhotos.length + 1,
              itemBuilder: (context, index) {
                if (index == _uploadedPhotos.length) {
                  // 添加按钮
                  return GestureDetector(
                    onTap: _uploading ? null : _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _uploading
                          ? const Center(child: CircularProgressIndicator())
                          : const Icon(Icons.add_photo_alternate, size: 48),
                    ),
                  );
                }

                // 照片缩略图
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _uploadedPhotos[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _addMultiplePhotos,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('批量上传'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploadedPhotos.isEmpty ? null : () {
                      // 提交表单，包含照片 URLs
                      print('照片列表: $_uploadedPhotos');
                    },
                    child: const Text('提交'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Supabase Storage 配置

### 创建 Storage Buckets

在 Supabase Dashboard 执行：

1. 进入 **Storage** → **Create a new bucket**
2. 创建以下 buckets：
   - `avatars` - 用户头像
   - `city-photos` - 城市照片
   - `coworking-photos` - 共享办公空间照片
   - `user-uploads` - 其他用户上传内容

3. 设置为 **Public** 访问（如果需要公开访问）

### 配置 Row Level Security (RLS)

```sql
-- 允许用户上传到自己的目录
CREATE POLICY "Users can upload own files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'user-uploads' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 允许用户删除自己的文件
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'user-uploads' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 允许所有人查看公开文件
CREATE POLICY "Public files are viewable"
ON storage.objects FOR SELECT
USING (bucket_id IN ('avatars', 'city-photos', 'coworking-photos'));
```

## 📦 依赖包

已添加到 `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  flutter_image_compress: ^2.3.0
  mime: ^1.0.5
  image_picker: ^1.0.7  # 已有
```

**记得运行**: `flutter pub get`

## 🎨 特性说明

### 图片压缩
- 默认质量: 85%
- 默认最大尺寸: 1920x1920
- 头像专用: 512x512, 90% 质量
- 自动选择压缩格式（JPEG/PNG/WebP）

### 错误处理
- 文件不存在检查
- 文件大小限制（20MB）
- 文件类型验证
- 上传失败自动清理
- 详细的日志输出

### 安全性
- 使用 Supabase RLS 控制权限
- 文件名自动生成（防止冲突）
- MIME 类型检测
- 文件大小验证

## 🔄 后续集成

### 保存 URL 到后端

需要在后端添加 API 端点来保存图片 URL：

```csharp
// CoworkingController.cs
[HttpPost("user-content/photos")]
public async Task<IActionResult> AddPhoto([FromBody] AddPhotoRequest request)
{
    var userId = User.GetUserId();
    
    // 验证 URL 是否来自 Supabase
    if (!request.ImageUrl.Contains("supabase.co/storage"))
    {
        return BadRequest("Invalid image URL");
    }
    
    // 保存到数据库
    var photo = new CoworkingPhoto
    {
        UserId = userId,
        ImageUrl = request.ImageUrl,
        FileName = request.FileName,
        FileSize = request.FileSize,
        MimeType = request.MimeType,
    };
    
    await _repository.AddPhotoAsync(photo);
    
    return Ok(photo);
}
```

## 📝 注意事项

1. **首次使用前**必须在 `supabase_config.dart` 配置 URL 和 Key
2. 在 `main.dart` 中调用 `initialize()`
3. 确保已运行 `flutter pub get` 安装依赖
4. 在 Supabase 创建对应的 Storage Buckets
5. 配置 RLS 策略确保安全性

## 🎯 完成状态

- ✅ Supabase 配置管理
- ✅ 图片上传核心服务
- ✅ 图片压缩功能
- ✅ 便捷工具类
- ✅ 上传 Widget
- ✅ 错误处理
- ✅ 批量上传
- ✅ 进度回调
- ✅ 完整示例代码
- ⏳ Supabase 项目配置（需用户操作）
- ⏳ 后端 API 集成（需后端开发）

## 🚀 下一步

1. 在 Supabase 创建项目并配置凭证
2. 创建 Storage Buckets
3. 配置 RLS 策略
4. 在 Flutter 项目中配置 `supabase_config.dart`
5. 运行 `flutter pub get`
6. 在 `main.dart` 初始化服务
7. 在需要的页面使用上传功能
8. 后端添加保存图片 URL 的 API
