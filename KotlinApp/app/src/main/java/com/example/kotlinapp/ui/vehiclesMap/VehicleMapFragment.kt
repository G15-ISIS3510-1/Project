@file:OptIn(
    androidx.compose.material3.ExperimentalMaterial3Api::class,
    com.google.accompanist.permissions.ExperimentalPermissionsApi::class
)
package com.example.kotlinapp.ui.vehiclesMap

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.viewmodel.compose.viewModel
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import androidx.compose.ui.graphics.Color


class VehicleMapFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                VehicleMapScreen()
            }
        }
    }
}

@Composable
fun VehicleMapScreen() {
    val vm: VehicleMapViewModel = viewModel()
    val vehicles by vm.vehicles.collectAsState()


    val bogota = LatLng(4.7110, -74.0721)
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(bogota, 12f)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Active Vehicles") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Black,
                    titleContentColor = Color.White
                )
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = cameraPositionState,
                uiSettings = MapUiSettings(
                    zoomControlsEnabled = true,
                    myLocationButtonEnabled = true
                )
            ) {
                vehicles.forEach { vehicle ->
                    Marker(
                        state = MarkerState(position = LatLng(vehicle.lat, vehicle.lng)),
                        title = "${vehicle.make} ${vehicle.model}",
                        snippet = "${vehicle.year} - $${vehicle.dailyPrice}/day"
                    )
                }
            }


            if (vehicles.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier
                        .size(50.dp)
                        .padding(16.dp)
                )
            }
        }
    }
}