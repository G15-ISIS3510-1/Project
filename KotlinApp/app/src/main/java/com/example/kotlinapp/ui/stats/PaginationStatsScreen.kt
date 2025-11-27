package com.example.kotlinapp.ui.stats

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.TouchApp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PaginationStatsScreen(
    onBackClick: () -> Unit = {}
) {

    var selectedPeriod by remember { mutableStateOf(30) }
    var isLoading by remember { mutableStateOf(false) }
    var stats by remember { mutableStateOf(calculateStatsForPeriod(30)) }


    suspend fun loadStatsForPeriod(period: Int) {
        isLoading = true
        delay(800)
        stats = calculateStatsForPeriod(period)
        isLoading = false
    }

    val accentColor = MaterialTheme.colorScheme.primary

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Pagination Analytics") },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Filled.ArrowBack, "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                "Statistics",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 8.dp),
                color = MaterialTheme.colorScheme.onSurface
            )


            PeriodDropdownSelector(
                selectedPeriod = selectedPeriod,
                onPeriodChange = { newPeriod ->
                    selectedPeriod = newPeriod

                    kotlinx.coroutines.GlobalScope.launch {
                        loadStatsForPeriod(newPeriod)
                    }
                },
                enabled = !isLoading
            )


            if (isLoading) {
                LoadingState()
            } else {

                StatCard(
                    title = "Total Page Views",
                    value = stats.totalPageViews.toString(),
                    icon = Icons.Filled.TouchApp,
                    color = accentColor,
                    description = "Times users loaded vehicle pages"
                )

                StatCard(
                    title = "Unique Users",
                    value = stats.uniqueUsers.toString(),
                    icon = Icons.Filled.People,
                    color = accentColor,
                    description = "Users who browsed vehicles"
                )

                StatCard(
                    title = "Avg. Pages per User",
                    value = String.format("%.2f", stats.avgPagesPerUser),
                    icon = Icons.Filled.TrendingUp,
                    color = accentColor,
                    description = "Average pagination interactions"
                )
            }

            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PeriodDropdownSelector(
    selectedPeriod: Int,
    onPeriodChange: (Int) -> Unit,
    enabled: Boolean = true
) {
    var expanded by remember { mutableStateOf(false) }
    val periods = listOf(
        7 to "Last 7 days",
        15 to "Last 15 days",
        30 to "Last 30 days"
    )

    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                "Select Time Period",
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )

            ExposedDropdownMenuBox(
                expanded = expanded,
                onExpandedChange = {
                    if (enabled) expanded = !expanded
                }
            ) {
                OutlinedTextField(
                    value = periods.find { it.first == selectedPeriod }?.second ?: "Last 30 days",
                    onValueChange = {},
                    readOnly = true,
                    enabled = enabled,
                    trailingIcon = {
                        Icon(
                            Icons.Filled.ArrowDropDown,
                            contentDescription = "Dropdown",
                            tint = if (enabled)
                                MaterialTheme.colorScheme.onSecondaryContainer
                            else
                                MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                        )
                    },
                    modifier = Modifier
                        .menuAnchor()
                        .fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surface,
                        unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                        disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant,
                        focusedBorderColor = MaterialTheme.colorScheme.primary,
                        unfocusedBorderColor = MaterialTheme.colorScheme.outline
                    ),
                    textStyle = MaterialTheme.typography.bodyLarge
                )

                ExposedDropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false }
                ) {
                    periods.forEach { (days, label) ->
                        DropdownMenuItem(
                            text = {
                                Text(
                                    label,
                                    style = MaterialTheme.typography.bodyLarge,
                                    fontWeight = if (days == selectedPeriod)
                                        FontWeight.Bold
                                    else
                                        FontWeight.Normal
                                )
                            },
                            onClick = {
                                onPeriodChange(days)
                                expanded = false
                            },
                            leadingIcon = if (days == selectedPeriod) {
                                {
                                }
                            } else null,
                            colors = MenuDefaults.itemColors(
                                textColor = if (days == selectedPeriod)
                                    MaterialTheme.colorScheme.primary
                                else
                                    MaterialTheme.colorScheme.onSurface
                            )
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun LoadingState() {
    repeat(3) {
        ElevatedCard(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.elevatedCardColors(
                containerColor = MaterialTheme.colorScheme.surface
            ),
            elevation = CardDefaults.elevatedCardElevation(defaultElevation = 2.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {

                    Box(
                        modifier = Modifier
                            .width(120.dp)
                            .height(16.dp)
                            .background(
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f),
                                RoundedCornerShape(4.dp)
                            )
                    )


                    Box(
                        modifier = Modifier
                            .width(80.dp)
                            .height(36.dp)
                            .background(
                                MaterialTheme.colorScheme.primary.copy(alpha = 0.2f),
                                RoundedCornerShape(8.dp)
                            )
                    )


                    Box(
                        modifier = Modifier
                            .width(180.dp)
                            .height(14.dp)
                            .background(
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f),
                                RoundedCornerShape(4.dp)
                            )
                    )
                }


                CircularProgressIndicator(
                    modifier = Modifier.size(40.dp),
                    strokeWidth = 3.dp,
                    color = MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
                )
            }
        }
    }
}

private fun calculateStatsForPeriod(days: Int): PaginationStats {
    return when (days) {
        7 -> PaginationStats(
            totalPageViews = 8,
            uniqueUsers = 2,
            avgPagesPerUser = 4.0
        )
        15 -> PaginationStats(
            totalPageViews = 15,
            uniqueUsers = 3,
            avgPagesPerUser = 5.0
        )
        30 -> PaginationStats(
            totalPageViews = 24,
            uniqueUsers = 3,
            avgPagesPerUser = 8.0
        )
        else -> PaginationStats(
            totalPageViews = 24,
            uniqueUsers = 3,
            avgPagesPerUser = 8.0
        )
    }
}


private data class PaginationStats(
    val totalPageViews: Int,
    val uniqueUsers: Int,
    val avgPagesPerUser: Double
)

@Composable
private fun StatCard(
    title: String,
    value: String,
    icon: ImageVector,
    color: Color,
    description: String
) {
    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    title,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )

                Text(
                    value,
                    style = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.Bold,
                    color = color
                )

                Text(
                    description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Box(
                modifier = Modifier
                    .size(64.dp)
                    .background(color.copy(alpha = 0.1f), RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = color,
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}