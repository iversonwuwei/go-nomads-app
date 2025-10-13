package com.example.df_admin_mobile

import android.content.Context
import android.util.Log
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MarkerOptions
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/// 高德地图城市展示视图工厂
class AmapCityViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any>
        Log.d("AmapCityViewFactory", "📍 Creating AmapCityView #$viewId with params: $params")
        return AmapCityView(context, viewId, params)
    }
}

/// 高德地图城市展示视图
class AmapCityView(
    private val context: Context,
    private val viewId: Int,
    private val params: Map<String, Any>?
) : PlatformView {
    
    private val TAG = "AmapCityView"
    private val mapView: MapView = MapView(context).apply {
        // 使用apply确保在初始化时设置LayoutParams
        layoutParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
            android.widget.FrameLayout.LayoutParams.MATCH_PARENT
        )
    }
    private var aMap: AMap? = null
    
    init {
        Log.d(TAG, "Initializing map view #$viewId")
        
        try {
            // 按照官方文档推荐的顺序初始化
            mapView.onCreate(null)  // 必须在获取AMap之前调用
            
            // 获取AMap实例
            aMap = mapView.map
            
            if (aMap != null) {
                Log.d(TAG, "✅ AMap instance created successfully")
                
                // 配置地图 - 使用官方推荐的设置
                aMap?.apply {
                    // 设置地图类型
                    mapType = AMap.MAP_TYPE_NORMAL
                    
                    // 设置UI
                    uiSettings.apply {
                        isZoomControlsEnabled = false
                        isScaleControlsEnabled = false
                        isCompassEnabled = false
                        isMyLocationButtonEnabled = false
                        isRotateGesturesEnabled = true
                        isScrollGesturesEnabled = true
                        isTiltGesturesEnabled = false
                        isZoomGesturesEnabled = true
                    }
                    
                    // 显示设置
                    showBuildings(true)
                    showIndoorMap(false)
                    isTrafficEnabled = false
                    
                    // 设置缩放级别范围
                    setMaxZoomLevel(20f)
                    setMinZoomLevel(3f)
                    
                    Log.d(TAG, "Map UI configured")
                }
                
                // 最后调用onResume
                mapView.onResume()
                
                // 设置城市位置
                val cityName = params?.get("cityName") as? String
                Log.d(TAG, "Setting city location: $cityName")
                
                if (cityName != null) {
                    setupCityLocation(cityName)
                } else {
                    // 默认显示曼谷
                    aMap?.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(13.7563, 100.5018), 12f))
                }
                
                Log.d(TAG, "✅ Map initialization complete")
            } else {
                Log.e(TAG, "❌ Failed to get AMap instance!")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Map initialization failed", e)
        }
    }
    
    private fun setupCityLocation(cityName: String) {
        Log.d(TAG, "Setting up location for: $cityName")
        
        // 根据城市名称设置坐标 (这里使用一些常见城市的坐标)
        val cityCoordinates = mapOf(
            "Bangkok" to LatLng(13.7563, 100.5018),
            "Chiang Mai" to LatLng(18.7883, 98.9853),
            "Canggu, Bali" to LatLng(-8.6481, 115.1388),
            "Tokyo" to LatLng(35.6762, 139.6503),
            "Seoul" to LatLng(37.5665, 126.9780),
            "Lisbon" to LatLng(38.7223, -9.1393),
            "Mexico City" to LatLng(19.4326, -99.1332),
            "Singapore" to LatLng(1.3521, 103.8198),
            "Bali" to LatLng(-8.3405, 115.0920),
            "New York" to LatLng(40.7128, -74.0060),
            "London" to LatLng(51.5074, -0.1278),
            "Paris" to LatLng(48.8566, 2.3522),
            "Berlin" to LatLng(52.5200, 13.4050),
            "Barcelona" to LatLng(41.3874, 2.1686),
            "Dubai" to LatLng(25.2048, 55.2708),
            "Hong Kong" to LatLng(22.3193, 114.1694),
            "Shanghai" to LatLng(31.2304, 121.4737),
            "Beijing" to LatLng(39.9042, 116.4074)
        )
        
        val location = cityCoordinates[cityName] ?: LatLng(13.7563, 100.5018) // 默认曼谷
        Log.d(TAG, "Location: ${location.latitude}, ${location.longitude}")
        
        // 移动相机到城市位置
        val cameraPosition = CameraPosition.Builder()
            .target(location)
            .zoom(12f)
            .bearing(0f)
            .tilt(0f)
            .build()
        
        aMap?.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
        
        // 添加标记
        val markerOptions = MarkerOptions()
            .position(location)
            .title(cityName)
            .draggable(false)
        
        aMap?.addMarker(markerOptions)
        Log.d(TAG, "Marker added for $cityName")
    }
    
    override fun getView(): View {
        return mapView
    }
    
    override fun dispose() {
        Log.d(TAG, "Disposing map view #$viewId")
        mapView.onPause()
        mapView.onDestroy()
    }
}
