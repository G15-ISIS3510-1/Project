package com.example.kotlinapp.data.remote.dto


data class AvailabilityDto(
    val availability_id: String,
    val vehicle_id: String,
    val start_ts: String,
    val end_ts: String,
    val type: String,
    val notes: String?
)

data class CreateAvailabilityRequest(
    val vehicle_id: String,
    val start_ts: String,
    val end_ts: String,
    val type: String,
    val notes: String? = null
)

data class UpdateAvailabilityRequest(
    val start_ts: String?,
    val end_ts: String?,
    val type: String?,
    val notes: String?
)
