package com.example.kotlinapp.ui.toprated

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.example.kotlinapp.ui.theme.AppTheme
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.repository.VehicleRatingRepository
import com.example.kotlinapp.data.repository.AuthRepository
import com.example.kotlinapp.data.local.PreferencesManager

class TopRatedVehiclesActivity : ComponentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val authRepository = AuthRepository()
        
        if (!authRepository.isLoggedIn()) {
            startActivity(Intent(this, com.example.kotlinapp.MainActivity::class.java))
            finish()
            return
        }
        
        val viewModel = TopRatedVehiclesViewModel(
            repository = VehicleRatingRepository(
                api = ApiClient.vehicleRatingApi
            )
        )
        
        
        val token = authRepository.getAuthToken() ?: ""
        
        setContent {
            AppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    TopRatedVehiclesScreen(
                        viewModel = viewModel,
                        token = token,
                        onNavigateBack = {
                            finish()
                        }
                    )
                }
            }
        }
    }
}
