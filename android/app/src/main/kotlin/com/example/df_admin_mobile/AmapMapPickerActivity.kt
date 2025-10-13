package com.example.df_admin_mobile

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.Gravity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.cardview.widget.CardView
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MyLocationStyle
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItem
import com.amap.api.services.core.ServiceSettings
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeQuery
import com.amap.api.services.geocoder.RegeocodeResult
import com.amap.api.services.poisearch.PoiResult
import com.amap.api.services.poisearch.PoiSearch

/**
 * 高德地图位置选择器 Activity
 * 
 * 功能：
 * - 显示高德 3D 地图
 * - 支持地图拖动选择位置
 * - 支持地址/POI搜索
 * - 自动逆地理编码获取地址信息
 * - 返回经纬度和详细地址
 */
class AmapMapPickerActivity : AppCompatActivity(), 
    AMap.OnCameraChangeListener, 
    GeocodeSearch.OnGeocodeSearchListener,
    PoiSearch.OnPoiSearchListener {

    companion object {
        const val KEY_INITIAL_LATITUDE = "initialLatitude"
        const val KEY_INITIAL_LONGITUDE = "initialLongitude"
        const val KEY_RESULT_LATITUDE = "latitude"
        const val KEY_RESULT_LONGITUDE = "longitude"
        const val KEY_RESULT_ADDRESS = "address"
        const val KEY_RESULT_CITY = "city"
        const val KEY_RESULT_PROVINCE = "province"
    }

    private lateinit var mapView: MapView
    private lateinit var aMap: AMap
    private lateinit var geocodeSearch: GeocodeSearch
    private lateinit var poiSearch: PoiSearch
    private lateinit var searchInput: EditText
    private lateinit var searchResultsCard: CardView
    private lateinit var searchResultsContainer: LinearLayout
    private lateinit var addressLabel: TextView
    private lateinit var confirmButton: Button
    private lateinit var centerPinIcon: ImageView
    private lateinit var relocateButton: FrameLayout
    
    private var currentAddress: String = ""
    private var currentCity: String = ""
    private var currentProvince: String = ""
    private var currentCityCode: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 设置高德地图隐私合规（必须在使用任何高德 SDK 功能前调用）
        MapsInitializer.updatePrivacyShow(this, true, true)
        MapsInitializer.updatePrivacyAgree(this, true)
        
        // 设置高德搜索服务隐私合规
        ServiceSettings.updatePrivacyShow(this, true, true)
        ServiceSettings.updatePrivacyAgree(this, true)
        
        // 创建 UI
        setupUI()
        
        // 初始化地图
        mapView.onCreate(savedInstanceState)
        setupMap()
        
        // 初始化地理编码搜索
        geocodeSearch = GeocodeSearch(this)
        geocodeSearch.setOnGeocodeSearchListener(this)
        
        // 初始化POI搜索
        poiSearch = PoiSearch(this, null)
        poiSearch.setOnPoiSearchListener(this)
        
        // 设置初始位置
        val initialLat = intent.getDoubleExtra(KEY_INITIAL_LATITUDE, 39.909187)
        val initialLng = intent.getDoubleExtra(KEY_INITIAL_LONGITUDE, 116.397451)
        val initialPosition = LatLng(initialLat, initialLng)
        aMap.moveCamera(CameraUpdateFactory.newLatLngZoom(initialPosition, 15f))
        
        // 初始逆地理编码
        reverseGeocode(initialPosition)
    }

    private fun setupUI() {
        // 根布局
        val rootLayout = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        // 地图视图
        mapView = MapView(this)
        rootLayout.addView(mapView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        // 顶部搜索栏
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.WHITE)
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(12), dpToPx(12), dpToPx(12), dpToPx(12))
            elevation = dpToPx(4).toFloat()
        }

        // 返回按钮
        val backButton = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            setColorFilter(Color.parseColor("#666666"))
            setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8))
            setOnClickListener {
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
        }
        topBar.addView(backButton, LinearLayout.LayoutParams(
            dpToPx(40),
            dpToPx(40)
        ))

        // 搜索框容器
        val searchContainer = CardView(this).apply {
            radius = dpToPx(8).toFloat()
            cardElevation = dpToPx(2).toFloat()
            setCardBackgroundColor(Color.parseColor("#F5F5F5"))
        }
        
        // 搜索输入框
        searchInput = EditText(this).apply {
            hint = "搜索地点、地址"
            textSize = 16f
            setTextColor(Color.BLACK)
            setHintTextColor(Color.parseColor("#999999"))
            setBackgroundColor(Color.TRANSPARENT)
            setPadding(dpToPx(12), dpToPx(8), dpToPx(12), dpToPx(8))
            setSingleLine(true)
            imeOptions = EditorInfo.IME_ACTION_SEARCH
            
            // 搜索框文本变化监听
            addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    val query = s.toString().trim()
                    if (query.isNotEmpty()) {
                        performSearch(query)
                    } else {
                        hideSearchResults()
                    }
                }
            })
            
            // 搜索按钮点击
            setOnEditorActionListener { _, actionId, _ ->
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    val query = text.toString().trim()
                    if (query.isNotEmpty()) {
                        performSearch(query)
                    }
                    true
                } else {
                    false
                }
            }
        }
        searchContainer.addView(searchInput)
        
        topBar.addView(searchContainer, LinearLayout.LayoutParams(
            0,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            weight = 1f
            leftMargin = dpToPx(8)
        })

        rootLayout.addView(topBar, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.TOP
        })
        
        // 搜索结果卡片
        searchResultsCard = CardView(this).apply {
            radius = dpToPx(8).toFloat()
            cardElevation = dpToPx(8).toFloat()
            setCardBackgroundColor(Color.WHITE)
            visibility = View.GONE
        }
        
        val searchResultsScrollView = ScrollView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                dpToPx(300)
            )
        }
        
        searchResultsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 0, 0, 0)
        }
        
        searchResultsScrollView.addView(searchResultsContainer)
        searchResultsCard.addView(searchResultsScrollView)
        
        rootLayout.addView(searchResultsCard, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.TOP
            topMargin = dpToPx(64)
            leftMargin = dpToPx(16)
            rightMargin = dpToPx(16)
        })

        // 中心定位大头针图标
        centerPinIcon = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_mylocation)
            setColorFilter(Color.parseColor("#FF4458"))
            scaleX = 1.5f
            scaleY = 1.5f
            elevation = dpToPx(4).toFloat()
        }
        rootLayout.addView(centerPinIcon, FrameLayout.LayoutParams(
            dpToPx(48),
            dpToPx(48)
        ).apply {
            gravity = Gravity.CENTER
            bottomMargin = dpToPx(24)
        })

        // 重新定位按钮（右下角）
        relocateButton = FrameLayout(this).apply {
            // 创建圆形背景
            val bgDrawable = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.WHITE)
            }
            background = bgDrawable
            elevation = dpToPx(6).toFloat()
            setPadding(dpToPx(12), dpToPx(12), dpToPx(12), dpToPx(12))
            
            // 添加定位图标
            val locationIcon = ImageView(this@AmapMapPickerActivity).apply {
                setImageResource(android.R.drawable.ic_menu_mylocation)
                setColorFilter(Color.parseColor("#FF4458"))
            }
            addView(locationIcon, FrameLayout.LayoutParams(
                dpToPx(24),
                dpToPx(24)
            ))
            
            // 点击重新定位到当前位置
            setOnClickListener {
                relocateToCurrentPosition()
            }
        }
        rootLayout.addView(relocateButton, FrameLayout.LayoutParams(
            dpToPx(48),
            dpToPx(48)
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.END
            setMargins(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(240))
        })

        // 底部地址面板
        val addressPanel = CardView(this).apply {
            radius = dpToPx(16).toFloat()
            cardElevation = dpToPx(8).toFloat()
            setCardBackgroundColor(Color.WHITE)
        }

        val addressPanelLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(20), dpToPx(20), dpToPx(20), dpToPx(20))
        }

        // 地址文本
        addressLabel = TextView(this).apply {
            text = "正在获取地址..."
            textSize = 16f
            setTextColor(Color.BLACK)
            maxLines = 2
        }
        addressPanelLayout.addView(addressLabel, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // 间距
        addressPanelLayout.addView(View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(16)
            )
        })

        // 确认按钮
        confirmButton = Button(this).apply {
            text = "确认位置"
            textSize = 16f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#FF4458"))
            setOnClickListener {
                confirmLocation()
            }
        }
        addressPanelLayout.addView(confirmButton, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            dpToPx(48)
        ))

        addressPanel.addView(addressPanelLayout)

        rootLayout.addView(addressPanel, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.BOTTOM
            setMargins(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(80))
        })

        setContentView(rootLayout)
    }

    private fun setupMap() {
        aMap = mapView.map
        
        // 设置地图UI
        aMap.uiSettings.apply {
            isZoomControlsEnabled = false
            isCompassEnabled = true
            isMyLocationButtonEnabled = true
            isScaleControlsEnabled = true
        }
        
        // 设置定位样式
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE)
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true
        
        // 设置相机变化监听
        aMap.setOnCameraChangeListener(this)
        
        // 添加地图点击监听 - 点击地图任意位置即可选中
        aMap.setOnMapClickListener { latLng ->
            // 点击地图时,将相机移动到点击位置
            aMap.animateCamera(CameraUpdateFactory.newLatLng(latLng), 300, null)
        }
    }

    override fun onCameraChange(cameraPosition: CameraPosition?) {
        // 相机移动中，抬起图标
        centerPinIcon.animate()
            .translationY(-dpToPx(10).toFloat())
            .scaleX(1.2f)
            .scaleY(1.2f)
            .setDuration(100)
            .start()
    }

    override fun onCameraChangeFinish(cameraPosition: CameraPosition?) {
        // 相机停止，放下图标
        centerPinIcon.animate()
            .translationY(0f)
            .scaleX(1.5f)
            .scaleY(1.5f)
            .setDuration(150)
            .start()
        
        // 用户拖动地图结束，触发逆地理编码
        cameraPosition?.target?.let { latLng ->
            reverseGeocode(latLng)
        }
    }
    
    private fun relocateToCurrentPosition() {
        // 获取地图当前的我的位置
        val myLocation = aMap.myLocation
        if (myLocation != null) {
            val currentLocation = LatLng(myLocation.latitude, myLocation.longitude)
            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(currentLocation, 15f))
        } else {
            // 如果无法获取当前位置，使用地图中心点
            val center = aMap.cameraPosition.target
            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(center, 15f))
        }
    }

    private fun reverseGeocode(latLng: LatLng) {
        val latLonPoint = LatLonPoint(latLng.latitude, latLng.longitude)
        val query = RegeocodeQuery(latLonPoint, 200f, GeocodeSearch.AMAP)
        geocodeSearch.getFromLocationAsyn(query)
    }

    override fun onRegeocodeSearched(result: RegeocodeResult?, code: Int) {
        if (code == 1000 && result != null && result.regeocodeAddress != null) {
            val regeocodeAddress = result.regeocodeAddress
            
            // 更新地址信息
            currentAddress = regeocodeAddress.formatAddress ?: "未知地址"
            currentCity = regeocodeAddress.city ?: ""
            currentProvince = regeocodeAddress.province ?: ""
            currentCityCode = regeocodeAddress.cityCode ?: ""
            
            // 更新 UI
            runOnUiThread {
                addressLabel.text = currentAddress
            }
        } else {
            runOnUiThread {
                addressLabel.text = "获取地址失败"
            }
        }
    }

    override fun onGeocodeSearched(result: com.amap.api.services.geocoder.GeocodeResult?, code: Int) {
        // 不需要实现
    }
    
    // POI 搜索监听器实现
    override fun onPoiSearched(result: PoiResult?, code: Int) {
        if (code == 1000 && result != null) {
            val poiItems = result.pois
            runOnUiThread {
                displaySearchResults(poiItems)
            }
        } else {
            runOnUiThread {
                showSearchError()
            }
        }
    }
    
    override fun onPoiItemSearched(item: PoiItem?, code: Int) {
        // 不需要实现
    }
    
    // 执行搜索
    private fun performSearch(query: String) {
        val city = if (currentCityCode.isNotEmpty()) {
            currentCityCode
        } else if (currentCity.isNotEmpty()) {
            currentCity
        } else {
            "全国"
        }
        
        val poiQuery = com.amap.api.services.poisearch.PoiSearch.Query(query, "", city)
        poiQuery.pageSize = 20
        poiQuery.pageNum = 0
        
        poiSearch.query = poiQuery
        poiSearch.searchPOIAsyn()
    }
    
    // 显示搜索结果
    private fun displaySearchResults(poiItems: ArrayList<PoiItem>?) {
        searchResultsContainer.removeAllViews()
        
        if (poiItems.isNullOrEmpty()) {
            val emptyView = TextView(this).apply {
                text = "未找到相关地点"
                textSize = 14f
                setTextColor(Color.parseColor("#999999"))
                gravity = Gravity.CENTER
                setPadding(dpToPx(16), dpToPx(32), dpToPx(16), dpToPx(32))
            }
            searchResultsContainer.addView(emptyView)
        } else {
            poiItems.forEachIndexed { index, poi ->
                val itemView = createSearchResultItem(poi)
                searchResultsContainer.addView(itemView)
                
                // 添加分割线（除了最后一项）
                if (index < poiItems.size - 1) {
                    val divider = View(this).apply {
                        setBackgroundColor(Color.parseColor("#EEEEEE"))
                    }
                    searchResultsContainer.addView(divider, LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        1
                    ))
                }
            }
        }
        
        searchResultsCard.visibility = View.VISIBLE
    }
    
    // 创建搜索结果项
    private fun createSearchResultItem(poi: PoiItem): View {
        val itemLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(16), dpToPx(12), dpToPx(16), dpToPx(12))
            isClickable = true
            isFocusable = true
            setBackgroundResource(android.R.drawable.list_selector_background)
            
            setOnClickListener {
                selectSearchResult(poi)
            }
        }
        
        // POI 名称
        val nameView = TextView(this).apply {
            text = poi.title
            textSize = 16f
            setTextColor(Color.BLACK)
            maxLines = 1
        }
        itemLayout.addView(nameView, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))
        
        // POI 地址
        if (!poi.snippet.isNullOrEmpty()) {
            val addressView = TextView(this).apply {
                text = poi.snippet
                textSize = 12f
                setTextColor(Color.parseColor("#666666"))
                maxLines = 1
            }
            itemLayout.addView(addressView, LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = dpToPx(4)
            })
        }
        
        // 距离信息
        val distance = poi.distance
        if (distance > 0) {
            val distanceText = if (distance < 1000) {
                "${distance.toInt()}米"
            } else {
                String.format("%.1f公里", distance / 1000)
            }
            
            val distanceView = TextView(this).apply {
                text = distanceText
                textSize = 11f
                setTextColor(Color.parseColor("#999999"))
            }
            itemLayout.addView(distanceView, LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = dpToPx(4)
            })
        }
        
        return itemLayout
    }
    
    // 选择搜索结果
    private fun selectSearchResult(poi: PoiItem) {
        val latLng = LatLng(poi.latLonPoint.latitude, poi.latLonPoint.longitude)
        
        // 隐藏搜索结果
        hideSearchResults()
        
        // 清空搜索框
        searchInput.setText("")
        searchInput.clearFocus()
        
        // 隐藏键盘
        val imm = getSystemService(android.content.Context.INPUT_METHOD_SERVICE) as android.view.inputmethod.InputMethodManager
        imm.hideSoftInputFromWindow(searchInput.windowToken, 0)
        
        // 移动地图到选中位置
        aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(latLng, 16f), 500, null)
    }
    
    // 隐藏搜索结果
    private fun hideSearchResults() {
        searchResultsCard.visibility = View.GONE
        searchResultsContainer.removeAllViews()
    }
    
    // 显示搜索错误
    private fun showSearchError() {
        searchResultsContainer.removeAllViews()
        
        val errorView = TextView(this).apply {
            text = "搜索出错，请重试"
            textSize = 14f
            setTextColor(Color.parseColor("#FF4458"))
            gravity = Gravity.CENTER
            setPadding(dpToPx(16), dpToPx(32), dpToPx(16), dpToPx(32))
        }
        searchResultsContainer.addView(errorView)
        searchResultsCard.visibility = View.VISIBLE
    }

    private fun confirmLocation() {
        val center = aMap.cameraPosition.target
        val resultIntent = Intent().apply {
            putExtra(KEY_RESULT_LATITUDE, center.latitude)
            putExtra(KEY_RESULT_LONGITUDE, center.longitude)
            putExtra(KEY_RESULT_ADDRESS, currentAddress)
            putExtra(KEY_RESULT_CITY, currentCity)
            putExtra(KEY_RESULT_PROVINCE, currentProvince)
        }
        setResult(Activity.RESULT_OK, resultIntent)
        finish()
    }

    private fun dpToPx(dp: Int): Int {
        val density = resources.displayMetrics.density
        return (dp * density).toInt()
    }

    // 地图生命周期方法
    override fun onResume() {
        super.onResume()
        mapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapView.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapView.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView.onSaveInstanceState(outState)
    }
}
