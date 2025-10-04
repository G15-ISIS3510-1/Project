package com.example.kotlinapp.data.models

import com.google.gson.annotations.SerializedName

// Modelo para login request
data class LoginRequest(
    @SerializedName("email")
    val email: String,
    
    @SerializedName("password")
    val password: String
)

// Modelo para login response (Token)
data class LoginResponse(
    @SerializedName("access_token")
    val accessToken: String,
    
    @SerializedName("token_type")
    val tokenType: String
)

// Modelo para usuario
data class UserResponse(
    @SerializedName("user_id")
    val userId: String,
    
    @SerializedName("name")
    val name: String,
    
    @SerializedName("email")
    val email: String,
    
    @SerializedName("phone")
    val phone: String,
    
    @SerializedName("role")
    val role: String,
    
    @SerializedName("driver_license_status")
    val driverLicenseStatus: String,
    
    @SerializedName("status")
    val status: String,
    
    @SerializedName("created_at")
    val createdAt: String
)

// Modelo para registro
data class RegisterRequest(
    @SerializedName("name")
    val name: String,
    
    @SerializedName("email")
    val email: String,
    
    @SerializedName("password")
    val password: String,
    
    @SerializedName("phone")
    val phone: String,
    
    @SerializedName("role")
    val role: String
)

// Modelo para respuestas de error
data class ErrorResponse(
    @SerializedName("detail")
    val detail: String
)
