@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class,
    com.google.accompanist.permissions.ExperimentalPermissionsApi::class)
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



import android.net.Uri
import android.os.Environment
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.MyLocation
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.FileProvider
import coil.compose.AsyncImage
import com.google.accompanist.permissions.*
import com.google.android.gms.location.LocationServices
import java.io.File
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width

import androidx.compose.ui.res.painterResource

@Composable
fun AddCar(
    onDone: () -> Unit = {}
) {



    var make by remember { mutableStateOf("") }
    var model by remember { mutableStateOf("") }
    var year by remember { mutableStateOf("") }
    var plate by remember { mutableStateOf("") }
    var seats by remember { mutableStateOf("") }
    var transmission by remember { mutableStateOf("AT") }
    var fuelType by remember { mutableStateOf("gas") }
    var mileage by remember { mutableStateOf("") }


    var dailyPrice by remember { mutableStateOf("") }
    var minDays by remember { mutableStateOf("1") }
    var maxDays by remember { mutableStateOf("") }
    var currency by remember { mutableStateOf("USD") }


    var photoUri by remember { mutableStateOf<Uri?>(null) }
    var photoFile by remember { mutableStateOf<File?>(null) }
    var latValue by remember { mutableStateOf<Double?>(null) }
    var lngValue by remember { mutableStateOf<Double?>(null) }
    var validationError by remember { mutableStateOf<String?>(null) }


    val vm: AddCarViewModel = viewModel()
    val ui by vm.ui.collectAsState()
    val context = LocalContext.current
    val statusValue = "active"

    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicture()
    ) { success ->
        if (success && photoFile != null) {

            photoUri = Uri.fromFile(photoFile)
        } else {
            photoUri = null
            photoFile = null
        }
    }

    //Permiso para camara
    val cameraPermissionState = rememberPermissionState(
        android.Manifest.permission.CAMERA
    )

    //Permiso para ubicacion
    val locationPermissionState = rememberMultiplePermissionsState(
        permissions = listOf(
            android.Manifest.permission.ACCESS_FINE_LOCATION,
            android.Manifest.permission.ACCESS_COARSE_LOCATION
        )
    )

    //Obtener ubicacion
    val fusedLocationClient = remember {
        LocationServices.getFusedLocationProviderClient(context)
    }


    fun getLocation() {
        if (locationPermissionState.allPermissionsGranted) {
            try {
                fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                    if (location != null) {
                        latValue = location.latitude
                        lngValue = location.longitude
                        Toast.makeText(
                            context,
                            "Location obtained: ${location.latitude}, ${location.longitude}",
                            Toast.LENGTH_SHORT
                        ).show()
                    } else {
                        Toast.makeText(
                            context,
                            "The location could not be obtained. Try enabling GPS.",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            } catch (e: SecurityException) {
                Toast.makeText(context, "Permissions error", Toast.LENGTH_SHORT).show()
            }
        } else {
            locationPermissionState.launchMultiplePermissionRequest()
        }
    }

    fun takePhoto() {
        if (cameraPermissionState.status.isGranted) {
            val file = File(
                context.getExternalFilesDir(Environment.DIRECTORY_PICTURES),
                "vehicle_${System.currentTimeMillis()}.jpg"
            )
            photoFile = file

            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )
            photoUri = uri
            cameraLauncher.launch(uri)
        } else {
            cameraPermissionState.launchPermissionRequest()
        }
    }

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


            if (ui.error != null) {
                Card(
                    colors = CardDefaults.cardColors(containerColor = Color(0xFFFFEBEE)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = ui.error!!,
                        color = Color.Red,
                        modifier = Modifier.padding(12.dp)
                    )
                }
            }

            if (validationError != null) {
                Card(
                    colors = CardDefaults.cardColors(containerColor = Color(0xFFFFF3E0)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = validationError!!,
                        color = Color(0xFFE65100),
                        modifier = Modifier.padding(12.dp)
                    )
                }
            }


            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Photo of the vehicle", fontWeight = FontWeight.Bold)
                    Spacer(Modifier.height(8.dp))

                    if (photoFile != null && photoFile!!.exists()) {
                        AsyncImage(
                            model = photoFile,
                            contentDescription = "Vehicle photo",
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp)
                                .clip(RoundedCornerShape(8.dp)),
                            contentScale = ContentScale.Crop,
                            error = painterResource(android.R.drawable.ic_menu_gallery)
                        )
                        Spacer(Modifier.height(8.dp))
                    } else if (photoUri != null) {

                        Text("Photo captured but not available", color = Color.Gray)
                    }

                    Button(onClick = { takePhoto() }) {
                        Icon(Icons.Default.CameraAlt, contentDescription = null)
                        Spacer(Modifier.width(8.dp))
                        Text(if (photoUri == null) "Take foto" else "Change foto")
                    }
                }
            }


            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("vehicle location", fontWeight = FontWeight.Bold)
                    Spacer(Modifier.height(8.dp))

                    if (latValue != null && lngValue != null) {
                        Text(
                            "Lat: %.6f, Lng: %.6f".format(latValue, lngValue),
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.Gray
                        )
                    } else {
                        Text(
                            "Location not obtained",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.Gray
                        )
                    }

                    Spacer(Modifier.height(8.dp))
                    Button(onClick = { getLocation() }) {
                        Icon(Icons.Default.MyLocation, contentDescription = null)
                        Spacer(Modifier.width(8.dp))
                        Text("Get location")
                    }
                }
            }


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

            SimpleDropdown(
                label = "Currency",
                value = currency,
                options = listOf("USD", "COP", "EUR", "GBP"),
                onChange = { currency = it },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(24.dp))

            Button(
                onClick = {
                    validationError = null

                    // Validar ubicación, que se tomo con el sensor
                    if (latValue == null || lngValue == null) {
                        validationError = "Debes obtener la ubicación del vehículo"
                        return@Button
                    }

                    val y = year.toIntOrNull()
                    val s = seats.toIntOrNull()
                    val m = mileage.toIntOrNull()
                    val price = dailyPrice.toDoubleOrNull()
                    val min = minDays.toIntOrNull()
                    val max = maxDays.toIntOrNull()

                    when {
                        make.isBlank() -> validationError = "Ingresa la marca"
                        model.isBlank() -> validationError = "Ingresa el modelo"
                        y == null || y !in 1900..2030 -> validationError = "Año inválido"
                        s == null || s !in 1..50 -> validationError = "Número de asientos inválido"
                        m == null || m < 0 -> validationError = "Kilometraje inválido"
                        price == null || price <= 0.0 -> validationError = "Precio inválido"
                        min == null || min < 1 -> validationError = "Días mínimos inválido"
                        else -> {
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
                                lat = latValue!!,
                                lng = lngValue!!
                            )

                            val pReq = PricingCreate(
                                vehicle_id = "",
                                daily_price = price,
                                min_days = min,
                                max_days = max,
                                currency = currency
                            )


                            vm.submit(vReq, pReq, photoFile)
                        }
                    }
                },
                enabled = !ui.loading,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (ui.loading) {
                    CircularProgressIndicator(
                        strokeWidth = 2.dp,
                        modifier = Modifier.size(18.dp),
                        color = Color.White
                    )
                    Spacer(Modifier.width(8.dp))
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

            expanded = !expanded

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
