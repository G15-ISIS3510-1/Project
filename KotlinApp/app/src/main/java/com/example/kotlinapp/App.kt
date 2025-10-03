package com.example.kotlinapp

import android.app.Application
import android.util.Log
import com.example.kotlinapp.data.local.PreferencesManager

class App : Application() {
    
    lateinit var preferencesManager: PreferencesManager
        private set
    
    override fun onCreate() {
        super.onCreate()
        
        try {
            // Inicializar el PreferencesManager
            preferencesManager = PreferencesManager(this)
            Log.d("App", "App initialized successfully")
            
            // Guardar referencia estática
            instance = this
        } catch (e: Exception) {
            Log.e("App", "Error initializing App", e)
            throw e
        }
    }
    
    companion object {
        @Volatile
        private var instance: App? = null
        
        fun getInstance(): App {
            return instance ?: throw IllegalStateException("App not initialized")
        }
        
        fun getPreferencesManager(): PreferencesManager {
            return getInstance().preferencesManager
        }
    }
}
