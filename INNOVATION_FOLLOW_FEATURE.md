# 创意项目关注功能实现文档

## 概述
为创意列表页面和创意详情页面添加了关注/收藏功能,允许用户关注感兴趣的创意项目。

## 实现文件

### 1. 创意列表页面 (innovation_list_page.dart)

#### 关键修改
- **从 StatelessWidget 改为 StatefulWidget**
- 添加关注状态管理: `Map<String, bool> _followedProjects = {}`
- 在项目卡片图片上添加悬浮关注按钮

#### 关注按钮设计
- **位置**: 右上角悬浮于项目图片之上
- **样式**: 
  - 未关注: 白色背景 + 灰色文字 + 空心心形图标
  - 已关注: 紫色背景 (#8B5CF6) + 白色文字 + 实心心形图标
- **交互**: 点击切换状态,显示 SnackBar 反馈

#### 代码结构
```dart
class InnovationListPage extends StatefulWidget {
  final Map<String, bool> _followedProjects = {};
  
  Widget _buildFollowButton(String projectId) {
    final isFollowed = _followedProjects[projectId] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: isFollowed 
            ? const Color(0xFF8B5CF6) 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleFollow(projectId),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, 
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFollowed ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFollowed 
                      ? Colors.white 
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  isFollowed ? '已关注' : '关注',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFollowed 
                        ? Colors.white 
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _toggleFollow(String projectId) {
    setState(() {
      _followedProjects[projectId] = 
          !(_followedProjects[projectId] ?? false);
    });
    
    final isFollowed = _followedProjects[projectId] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowed ? '已关注项目' : '已取消关注',
          style: const TextStyle(fontSize: 15),
        ),
        backgroundColor: isFollowed 
            ? const Color(0xFF8B5CF6) 
            : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

### 2. 创意详情页面 (innovation_detail_page.dart)

#### 关键修改
- **从 StatelessWidget 改为 StatefulWidget**
- 添加关注状态: `bool _isFollowed = false`
- 所有 `project` 引用改为 `widget.project` (StatefulWidget 要求)
- 底部栏添加关注按钮

#### 关注按钮设计
- **位置**: 底部栏左侧,联系按钮旁边
- **样式**:
  - 未关注: 边框按钮 + 灰色边框 + 空心心形图标
  - 已关注: 边框按钮 + 紫色边框 (#8B5CF6) + 实心心形图标
- **布局**: 关注按钮(flex: 1) + 联系按钮(flex: 2)

#### 代码结构
```dart
class _InnovationDetailPageState extends State<InnovationDetailPage> {
  bool _isFollowed = false;

  void _toggleFollow() {
    setState(() {
      _isFollowed = !_isFollowed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowed ? '已关注项目' : '已取消关注',
          style: const TextStyle(fontSize: 15),
        ),
        backgroundColor: _isFollowed 
            ? const Color(0xFF8B5CF6) 
            : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Row(
          children: [
            // 关注按钮
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: _toggleFollow,
                icon: Icon(
                  _isFollowed ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                ),
                label: Text(_isFollowed ? '已关注' : '关注'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isFollowed 
                      ? const Color(0xFF8B5CF6) 
                      : Colors.grey[700],
                  side: BorderSide(
                    color: _isFollowed 
                        ? const Color(0xFF8B5CF6) 
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 联系按钮
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _contactCreator(context),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l10n.message),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 设计规范

### 配色方案
- **主色调**: 紫色 #8B5CF6 (与创意功能主题色一致)
- **未关注状态**: 
  - 列表页: 白色背景 + 灰色文字
  - 详情页: 灰色边框 + 灰色文字
- **已关注状态**: 紫色背景/边框 + 白色文字

### 图标使用
- **未关注**: `Icons.favorite_border` (空心心形)
- **已关注**: `Icons.favorite` (实心心形)

### 用户反馈
- **SnackBar 提示**:
  - 关注成功: "已关注项目" (紫色背景)
  - 取消关注: "已取消关注" (灰色背景)
  - 显示时长: 2 秒
  - 样式: 浮动式 + 圆角

## 状态管理

### 当前实现
- **列表页**: 使用 `Map<String, bool>` 管理多个项目的关注状态
- **详情页**: 使用 `bool` 管理单个项目的关注状态
- **生命周期**: 状态仅在当前页面会话中保持,退出后重置

### 局限性
1. **状态不持久化**: 
   - 关闭应用后状态丢失
   - 列表页和详情页状态不同步

2. **无后端集成**: 
   - 未调用实际 API
   - 未存储到数据库

## 未来改进方向

### 1. 状态持久化
```dart
// 使用 SharedPreferences 或 Hive
class FollowService {
  static const String _key = 'followed_projects';
  
  Future<void> followProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final followed = prefs.getStringList(_key) ?? [];
    if (!followed.contains(projectId)) {
      followed.add(projectId);
      await prefs.setStringList(_key, followed);
    }
  }
  
  Future<void> unfollowProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final followed = prefs.getStringList(_key) ?? [];
    followed.remove(projectId);
    await prefs.setStringList(_key, followed);
  }
  
  Future<bool> isFollowed(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final followed = prefs.getStringList(_key) ?? [];
    return followed.contains(projectId);
  }
}
```

### 2. 状态同步
- 使用 Provider/Riverpod 全局状态管理
- 列表页和详情页共享同一状态源
- 实时更新所有相关页面

### 3. 后端集成
```dart
class FollowApi {
  Future<void> followProject(String userId, String projectId) async {
    await http.post(
      Uri.parse('$baseUrl/api/projects/$projectId/follow'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
  
  Future<List<String>> getFollowedProjects(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/followed-projects'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return (jsonDecode(response.body) as List).cast<String>();
  }
}
```

### 4. 功能扩展
- **关注数显示**: 显示项目被关注的总数
- **关注列表页**: 专门页面查看所有已关注项目
- **关注通知**: 关注的项目有更新时推送通知
- **关注者列表**: 查看谁关注了这个项目
- **取消关注确认**: 添加确认对话框防止误操作

## 测试建议

### 功能测试
1. 列表页关注按钮点击测试
2. 详情页关注按钮点击测试
3. 状态切换动画流畅性
4. SnackBar 提示正确性
5. 图标和颜色变化正确性

### 边界测试
1. 快速连续点击关注按钮
2. 同时关注多个项目
3. 从列表页进入详情页后状态一致性
4. 退出应用后重新进入状态重置

### UI 测试
1. 不同屏幕尺寸下按钮显示
2. 长文本项目名称不影响布局
3. 深色模式下按钮可见性
4. 按钮点击区域足够大

## 总结
成功为创意功能添加了完整的关注系统,提升了用户参与度和项目互动性。当前实现满足基本需求,为后续扩展预留了充足空间。
