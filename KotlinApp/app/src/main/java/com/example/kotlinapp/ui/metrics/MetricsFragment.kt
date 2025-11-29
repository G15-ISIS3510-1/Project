@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
package com.example.kotlinapp.ui.metrics

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.kotlinapp.App
import com.example.kotlinapp.R
import com.example.kotlinapp.data.api.ApiClient
import kotlinx.coroutines.launch

class MetricsFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val navController = findNavController()
        return ComposeView(requireContext()).apply {
            setContent {
                MetricsScreen(
                    onBackClick = {
                        navController.popBackStack()
                    },
                    onTestBatchRatingStats = { vehicleIds ->
                        val bundle = Bundle().apply {
                            putStringArray("vehicle_ids", vehicleIds.toTypedArray())
                        }
                        navController.navigate(R.id.batchRatingStatsFragment, bundle)
                    }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MetricsScreen(
    onBackClick: () -> Unit = {},
    onTestBatchRatingStats: (List<String>) -> Unit = {}
) {
    val vm: FeatureUsageViewModel = viewModel()
    val lowUsageFeatures by vm.lowUsageFeatures.collectAsState()
    val usageStats by vm.usageStats.collectAsState()
    val chatTimeStats by vm.chatTimeStats.collectAsState()
    val loading by vm.loading.collectAsState()
    val error by vm.error.collectAsState()
    
    // Estado para IDs de vehículos reales
    // Usar los 5 vehículos que tienen ratings en la base de datos
    val realVehicleIds = remember {
        listOf(
            "07da8f35-6106-465a-a57a-e567b8ac792d",  // Volkswagen - 17 ratings
            "505e9d11-96dd-4fde-9048-2ecd87b465ff",  // Hyundai East - 9 ratings
            "42e0b78f-1e08-43f5-b92f-f929812b141d",  // Ford Somebody - 9 ratings
            "e3ecb219-d5b4-4739-a9d0-6887f777f0aa",  // Hyundai Country - 8 ratings
            "3497c3b1-7e01-4823-a06a-4e9b416f04df"   // Ford Response - 8 ratings
        )
    }
    var loadingVehicles by remember { mutableStateOf(false) }
    
    // Intentar cargar vehículos del usuario (opcional, para mostrar si el usuario tiene vehículos propios)
    LaunchedEffect(Unit) {
        loadingVehicles = true
        try {
            val userId = App.getPreferencesManager().getUserId()
            if (userId != null) {
                val response = ApiClient.vehiclesApi.getOwnerVehicles(userId, skip = 0, limit = 100)
                if (response.isSuccessful) {
                    val vehicles = response.body()?.items ?: emptyList()
                    val userVehicleIds = vehicles.map { it.vehicle_id }
                    android.util.Log.d("MetricsFragment", "User has ${userVehicleIds.size} vehicles: $userVehicleIds")
                    // Nota: Seguimos usando los 5 vehículos con ratings para la prueba
                } else {
                    android.util.Log.w("MetricsFragment", "Failed to load user vehicles: ${response.code()}")
                }
            } else {
                android.util.Log.w("MetricsFragment", "User ID is null")
            }
        } catch (e: Exception) {
            android.util.Log.e("MetricsFragment", "Error loading user vehicles", e)
        } finally {
            loadingVehicles = false
        }
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Usage Metrics") },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onSurface
                )
            )
        },
        containerColor = MaterialTheme.colorScheme.surface
    ) { padding ->
        when {
            loading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
                        Spacer(Modifier.height(16.dp))
                        Text("Loading metrics...", color = MaterialTheme.colorScheme.onSurface)
                    }
                }
            }
            error != null -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(16.dp)
                ) {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceVariant
                        )
                    ) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Default.Error,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.primary,
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(Modifier.height(8.dp))
                            Text(
                                "Error loading data",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                error ?: "Unknown error",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                textAlign = TextAlign.Center
                            )
                            Spacer(Modifier.height(16.dp))
                            Button(
                                onClick = { vm.refresh() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = MaterialTheme.colorScheme.surface,
                                    contentColor = MaterialTheme.colorScheme.onPrimary
                                )
                            ) {
                                Icon(Icons.Default.Refresh, contentDescription = null)
                                Spacer(Modifier.width(8.dp))
                                Text("Retry")
                            }
                        }
                    }
                }
            }
            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Card de información header
                    item {
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surface
                            ),
                            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Icon(
                                    imageVector = Icons.Default.Insights,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.size(32.dp)
                                )
                                Spacer(Modifier.height(8.dp))
                                Text(
                                    "Low Usage Features",
                                    style = MaterialTheme.typography.headlineSmall,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                Text(
                                    "Less than 2 times per week per user",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                                )
                            }
                        }
                    }
                    
                    // Estado vacío
                    if (lowUsageFeatures.isEmpty() && usageStats.isEmpty()) {
                        item {
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                colors = CardDefaults.cardColors(
                                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                                )
                            ) {
                                Column(
                                    modifier = Modifier
                                        .padding(32.dp)
                                        .fillMaxWidth(),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.CheckCircle,
                                        contentDescription = null,
                                        modifier = Modifier.size(64.dp),
                                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                    Spacer(Modifier.height(16.dp))
                                    Text(
                                        "Excellent!",
                                        style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.primary
                                    )
                                    Text(
                                        "All features are used frequently",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        textAlign = TextAlign.Center
                                    )
                                }
                            }
                        }
                    } else {
                        // Funcionalidades con bajo uso
                        if (lowUsageFeatures.isNotEmpty()) {
                            item {
                                Text(
                                    "Low Usage Features",
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(vertical = 8.dp),
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                            
                            items(lowUsageFeatures) { feature ->
                                LowUsageFeatureCard(feature)
                            }
                            
                            item {
                                Spacer(Modifier.height(8.dp))
                            }
                        }
                        
                        // Estadísticas de tiempo en chat
                        val chatStats = chatTimeStats
                        if (chatStats != null && chatStats.totalSessions > 0) {
                            item {
                                Text(
                                    "Chat Time Statistics",
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(vertical = 8.dp),
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                            
                            item {
                                ChatTimeStatCard(chatStats)
                            }
                            
                            item {
                                Spacer(Modifier.height(16.dp))
                            }
                        }
                        
                        // Estadísticas generales
                        val otherStats = usageStats.filter { 
                            it.featureName != "time_spent_in_chat_before_leave" 
                        }
                        if (otherStats.isNotEmpty()) {
                            item {
                                Text(
                                    "General Statistics",
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(vertical = 8.dp),
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                            
                            items(otherStats.sortedByDescending { it.totalUses }) { stat ->
                                FeatureStatCard(stat)
                            }
                            
                            item {
                                Spacer(Modifier.height(24.dp))
                            }
                        }
                    }
                    
                    // Botón de prueba para Batch Rating Stats
                    item {
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.secondaryContainer
                            ),
                            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Column(
                                modifier = Modifier
                                    .padding(20.dp)
                                    .fillMaxWidth()
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Star,
                                        contentDescription = null,
                                        tint = MaterialTheme.colorScheme.secondary,
                                        modifier = Modifier.size(32.dp)
                                    )
                                    Spacer(Modifier.width(12.dp))
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(
                                            "Test Batch Rating Stats",
                                            style = MaterialTheme.typography.titleMedium,
                                            fontWeight = FontWeight.Bold,
                                            color = MaterialTheme.colorScheme.onSecondaryContainer
                                        )
                                        Text(
                                            "Probar procesamiento de estadísticas de ratings en batch",
                                            style = MaterialTheme.typography.bodySmall,
                                            color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                                        )
                                    }
                                }
                                Spacer(Modifier.height(16.dp))
                                
                                // Mostrar información sobre vehículos con ratings
                                Text(
                                    "${realVehicleIds.size} vehículo(s) con ratings disponibles para prueba",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                                )
                                Spacer(Modifier.height(8.dp))
                                
                                Button(
                                    onClick = {
                                        // Usar los 5 vehículos que tienen ratings
                                        android.util.Log.d("MetricsFragment", "Testing with ${realVehicleIds.size} vehicle IDs: $realVehicleIds")
                                        onTestBatchRatingStats(realVehicleIds)
                                    },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = MaterialTheme.colorScheme.secondary
                                    ),
                                    enabled = !loadingVehicles
                                ) {
                                    Icon(Icons.Default.PlayArrow, contentDescription = null)
                                    Spacer(Modifier.width(8.dp))
                                    Text("Probar con ${realVehicleIds.size} vehículo(s) con ratings")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LowUsageFeatureCard(feature: com.example.kotlinapp.data.remote.dto.FeatureUsageItemDto) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        ),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Warning,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(32.dp)
            )
            
            Spacer(Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    feature.featureName.replace("_", " ").replaceFirstChar { 
                        if (it.isLowerCase()) it.titlecase() else it.toString() 
                    },
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.People,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        "${feature.uniqueUsers} unique users",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Spacer(Modifier.width(8.dp))
            
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = MaterialTheme.colorScheme.primary
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    horizontalAlignment = Alignment.End
                ) {
                    Text(
                        String.format("%.2f", feature.avgUsesPerWeekPerUser),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Text(
                        "uses/week",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                    )
                }
            }
        }
    }
}

@Composable
fun ChatTimeStatCard(stats: com.example.kotlinapp.data.remote.dto.ChatTimeStatsDto) {
    // Formatear duración promedio
    val avgDurationFormatted = formatDuration(stats.avgDurationSeconds)
    val medianDurationFormatted = formatDuration(stats.medianDurationSeconds)
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        ),
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier
                .padding(20.dp)
                .fillMaxWidth()
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Message,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(32.dp)
                    )
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text(
                            "Time Spent in Chat",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        Text(
                            "Before switching sections",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                        )
                    }
                }
            }
            
            Spacer(Modifier.height(24.dp))
            
            // Destacar la duración promedio
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primary
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(
                    modifier = Modifier
                        .padding(16.dp)
                        .fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        "Average Time",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        avgDurationFormatted,
                        style = MaterialTheme.typography.displaySmall,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Text(
                        "per session in Messages",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.7f)
                    )
                }
            }
            
            Spacer(Modifier.height(20.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatItem(
                    label = "Total Sessions",
                    value = "${stats.totalSessions}",
                    icon = Icons.Default.AccessTime,
                    color = MaterialTheme.colorScheme.primary
                )
                StatItem(
                    label = "Median Time",
                    value = medianDurationFormatted,
                    icon = Icons.Default.TrendingUp,
                    color = MaterialTheme.colorScheme.tertiary
                )
            }
            
            Spacer(Modifier.height(16.dp))
            
            Divider(
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.2f),
                thickness = 1.dp
            )
            
            Spacer(Modifier.height(12.dp))
            
            Text(
                "This metric tracks how long users spend in the Messages section before navigating to another part of the app.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
                lineHeight = MaterialTheme.typography.bodySmall.lineHeight * 1.2
            )
        }
    }
}

fun formatDuration(seconds: Double): String {
    return when {
        seconds < 60 -> String.format("%.1f sec", seconds)
        seconds < 3600 -> {
            val minutes = (seconds / 60).toInt()
            val remainingSeconds = (seconds % 60).toInt()
            if (remainingSeconds == 0) {
                "$minutes min"
            } else {
                "$minutes min $remainingSeconds sec"
            }
        }
        else -> {
            val hours = (seconds / 3600).toInt()
            val remainingMinutes = ((seconds % 3600) / 60).toInt()
            if (remainingMinutes == 0) {
                "$hours hr"
            } else {
                "$hours hr $remainingMinutes min"
            }
        }
    }
}

@Composable
fun StatItem(label: String, value: String, icon: androidx.compose.ui.graphics.vector.ImageVector, color: Color) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(horizontal = 8.dp)
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = color,
            modifier = Modifier.size(24.dp)
        )
        Spacer(Modifier.height(8.dp))
        Text(
            value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onPrimaryContainer
        )
        Spacer(Modifier.height(4.dp))
        Text(
            label,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f),
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun FeatureStatCard(stat: com.example.kotlinapp.data.remote.dto.FeatureStatDto) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        ),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    stat.featureName.replace("_", " ").replaceFirstChar { 
                        if (it.isLowerCase()) it.titlecase() else it.toString() 
                    },
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "${stat.totalUses} total uses • ${stat.uniqueUsers} users",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                )
            }
            
            Spacer(Modifier.width(8.dp))
            
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = MaterialTheme.colorScheme.primary
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    horizontalAlignment = Alignment.End
                ) {
                    Text(
                        String.format("%.2f", stat.avgUsesPerWeekPerUser),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Text(
                        "per week",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                    )
                }
            }
        }
    }
}

