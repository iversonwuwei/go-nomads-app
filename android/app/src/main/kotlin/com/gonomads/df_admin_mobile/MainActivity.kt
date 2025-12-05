package com.gonomads.df_admin_mobile

import android.os.Bundle
import com.amap.api.maps.MapsInitializer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    
    private val CHANNEL_NAME = "com.gonomads.df_admin_mobile/amap"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 高德地图隐私合规设置 - 必须在使用任何 SDK 接口前调用
        MapsInitializer.updatePrivacyShow(this, true, true)
        MapsInitializer.updatePrivacyAgree(this, true)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // 注册高德地图全球视图 Platform View
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "amap_global_view",
            AmapGlobalViewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
        
        // 设置 MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "test" -> {
                        result.success("Native Android Amap connected ✅")
                    }
                    "getCurrentLocation" -> {
                        // 简单实现：返回北京天安门坐标
                        // 后续可以集成 AMapLocationClient 获取真实位置
                        val locationData = mapOf(
                            "latitude" to 39.909187,
                            "longitude" to 116.397451,
                            "address" to "Tiananmen Square, Beijing",
                            "city" to "Beijing",
                            "province" to "Beijing"
                        )
                        result.success(locationData)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
