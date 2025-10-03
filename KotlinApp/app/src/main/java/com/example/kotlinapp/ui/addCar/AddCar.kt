@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
package com.example.kotlinapp.ui.addCar

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.imePadding
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.kotlinapp.data.remote.dto.PricingCreate
import com.example.kotlinapp.data.remote.dto.VehicleCreate


@Composable
fun AddCar(
    onDone: () -> Unit = {}
) {
    //val vm: AddCarViewModel = viewModel()
    //val ui = vm.ui.collectAsState()

    // Estados de los campos
    var make by remember { mutableStateOf("") }
    var model by remember { mutableStateOf("") }
    var year by remember { mutableStateOf("") }
    var plate by remember { mutableStateOf("") }
    var seats by remember { mutableStateOf("") }
    var transmission by remember { mutableStateOf("AT") }
    var fuelType by remember { mutableStateOf("gas") }
    var mileage by remember { mutableStateOf("") }

    // Simula owner desde sesión (reemplaza por tu SessionManager)
    val ownerId = remember { "00000000-0000-0000-0000-000000000001" }

    var dailyPrice by remember { mutableStateOf("") } // usa String y validas
    var minDays by remember { mutableStateOf("1") }
    var maxDays by remember { mutableStateOf("") }
    var currency by remember { mutableStateOf("USD") }

    // Navegar al terminar
//    if (ui.value.success) onDone()

    val vm: AddCarViewModel = viewModel()
    val ui by vm.ui.collectAsState()
    val statusValue = "active"
    val latValue = 4.7110           //cambiar para que ponga ubicación
    val lngValue = -74.0721

    LaunchedEffect(ui.success) {
        if (ui.success) onDone()
    }

    if (ui.error != null) {
        Text(
            text = ui.error!!,
            color = Color.Red,
            modifier = Modifier.fillMaxWidth()
        )
    }


    Scaffold(
        topBar = { TopAddCar() },
        containerColor = Color(0xFFF7F7F7)
    ) { padding ->
        val scroll = rememberScrollState()
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(16.dp)
                .verticalScroll(scroll)
                .imePadding(),


        verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {

            // Campos
            OutlinedTextField(
                value = make,
                onValueChange = { make = it },
                label = { Text("Make") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = model,
                onValueChange = { model = it },
                label = { Text("Model") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = year,
                onValueChange = { year = it.filter(Char::isDigit) },
                label = { Text("Year") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = plate,
                onValueChange = { plate = it.uppercase() },
                label = { Text("Plate") },
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = seats,
                onValueChange = { seats = it.filter(Char::isDigit) },
                label = { Text("Seats") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = mileage,
                onValueChange = { mileage = it.filter(Char::isDigit) },
                label = { Text("Mileage") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SimpleDropdown(
                    label = "Transmission",
                    value = transmission,
                    options = listOf("AT", "MT", "CVT", "EV"),
                    onChange = { transmission = it },
                    modifier = Modifier.weight(1f)
                )
                SimpleDropdown(
                    label = "Fuel",
                    value = fuelType,
                    options = listOf("gas", "diesel", "hybrid", "ev"),
                    onChange = { fuelType = it },
                    modifier = Modifier.weight(1f)
                )
            }

            // ...
            OutlinedTextField(
                value = dailyPrice,
                onValueChange = { dailyPrice = it.filter { ch -> ch.isDigit() || ch == '.' } },
                label = { Text("Daily price") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = minDays,
                onValueChange = { minDays = it.filter(Char::isDigit) },
                label = { Text("Min days") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = maxDays,
                onValueChange = { maxDays = it.filter(Char::isDigit) },
                label = { Text("Max days (optional)") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )

            // Currency como dropdown
            SimpleDropdown(
                label = "Currency",
                value = currency,
                options = listOf("USD","COP","EUR","GBP"),
                onChange = { currency = it },
                modifier = Modifier.fillMaxWidth()
            )


            Spacer(Modifier.height(24.dp))


            Button(
                onClick = {
                    // Aquí hacer la llamada al backend para registrar el vehículo
                    // o navegar de regreso
                    val y = year.toIntOrNull()
                    val s = seats.toIntOrNull()
                    val m = mileage.toIntOrNull()
                    val price = dailyPrice.toDoubleOrNull()
                    val min = minDays.toIntOrNull()
                    val max = maxDays.toIntOrNull()

                    // Validaciones mínimas para no romper el backend
                    if (y == null || y !in 1900..2030) { /* mostrar error */ return@Button }
                    if (s == null || s !in 1..50) { /* error */ return@Button }
                    if (m == null || m < 0) { /* error */ return@Button }
                    if (price == null || price <= 0.0) { /* error */ return@Button }
                    if (min == null || min < 1) { /* error */ return@Button }
                    if (transmission !in listOf("AT","MT","CVT","EV")) { /* error */ return@Button }
                    if (fuelType !in listOf("gas","diesel","hybrid","ev")) { /* error */ return@Button }

                    val vReq = VehicleCreate(
                        make = make.trim(),
                        model = model.trim(),
                        year = y,
                        plate = plate.trim(),
                        seats = s,
                        transmission = transmission,
                        fuel_type = fuelType,
                        mileage = m,
                        status = statusValue,
                        lat = latValue,
                        lng = lngValue
                    )

                    val pReq = PricingCreate(
                        vehicle_id = "",
                        daily_price = price,
                        min_days = min,
                        max_days = max,
                        currency = currency
                    )

                    vm.submit(vReq, pReq)
                    onDone()
                },
//                enabled = !ui.value.loading,
                modifier = Modifier.fillMaxWidth()
            ) {
//                if (ui.value.loading) {
//                    CircularProgressIndicator(strokeWidth = 2.dp, modifier = Modifier.size(18.dp))
//                    Spacer(Modifier.width(8.dp))
//                }

                if (ui.error != null) {
                    Text(
                        text = ui.error!!,
                        color = Color.Red,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                Text("Add Vehicle")
            }
        }
    }
}


@Composable
fun SimpleDropdown(
    label: String,
    value: String,
    options: List<String>,
    onChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    val focusManager = LocalFocusManager.current

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = {
            // Alterna el menú al tocar el campo
            expanded = !expanded
            // Opcional: quita el foco para que no aparezca el teclado
            if (expanded) focusManager.clearFocus()
        },
        modifier = modifier
    ) {
        OutlinedTextField(
            value = value,
            onValueChange = {},
            readOnly = true,
            label = { Text(label) },
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
            },
            modifier = Modifier
                .menuAnchor()
                .fillMaxWidth()
        )

        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(option) },
                    onClick = {
                        onChange(option)
                        expanded = false
                    }
                )
            }
        }
    }
}


@Composable
private fun TopAddCar() {
    Surface(color = Color.White, shadowElevation = 0.dp) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp, bottom = 4.dp),
            contentAlignment = Alignment.Center
        ) {
            Text("Add Vehicle", fontSize = 28.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 1.sp)
        }

    }
}
