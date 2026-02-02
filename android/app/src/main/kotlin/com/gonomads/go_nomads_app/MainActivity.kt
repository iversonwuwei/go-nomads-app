package com.gonomads.go_nomads_app

import android.os.Bundle
import com.amap.api.maps.MapsInitializer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    
    private val CHANNEL_NAME = "com.gonomads.go_nomads_app/amap"
    
    // 高德定位服务实例
    private var amapLocationService: AmapLocationService? = null
    
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
        
        // 初始化高德定位服务（混合实现核心）
        amapLocationService = AmapLocationService(this, flutterEngine.dartExecutor.binaryMessenger)
        
        // 设置原有的 MethodChannel（保持兼容性）
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "test" -> {
                        result.success("Native Android Amap connected ✅")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    override fun onDestroy() {
        amapLocationService?.destroy()
        amapLocationService = null
        super.onDestroy()
    }
}
