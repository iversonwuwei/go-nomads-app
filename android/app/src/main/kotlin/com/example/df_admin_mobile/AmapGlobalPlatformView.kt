package com.example.df_admin_mobile

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MarkerOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * 高德地图全球视图工厂
 */
class AmapGlobalViewFactory(private val messenger: BinaryMessenger) : 
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String, Any>
        return AmapGlobalPlatformView(context, viewId, creationParams, messenger)
    }
}

/**
 * 城市标记数据类
 */
data class CityMarkerData(
    val id: Int,
    val name: String,
    val latitude: Double,
    val longitude: Double,
    val country: String,
    val score: Double
)

/**
 * 高德地图全球 Platform View - 显示全球城市分布
 */
class AmapGlobalPlatformView(
    private val context: Context,
    private val viewId: Int,
    private val creationParams: Map<String, Any>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {
    
    private val mapView: MapView = MapView(context)
    private var aMap: AMap? = null
    private val methodChannel: MethodChannel
    private val cities = mutableListOf<CityMarkerData>()
    private val markers = mutableListOf<Marker>()
    
    init {
        // 初始化方法通道
        methodChannel = MethodChannel(messenger, "amap_global_view_$viewId")
        methodChannel.setMethodCallHandler(this)
        
        // 初始化地图
        mapView.onCreate(null)
        aMap = mapView.map
        
        // 配置地图
        configureMap()
    }
    
    private fun configureMap() {
        aMap?.apply {
            // 地图基本设置
            uiSettings.isZoomControlsEnabled = false
            uiSettings.isCompassEnabled = true
            uiSettings.isScaleControlsEnabled = true
            uiSettings.isMyLocationButtonEnabled = false
            
            // 设置地图类型
            mapType = AMap.MAP_TYPE_NORMAL
            
            // 设置初始位置和缩放
            val initialZoom = (creationParams?.get("initialZoom") as? Double)?.toFloat() ?: 2f
            val centerLat = creationParams?.get("centerLatitude") as? Double ?: 20.0
            val centerLng = creationParams?.get("centerLongitude") as? Double ?: 0.0
            
            val cameraPosition = CameraPosition.Builder()
                .target(LatLng(centerLat, centerLng))
                .zoom(initialZoom)
                .build()
            moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
            
            // 设置标记点击监听
            setOnMarkerClickListener { marker ->
                onMarkerClicked(marker)
                true
            }
            
            // 解析并添加城市标记
            @Suppress("UNCHECKED_CAST")
            val citiesData = creationParams?.get("cities") as? List<Map<String, Any>>
            citiesData?.let { updateCities(it) }
        }
    }
    
    override fun getView(): View = mapView
    
    override fun dispose() {
        mapView.onDestroy()
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setZoom" -> {
                val zoom = call.argument<Double>("zoom")?.toFloat()
                if (zoom != null) {
                    aMap?.animateCamera(CameraUpdateFactory.zoomTo(zoom))
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Zoom level required", null)
                }
            }
            "setCenter" -> {
                val lat = call.argument<Double>("latitude")
                val lng = call.argument<Double>("longitude")
                if (lat != null && lng != null) {
                    aMap?.animateCamera(CameraUpdateFactory.newLatLng(LatLng(lat, lng)))
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Latitude and longitude required", null)
                }
            }
            "resetToWorld" -> {
                val worldPosition = CameraPosition.Builder()
                    .target(LatLng(20.0, 0.0))
                    .zoom(2f)
                    .build()
                aMap?.animateCamera(CameraUpdateFactory.newCameraPosition(worldPosition))
                result.success(null)
            }
            "updateCities" -> {
                @Suppress("UNCHECKED_CAST")
                val citiesData = call.argument<List<Map<String, Any>>>("cities")
                if (citiesData != null) {
                    updateCities(citiesData)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Cities data required", null)
                }
            }
            else -> result.notImplemented()
        }
    }
    
    private fun updateCities(citiesData: List<Map<String, Any>>) {
        // 清除现有标记
        markers.forEach { it.remove() }
        markers.clear()
        cities.clear()
        
        // 解析城市数据
        for (cityData in citiesData) {
            val id = (cityData["id"] as? Number)?.toInt() ?: continue
            val name = cityData["name"] as? String ?: continue
            val lat = (cityData["latitude"] as? Number)?.toDouble() ?: continue
            val lng = (cityData["longitude"] as? Number)?.toDouble() ?: continue
            val country = cityData["country"] as? String ?: ""
            val score = (cityData["score"] as? Number)?.toDouble() ?: 0.0
            
            val city = CityMarkerData(id, name, lat, lng, country, score)
            cities.add(city)
            
            // 创建标记
            val markerColor = getMarkerColor(score)
            val markerOptions = MarkerOptions()
                .position(LatLng(lat, lng))
                .title(name)
                .snippet(country)
                .icon(BitmapDescriptorFactory.defaultMarker(markerColor))
            
            aMap?.addMarker(markerOptions)?.let { marker ->
                markers.add(marker)
            }
        }
        
        android.util.Log.d("AmapGlobal", "Added ${markers.size} city markers to AMap")
    }
    
    private fun getMarkerColor(score: Double): Float {
        return when {
            score >= 4.0 -> BitmapDescriptorFactory.HUE_GREEN
            score >= 3.0 -> BitmapDescriptorFactory.HUE_VIOLET
            else -> BitmapDescriptorFactory.HUE_RED
        }
    }
    
    private fun onMarkerClicked(marker: Marker) {
        // 查找对应的城市
        val index = markers.indexOf(marker)
        if (index >= 0 && index < cities.size) {
            val city = cities[index]
            methodChannel.invokeMethod("onCityTapped", mapOf(
                "id" to city.id,
                "name" to city.name,
                "latitude" to city.latitude,
                "longitude" to city.longitude,
                "country" to city.country,
                "score" to city.score
            ))
        }
    }
    
    // 生命周期方法
    fun onResume() {
        mapView.onResume()
    }
    
    fun onPause() {
        mapView.onPause()
    }
    
    fun onSaveInstanceState(outState: android.os.Bundle) {
        mapView.onSaveInstanceState(outState)
    }
}
