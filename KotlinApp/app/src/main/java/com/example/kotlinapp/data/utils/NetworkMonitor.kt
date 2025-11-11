package com.example.kotlinapp.data.utils

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.util.Log
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.distinctUntilChanged

class NetworkMonitor(context: Context) {

    private val connectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    val isConnected: Flow<Boolean> = callbackFlow {
        val callback = object : ConnectivityManager.NetworkCallback() {
            private val networks = mutableSetOf<Network>()

            override fun onAvailable(network: Network) {
                networks.add(network)
                val connected = networks.isNotEmpty()
                Log.d("NetworkMonitor", if (connected) "Internet disponible" else "Sin internet")
                trySend(connected)
            }

            override fun onLost(network: Network) {
                networks.remove(network)
                val connected = networks.isNotEmpty()
                Log.d("NetworkMonitor", if (connected) "Internet disponible" else "Internet perdido")
                trySend(connected)
            }
        }

        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        connectivityManager.registerNetworkCallback(request, callback)

        // Estado inicial
        val isCurrentlyConnected = connectivityManager.activeNetwork?.let { network ->
            connectivityManager.getNetworkCapabilities(network)
                ?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        } ?: false

        Log.d("NetworkMonitor", " Estado inicial: ${if (isCurrentlyConnected) "Conectado" else "Desconectado"}")
        trySend(isCurrentlyConnected)

        awaitClose {
            connectivityManager.unregisterNetworkCallback(callback)
        }
    }.distinctUntilChanged()
}