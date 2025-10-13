package com.example.df_admin_mobile

import android.app.Application
import android.util.Log
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.ServiceSettings

class MyApplication : Application() {
    
    companion object {
        init {
            Log.e("MyApplication", "========== STATIC INIT BLOCK ==========")
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        
        // 使用 System.err 确保一定能看到输出
        System.err.println("========================================")
        System.err.println("🚀 MyApplication onCreate - START")
        System.err.println("========================================")
        
        Log.e("MyApplication", "============================================")
        Log.e("MyApplication", "🚀 Application onCreate - START")
        Log.e("MyApplication", "============================================")
        
        // 高德地图隐私合规设置 - 必须在地图初始化之前调用
        try {
            Log.e("MyApplication", "🔧 Setting Amap privacy compliance...")
            
            // 地图隐私合规
            MapsInitializer.updatePrivacyShow(this, true, true)
            MapsInitializer.updatePrivacyAgree(this, true)
            
            // 搜索服务隐私合规
            ServiceSettings.updatePrivacyShow(this, true, true)
            ServiceSettings.updatePrivacyAgree(this, true)
            
            Log.e("MyApplication", "✅ Amap privacy compliance configured successfully!")
            System.err.println("✅ Amap privacy configured!")
        } catch (e: Exception) {
            Log.e("MyApplication", "❌ Failed to configure Amap privacy compliance", e)
            System.err.println("❌ Failed: ${e.message}")
        }
        
        Log.e("MyApplication", "============================================")
        Log.e("MyApplication", "🎉 Application onCreate - COMPLETE")
        Log.e("MyApplication", "============================================")
        System.err.println("🎉 MyApplication onCreate - COMPLETE")
        System.err.println("========================================")
    }
}
