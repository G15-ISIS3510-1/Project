package com.example.kotlinapp.ui.toprated

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.example.kotlinapp.ui.theme.AppTheme
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.repository.VehicleRatingRepository
import com.example.kotlinapp.data.repository.AuthRepository
import com.example.kotlinapp.data.local.PreferencesManager

class TopRatedVehiclesFragment : Fragment() {
    
    private val viewModel: TopRatedVehiclesViewModel by viewModels {
        TopRatedVehiclesViewModelFactory(
            repository = VehicleRatingRepository(
                api = ApiClient.vehicleRatingApi
            )
        )
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                AppTheme {
                    TopRatedVehiclesScreenContent()
                }
            }
        }
    }
    
    @Composable
    private fun TopRatedVehiclesScreenContent() {
        val authRepository = AuthRepository()
        
        if (!authRepository.isLoggedIn()) {
            startActivity(Intent(requireContext(), com.example.kotlinapp.MainActivity::class.java))
            requireActivity().finish()
            return
        }
        
        val token = authRepository.getAuthToken() ?: ""
        
        TopRatedVehiclesScreen(
            viewModel = viewModel,
            token = token,
            onNavigateBack = {
                // Navigate back to previous screen
                requireActivity().onBackPressed()
            }
        )
    }
}

// Factory for ViewModel
class TopRatedVehiclesViewModelFactory(
    private val repository: VehicleRatingRepository
) : androidx.lifecycle.ViewModelProvider.Factory {
    override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(TopRatedVehiclesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return TopRatedVehiclesViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
