package com.example.kotlinapp.core

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class TimeChangeReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_TIME_TICK,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                Log.d("TimeChangeReceiver", "Time changed, checking theme...")
                
                try {
                    val themeController = ThemeController(context)
                    val currentMode = themeController.getCurrentThemeMode()
                    
                    // Solo aplicar tema automático si está habilitado
                    if (currentMode == ThemeController.THEME_AUTO_TIME) {
                        themeController.applyTheme(currentMode)
                        Log.d("TimeChangeReceiver", "Theme updated based on time change")
                    }
                } catch (e: Exception) {
                    Log.e("TimeChangeReceiver", "Error updating theme on time change", e)
                }
            }
        }
    }
}
