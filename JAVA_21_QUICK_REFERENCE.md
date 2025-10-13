# Java 21 快速参考指南

## ✅ 当前状态

```bash
Java: 21.0.5 LTS
Gradle: 8.10.2
Kotlin: 1.9.24
```

## 🔧 常用命令

### 检查 Java 版本
```bash
java -version
```

### 检查 Gradle 版本
```bash
cd android && ./gradlew --version
```

### 清理并重新构建
```bash
# Flutter 清理
flutter clean
flutter pub get

# Android 清理
cd android
./gradlew clean
./gradlew build
```

### 构建 APK
```bash
flutter build apk --debug
flutter build apk --release
```

## 📋 配置文件位置

| 文件 | 路径 | 用途 |
|------|------|------|
| build.gradle | `android/app/build.gradle` | Java 版本配置 |
| gradle.properties | `android/gradle.properties` | JVM 参数配置 |
| gradle-wrapper | `android/gradle/wrapper/gradle-wrapper.properties` | Gradle 版本 |

## ⚙️ Java 21 配置

### android/app/build.gradle
```gradle
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

kotlinOptions {
    jvmTarget = "21"
}
```

### android/gradle.properties
```properties
org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

## 🚨 故障排除

### 问题: Java 版本不匹配
```bash
# 检查 JAVA_HOME
echo $JAVA_HOME

# 设置 JAVA_HOME (macOS)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# 重启 Gradle Daemon
cd android
./gradlew --stop
./gradlew --version
```

### 问题: 构建失败
```bash
# 1. 清理缓存
flutter clean
cd android
./gradlew clean

# 2. 删除 build 目录
rm -rf build/
rm -rf android/.gradle/

# 3. 重新获取依赖
flutter pub get
cd android
./gradlew build --refresh-dependencies
```

### 问题: 内存溢出
在 `android/gradle.properties` 中增加内存:
```properties
org.gradle.jvmargs=-Xmx6G -XX:+HeapDumpOnOutOfMemoryError
```

## 🔍 验证清单

- [ ] `java -version` 显示 21.0.5
- [ ] `echo $JAVA_HOME` 指向 JDK 21
- [ ] `./gradlew --version` 显示 JVM 21
- [ ] `flutter doctor` 无错误
- [ ] 项目可以正常构建

## 📚 相关文档

- [Java 21 升级完成报告](JAVA_21_LTS_UPGRADE_COMPLETE.md)
- [Oracle Java 21 文档](https://docs.oracle.com/en/java/javase/21/)
- [Gradle 8.x 文档](https://docs.gradle.org/8.10.2/userguide/userguide.html)
