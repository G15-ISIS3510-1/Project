package com.example.kotlinapp.ui.navigation

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
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
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

enum class BottomTab(val label: String) {
    Home("Home"), Trip("Trip"), Messages("Messages"), Host("Host"), Account("Account")
}

@Composable
fun PillBottomNavBar(
    selectedTab: BottomTab = BottomTab.Home,
    onTabSelected: (BottomTab) -> Unit
) {
    var selected by remember { mutableStateOf(selectedTab) }

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
                selectedColor = blue, unselectedColor = grey,
                onClick = { selected = BottomTab.Home; onTabSelected(BottomTab.Home) },
                icon = { DiamondIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Trip,
                label = BottomTab.Trip.label,
                selectedColor = blue, unselectedColor = grey,
                onClick = { selected = BottomTab.Trip; onTabSelected(BottomTab.Trip) },
                icon = { CircleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Messages,
                label = BottomTab.Messages.label,
                selectedColor = blue, unselectedColor = grey,
                onClick = { selected = BottomTab.Messages; onTabSelected(BottomTab.Messages) },
                icon = { TriangleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Host,
                label = BottomTab.Host.label,
                selectedColor = blue, unselectedColor = grey,
                onClick = { selected = BottomTab.Host; onTabSelected(BottomTab.Host) },
                icon = { TriangleIcon(it) }
            )
            BottomItem(
                isSelected = selected == BottomTab.Account,
                label = BottomTab.Account.label,
                selectedColor = blue, unselectedColor = grey,
                onClick = { selected = BottomTab.Account; onTabSelected(BottomTab.Account) },
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
        modifier = Modifier.size(boxSize).offset(y = yOffset),
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
        fun Offset.norm(): Offset { val l = len(); return if (l == 0f) this else Offset(x / l, y / l) }
        fun along(from: Offset, to: Offset, d: Float) = from + (to - from).norm() * d

        val a1 = along(a, b, r); val a2 = along(a, c, r)
        val b1 = along(b, c, r); val b2 = along(b, a, r)
        val c1 = along(c, a, r); val c2 = along(c, b, r)

        val path = Path().apply {
            moveTo(a1.x, a1.y); quadraticTo(a.x, a.y, a2.x, a2.y)
            lineTo(c1.x, c1.y); quadraticTo(c.x, c.y, c2.x, c2.y)
            lineTo(b1.x, b1.y); quadraticTo(b.x, b.y, b2.x, b2.y)
            close()
        }
        drawPath(path, color = tint, style = Fill)
    }
}


