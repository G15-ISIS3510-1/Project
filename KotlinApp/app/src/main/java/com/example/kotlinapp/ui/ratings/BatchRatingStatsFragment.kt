package com.example.kotlinapp.ui.ratings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.ui.theme.AppTheme

class BatchRatingStatsFragment : Fragment() {
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        // Obtener vehicle_ids de los argumentos
        val vehicleIds = arguments?.getStringArray("vehicle_ids")?.toList() ?: emptyList()
        
        return ComposeView(requireContext()).apply {
            setContent {
                AppTheme {
                    BatchRatingStatsScreen(
                        vehicleIds = vehicleIds,
                        onBackClick = {
                            findNavController().popBackStack()
                        }
                    )
                }
            }
        }
    }
}

