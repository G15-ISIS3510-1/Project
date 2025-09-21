package com.example.kotlinapp.ui.load

import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun LoadScreen(
    onFinished: (() -> Unit)? = null,
    durationMs: Long = 1200,
    yOffsetLogo: Dp = 0.dp,
    showSpinner: Boolean = true,
    spinnerSize: Dp = 28.dp,
    spinnerStroke: Dp = 3.dp,
    spinnerTopGap: Dp = 24.dp
) {
    LaunchedEffect(onFinished, durationMs) {
        if (onFinished != null) {
            delay(durationMs)
            onFinished()
        }
    }

    Surface(color = Color.White) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.systemBars),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "QOVO",
                    fontSize = 64.sp,
                    fontWeight = FontWeight.SemiBold,
                    letterSpacing = 2.sp,
                    color = Color.Black,
                    modifier = Modifier.offset(y = yOffsetLogo)
                )

                if (showSpinner) {
                    Spacer(Modifier.height(spinnerTopGap))
                    CircularProgressIndicator(
                        modifier = Modifier.size(spinnerSize),
                        color = Color.Black,
                        strokeWidth = spinnerStroke
                    )
                }
            }
        }
    }
}