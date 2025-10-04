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
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
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
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp


@Composable
fun HomeScreen(
    onCardClick: (VehicleItem) -> Unit = {},
    onBottomClick: (BottomTab) -> Unit = {}
) {
    var query by remember { mutableStateOf("") }
    val categories = listOf("Cars", "SUVs", "Minivans", "Trucks", "Vans", "Luxury")
    val items = sampleVehicles


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
                    value = query,
                    onChange = { query = it },
                    onMic = { }
                )
            }
            item { CategoryChips(categories = categories) }
            items(items) { v ->
                VehicleCard(v, onFavorite = { }) { onCardClick(v) }
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
            Text("QOVO", fontSize = 28.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 1.sp, color = MaterialTheme.colorScheme.onSurface)
        }
    }
}

@Composable
private fun SearchBar(
    value: String,
    onChange: (String) -> Unit,
    onMic: () -> Unit
) {
    // Colores del sistema Material Design
    val surfaceVariantColor = MaterialTheme.colorScheme.surfaceVariant
    val onSurfaceVariantColor = MaterialTheme.colorScheme.onSurfaceVariant
    
    TextField(
        value = value,
        onValueChange = onChange,
        placeholder = { Text("Search", color = onSurfaceVariantColor) },
        leadingIcon = { Icon(imageVector = Icons.Filled.Search, contentDescription = "Search", tint = onSurfaceVariantColor) },
        trailingIcon = {
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(surfaceVariantColor)
                    .clickable { onMic() },
                contentAlignment = Alignment.Center
            ) { Icon(imageVector = Icons.Filled.Mic, contentDescription = "Mic", tint = onSurfaceVariantColor) }
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
private fun CategoryChips(categories: List<String>) {
    // Colores del sistema Material Design
    val surfaceColor = MaterialTheme.colorScheme.surface
    val onSurfaceColor = MaterialTheme.colorScheme.onSurface
    
    // Color del sistema para chips
    val chipColor = MaterialTheme.colorScheme.surfaceVariant
    
    LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        items(categories) { label ->
            AssistChip(
                onClick = { },
                label = { Text(label, color = onSurfaceColor) },
                shape = RoundedCornerShape(16.dp),
                       colors = AssistChipDefaults.assistChipColors(containerColor = chipColor),
                border = AssistChipDefaults.assistChipBorder(true)
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
    // Colores del sistema Material Design
    val surfaceColor = MaterialTheme.colorScheme.surface
    val onSurfaceColor = MaterialTheme.colorScheme.onSurface
    val surfaceVariantColor = MaterialTheme.colorScheme.surfaceVariant
    val onSurfaceVariantColor = MaterialTheme.colorScheme.onSurfaceVariant
    
    // Colores del sistema Material Design
    val starColor = MaterialTheme.colorScheme.tertiary // Naranja para estrellas
    val priceColor = MaterialTheme.colorScheme.primary // Azul para precios
    val favoriteColor = MaterialTheme.colorScheme.error // Rojo para favoritos
    
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
            Icon(
                imageVector = Icons.Filled.Image,
                contentDescription = null,
                tint = onSurfaceVariantColor,
                modifier = Modifier.size(48.dp)
            )
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
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
                Text(
                    item.title,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = onSurfaceColor
                )
                Icon(Icons.Filled.Star, contentDescription = null, tint = starColor, modifier = Modifier.size(16.dp))
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
                Text(item.price, style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold), color = priceColor)
            }
        }
    }
}


enum class BottomTab(val label: String) { Home("Home"), Trip("Trip"), Messages("Messages"), Host("Host"), Account("Account") }

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
    // Colores del sistema Material Design para navegación
    val blue = MaterialTheme.colorScheme.primary // Azul para seleccionado
    val grey = MaterialTheme.colorScheme.onSurfaceVariant // Gris para no seleccionado
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
@Composable private fun CircleIcon(tint: Color) {
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
            val l = len(); return if (l == 0f) this else Offset(x / l, y / l)
        }
        fun along(from: Offset, to: Offset, d: Float) = from + (to - from).norm() * d

        val a1 = along(a, b, r); val a2 = along(a, c, r)
        val b1 = along(b, c, r); val b2 = along(b, a, r)
        val c1 = along(c, a, r); val c2 = along(c, b, r)

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

private val sampleVehicles = listOf(
    VehicleItem("Mercedes Blue 2023", 4.8, "Automatic", "$176,037.11"),
    VehicleItem("Audi A4 2022", 4.7, "Automatic", "$92,510.00"),
    VehicleItem("BMW X3 2021", 4.6, "Manual", "$80,990.00")
)