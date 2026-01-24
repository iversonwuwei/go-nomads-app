package com.gonomads.go_nomads_app.wxapi

import com.jarvan.fluwx.wxapi.FluwxWXEntryActivity

/**
 * 微信回调 Activity
 * 处理微信登录、分享、支付等回调
 * 必须放在 包名/wxapi/ 目录下，且类名必须为 WXEntryActivity
 * 
 * 继承 FluwxWXEntryActivity 让 fluwx 插件自动处理回调
 */
class WXEntryActivity : FluwxWXEntryActivity()
