# QQ SDK (tencent_kit) 依赖 OkHttp 但未直接打包，R8 会报 missing class
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.tencent.**
-keep class com.tencent.** { *; }
