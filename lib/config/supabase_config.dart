/// Supabase 配置
/// 
/// 请在项目中创建 .env 文件或在此处直接配置 Supabase 凭证
class SupabaseConfig {
  /// Supabase 项目 URL
  /// 
  /// 格式: https://your-project-id.supabase.co
  /// 从 Supabase Dashboard → Settings → API 获取
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lcfbajrocmjlqndkrsao.supabase.co',
  );

  /// Supabase Anon (Public) Key
  /// 
  /// 从 Supabase Dashboard → Settings → API → Project API keys 获取
  /// 这是公开密钥，可以安全地在客户端使用
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjZmJhanJvY21qbHFuZGtyc2FvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3MTg1MjUsImV4cCI6MjA3NjI5NDUyNX0.-aYrl3f6AAhURF025S_4NwvehfugUiG3VR-wvZe3mRU',
  );

  /// 存储桶配置
  static const String defaultBucket = 'user-uploads';
  
  /// 各类型内容的存储桶
  static const Map<String, String> buckets = {
    'avatars': 'avatars',           // 用户头像
    'cityPhotos': 'city-photos',    // 城市照片
    'coworkingPhotos': 'coworking-photos', // 共享办公空间照片
    'userContent': 'user-uploads',  // 用户上传的其他内容
  };

  /// 图片压缩配置
  static const int defaultQuality = 85;
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int maxFileSize = 20 * 1024 * 1024; // 20MB

  /// 头像专用配置
  static const int avatarQuality = 90;
  static const int avatarMaxSize = 512;

  /// 是否已配置
  static bool get isConfigured {
    return url != 'https://your-project.supabase.co' &&
           anonKey != 'your-anon-key-here' &&
           url.isNotEmpty &&
           anonKey.isNotEmpty;
  }
}
