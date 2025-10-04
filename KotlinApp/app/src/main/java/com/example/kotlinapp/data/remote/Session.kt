package com.example.kotlinapp.data.remote

object Session {
    @Volatile var token: String? = null
}