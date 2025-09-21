package com.example.kotlinapp

import android.os.Bundle


import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

import com.example.kotlinapp.ui.home.HomeScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            HomeScreen()
        }
    }




}