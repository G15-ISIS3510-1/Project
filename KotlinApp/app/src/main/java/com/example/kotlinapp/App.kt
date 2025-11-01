package com.example.kotlinapp

import android.app.Application
import android.util.Log
import com.example.kotlinapp.core.MessagesSyncScheduler
import com.example.kotlinapp.core.ThemeController
import com.example.kotlinapp.data.local.PreferencesManager

class App : Application() {
    
    lateinit var preferencesManager: PreferencesManager
        private set
    
    lateinit var themeController: ThemeController
        private set
    
    lateinit var messagesSyncScheduler: MessagesSyncScheduler
        private set
    
    override fun onCreate() {
        super.onCreate()
        
        try {
            preferencesManager = PreferencesManager(this)
            
            themeController = ThemeController(this)
            themeController.initializeTheme()
            
            // Inicializar scheduler de sincronización de mensajes
            messagesSyncScheduler = MessagesSyncScheduler(this)
            
            Log.d("App", "App initialized successfully")
            
            _instance = this
        } catch (e: Exception) {
            Log.e("App", "Error initializing App", e)
            throw e
        }
    }
    
    companion object {
        @Volatile
        @JvmStatic
        private var _instance: App? = null
        
        @JvmStatic
        fun getInstance(): App {
            return _instance ?: throw IllegalStateException("App not initialized")
        }
        
        fun getPreferencesManager(): PreferencesManager {
            return getInstance().preferencesManager
        }
        
        fun getThemeController(): ThemeController {
            return getInstance().themeController
        }
        
        fun getMessagesSyncScheduler(): MessagesSyncScheduler {
            return getInstance().messagesSyncScheduler
        }
    }
}
