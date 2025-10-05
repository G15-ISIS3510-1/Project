package com.example.kotlinapp.core

import android.content.Context
import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatDelegate
import java.util.*

class ThemeController(private val context: Context) {
    
    private val preferences: SharedPreferences = 
        context.getSharedPreferences("theme_preferences", Context.MODE_PRIVATE)
    
    companion object {
        private const val KEY_THEME_MODE = "theme_mode"
        private const val KEY_AUTO_THEME_ENABLED = "auto_theme_enabled"
        private const val KEY_DARK_START_HOUR = "dark_start_hour"
        private const val KEY_DARK_END_HOUR = "dark_end_hour"
        
        private const val DEFAULT_DARK_START_HOUR = 18 // las 6 PM
        private const val DEFAULT_DARK_END_HOUR = 7    // 7 AM 

        
        // Modos de tema
        const val THEME_LIGHT = "light"
        const val THEME_DARK = "dark"
        const val THEME_SYSTEM = "system"
        const val THEME_AUTO_TIME = "auto_time"
    }
    
    /**
     * Obtiene el modo de tema actual
     */
    fun getCurrentThemeMode(): String {

        return preferences.getString(KEY_THEME_MODE, THEME_AUTO_TIME) ?: THEME_AUTO_TIME
    }
    
    /**
     * Establece el modo de tema
     */
    fun setThemeMode(mode: String) {
        preferences.edit().putString(KEY_THEME_MODE, mode).apply()
        applyTheme(mode)
    }
    
    /**
     * Verifica si el tema automático está habilitado
     */
    fun isAutoThemeEnabled(): Boolean {
        return preferences.getBoolean(KEY_AUTO_THEME_ENABLED, true)
    }
    
    /**
     * Habilita/deshabilita el tema automático
     */
    fun setAutoThemeEnabled(enabled: Boolean) {
        preferences.edit().putBoolean(KEY_AUTO_THEME_ENABLED, enabled).apply()
    }
    
    /**
     * Obtiene la hora de inicio del tema oscuro
     */
    fun getDarkStartHour(): Int {
        return preferences.getInt(KEY_DARK_START_HOUR, DEFAULT_DARK_START_HOUR)
    }
    
    /**
     * Establece la hora de inicio del tema oscuro
     */
    fun setDarkStartHour(hour: Int) {
        preferences.edit().putInt(KEY_DARK_START_HOUR, hour).apply()
    }
    
    /**
     * Obtiene la hora de fin del tema oscuro
     */
    fun getDarkEndHour(): Int {
        return preferences.getInt(KEY_DARK_END_HOUR, DEFAULT_DARK_END_HOUR)
    }
    
    /**
     * Establece la hora de fin del tema oscuro
     */
    fun setDarkEndHour(hour: Int) {
        preferences.edit().putInt(KEY_DARK_END_HOUR, hour).apply()
    }
    
    /**
     * Verifica si actualmente debería estar en modo oscuro según la hora
     */
    fun shouldUseDarkThemeByTime(): Boolean {
        val calendar = Calendar.getInstance()
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
        val darkStartHour = getDarkStartHour()
        val darkEndHour = getDarkEndHour()
        
        return when {
            darkStartHour > darkEndHour -> {
                currentHour >= darkStartHour || currentHour < darkEndHour
            }
            else -> {
                currentHour >= darkStartHour && currentHour < darkEndHour
            }
        }
    }
    
    /**
     * Aplica el tema según el modo seleccionado
     */
    fun applyTheme(mode: String? = null) {
        val themeMode = mode ?: getCurrentThemeMode()
        
        when (themeMode) {
            THEME_LIGHT -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            }
            THEME_DARK -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            }
            THEME_SYSTEM -> {
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
            }
            THEME_AUTO_TIME -> {
                if (shouldUseDarkThemeByTime()) {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
                } else {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
                }
            }
        }
    }
    
    /**
     * Inicializa el tema al iniciar la aplicación
     */
    fun initializeTheme() {
        val currentMode = getCurrentThemeMode()
        applyTheme(currentMode)
    }
    
    /**
     * Obtiene el nombre legible del modo de tema
     */
    fun getThemeModeDisplayName(mode: String): String {
        return when (mode) {
            THEME_LIGHT -> "Modo Claro"
            THEME_DARK -> "Modo Oscuro"
            THEME_SYSTEM -> "Seguir Sistema"
            THEME_AUTO_TIME -> "Automático por Hora"
            else -> "Desconocido"
        }
    }
    
    /**
     * Obtiene todos los modos de tema disponibles
     */
    fun getAvailableThemeModes(): List<String> {
        return listOf(THEME_LIGHT, THEME_DARK, THEME_SYSTEM, THEME_AUTO_TIME)
    }
}
