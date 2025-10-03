package com.example.kotlinapp.data.remote.api



import com.example.kotlinapp.data.remote.Session
import retrofit2.converter.moshi.MoshiConverterFactory
import okhttp3.logging.HttpLoggingInterceptor
import okhttp3.OkHttpClient
import okhttp3.Interceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {
    private const val BASE_URL = "http://10.137.91.197:8000/"

    private val logging = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

//    private val authInterceptor = Interceptor { chain ->
//
//        val token = Session.token // TODO: obtén tu JWT tras login
//        val req = chain.request().newBuilder().apply {
//            if (!token.isNullOrBlank()) {
//                addHeader("Authorization", "Bearer $token")
//            }
//        }.build()
//        chain.proceed(req)
//    }

    private val authInterceptor = Interceptor { chain ->
        val builder = chain.request().newBuilder()
        Session.token?.let { tk ->
            builder.addHeader("Authorization", "Bearer $tk")
        }
        chain.proceed(builder.build())
    }

    private val client = OkHttpClient.Builder()
        .addInterceptor(logging)
        .addInterceptor(authInterceptor)
        .build()

    val api: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}
