@file:OptIn(
    androidx.compose.material3.ExperimentalMaterial3Api::class
)
package com.example.kotlinapp.ui.vehiclesMap

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.viewmodel.compose.viewModel
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*

class VehicleMapFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                MaterialTheme {
                    VehicleMapScreen()
                }
            }
        }
    }
}

@Composable
fun VehicleMapScreen() {
    val vm: VehicleMapViewModel = viewModel()
    val vehicles by vm.vehicles.collectAsState()
    val isRefreshing by vm.isRefreshing.collectAsState()
    val showCacheBanner by vm.showCacheBanner.collectAsState()

    val bogota = LatLng(4.7110, -74.0721)
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(bogota, 12f)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Active Vehicles") },
                actions = {
                    // Botón de refresh con animación
                    IconButton(
                        onClick = { vm.revalidate() },
                        enabled = !isRefreshing
                    ) {
                        if (isRefreshing) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                strokeWidth = 2.dp,
                                color = MaterialTheme.colorScheme.onPrimary
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Actualizar",
                                tint = MaterialTheme.colorScheme.onPrimary
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
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
                        snippet = "${vehicle.year} - ${vehicle.plate}"
                    )
                }
            }

            // Banner de caché
            if (showCacheBanner) {
                Card(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .padding(16.dp)
                        .fillMaxWidth(0.9f),
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFFFFF3CD)
                    )
                ) {
                    Text(
                        text = " Sin conexión. Mostrando datos guardados.\nToca el ícono ⟳ arriba para actualizar.",
                        modifier = Modifier.padding(12.dp),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }

            // Spinner inicial solo si no hay datos Y está cargando
            if (vehicles.isEmpty() && isRefreshing) {
                CircularProgressIndicator(
                    modifier = Modifier
                        .size(50.dp)
                        .align(Alignment.Center)
                )
            }
        }
    }
}
