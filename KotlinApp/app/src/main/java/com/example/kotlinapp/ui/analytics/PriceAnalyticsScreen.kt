// ui/analytics/PriceAnalyticsScreen.kt
package com.example.kotlinapp.ui.analytics

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.models.PriceAnalytics
import com.example.kotlinapp.data.utils.GeoUtils
import kotlinx.coroutines.launch
import com.example.kotlinapp.data.models.Location

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PriceAnalyticsScreen(
    onBackClick: () -> Unit = {}
) {
    var uiState by remember { mutableStateOf<AnalyticsUiState>(AnalyticsUiState.Initial) }
    var radiusKm by remember { mutableStateOf(5.0) }

    val userLat = 4.6097  // Bogotá
    val userLng = -74.0817

    val scope = rememberCoroutineScope()

    fun analyzePrices() {
        scope.launch {
            uiState = AnalyticsUiState.Loading

            try {
                // 1. Obtener vehículos del API

                val response = ApiClient.vehiclesApi.getActiveVehiclesWithPricing()
                val allVehicles = response.items

                // 2. Filtrar por distancia
                val nearbyVehicles = allVehicles.filter { vehicle ->
                    vehicle.lat != null && vehicle.lng != null &&
                            GeoUtils.calculateDistance(
                                userLat, userLng,
                                vehicle.lat, vehicle.lng
                            ) <= radiusKm
                }

                // 3. Calcular promedio
                val avgPrice = if (nearbyVehicles.isNotEmpty()) {
                    nearbyVehicles.map { it.dailyRate }.average()
                } else {
                    0.0
                }

                // 4. Crear resultado con userLocation
                val analytics = PriceAnalytics(
                    currentAvgPrice = avgPrice,
                    totalVehicles = nearbyVehicles.size,
                    radiusKm = radiusKm,
                    userLocation = Location(userLat, userLng),
                    nearbyVehicles = nearbyVehicles
                )

                uiState = AnalyticsUiState.Success(analytics)

            } catch (e: Exception) {
                uiState = AnalyticsUiState.Error(
                    e.message ?: "Error al obtener datos"
                )
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Análisis de Precios") },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Volver"
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
        ) {
            Text(
                text = "Análisis de Precios por Zona",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Control de radio
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Radio de búsqueda: ${radiusKm.toInt()} km",
                        style = MaterialTheme.typography.bodyLarge
                    )
                    Slider(
                        value = radiusKm.toFloat(),
                        onValueChange = { radiusKm = it.toDouble() },
                        valueRange = 1f..20f,
                        steps = 18
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Botón para analizar
            Button(
                onClick = { analyzePrices() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Analizar Precios")
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Resultados
            when (val state = uiState) {
                is AnalyticsUiState.Initial -> {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.secondaryContainer
                        )
                    ) {
                        Text(
                            text = "👆 Presiona el botón para analizar precios en tu zona",
                            modifier = Modifier.padding(16.dp),
                            style = MaterialTheme.typography.bodyLarge
                        )
                    }
                }

                is AnalyticsUiState.Loading -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }

                is AnalyticsUiState.Success -> {
                    PriceAnalyticsResult(analytics = state.analytics)
                }

                is AnalyticsUiState.Error -> {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.errorContainer
                        )
                    ) {
                        Text(
                            text = "❌ Error: ${state.message}",
                            color = MaterialTheme.colorScheme.onErrorContainer,
                            modifier = Modifier.padding(16.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun PriceAnalyticsResult(analytics: PriceAnalytics) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = "📊 Resultados del Análisis",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Precio promedio
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Precio promedio actual:")
                Text(
                    text = "$${String.format("%.2f", analytics.currentAvgPrice)}/día",
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Vehículos encontrados
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Vehículos disponibles:")
                Text(
                    text = "${analytics.totalVehicles}",
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Radio de búsqueda
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Radio de búsqueda:")
                Text(text = "${analytics.radiusKm.toInt()} km")
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Info adicional
            if (analytics.totalVehicles == 0) {
                Text(
                    text = "⚠️ No hay vehículos disponibles en esta zona",
                    color = MaterialTheme.colorScheme.error
                )
            } else {
                Text(
                    text = "💡 Rango de precios: $${analytics.nearbyVehicles.minOf { it.dailyRate }} - $${analytics.nearbyVehicles.maxOf { it.dailyRate }}",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}
