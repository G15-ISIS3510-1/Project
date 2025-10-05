package com.example.kotlinapp.ui.home

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.Button
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage

import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar


@Composable
fun HomeScreen(
    viewModel: HomeViewModel = viewModel(),
    onCardClick: (VehicleItem) -> Unit = {},
    onBottomClick: (BottomTab) -> Unit = {},
    onTopRatedClick: () -> Unit = {}
) {
    val categories = listOf("Cars", "SUVs", "Minivans", "Trucks", "Vans", "Luxury")


    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = { TopLogoBar() },
        bottomBar = {
            PillBottomNavBar(selectedTab = BottomTab.Home) { tab ->
                onBottomClick(tab)
            }
        },
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
                SearchBar(
                    value = uiState.searchQuery,
                    onChange = { viewModel.onSearchQueryChange(it) },
                    onMic = { }
                )
            }
            item {
                TopRatedButton(onClick = onTopRatedClick)
            }
            item {
                CategoryChips(
                    categories = categories,
                    selectedCategory = uiState.selectedCategory,
                    onCategoryClick = { viewModel.onCategorySelected(it) }
                )
            }


            if (uiState.searchQuery.isNotBlank() || uiState.selectedCategory != null) {
                item {
                    FilterIndicator(
                        searchQuery = uiState.searchQuery,
                        selectedCategory = uiState.selectedCategory,
                        onClear = { viewModel.clearFilters() }
                    )
                }
            }


            when {
                uiState.loading -> {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator()
                        }
                    }
                }
                uiState.error != null -> {
                    item {
                        ErrorMessage(
                            error = uiState.error ?: "Unknown error",
                            onRetry = { viewModel.retry() }
                        )
                    }
                }
                uiState.vehicles.isEmpty() -> {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                "No vehicles available",
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
                else -> {

                    items(uiState.vehicles) { vehicle ->
                        val priceText = "${vehicle.currency} ${String.format("%.2f", vehicle.dailyRate)}/día"

                        val vehicleItem = VehicleItem(
                            title = "${vehicle.brand} ${vehicle.model} ${vehicle.year}",
                            rating = 4.5,
                            transmission = vehicle.transmission,
                            price = priceText,
                            imageUrl = vehicle.imageUrl
                        )
                        VehicleCard(vehicleItem, onFavorite = { }) { onCardClick(vehicleItem) }
                    }
                }
            }

            item { Spacer(Modifier.height(24.dp)) }
        }
    }
}

@Composable
private fun ErrorMessage(error: String, onRetry: () -> Unit) {
    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "⚠️ Error",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = error,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
            Spacer(Modifier.height(12.dp))
            Button(onClick = onRetry) {
                Text("Reintentar")
            }
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
            Text(
                "QOVO",
                fontSize = 28.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 1.sp,
                color = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}

@Composable
private fun SearchBar(
    value: String,
    onChange: (String) -> Unit,
    onMic: () -> Unit
) {
    val surfaceVariantColor = MaterialTheme.colorScheme.surfaceVariant
    val onSurfaceVariantColor = MaterialTheme.colorScheme.onSurfaceVariant

    TextField(
        value = value,
        onValueChange = onChange,
        placeholder = { Text("Search", color = onSurfaceVariantColor) },
        leadingIcon = {
            Icon(
                imageVector = Icons.Filled.Search,
                contentDescription = "Search",
                tint = onSurfaceVariantColor
            )
        },

        singleLine = true,
        shape = RoundedCornerShape(24.dp),
        colors = TextFieldDefaults.colors(
            unfocusedContainerColor = surfaceVariantColor,
            focusedContainerColor = surfaceVariantColor,
            unfocusedIndicatorColor = Color.Transparent,
            focusedIndicatorColor = Color.Transparent
        ),
        modifier = Modifier.fillMaxWidth()
    )
}

@Composable
private fun CategoryChips(
    categories: List<String>,
    selectedCategory: String?,
    onCategoryClick: (String) -> Unit
) {
    val onSurfaceColor = MaterialTheme.colorScheme.onSurface

    LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        items(categories) { label ->
            val isSelected = selectedCategory == label
            val chipColor = if (isSelected) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surfaceVariant
            }
            val textColor = if (isSelected) {
                MaterialTheme.colorScheme.onPrimaryContainer
            } else {
                onSurfaceColor
            }

            AssistChip(
                onClick = { onCategoryClick(label) },
                label = { Text(label, color = textColor, fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal) },
                shape = RoundedCornerShape(16.dp),
                colors = AssistChipDefaults.assistChipColors(containerColor = chipColor),
                border = if (isSelected) {
                    AssistChipDefaults.assistChipBorder(
                        enabled = true,
                        borderColor = MaterialTheme.colorScheme.primary,
                        borderWidth = 2.dp
                    )
                } else {
                    AssistChipDefaults.assistChipBorder(true)
                }
            )
        }
    }
}

@Composable
private fun VehicleCard(
    item: VehicleItem,
    onFavorite: (VehicleItem) -> Unit,
    onClick: (VehicleItem) -> Unit
) {
    val surfaceColor = MaterialTheme.colorScheme.surface
    val onSurfaceColor = MaterialTheme.colorScheme.onSurface
    val surfaceVariantColor = MaterialTheme.colorScheme.surfaceVariant
    val onSurfaceVariantColor = MaterialTheme.colorScheme.onSurfaceVariant
    val starColor = MaterialTheme.colorScheme.tertiary
    val priceColor = MaterialTheme.colorScheme.primary
    val favoriteColor = MaterialTheme.colorScheme.error

    ElevatedCard(
        onClick = { onClick(item) },
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(containerColor = surfaceColor)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(140.dp)
                .background(surfaceVariantColor),
            contentAlignment = Alignment.Center
        ) {

            if (item.imageUrl != null) {
                AsyncImage(
                    model = item.imageUrl,
                    contentDescription = item.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop,
                    error = painterResource(android.R.drawable.ic_menu_gallery),
                    placeholder = painterResource(android.R.drawable.ic_menu_gallery)
                )
            } else {
                Icon(
                    imageVector = Icons.Filled.Image,
                    contentDescription = null,
                    tint = onSurfaceVariantColor,
                    modifier = Modifier.size(48.dp)
                )
            }

            Icon(
                imageVector = Icons.Outlined.FavoriteBorder,
                contentDescription = "Fav",
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(12.dp)
                    .size(22.dp),
                tint = favoriteColor
            )
        }

        Column(Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    item.title,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.SemiBold
                    ),
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = onSurfaceColor
                )
                Icon(
                    Icons.Filled.Star,
                    contentDescription = null,
                    tint = starColor,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(Modifier.width(4.dp))
                Text(item.rating.toString(), fontSize = 12.sp, color = starColor)
            }
            Spacer(Modifier.height(6.dp))
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(item.transmission, color = onSurfaceVariantColor)
                Text(
                    item.price,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Bold
                    ),
                    color = priceColor
                )
            }
        }
    }
}

@Composable
private fun FilterIndicator(
    searchQuery: String,
    selectedCategory: String?,
    onClear: () -> Unit
) {
    ElevatedCard(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    "Filtros activos",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.height(4.dp))
                val filters = buildList {
                    if (searchQuery.isNotBlank()) add("Búsqueda: \"$searchQuery\"")
                    if (selectedCategory != null) add("Categoría: $selectedCategory")
                }
                Text(
                    filters.joinToString(", "),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
            }
            Button(
                onClick = onClear,
                modifier = Modifier.height(32.dp),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)
            ) {
                Text("Limpiar", style = MaterialTheme.typography.labelSmall)
            }
        }
    }
}

@Composable
private fun TopRatedButton(onClick: () -> Unit) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.elevatedCardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        ),
        elevation = CardDefaults.elevatedCardElevation(defaultElevation = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column {
                Text(
                    text = "🏆 Vehículos Top Rated",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Descubre los vehículos mejor calificados",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
            Icon(
                imageVector = Icons.Filled.Star,
                contentDescription = "Top Rated",
                tint = Color.Yellow,
                modifier = Modifier.size(32.dp)
            )
        }
    }
}


@Composable
fun PillBottomNavBar(
    selectedTab: BottomTab = BottomTab.Home,
    onTabSelected: (BottomTab) -> Unit
) {
    var selected by remember { mutableStateOf(selectedTab) }
    PillBar(selected = selected) { selected = it; onTabSelected(it) }
}

@Composable
private fun PillBar(selected: BottomTab, onSelect: (BottomTab) -> Unit) {
    val blue = MaterialTheme.colorScheme.primary
    val grey = MaterialTheme.colorScheme.onSurfaceVariant
    val bg = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .windowInsetsPadding(WindowInsets.navigationBars)
    ) {
        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .shadow(16.dp, RoundedCornerShape(28.dp), clip = false)
                .clip(RoundedCornerShape(28.dp))
                .background(bg)
                .padding(horizontal = 14.dp, vertical = 10.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            BottomItem(
                isSelected = selected == BottomTab.Home,
                label = BottomTab.Home.label,
                selectedColor = blue,
                unselectedColor = grey,
                onClick = { onSelect(BottomTab.Home) },
                icon = { DiamondIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Trip,
                label = BottomTab.Trip.label,
                selectedColor = blue,
                unselectedColor = grey,
                onClick = { onSelect(BottomTab.Trip) },
                icon = { CircleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Messages,
                label = BottomTab.Messages.label,
                selectedColor = blue,
                unselectedColor = grey,
                onClick = { onSelect(BottomTab.Messages) },
                icon = { TriangleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Host,
                label = BottomTab.Host.label,
                selectedColor = blue,
                unselectedColor = grey,
                onClick = { onSelect(BottomTab.Host) },
                icon = { TriangleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Account,
                label = BottomTab.Account.label,
                selectedColor = blue,
                unselectedColor = grey,
                onClick = { onSelect(BottomTab.Account) },
                icon = { TriangleIcon(it) }
            )
        }
    }
}

@Composable
private fun BottomItem(
    isSelected: Boolean,
    label: String,
    selectedColor: Color,
    unselectedColor: Color,
    onClick: () -> Unit,
    icon: @Composable (Color) -> Unit
) {
    val color = if (isSelected) selectedColor else unselectedColor

    Column(
        modifier = Modifier
            .width(72.dp)
            .clip(RoundedCornerShape(20.dp))
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        icon(color)
        Spacer(Modifier.height(6.dp))
        Text(
            text = label,
            color = if (isSelected) selectedColor else unselectedColor.copy(alpha = 0.9f),
            style = MaterialTheme.typography.labelMedium
        )
    }
}

@Composable
private fun DiamondIcon(
    tint: Color,
    boxSize: Dp = 24.dp,
    rhombusSize: Dp = 18.dp,
    cornerRadius: Dp = 5.dp,
    yOffset: Dp = 1.dp
) {
    Box(
        modifier = Modifier
            .size(boxSize)
            .offset(y = yOffset),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .size(rhombusSize)
                .rotate(45f)
                .background(tint, RoundedCornerShape(cornerRadius))
        )
    }
}

@Composable
private fun CircleIcon(tint: Color) {
    Box(modifier = Modifier.size(24.dp).background(tint, CircleShape))
}

@Composable
private fun TriangleIcon(
    tint: Color,
    size: Dp = 24.dp,
    cornerRadius: Dp = 3.dp
) {
    val s = with(LocalDensity.current) { size.toPx() }
    val r = with(LocalDensity.current) { cornerRadius.toPx() }.coerceAtMost(s / 5f)

    Canvas(Modifier.size(size)) {
        val a = Offset(s / 2f, 0f)
        val b = Offset(0f, s)
        val c = Offset(s, s)

        fun Offset.len() = kotlin.math.sqrt(x * x + y * y)
        fun Offset.norm(): Offset {
            val l = len()
            return if (l == 0f) this else Offset(x / l, y / l)
        }
        fun along(from: Offset, to: Offset, d: Float) = from + (to - from).norm() * d

        val a1 = along(a, b, r)
        val a2 = along(a, c, r)
        val b1 = along(b, c, r)
        val b2 = along(b, a, r)
        val c1 = along(c, a, r)
        val c2 = along(c, b, r)

        val path = Path().apply {
            moveTo(a1.x, a1.y)
            quadraticTo(a.x, a.y, a2.x, a2.y)
            lineTo(c1.x, c1.y)
            quadraticTo(c.x, c.y, c2.x, c2.y)
            lineTo(b1.x, b1.y)
            quadraticTo(b.x, b.y, b2.x, b2.y)
            close()
        }
        drawPath(path, color = tint, style = Fill)
    }
}

data class VehicleItem(
    val title: String,
    val rating: Double,
    val transmission: String,
    val price: String,
    val imageUrl: String? = null
)