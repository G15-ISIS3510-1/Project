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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PriceAnalyticsScreen(
    onBackClick: () -> Unit = {}
) {
    var uiState by remember { mutableStateOf<AnalyticsUiState>(AnalyticsUiState.Initial) }
    var radiusKm by remember { mutableStateOf(5.0) }

    val userLat = 4.6097
    val userLng = -74.0817

    val scope = rememberCoroutineScope()

    // Optimización 1: Mover cálculos pesados a background thread
    fun analyzePrices() {
        scope.launch {
            uiState = AnalyticsUiState.Loading

            try {
                // Ejecutar en IO dispatcher para operaciones pesadas
                val analytics = withContext(Dispatchers.Default) {

                    val response = ApiClient.vehiclesApi.getActiveVehiclesWithPricing()
                    val allVehicles = response.items


                    val nearbyVehicles = allVehicles.filter { vehicle ->
                        vehicle.lat != null && vehicle.lng != null &&
                                GeoUtils.calculateDistance(
                                    userLat, userLng,
                                    vehicle.lat, vehicle.lng
                                ) <= radiusKm
                    }

                    val avgPrice = if (nearbyVehicles.isNotEmpty()) {
                        nearbyVehicles.map { it.dailyRate }.average()
                    } else {
                        0.0
                    }

                    PriceAnalytics(
                        currentAvgPrice = avgPrice,
                        totalVehicles = nearbyVehicles.size,
                        radiusKm = radiusKm,
                        userLocation = Location(userLat, userLng),
                        nearbyVehicles = nearbyVehicles
                    )
                }

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

            // optimización 2: Extraer componentes pesados
            RadiusControl(
                radiusKm = radiusKm,
                onRadiusChange = { radiusKm = it }
            )

            Spacer(modifier = Modifier.height(16.dp))


            Button(
                onClick = { analyzePrices() },
                modifier = Modifier.fillMaxWidth(),
                enabled = uiState !is AnalyticsUiState.Loading
            ) {
                Text("Analizar Precios")
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Resultados
            when (val state = uiState) {
                is AnalyticsUiState.Initial -> {
                    InitialState()
                }

                is AnalyticsUiState.Loading -> {
                    LoadingState()
                }

                is AnalyticsUiState.Success -> {
                    PriceAnalyticsResult(analytics = state.analytics)
                }

                is AnalyticsUiState.Error -> {
                    ErrorState(message = state.message)
                }
            }
        }
    }
}

// Optimización 3: Componentes separados para evitar recomposiciones innecesarias
@Composable
private fun RadiusControl(
    radiusKm: Double,
    onRadiusChange: (Double) -> Unit
) {
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
                onValueChange = { onRadiusChange(it.toDouble()) },
                valueRange = 1f..20f,
                steps = 18
            )
        }
    }
}

@Composable
private fun InitialState() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Text(
            text = "Presiona el botón para analizar precios en tu zona",
            modifier = Modifier.padding(16.dp),
            style = MaterialTheme.typography.bodyLarge
        )
    }
}

@Composable
private fun LoadingState() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            CircularProgressIndicator()
            Text(
                "Analizando precios...",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun ErrorState(message: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
        )
    ) {
        Text(
            text = "Error: $message",
            color = MaterialTheme.colorScheme.onErrorContainer,
            modifier = Modifier.padding(16.dp)
        )
    }
}

@Composable
fun PriceAnalyticsResult(analytics: PriceAnalytics) {
    // optimización 4: Calcular min/max una sola vez con remember
    val priceRange = remember(analytics.nearbyVehicles) {
        if (analytics.nearbyVehicles.isNotEmpty()) {
            var min = Double.MAX_VALUE
            var max = Double.MIN_VALUE

            // Una sola iteración para calcular min y max
            analytics.nearbyVehicles.forEach { vehicle ->
                if (vehicle.dailyRate < min) min = vehicle.dailyRate
                if (vehicle.dailyRate > max) max = vehicle.dailyRate
            }

            Pair(min, max)
        } else {
            Pair(0.0, 0.0)
        }
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = "Resultados del Análisis",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Precio promedio
            ResultRow(
                label = "Precio promedio actual:",
                value = "$${String.format("%.2f", analytics.currentAvgPrice)}/día",
                valueColor = MaterialTheme.colorScheme.primary
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Vehículos encontrados
            ResultRow(
                label = "Vehículos disponibles:",
                value = "${analytics.totalVehicles}"
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Radio de búsqueda
            ResultRow(
                label = "Radio de búsqueda:",
                value = "${analytics.radiusKm.toInt()} km"
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Info adicional
            if (analytics.totalVehicles == 0) {
                Text(
                    text = "No hay vehículos disponibles en esta zona",
                    color = MaterialTheme.colorScheme.error
                )
            } else {
                Text(
                    text = "Rango de precios: $${String.format("%.2f", priceRange.first)} - $${String.format("%.2f", priceRange.second)}",
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}

// Optimización 5: Componente reutilizable para filas de resultados
@Composable
private fun ResultRow(
    label: String,
    value: String,
    valueColor: androidx.compose.ui.graphics.Color = MaterialTheme.colorScheme.onSurface
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label)
        Text(
            text = value,
            fontWeight = FontWeight.Bold,
            color = valueColor
        )
    }
}