package com.example.kotlinapp.ui.vehicleSelection


import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.ui.theme.AppTheme


class VehicleSelectionFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                AppTheme {
                    VehicleSelectionScreen(
                        onVehicleSelected = { vehicleId, vehicleName ->

                            val bundle = Bundle().apply {
                                putString("vehicleId", vehicleId)
                                putString("vehicleName", vehicleName)
                            }
                            findNavController().navigate(
                                R.id.availabilityManagementFragment,
                                bundle
                            )
                        },
                        onNavigateBack = {
                            findNavController().popBackStack()
                        }
                    )
                }
            }
        }
    }
}
