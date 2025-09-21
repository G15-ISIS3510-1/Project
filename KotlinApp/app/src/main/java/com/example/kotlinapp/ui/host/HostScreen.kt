package com.example.kotlinapp.ui.host

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp


@Composable
fun HostScreen(
    onSubmitPin: (String) -> Unit = {}
) {
    val topOffset = 210.dp
    val logoSizeSp = 56.sp
    val pinBoxWidth = 64.dp
    val pinBoxHeight = 88.dp
    val pinCorner = 14.dp
    val buttonWidth = 280.dp
    val buttonHeight = 56.dp
    val spaceAfterLogo = 56.dp

    Surface(color = Color.White) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(topOffset))


            Text(
                text = "QOVO",
                fontSize = logoSizeSp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 2.sp,
                color = Color.Black
            )

            Spacer(Modifier.height(spaceAfterLogo))

            Text(
                text = "Host PIN",
                style = MaterialTheme.typography.titleMedium.copy(
                    fontWeight = FontWeight.SemiBold,
                    color = Color(0xFF6F6F6F)
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 30.dp),
                textAlign = TextAlign.Start
            )

            Spacer(Modifier.height(16.dp))

            var digits by remember { mutableStateOf(List(4) { "" }) }
            val pin = digits.joinToString("")
            PinRow(
                digits = digits,
                onChange = { digits = it },
                boxWidth = pinBoxWidth,
                boxHeight = pinBoxHeight,
                radius = pinCorner,
                center = true
            )

            Spacer(Modifier.height(40.dp))

            Button(
                onClick = { onSubmitPin(pin) },
                enabled = pin.length == 4,
                shape = RoundedCornerShape(10.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF111111),
                    contentColor = Color.White,
                    disabledContainerColor = Color(0xFF111111).copy(alpha = 0.4f),
                    disabledContentColor = Color.White.copy(alpha = 0.8f)
                ),
                modifier = Modifier
                    .width(buttonWidth)
                    .height(buttonHeight)
                    .align(Alignment.CenterHorizontally)
            ) {
                Text("Enter")
            }
        }
    }
}

@Composable
private fun PinRow(
    digits: List<String>,
    onChange: (List<String>) -> Unit,
    boxWidth: Dp = 64.dp,
    boxHeight: Dp = 88.dp,
    radius: Dp = 12.dp,
    center: Boolean = false
) {
    val focusManager = LocalFocusManager.current
    val requesters = remember { List(4) { FocusRequester() } }

    Row(
        horizontalArrangement = if (center)
            Arrangement.spacedBy(16.dp, Alignment.CenterHorizontally)
        else
            Arrangement.spacedBy(12.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        repeat(4) { i ->
            val value = digits[i]

            BasicTextField(
                value = value,
                onValueChange = { new ->
                    val filtered = new.filter { it.isDigit() }.take(1)
                    if (filtered != value) {
                        val updated = digits.toMutableList()
                        updated[i] = filtered
                        onChange(updated)
                        if (filtered.isNotEmpty() && i < 3) requesters[i + 1].requestFocus()
                    }
                },
                textStyle = TextStyle(
                    fontSize = 24.sp,
                    textAlign = TextAlign.Center,
                    color = Color.Black
                ),
                singleLine = true,
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.NumberPassword,
                    imeAction = if (i == 3) ImeAction.Done else ImeAction.Next
                ),
                keyboardActions = KeyboardActions(
                    onNext = { if (i < 3) requesters[i + 1].requestFocus() },
                    onDone = { focusManager.clearFocus() }
                ),
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier
                    .width(boxWidth)
                    .height(boxHeight)
                    .focusRequester(requesters[i])
                    .clip(RoundedCornerShape(radius))
                    .background(Color.White)
                    .border(
                        width = 1.dp,
                        color = Color(0xFFE6E6E6),
                        shape = RoundedCornerShape(radius)
                    ),
                decorationBox = { inner ->
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { inner() }
                }
            )
        }
    }
}

