package com.example.kotlinapp.data.repository

import com.example.kotlinapp.App
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.models.*
import retrofit2.HttpException
import java.io.IOException

class AuthRepository {
    
    private val authApiService = ApiClient.authApiService
    private val preferencesManager = App.getPreferencesManager()
    
    suspend fun login(email: String, password: String): Result<LoginResponse> {
        return try {
            val loginRequest = LoginRequest(email, password)
            val response = authApiService.login(loginRequest)
            
            if (response.isSuccessful) {
                response.body()?.let { loginResponse ->
                    // Guardar token en SharedPreferences
                    preferencesManager.saveAccessToken(loginResponse.accessToken, loginResponse.tokenType)
                    Result.success(loginResponse)
                } ?: Result.failure(Exception("Error del servidor"))
            } else {
                when (response.code()) {
                    401 -> Result.failure(Exception("Contraseña o usuario incorrecto"))
                    403 -> Result.failure(Exception("Usuario suspendido"))
                    422 -> Result.failure(Exception("Datos inválidos"))
                    500 -> Result.failure(Exception("Error del servidor"))
                    else -> {
                        val errorBody = response.errorBody()?.string() ?: "Error desconocido"
                        Result.failure(Exception("Error del servidor: $errorBody"))
                    }
                }
            }
        } catch (e: HttpException) {
            when (e.code()) {
                401 -> Result.failure(Exception("Contraseña o usuario incorrecto"))
                403 -> Result.failure(Exception("Usuario suspendido"))
                422 -> Result.failure(Exception("Datos inválidos"))
                500 -> Result.failure(Exception("Error del servidor"))
                else -> Result.failure(Exception("Error del servidor: ${e.message()}"))
            }
        } catch (e: IOException) {
            Result.failure(Exception("Error de conexión. Verifica tu conexión a internet"))
        } catch (e: Exception) {
            Result.failure(Exception("Error inesperado: ${e.message}"))
        }
    }
    
    suspend fun register(
        name: String,
        email: String,
        password: String,
        phone: String,
        role: String
    ): Result<UserResponse> {
        return try {
            val registerRequest = RegisterRequest(name, email, password, phone, role)
            val response = authApiService.register(registerRequest)
            
            if (response.isSuccessful) {
                response.body()?.let { userResponse ->
                    Result.success(userResponse)
                } ?: Result.failure(Exception("Error del servidor"))
            } else {
                when (response.code()) {
                    409 -> Result.failure(Exception("El email ya está registrado"))
                    400 -> Result.failure(Exception("Datos inválidos"))
                    422 -> Result.failure(Exception("Datos inválidos"))
                    500 -> Result.failure(Exception("Error del servidor"))
                    else -> {
                        val errorBody = response.errorBody()?.string() ?: "Error desconocido"
                        Result.failure(Exception("Error del servidor: $errorBody"))
                    }
                }
            }
        } catch (e: HttpException) {
            when (e.code()) {
                409 -> Result.failure(Exception("El email ya está registrado"))
                400 -> Result.failure(Exception("Datos inválidos"))
                422 -> Result.failure(Exception("Datos inválidos"))
                500 -> Result.failure(Exception("Error del servidor"))
                else -> Result.failure(Exception("Error del servidor: ${e.message()}"))
            }
        } catch (e: IOException) {
            Result.failure(Exception("Error de conexión. Verifica tu conexión a internet"))
        } catch (e: Exception) {
            Result.failure(Exception("Error inesperado: ${e.message}"))
        }
    }
    
    suspend fun getCurrentUser(token: String): Result<UserResponse> {
        return try {
            val authHeader = "Bearer $token"
            val response = authApiService.getCurrentUser(authHeader)
            
            if (response.isSuccessful) {
                response.body()?.let { userResponse ->
                    // Guardar información del usuario
                    preferencesManager.saveUserInfo(userResponse)
                    Result.success(userResponse)
                } ?: Result.failure(Exception("Empty response body"))
            } else {
                Result.failure(Exception("Failed to get user info"))
            }
        } catch (e: HttpException) {
            when (e.code()) {
                401 -> Result.failure(Exception("Token inválido"))
                404 -> Result.failure(Exception("Usuario no encontrado"))
                else -> Result.failure(Exception("Error del servidor: ${e.message()}"))
            }
        } catch (e: IOException) {
            Result.failure(Exception("Error de conexión. "))
        } catch (e: Exception) {
            Result.failure(Exception("Error inesperado: ${e.message}"))
        }
    }
    
    fun getCachedUserInfo(): UserResponse? {
        return preferencesManager.getUserInfo()
    }
    
    fun isLoggedIn(): Boolean {
        return preferencesManager.isLoggedIn()
    }
    
    fun logout() {
        preferencesManager.logout()
    }
    
    fun getAuthToken(): String? {
        return preferencesManager.getAccessToken()
    }
}
