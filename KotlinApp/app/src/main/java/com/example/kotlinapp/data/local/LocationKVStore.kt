package com.example.kotlinapp.data.local

import com.tencent.mmkv.MMKV

class LocationKVStore {

    private val mmkv: MMKV = MMKV.defaultMMKV()


    fun saveLastLocation(lat: Double, lng: Double) {
        mmkv.encode("last_lat", lat.toFloat())
        mmkv.encode("last_lng", lng.toFloat())
        mmkv.encode("last_location_timestamp", System.currentTimeMillis())
    }


    fun getLastLocation(): Pair<Double, Double>? {
        val lat = mmkv.decodeFloat("last_lat", Float.MIN_VALUE)
        val lng = mmkv.decodeFloat("last_lng", Float.MIN_VALUE)

        return if (lat != Float.MIN_VALUE && lng != Float.MIN_VALUE) {
            Pair(lat.toDouble(), lng.toDouble())
        } else {
            null
        }
    }


    fun isLocationRecent(): Boolean {
        val timestamp = mmkv.decodeLong("last_location_timestamp", 0L)
        val now = System.currentTimeMillis()
        val oneDayInMillis = 24 * 60 * 60 * 1000

        return (now - timestamp) < oneDayInMillis
    }


    fun clearLocation() {
        mmkv.remove("last_lat")
        mmkv.remove("last_lng")
        mmkv.remove("last_location_timestamp")
    }
}