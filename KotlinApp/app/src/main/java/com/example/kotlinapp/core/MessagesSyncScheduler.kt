package com.example.kotlinapp.core

import android.content.Context
import android.util.Log
import com.example.kotlinapp.data.network.NetworkMonitor
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.distinctUntilChanged

/**
 * Scheduler que programa automáticamente la sincronización de mensajes
 * cuando detecta que hay conexión a internet.
 * 
 * ESTRATEGIA DE CONCURRENCIA:
 * - Usa CoroutineScope para ejecutar observadores en background
 * - Observa cambios de conectividad usando Flow (reactive)
 * - Programa Workers automáticamente cuando detecta internet
 * - Maneja múltiples hilos: NetworkMonitor (IO), WorkManager (IO), observación (Main)
 * 
 * FUNCIONALIDADES:
 * 1. Observa cambios de conectividad en tiempo real
 * 2. Programa sincronización periódica (cada 15 min)
 * 3. Programa sincronización inmediata cuando vuelve internet
 * 4. Se integra con el ciclo de vida de la aplicación
 */
class MessagesSyncScheduler(
    private val context: Context
) {
    
    private val networkMonitor = NetworkMonitor(context)
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var isMonitoring = false
    
    companion object {
        private const val TAG = "MessagesSyncScheduler"
    }
    
    /**
     * Inicia el monitoreo automático de conectividad y programa sincronizaciones
     */
    fun start() {
        if (isMonitoring) {
            Log.d(TAG, "Scheduler ya está activo")
            return
        }
        
        isMonitoring = true
        Log.d(TAG, "Iniciando scheduler de sincronización de mensajes...")
        
        // Programar sincronización periódica inicial
        MessagesSyncWorker.schedulePeriodic(context)
        
        // Observar cambios de conectividad en hilo de IO para no bloquear Main
        scope.launch(Dispatchers.IO) {
            networkMonitor.observeConnectivity()
                .distinctUntilChanged() // Solo actuar cuando cambia el estado
                .collect { isConnected ->
                    if (isConnected) {
                        Log.d(TAG, "Internet detectado, programando sincronización inmediata...")
                        // Programar sincronización inmediata cuando vuelve internet
                        // Usar Dispatchers.IO porque WorkManager es una operación de IO
                        withContext(Dispatchers.IO) {
                            MessagesSyncWorker.scheduleOnce(context)
                        }
                    } else {
                        Log.d(TAG, "Sin conexión a internet")
                    }
                }
        }
    }
    
    /**
     * Detiene el monitoreo y cancela sincronizaciones pendientes
     */
    fun stop() {
        if (!isMonitoring) {
            return
        }
        
        isMonitoring = false
        Log.d(TAG, "Deteniendo scheduler...")
        
        scope.cancel()
        MessagesSyncWorker.cancel(context)
    }
    
    /**
     * Fuerza una sincronización inmediata (útil para testing o acciones del usuario)
     */
    fun syncNow() {
        Log.d(TAG, "Sincronización manual solicitada")
        MessagesSyncWorker.scheduleOnce(context)
    }
}

