package com.example.kotlinapp.data.api

import com.example.kotlinapp.App
import okhttp3.Interceptor
import okhttp3.Response

class AuthInterceptor : Interceptor {
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        val preferencesManager = App.getPreferencesManager()
        
        val authHeader = preferencesManager.getAuthHeader()
        
        val newRequest = if (authHeader != null) {
            originalRequest.newBuilder()
                .header("Authorization", authHeader)
                .build()
        } else {
            originalRequest
        }
        
        return chain.proceed(newRequest)
    }
}
