package com.example.kotlinapp.data.local

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.example.kotlinapp.data.models.UserResponse

class PreferencesManager(context: Context) {
    
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences("auth_prefs", Context.MODE_PRIVATE)
    
    init {
        Log.d("PreferencesManager", "PreferencesManager initialized successfully")
    }
    
    companion object {
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_TOKEN_TYPE = "token_type"
        private const val KEY_USER_ID = "user_id"
        private const val KEY_USER_NAME = "user_name"
        private const val KEY_USER_EMAIL = "user_email"
        private const val KEY_USER_ROLE = "user_role"
        private const val KEY_IS_LOGGED_IN = "is_logged_in"
    }
    
    // Guardar token de acceso
    fun saveAccessToken(token: String, tokenType: String = "bearer") {
        sharedPreferences.edit()
            .putString(KEY_ACCESS_TOKEN, token)
            .putString(KEY_TOKEN_TYPE, tokenType)
            .putBoolean(KEY_IS_LOGGED_IN, true)
            .apply()
    }
    
    fun getAccessToken(): String? {
        return sharedPreferences.getString(KEY_ACCESS_TOKEN, null)
    }
    
    fun getAuthHeader(): String? {
        val token = getAccessToken()
        val tokenType = sharedPreferences.getString(KEY_TOKEN_TYPE, "bearer") ?: "bearer"
        return if (token != null) "$tokenType $token" else null
    }
    
    // Guardar información del usuario
    fun saveUserInfo(user: UserResponse) {
        sharedPreferences.edit()
            .putString(KEY_USER_ID, user.userId)
            .putString(KEY_USER_NAME, user.name)
            .putString(KEY_USER_EMAIL, user.email)
            .putString(KEY_USER_ROLE, user.role)
            .apply()
    }
    
    // Obtener información del usuario
    fun getUserInfo(): UserResponse? {
        val userId = sharedPreferences.getString(KEY_USER_ID, null)
        val userName = sharedPreferences.getString(KEY_USER_NAME, null)
        val userEmail = sharedPreferences.getString(KEY_USER_EMAIL, null)
        val userRole = sharedPreferences.getString(KEY_USER_ROLE, null)
        
        return if (userId != null && userName != null && userEmail != null) {
            UserResponse(
                userId = userId,
                name = userName,
                email = userEmail,
                phone = "", // No guardamos phone por seguridad
                role = userRole ?: "renter",
                driverLicenseStatus = "pending",
                status = "active",
                createdAt = ""
            )
        } else {
            null
        }
    }
    
    fun isLoggedIn(): Boolean {
        return sharedPreferences.getBoolean(KEY_IS_LOGGED_IN, false) && getAccessToken() != null
    }
    
    fun logout() {
        sharedPreferences.edit().clear().apply()
    }
    
    fun hasValidToken(): Boolean {
        return getAccessToken()?.isNotEmpty() == true
    }
}
