package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.models.*
import retrofit2.Response
import retrofit2.http.*

interface AuthApiService {
    
    @POST("api/auth/login")
    suspend fun login(
        @Body loginRequest: LoginRequest
    ): Response<LoginResponse>
    
    @POST("api/auth/register")
    suspend fun register(
        @Body registerRequest: RegisterRequest
    ): Response<UserResponse>
    
    @GET("api/auth/me")
    suspend fun getCurrentUser(
        @Header("Authorization") token: String
    ): Response<UserResponse>
}
