package com.gonomads.go_nomads_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

/**
 * 高德定位服务
 * 使用原生 AMapLocationClient 实现精准定位
 */
class AmapLocationService(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, AMapLocationListener {

    companion object {
        private const val TAG = "AmapLocationService"
        private const val CHANNEL_NAME = "com.gonomads.df_admin_mobile/amap_location"
    }

    private val methodChannel: MethodChannel = MethodChannel(messenger, CHANNEL_NAME)
    private var locationClient: AMapLocationClient? = null
    private var pendingResult: MethodChannel.Result? = null

    init {
        methodChannel.setMethodCallHandler(this)
        initLocationClient()
    }

    /**
     * 初始化定位客户端
     */
    private fun initLocationClient() {
        try {
            // 高德隐私合规 - 必须在初始化前调用
            AMapLocationClient.updatePrivacyShow(context, true, true)
            AMapLocationClient.updatePrivacyAgree(context, true)

            locationClient = AMapLocationClient(context.applicationContext)
            locationClient?.setLocationListener(this)

            Log.i(TAG, "✅ 高德定位客户端初始化成功")
        } catch (e: Exception) {
            Log.e(TAG, "❌ 高德定位客户端初始化失败: ${e.message}")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCurrentLocation" -> getCurrentLocation(result)
            "startContinuousLocation" -> startContinuousLocation(result)
            "stopContinuousLocation" -> stopContinuousLocation(result)
            "checkPermission" -> checkLocationPermission(result)
            else -> result.notImplemented()
        }
    }

    /**
     * 获取当前位置（单次定位）
     */
    private fun getCurrentLocation(result: MethodChannel.Result) {
        Log.i(TAG, "📍 开始获取当前位置...")

        // 检查权限
        if (!hasLocationPermission()) {
            Log.w(TAG, "⚠️ 没有位置权限")
            result.error("PERMISSION_DENIED", "未授予位置权限", null)
            return
        }

        // 检查定位客户端
        if (locationClient == null) {
            initLocationClient()
            if (locationClient == null) {
                result.error("INIT_FAILED", "定位客户端初始化失败", null)
                return
            }
        }

        // 保存待返回的 result
        pendingResult = result

        // 配置定位参数 - 单次高精度定位
        val option = AMapLocationClientOption().apply {
            // 定位模式：高精度模式（同时使用GPS和网络定位）
            locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy

            // 单次定位
            isOnceLocation = true

            // 单次定位最近3秒内的GPS缓存结果优先使用
            isOnceLocationLatest = true

            // 设置定位超时时间，默认30秒
            httpTimeOut = 30000

            // 设置是否返回地址信息（需要联网）
            isNeedAddress = true

            // 设置定位间隔（连续定位时使用）
            interval = 2000

            // 设置是否允许模拟位置
            isMockEnable = false

            // 设置是否使用传感器（室内定位）
            isSensorEnable = true

            // GPS定位优先
            isGpsFirst = true

            // GPS定位最长等待时间
            gpsFirstTimeout = 10000
        }

        locationClient?.setLocationOption(option)
        locationClient?.startLocation()

        Log.i(TAG, "📡 定位请求已发送，等待回调...")
    }

    /**
     * 开始连续定位
     */
    private fun startContinuousLocation(result: MethodChannel.Result) {
        if (!hasLocationPermission()) {
            result.error("PERMISSION_DENIED", "未授予位置权限", null)
            return
        }

        if (locationClient == null) {
            initLocationClient()
        }

        val option = AMapLocationClientOption().apply {
            locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
            isOnceLocation = false
            interval = 3000
            isNeedAddress = true
            isSensorEnable = true
        }

        locationClient?.setLocationOption(option)
        locationClient?.startLocation()

        result.success(mapOf("success" to true, "message" to "连续定位已启动"))
    }

    /**
     * 停止连续定位
     */
    private fun stopContinuousLocation(result: MethodChannel.Result) {
        locationClient?.stopLocation()
        result.success(mapOf("success" to true, "message" to "连续定位已停止"))
    }

    /**
     * 检查位置权限
     */
    private fun checkLocationPermission(result: MethodChannel.Result) {
        val hasPermission = hasLocationPermission()
        result.success(mapOf("hasPermission" to hasPermission))
    }

    /**
     * 判断是否有位置权限
     */
    private fun hasLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * 定位回调
     */
    override fun onLocationChanged(location: AMapLocation?) {
        val result = pendingResult
        pendingResult = null

        if (location == null) {
            Log.e(TAG, "❌ 定位返回 null")
            result?.error("LOCATION_NULL", "定位结果为空", null)
            return
        }

        if (location.errorCode != 0) {
            Log.e(TAG, "❌ 定位失败: ${location.errorCode} - ${location.errorInfo}")
            result?.error(
                "LOCATION_ERROR",
                "定位失败: ${location.errorInfo}",
                mapOf(
                    "errorCode" to location.errorCode,
                    "errorInfo" to location.errorInfo
                )
            )
            return
        }

        // 定位成功
        Log.i(TAG, "✅ 定位成功: ${location.latitude}, ${location.longitude}")
        Log.i(TAG, "   地址: ${location.address}")
        Log.i(TAG, "   城市: ${location.city}")
        Log.i(TAG, "   区县: ${location.district}")
        Log.i(TAG, "   街道: ${location.street}")
        Log.i(TAG, "   定位类型: ${location.locationType}")

        val locationData = mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy,
            "address" to (location.address ?: ""),
            "country" to (location.country ?: ""),
            "province" to (location.province ?: ""),
            "city" to (location.city ?: ""),
            "cityCode" to (location.cityCode ?: ""),
            "district" to (location.district ?: ""),
            "adCode" to (location.adCode ?: ""),
            "street" to (location.street ?: ""),
            "streetNum" to (location.streetNum ?: ""),
            "poiName" to (location.poiName ?: ""),
            "aoiName" to (location.aoiName ?: ""),
            "locationType" to location.locationType,
            "description" to (location.description ?: ""),
            "errorCode" to 0
        )

        result?.success(locationData)

        // 如果有持续监听，发送位置更新事件
        // methodChannel.invokeMethod("onLocationUpdate", locationData)
    }

    /**
     * 销毁资源
     */
    fun destroy() {
        locationClient?.stopLocation()
        locationClient?.onDestroy()
        locationClient = null
        methodChannel.setMethodCallHandler(null)
        Log.i(TAG, "🗑️ 定位服务已销毁")
    }
}
