@file:OptIn(ExperimentalMaterial3Api::class)

package com.example.kotlinapp.ui.ownerAvailabilityManager

import android.widget.Toast
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.kotlinapp.data.repository.AvailabilityItem
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun AvailabilityManagementScreen(
    vehicleId: String,
    vehicleName: String,
    onNavigateBack: () -> Unit
) {
    val vm: AvailabilityViewModel = viewModel()
    val ui by vm.ui.collectAsState()
    val pendingCount by vm.pendingCount.collectAsState()
    val isOffline by vm.isOffline.collectAsState()
    val availabilities by vm.availabilities.collectAsState()
    val context = LocalContext.current

    var showCreateDialog by remember { mutableStateOf(false) }
    var showEditDialog by remember { mutableStateOf(false) }
    var selectedAvailability by remember { mutableStateOf<AvailabilityItem?>(null) }


    LaunchedEffect(vehicleId) {
        vm.loadAvailabilities(vehicleId)
    }


    LaunchedEffect(ui.success) {
        if (ui.success) {
            ui.message?.let {
                Toast.makeText(context, it, Toast.LENGTH_LONG).show()
            }
            showCreateDialog = false
            showEditDialog = false
            selectedAvailability = null
            vm.clearMessage()
        }
    }

    Scaffold(
        topBar = {
            TopAvailabilityBar(
                vehicleName = vehicleName,
                onNavigateBack = onNavigateBack,
                unsyncedCount = pendingCount
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showCreateDialog = true },
                containerColor = MaterialTheme.colorScheme.primary
            ) {
                Icon(Icons.Default.Add, "Add availability")
            }
        },
        containerColor = MaterialTheme.colorScheme.surface
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {

            if (isOffline) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = Color(0xFFFFF3CD)
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.CloudOff,
                            contentDescription = null,
                            tint = Color(0xFF856404)
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            text = "Offline Mode - Changes will be synced when online",
                            color = Color(0xFF856404),
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }


            if (pendingCount > 0) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.secondaryContainer
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Sync,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onSecondaryContainer
                            )
                            Spacer(Modifier.width(8.dp))
                            Text(
                                text = "$pendingCount change(s) waiting to sync",
                                color = MaterialTheme.colorScheme.onSecondaryContainer,
                                style = MaterialTheme.typography.bodyMedium
                            )
                        }

                        TextButton(
                            onClick = { vm.syncPending() },
                            enabled = !ui.loading
                        ) {
                            Text("Sync Now")
                        }
                    }
                }
            }


            if (ui.error != null) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = ui.error!!,
                        color = MaterialTheme.colorScheme.onErrorContainer,
                        modifier = Modifier.padding(12.dp)
                    )
                }
            }


            if (ui.message != null && !ui.success) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            text = ui.message!!,
                            color = MaterialTheme.colorScheme.onPrimaryContainer,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }


            if (ui.loading && availabilities.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            } else if (availabilities.isEmpty()) {
                EmptyAvailabilityState(
                    onAddClick = { showCreateDialog = true }
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(availabilities, key = { it.availabilityId }) { availability ->
                        AvailabilityCard(
                            availability = availability,
                            onEdit = {
                                selectedAvailability = availability
                                showEditDialog = true
                            },
                            onDelete = {
                                vm.deleteAvailability(availability.availabilityId, vehicleId)
                            }
                        )
                    }
                }
            }
        }
    }


    if (showCreateDialog) {
        CreateAvailabilityDialog(
            onDismiss = { showCreateDialog = false },
            onConfirm = { startDate, endDate, status, reason ->
                vm.createAvailability(vehicleId, startDate, endDate, status, reason)
            },
            isLoading = ui.loading
        )
    }

    if (showEditDialog && selectedAvailability != null) {
        EditAvailabilityDialog(
            availability = selectedAvailability!!,
            onDismiss = {
                showEditDialog = false
                selectedAvailability = null
            },
            onConfirm = { availabilityId, startDate, endDate, status, reason ->
                vm.updateAvailability(availabilityId, startDate, endDate, status, reason)
            },
            isLoading = ui.loading
        )
    }
}


@Composable
private fun TopAvailabilityBar(
    vehicleName: String,
    onNavigateBack: () -> Unit,
    unsyncedCount: Int
) {
    Surface(
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 4.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                    Spacer(Modifier.width(8.dp))
                    Column {
                        Text(
                            "Availability Manager",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Text(
                            vehicleName,
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                if (unsyncedCount > 0) {
                    Badge(
                        containerColor = MaterialTheme.colorScheme.error
                    ) {
                        Text("$unsyncedCount")
                    }
                }
            }
        }
    }
}


@Composable
private fun EmptyAvailabilityState(
    onAddClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.EventBusy,
            contentDescription = null,
            modifier = Modifier.size(120.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
        )
        Spacer(Modifier.height(16.dp))
        Text(
            "No availability blocks",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(8.dp))
        Text(
            "Add blocks to manage when your vehicle is available, blocked, or in maintenance",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
        )
        Spacer(Modifier.height(24.dp))
        Button(onClick = onAddClick) {
            Icon(Icons.Default.Add, null, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text("Add Availability")
        }
    }
}


@Composable
private fun AvailabilityCard(
    availability: AvailabilityItem,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    var showDeleteDialog by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                StatusBadge(status = availability.status)

                Row {
                    IconButton(onClick = onEdit) {
                        Icon(
                            Icons.Default.Edit,
                            "Edit",
                            tint = MaterialTheme.colorScheme.primary
                        )
                    }
                    IconButton(onClick = { showDeleteDialog = true }) {
                        Icon(
                            Icons.Default.Delete,
                            "Delete",
                            tint = MaterialTheme.colorScheme.error
                        )
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                DateChip(
                    label = "Start",
                    date = availability.startDate,
                    icon = Icons.Default.DateRange
                )
                DateChip(
                    label = "End",
                    date = availability.endDate,
                    icon = Icons.Default.Event
                )
            }

            availability.reason?.let { reason ->
                Spacer(Modifier.height(12.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.Info,
                        null,
                        modifier = Modifier.size(16.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        reason,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }

    if (showDeleteDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteDialog = false },
            title = { Text("Delete availability?") },
            text = { Text("This action cannot be undone.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        onDelete()
                        showDeleteDialog = false
                    },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}


@Composable
private fun StatusBadge(status: String) {
    val (color, icon, text) = when (status) {
        "AVAILABLE" -> Triple(
            Color(0xFF4CAF50),
            Icons.Default.CheckCircle,
            "Available"
        )
        "BLOCKED" -> Triple(
            Color(0xFFF44336),
            Icons.Default.Block,
            "Blocked"
        )
        "MAINTENANCE" -> Triple(
            Color(0xFFFF9800),
            Icons.Default.Build,
            "Maintenance"
        )
        else -> Triple(
            Color.Gray,
            Icons.Default.Help,
            status
        )
    }

    Surface(
        shape = RoundedCornerShape(8.dp),
        color = color.copy(alpha = 0.15f)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon,
                null,
                modifier = Modifier.size(16.dp),
                tint = color
            )
            Spacer(Modifier.width(6.dp))
            Text(
                text,
                style = MaterialTheme.typography.labelMedium,
                color = color,
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun DateChip(
    label: String,
    date: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector
) {
    Surface(
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surface
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon,
                null,
                modifier = Modifier.size(16.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.width(8.dp))
            Column {
                Text(
                    label,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                )
                Text(
                    formatDate(date),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}


@Composable
private fun CreateAvailabilityDialog(
    onDismiss: () -> Unit,
    onConfirm: (String, String, String, String?) -> Unit,
    isLoading: Boolean
) {
    var startDate by remember { mutableStateOf("") }
    var endDate by remember { mutableStateOf("") }
    var selectedStatus by remember { mutableStateOf("AVAILABLE") }
    var reason by remember { mutableStateOf("") }
    var showStartDatePicker by remember { mutableStateOf(false) }
    var showEndDatePicker by remember { mutableStateOf(false) }

    val isValid = startDate.isNotEmpty() && endDate.isNotEmpty()

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("New Availability") },
        text = {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    "Status",
                    style = MaterialTheme.typography.labelMedium
                )
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    StatusFilterChip(
                        text = "Available",
                        icon = Icons.Default.CheckCircle,
                        selected = selectedStatus == "AVAILABLE",
                        onClick = { selectedStatus = "AVAILABLE" }
                    )
                    StatusFilterChip(
                        text = "Blocked",
                        icon = Icons.Default.Block,
                        selected = selectedStatus == "BLOCKED",
                        onClick = { selectedStatus = "BLOCKED" }
                    )
                    StatusFilterChip(
                        text = "Maintenance",
                        icon = Icons.Default.Build,
                        selected = selectedStatus == "MAINTENANCE",
                        onClick = { selectedStatus = "MAINTENANCE" }
                    )
                }

                OutlinedButton(
                    onClick = { showStartDatePicker = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.DateRange, null)
                    Spacer(Modifier.width(8.dp))
                    Text(
                        if (startDate.isEmpty()) "Select start date"
                        else "Start: ${formatDateShort(startDate)}"
                    )
                }

                OutlinedButton(
                    onClick = { showEndDatePicker = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Event, null)
                    Spacer(Modifier.width(8.dp))
                    Text(
                        if (endDate.isEmpty()) "Select end date"
                        else "End: ${formatDateShort(endDate)}"
                    )
                }

                OutlinedTextField(
                    value = reason,
                    onValueChange = { reason = it },
                    label = { Text("Reason (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 3,
                    leadingIcon = {
                        Icon(Icons.Default.Info, null)
                    }
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    onConfirm(
                        startDate,
                        endDate,
                        selectedStatus,
                        reason.takeIf { it.isNotEmpty() }
                    )
                },
                enabled = isValid && !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Spacer(Modifier.width(8.dp))
                }
                Text("Create")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss, enabled = !isLoading) {
                Text("Cancel")
            }
        }
    )

    if (showStartDatePicker) {
        DatePickerDialog(
            onDismiss = { showStartDatePicker = false },
            onConfirm = { date ->
                startDate = date
                showStartDatePicker = false
            }
        )
    }

    if (showEndDatePicker) {
        DatePickerDialog(
            onDismiss = { showEndDatePicker = false },
            onConfirm = { date ->
                endDate = date
                showEndDatePicker = false
            }
        )
    }
}


@Composable
private fun EditAvailabilityDialog(
    availability: AvailabilityItem,
    onDismiss: () -> Unit,
    onConfirm: (String, String?, String?, String?, String?) -> Unit,
    isLoading: Boolean
) {
    var startDate by remember { mutableStateOf(availability.startDate) }
    var endDate by remember { mutableStateOf(availability.endDate) }
    var selectedStatus by remember { mutableStateOf(availability.status) }
    var reason by remember { mutableStateOf(availability.reason ?: "") }
    var showStartDatePicker by remember { mutableStateOf(false) }
    var showEndDatePicker by remember { mutableStateOf(false) }

    val isValid = startDate.isNotEmpty() && endDate.isNotEmpty()
    val hasChanges = startDate != availability.startDate ||
            endDate != availability.endDate ||
            selectedStatus != availability.status ||
            reason != (availability.reason ?: "")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Availability") },
        text = {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    "Status",
                    style = MaterialTheme.typography.labelMedium
                )
                Row(
                    modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    StatusFilterChip(
                        text = "Available",
                        icon = Icons.Default.CheckCircle,
                        selected = selectedStatus == "AVAILABLE",
                        onClick = { selectedStatus = "AVAILABLE" }
                    )
                    StatusFilterChip(
                        text = "Blocked",
                        icon = Icons.Default.Block,
                        selected = selectedStatus == "BLOCKED",
                        onClick = { selectedStatus = "BLOCKED" }
                    )
                    StatusFilterChip(
                        text = "Maintenance",
                        icon = Icons.Default.Build,
                        selected = selectedStatus == "MAINTENANCE",
                        onClick = { selectedStatus = "MAINTENANCE" }
                    )
                }

                OutlinedButton(
                    onClick = { showStartDatePicker = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.DateRange, null)
                    Spacer(Modifier.width(8.dp))
                    Text("Start: ${formatDateShort(startDate)}")
                }

                OutlinedButton(
                    onClick = { showEndDatePicker = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Event, null)
                    Spacer(Modifier.width(8.dp))
                    Text("End: ${formatDateShort(endDate)}")
                }

                OutlinedTextField(
                    value = reason,
                    onValueChange = { reason = it },
                    label = { Text("Reason (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 3,
                    leadingIcon = {
                        Icon(Icons.Default.Info, null)
                    }
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    onConfirm(
                        availability.availabilityId,
                        if (startDate != availability.startDate) startDate else null,
                        if (endDate != availability.endDate) endDate else null,
                        if (selectedStatus != availability.status) selectedStatus else null,
                        if (reason != (availability.reason ?: "")) reason else null
                    )
                },
                enabled = isValid && hasChanges && !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Spacer(Modifier.width(8.dp))
                }
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss, enabled = !isLoading) {
                Text("Cancel")
            }
        }
    )

    if (showStartDatePicker) {
        DatePickerDialog(
            onDismiss = { showStartDatePicker = false },
            onConfirm = { date ->
                startDate = date
                showStartDatePicker = false
            }
        )
    }

    if (showEndDatePicker) {
        DatePickerDialog(
            onDismiss = { showEndDatePicker = false },
            onConfirm = { date ->
                endDate = date
                showEndDatePicker = false
            }
        )
    }
}


@Composable
private fun StatusFilterChip(
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    selected: Boolean,
    onClick: () -> Unit
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = { Text(text, style = MaterialTheme.typography.labelSmall) },
        leadingIcon = {
            Icon(
                icon,
                null,
                modifier = Modifier.size(16.dp)
            )
        }
    )
}


@Composable
private fun DatePickerDialog(
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    val datePickerState = rememberDatePickerState()

    DatePickerDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(
                onClick = {
                    datePickerState.selectedDateMillis?.let { millis ->
                        val date = Date(millis)
                        val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                        onConfirm(format.format(date))
                    }
                }
            ) {
                Text("OK")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    ) {
        DatePicker(state = datePickerState)
    }
}


private fun formatDate(isoDate: String): String {
    return try {
        val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        val outputFormat = SimpleDateFormat("dd MMM yyyy", Locale("en", "US"))
        val date = inputFormat.parse(isoDate)
        date?.let { outputFormat.format(it) } ?: isoDate
    } catch (e: Exception) {
        isoDate.substring(0, 10)
    }
}

private fun formatDateShort(isoDate: String): String {
    return try {
        val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
        val outputFormat = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
        val date = inputFormat.parse(isoDate)
        date?.let { outputFormat.format(it) } ?: isoDate
    } catch (e: Exception) {
        isoDate.substring(0, 10)
    }
}