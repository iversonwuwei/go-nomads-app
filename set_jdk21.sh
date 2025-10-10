#!/bin/bash
# JDK 21 环境设置脚本
# 在项目根目录运行: source ./set_jdk21.sh

echo "🔧 Setting up JDK 21 for Flutter Android build..."

# 检查是否为 macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS 系统
    export JAVA_HOME=$(/usr/libexec/java_home -v 21)
    
    if [ $? -eq 0 ]; then
        echo "✅ JAVA_HOME set to: $JAVA_HOME"
        java -version
        echo ""
        echo "📋 环境变量已设置（当前终端会话有效）"
        echo "💡 要永久设置，请添加以下内容到 ~/.zshrc 或 ~/.bash_profile:"
        echo "   export JAVA_HOME=\$(/usr/libexec/java_home -v 21)"
        echo "   export PATH=\$JAVA_HOME/bin:\$PATH"
    else
        echo "❌ JDK 21 not found. Please install JDK 21 first."
        echo "   brew install openjdk@21"
        exit 1
    fi
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux 系统
    JDK21_PATH=$(update-alternatives --list java | grep java-21 | head -n 1 | sed 's/\/bin\/java//')
    
    if [ -n "$JDK21_PATH" ]; then
        export JAVA_HOME=$JDK21_PATH
        echo "✅ JAVA_HOME set to: $JAVA_HOME"
        java -version
    else
        echo "❌ JDK 21 not found. Please install JDK 21 first."
        echo "   sudo apt install openjdk-21-jdk"
        exit 1
    fi
    
else
    echo "❌ Unsupported OS: $OSTYPE"
    echo "Please set JAVA_HOME manually to your JDK 21 installation path."
    exit 1
fi

# 添加到 PATH
export PATH=$JAVA_HOME/bin:$PATH

echo ""
echo "🚀 Ready to build! You can now run:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter build apk"
