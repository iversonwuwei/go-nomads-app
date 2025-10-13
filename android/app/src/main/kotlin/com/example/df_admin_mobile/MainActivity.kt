package com.example.df_admin_mobile

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.ServiceSettings

class MainActivity: FlutterActivity() {
    private val CHANNEL_NAME = "com.example.df_admin_mobile/amap"
    private val MAP_PICKER_REQUEST_CODE = 1001
    
    private var pendingResult: MethodChannel.Result? = null
    
    companion object {
        private var privacyInitialized = false
        
        @Synchronized
        fun ensurePrivacyCompliance(activity: Activity) {
            if (!privacyInitialized) {
                try {
                    Log.e("MainActivity", "🔧 Setting Amap privacy compliance...")
                    MapsInitializer.updatePrivacyShow(activity, true, true)
                    MapsInitializer.updatePrivacyAgree(activity, true)
                    ServiceSettings.updatePrivacyShow(activity, true, true)
                    ServiceSettings.updatePrivacyAgree(activity, true)
                    privacyInitialized = true
                    Log.e("MainActivity", "✅ Privacy compliance set!")
                } catch (e: Exception) {
                    Log.e("MainActivity", "❌ Failed to set privacy compliance", e)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // ⚡ 在Flutter引擎配置时就设置隐私合规
        ensurePrivacyCompliance(this)
        
        // 注册高德地图城市展示视图
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("amap_city_view", AmapCityViewFactory())
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "test" -> {
                    result.success("Native Android Amap connected ✅")
                }
                
                "openMapPicker" -> {
                    openMapPicker(call.arguments, result)
                }
                
                "getCurrentLocation" -> {
                    getCurrentLocation(result)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openMapPicker(arguments: Any?, result: MethodChannel.Result) {
        pendingResult = result
        
        val intent = Intent(this, AmapMapPickerActivity::class.java)
        
        // 传递初始坐标
        if (arguments is Map<*, *>) {
            val initialLat = arguments["initialLatitude"] as? Double
            val initialLng = arguments["initialLongitude"] as? Double
            
            if (initialLat != null && initialLng != null) {
                intent.putExtra(AmapMapPickerActivity.KEY_INITIAL_LATITUDE, initialLat)
                intent.putExtra(AmapMapPickerActivity.KEY_INITIAL_LONGITUDE, initialLng)
            }
        }
        
        startActivityForResult(intent, MAP_PICKER_REQUEST_CODE)
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        // 简单实现：返回北京天安门坐标
        // 后续可以集成定位服务获取真实位置
        val locationData = mapOf(
            "latitude" to 39.909187,
            "longitude" to 116.397451,
            "address" to "Tiananmen Square, Beijing",
            "city" to "Beijing",
            "province" to "Beijing"
        )
        result.success(locationData)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == MAP_PICKER_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val latitude = data.getDoubleExtra(AmapMapPickerActivity.KEY_RESULT_LATITUDE, 0.0)
                val longitude = data.getDoubleExtra(AmapMapPickerActivity.KEY_RESULT_LONGITUDE, 0.0)
                val address = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_ADDRESS) ?: ""
                val city = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_CITY) ?: ""
                val province = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_PROVINCE) ?: ""
                
                val resultData = mapOf(
                    "latitude" to latitude,
                    "longitude" to longitude,
                    "address" to address,
                    "city" to city,
                    "province" to province
                )
                
                pendingResult?.success(resultData)
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }
}
