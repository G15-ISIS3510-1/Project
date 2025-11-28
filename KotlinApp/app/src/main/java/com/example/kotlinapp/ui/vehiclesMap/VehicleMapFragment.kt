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
import com.example.kotlinapp.data.repository.VehicleMapItem
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

    // OPTIMIZACIÓN 1: Filtrar vehiculos visibles según cámara
    val visibleVehicles = remember(vehicles, cameraPositionState.position) {
        filterVisibleVehicles(vehicles, cameraPositionState.position)
    }

    // OPTIMIZACIÓN 2: Clustering para muchos markers
    val shouldCluster = visibleVehicles.size > 20
    val displayMarkers = remember(visibleVehicles, cameraPositionState.position.zoom) {
        if (shouldCluster) {
            clusterVehicles(visibleVehicles, cameraPositionState.position.zoom)
        } else {
            visibleVehicles
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Active Vehicles")
                        Text(
                            "${displayMarkers.size} visible of ${vehicles.size} total",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                },
                actions = {
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
                ),
                // OPTIMIZACIÓN 3: Desactivar features innecesarios
                properties = MapProperties(
                    isMyLocationEnabled = false,
                    isBuildingEnabled = false,
                    isTrafficEnabled = false
                )
            ) {
                // OPTIMIZACIÓN 4: Renderizar solo markers visibles y clusterizados
                displayMarkers.forEach { vehicle ->
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
                        text = "Sin conexión. Mostrando datos guardados.\nToca el ícono ⟳ arriba para actualizar.",
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

// OPTIMIZACIÓN: Filtrar vehículos dentro del viewport visible
private fun filterVisibleVehicles(
    vehicles: List<VehicleMapItem>,
    cameraPosition: CameraPosition
): List<VehicleMapItem> {
    if (vehicles.isEmpty()) return emptyList()

    // Calcular área visible basada en el zoom
    // Zoom 12 ≈ 0.1 grados, Zoom 15 ≈ 0.01 grados
    val latDelta = 0.2 / cameraPosition.zoom
    val lngDelta = 0.2 / cameraPosition.zoom

    val centerLat = cameraPosition.target.latitude
    val centerLng = cameraPosition.target.longitude

    val minLat = centerLat - latDelta
    val maxLat = centerLat + latDelta
    val minLng = centerLng - lngDelta
    val maxLng = centerLng + lngDelta

    return vehicles.filter { vehicle ->
        vehicle.lat in minLat..maxLat && vehicle.lng in minLng..maxLng
    }
}

// OPTIMIZACIÓN: Clustering simple de vehículos cercanos
private fun clusterVehicles(
    vehicles: List<VehicleMapItem>,
    zoom: Float
): List<VehicleMapItem> {
    // Si hay pocos vehículos o estamos muy cerca, no agrupar
    if (vehicles.size < 20 || zoom > 14f) return vehicles

    // Tamaño de la cuadrícula para clustering (más pequeño = más zoom)
    val gridSize = when {
        zoom < 10f -> 0.05  // ~5km
        zoom < 12f -> 0.02  // ~2km
        zoom < 14f -> 0.01  // ~1km
        else -> 0.005       // ~500m
    }

    // Agrupar vehículos en celdas de la cuadrícula
    val clusters = vehicles.groupBy { vehicle ->
        val gridLat = (vehicle.lat / gridSize).toInt()
        val gridLng = (vehicle.lng / gridSize).toInt()
        gridLat to gridLng
    }

    // Retornar un representante por cluster
    return clusters.map { (_, group) ->

        group.first()
    }
}