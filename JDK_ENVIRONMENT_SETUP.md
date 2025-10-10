# 🔧 JDK 环境配置指南

## ✅ 已完成的优化

### 问题描述
之前在 `android/gradle.properties` 中使用了绝对路径配置 JDK：
```properties
# ❌ 不推荐：硬编码绝对路径
org.gradle.java.home=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
```

这种配置方式存在以下问题：
- ❌ 仅适用于 macOS 系统
- ❌ 其他开发者的 JDK 安装路径可能不同
- ❌ Windows/Linux 系统会找不到 JDK
- ❌ CI/CD 环境无法正常构建

### 解决方案
现在已改为使用环境变量 `JAVA_HOME`，实现跨平台兼容。

---

## 📋 开发环境配置要求

### 1. JDK 版本要求
本项目需要 **Java 21 LTS**

### 2. 环境变量配置

#### macOS / Linux

##### 方法 1: 使用 java_home 工具（macOS）
```bash
# 查看已安装的 JDK 版本
/usr/libexec/java_home -V

# 设置 JAVA_HOME (临时)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# 永久设置 (添加到 ~/.zshrc 或 ~/.bash_profile)
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

##### 方法 2: 直接指定路径（macOS/Linux）
```bash
# 找到 JDK 21 安装路径
ls /Library/Java/JavaVirtualMachines/  # macOS
ls /usr/lib/jvm/                         # Linux

# 添加到 ~/.zshrc 或 ~/.bashrc
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
```

#### Windows

##### 方法 1: 图形界面设置
1. 右键 "此电脑" → "属性"
2. 点击 "高级系统设置"
3. 点击 "环境变量"
4. 在 "系统变量" 中点击 "新建"
   - 变量名: `JAVA_HOME`
   - 变量值: `C:\Program Files\Java\jdk-21` (根据实际安装路径)
5. 编辑 `Path` 变量，添加 `%JAVA_HOME%\bin`

##### 方法 2: 命令行设置（需要管理员权限）
```cmd
# 临时设置
set JAVA_HOME=C:\Program Files\Java\jdk-21
set PATH=%JAVA_HOME%\bin;%PATH%

# 永久设置
setx JAVA_HOME "C:\Program Files\Java\jdk-21"
setx PATH "%JAVA_HOME%\bin;%PATH%"
```

##### 方法 3: PowerShell 设置
```powershell
# 临时设置
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# 永久设置（需要管理员权限）
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-21', 'Machine')
[System.Environment]::SetEnvironmentVariable('PATH', "$env:JAVA_HOME\bin;$env:PATH", 'Machine')
```

---

## ✅ 验证配置

### 检查 JAVA_HOME
```bash
# macOS/Linux
echo $JAVA_HOME

# Windows CMD
echo %JAVA_HOME%

# Windows PowerShell
echo $env:JAVA_HOME
```

### 检查 Java 版本
```bash
java -version
```

应该看到类似输出：
```
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM (build 21.0.5+11-LTS, mixed mode, sharing)
```

### 检查 Gradle 使用的 JDK
```bash
cd android
./gradlew -version
```

应该显示 Java 21。

---

## 🚀 项目构建步骤

### 首次配置

1. **安装 JDK 21**
   - macOS: `brew install openjdk@21`
   - Windows: 从 [Oracle](https://www.oracle.com/java/technologies/downloads/) 或 [Adoptium](https://adoptium.net/) 下载
   - Linux: `sudo apt install openjdk-21-jdk` (Ubuntu/Debian)

2. **配置环境变量**
   - 按照上面的说明设置 `JAVA_HOME`

3. **创建 local.properties**
   ```bash
   cd android
   cp local.properties.template local.properties
   # 编辑 local.properties，填入你的本地路径
   ```

4. **验证配置**
   ```bash
   java -version
   echo $JAVA_HOME  # 或 Windows: echo %JAVA_HOME%
   ```

5. **运行项目**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 🔍 常见问题

### 问题 1: "Could not find or load main class"
**原因**: JAVA_HOME 未设置或设置错误

**解决方案**:
```bash
# 检查 JAVA_HOME
echo $JAVA_HOME

# 如果为空或错误，重新设置
export JAVA_HOME=$(/usr/libexec/java_home -v 21)  # macOS
```

### 问题 2: Gradle 使用了错误的 Java 版本
**原因**: 系统默认 Java 版本不是 21

**解决方案**:
```bash
# 临时指定 JDK（在项目根目录）
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
flutter clean
flutter build apk
```

### 问题 3: Windows 上环境变量不生效
**原因**: 需要重启终端或重新登录

**解决方案**:
1. 关闭所有命令行窗口
2. 重新打开命令行
3. 验证: `echo %JAVA_HOME%`

### 问题 4: CI/CD 环境找不到 JDK
**原因**: CI 环境未安装 JDK 21 或未设置 JAVA_HOME

**解决方案** (GitHub Actions 示例):
```yaml
- name: Set up JDK 21
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '21'
    cache: gradle
```

---

## 📁 文件结构说明

### gradle.properties
```properties
# ✅ 不包含绝对路径，依赖 JAVA_HOME 环境变量
org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

### local.properties
```properties
# ⚠️ 包含本地绝对路径，已添加到 .gitignore
sdk.dir=/Users/your-username/Library/Android/sdk
flutter.sdk=/Users/your-username/flutter
```

**注意**: `local.properties` 文件不会被提交到 Git，每个开发者需要根据自己的环境创建。

---

## 🎯 最佳实践

### ✅ 推荐做法
1. **使用环境变量** - JAVA_HOME, ANDROID_HOME, FLUTTER_HOME
2. **忽略 local.properties** - 添加到 .gitignore
3. **提供模板文件** - local.properties.template
4. **文档说明** - README 中说明环境配置要求
5. **CI/CD 配置** - 在 workflow 中明确指定 JDK 版本

### ❌ 避免做法
1. ~~硬编码绝对路径到 gradle.properties~~
2. ~~提交 local.properties 到 Git~~
3. ~~假设所有开发者使用相同的 JDK 安装路径~~
4. ~~不说明 JDK 版本要求~~

---

## 📝 团队协作建议

### README.md 中添加
```markdown
## 开发环境要求

- Flutter SDK: >=3.4.0
- Java: 21 LTS
- Android SDK: API 34+

## 环境配置

1. 安装 JDK 21
2. 设置 JAVA_HOME 环境变量
3. 复制 `android/local.properties.template` 为 `android/local.properties`
4. 填入你的 Android SDK 和 Flutter SDK 路径
5. 运行 `flutter pub get`
```

### 新成员上手清单
- [ ] 安装 JDK 21
- [ ] 配置 JAVA_HOME 环境变量
- [ ] 安装 Android SDK
- [ ] 创建 local.properties 文件
- [ ] 运行 `java -version` 验证
- [ ] 运行 `flutter doctor` 检查环境
- [ ] 执行 `flutter run` 测试

---

## 🔄 迁移指南 (从旧配置升级)

如果你之前使用了绝对路径配置：

### 步骤 1: 备份配置
```bash
cp android/gradle.properties android/gradle.properties.backup
```

### 步骤 2: 移除绝对路径
```bash
# 编辑 android/gradle.properties
# 删除或注释: org.gradle.java.home=/absolute/path/to/jdk
```

### 步骤 3: 设置 JAVA_HOME
```bash
# macOS/Linux
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Windows
setx JAVA_HOME "C:\Program Files\Java\jdk-21"
```

### 步骤 4: 清理重建
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📊 总结

### 修改内容
| 文件 | 修改前 | 修改后 |
|------|--------|--------|
| `gradle.properties` | 硬编码 JDK 绝对路径 | 使用环境变量 JAVA_HOME |
| `.gitignore` | 未忽略 local.properties | 添加 local.properties 到忽略列表 |
| - | - | 新建 local.properties.template |

### 优势
- ✅ 跨平台兼容 (macOS/Windows/Linux)
- ✅ 团队协作友好
- ✅ CI/CD 集成简单
- ✅ 易于维护和升级

### 注意事项
- ⚠️ 每个开发者需要配置 JAVA_HOME
- ⚠️ 每个开发者需要创建 local.properties
- ⚠️ 确保 JDK 21 已正确安装

---

**最后更新**: 2025-10-10
**状态**: ✅ 优化完成
**兼容性**: macOS / Windows / Linux
