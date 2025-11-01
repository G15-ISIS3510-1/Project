package com.example.kotlinapp.data.utils

import kotlin.math.*

object GeoUtils {

    /**
     * Calcula la distancia entre dos puntos geográficos usando la fórmula Haversine
     * @param lat1 Latitud del punto 1
     * @param lng1 Longitud del punto 1
     * @param lat2 Latitud del punto 2
     * @param lng2 Longitud del punto 2
     * @return Distancia en kilómetros
     */
    fun calculateDistance(
        lat1: Double,
        lng1: Double,
        lat2: Double,
        lng2: Double
    ): Double {
        val R = 6371.0 // Radio de la Tierra en km

        val lat1Rad = Math.toRadians(lat1)
        val lat2Rad = Math.toRadians(lat2)
        val deltaLat = Math.toRadians(lat2 - lat1)
        val deltaLng = Math.toRadians(lng2 - lng1)

        val a = sin(deltaLat / 2).pow(2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLng / 2).pow(2)

        val c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return R * c
    }
}