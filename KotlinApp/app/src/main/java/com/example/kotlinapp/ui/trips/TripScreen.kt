package com.example.kotlinapp.ui.trips

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar


@Composable
fun TripScreen(
    onBottomClick: (BottomTab) -> Unit = {}
) {
    var query by remember { mutableStateOf("") }
    var selected by remember { mutableStateOf(TripFilter.All) }

    val trips = remember { sampleTrips }
    val filtered = remember(trips, selected) {
        when (selected) {
            TripFilter.All -> trips
            else -> trips.filter { it.status == selected }
        }
    }

    Scaffold(
        topBar = { TopLogoBar() },
        bottomBar = { PillBottomNavBar(selectedTab = BottomTab.Trip, onTabSelected = onBottomClick) },
        containerColor = MaterialTheme.colorScheme.surface
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize(),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                TripSearchBar(
                    value = query,
                    onChange = { query = it },
                    onMic = { }
                )
            }

            item {
                TripSegmented(
                    selected = selected,
                    onSelect = { selected = it }
                )
            }

            items(filtered) { t ->
                TripCard(item = t, onClick = { })
            }

            item { Spacer(Modifier.height(24.dp)) }
        }
    }
}


@Composable
private fun TopLogoBar() {
    Surface(color = MaterialTheme.colorScheme.surface, shadowElevation = 0.dp) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp, bottom = 4.dp),
            contentAlignment = Alignment.Center
        ) {
            Text("QOVO", fontSize = 28.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 1.sp)
        }
    }
}


@Composable
private fun TripSearchBar(
    value: String,
    onChange: (String) -> Unit,
    onMic: () -> Unit
) {
    TextField(
        value = value,
        onValueChange = onChange,
        placeholder = { Text("Search") },
        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = "Search") },
        trailingIcon = {
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .clickable { onMic() },
                contentAlignment = Alignment.Center
            ) { Icon(Icons.Filled.Mic, contentDescription = "Mic") }
        },
        singleLine = true,
        shape = RoundedCornerShape(24.dp),
        colors = TextFieldDefaults.colors(
            unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
            focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
            unfocusedIndicatorColor = Color.Transparent,
            focusedIndicatorColor = Color.Transparent
        ),
        modifier = Modifier.fillMaxWidth()
    )
}


enum class TripFilter(val label: String) { All("All"), Booked("Booked"), History("History") }

@Composable
private fun TripSegmented(
    selected: TripFilter,
    onSelect: (TripFilter) -> Unit,
    height: Dp = 36.dp
) {
    val container = MaterialTheme.colorScheme.surfaceVariant
    val selectedText = MaterialTheme.colorScheme.primary
    val unselectedText = MaterialTheme.colorScheme.onSurfaceVariant

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(container)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TripFilter.values().forEach { option ->
                val isSel = option == selected
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = if (isSel) MaterialTheme.colorScheme.surface else Color.Transparent,
                    shadowElevation = if (isSel) 1.dp else 0.dp,
                    modifier = Modifier
                        .weight(1f)
                        .height(height)
                        .clip(RoundedCornerShape(16.dp))
                        .clickable { onSelect(option) },
                ) {
                    Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                        Text(
                            text = option.label,
                            color = if (isSel) selectedText else unselectedText,
                            fontSize = 12.sp,
                            fontWeight = if (isSel) FontWeight.SemiBold else FontWeight.Medium
                        )
                    }
                }
            }
        }
    }
}


data class TripItem(
    val title: String,
    val date: String,
    val status: TripFilter
)

@Composable
private fun TripCard(item: TripItem, onClick: (TripItem) -> Unit) {
    ElevatedCard(
        onClick = { onClick(item) },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.elevatedCardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    item.title,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(Modifier.height(6.dp))
                Text(
                    item.date,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 12.sp
                )
            }

            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.Image,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}


private val sampleTrips = listOf(
    TripItem("Mercedes Blue 2023", "17 May 2025", TripFilter.All),
    TripItem("Mercedes Blue 2023", "17 May 2025", TripFilter.Booked),
    TripItem("Mercedes Blue 2023", "17 May 2025", TripFilter.History),
    TripItem("Mercedes Blue 2023", "17 May 2025", TripFilter.Booked),
)