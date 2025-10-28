package com.example.kotlinapp.data.api

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {
    
    // private const val BASE_URL = "http://192.168.100.27:8000/"  
    // private const val BASE_URL = "http://10.0.2.2:8000/"  // Emulador Android (funciona siempre)
    private const val BASE_URL = "https://qovo-api-862569067561.us-central1.run.app/"  // GCP Cloud Run  

    private val gson = GsonBuilder()
        .setLenient()
        .create()
    
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }
    
    private val authInterceptor = AuthInterceptor()
    
    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .addInterceptor(authInterceptor)
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .build()
    
    val authApiService: AuthApiService = retrofit.create(AuthApiService::class.java)
    val vehicleRatingApi: VehicleRatingApi = retrofit.create(VehicleRatingApi::class.java)

    val vehiclesApi: VehiclesApiService = retrofit.create(VehiclesApiService::class.java)
    val pricingApi: PricingApiService = retrofit.create(PricingApiService::class.java)

    fun <T> create(service: Class<T>): T = retrofit.create(service)
}
