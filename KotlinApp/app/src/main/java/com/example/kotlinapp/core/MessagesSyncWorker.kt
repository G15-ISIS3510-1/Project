package com.example.kotlinapp.core

import android.content.Context
import android.util.Log
import androidx.work.*
import com.example.kotlinapp.App
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.network.NetworkMonitor
import com.example.kotlinapp.data.local.MessagesLocalRepository
import com.example.kotlinapp.data.remote.dto.MessageCreate
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Worker mejorado para sincronización automática de mensajes en background.
 * 
 * ESTRATEGIA DE CONCURRENCIA:
 * - Usa Dispatchers.IO para operaciones de red y base de datos (fuera del Main Thread)
 * - Usa Dispatchers.Default para procesamiento paralelo de múltiples mensajes
 * - Combina diferentes threads para: red (IO), base de datos (IO), procesamiento (Default)
 * - Sincroniza en paralelo: descarga nuevos mensajes y envía pendientes simultáneamente
 * 
 * FUNCIONALIDADES:
 * 1. Sincroniza mensajes pendientes de envío (offline -> servidor)
 * 2. Descarga nuevos mensajes del servidor (servidor -> local)
 * 3. Actualiza conversaciones con últimos mensajes
 * 4. Solo se ejecuta cuando hay conectividad a internet
 */
class MessagesSyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    private val localRepository = MessagesLocalRepository(context)
    private val networkMonitor = NetworkMonitor(context)
    private val preferencesManager = App.getPreferencesManager()
    
    override suspend fun doWork(): Result {
        // Verificar conectividad en hilo de red (IO)
        return withContext(Dispatchers.IO) {
            if (!networkMonitor.isConnected()) {
                Log.d(TAG, "Sin conexión a internet, reintentando más tarde...")
                return@withContext Result.retry()
            }
            
            try {
                val currentUserId = preferencesManager.getUserInfo()?.userId
                if (currentUserId == null) {
                    Log.d(TAG, "Usuario no autenticado, cancelando sincronización")
                    return@withContext Result.failure()
                }
                
                Log.d(TAG, "Iniciando sincronización de mensajes...")
                
                // EJECUTAR SINCRONIZACIÓN EN PARALELO:
                // Thread 1: Descargar nuevos mensajes del servidor
                // Thread 2: Enviar mensajes pendientes offline
                val downloadTask = async(Dispatchers.IO) {
                    syncMessagesFromServer(currentUserId)
                }
                
                val uploadTask = async(Dispatchers.IO) {
                    syncPendingMessagesToServer()
                }
                
                // Esperar a que ambas tareas terminen (paralelas)
                val downloadedCount = downloadTask.await()
                val uploadedCount = uploadTask.await()
                
                Log.d(TAG, "Sincronización completada: $downloadedCount mensajes descargados, $uploadedCount mensajes enviados")
                
                // Actualizar timestamp de última sincronización (en hilo de BD)
                localRepository.updateLastSyncTimestamp()
                
                Result.success()
            } catch (e: Exception) {
                Log.e(TAG, "Error durante sincronización: ${e.message}", e)
                // Retry con backoff exponencial
                Result.retry()
            }
        }
    }
    
    /**
     * Descarga nuevos mensajes del servidor y los guarda localmente.
     * Usa Dispatchers.IO para operaciones de red y base de datos.
     */
    private suspend fun syncMessagesFromServer(userId: String): Int = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "Descargando nuevos mensajes del servidor...")
            
            // Obtener últimas conversaciones desde el servidor
            val conversationsResponse = ApiClient.conversationsApi.listMyConversations(
                skip = 0,
                limit = 50
            )
            
            if (!conversationsResponse.isSuccessful || conversationsResponse.body() == null) {
                Log.w(TAG, "Error obteniendo conversaciones")
                return@withContext 0
            }
            
            val conversations = conversationsResponse.body()!!.items
            Log.d(TAG, "Obtenidas ${conversations.size} conversaciones")
            
            // Guardar conversaciones en base de datos (hilo de BD)
            localRepository.saveConversations(conversations)
            
            // Para cada conversación, descargar mensajes recientes
            var totalMessagesDownloaded = 0
            
            // Procesar conversaciones en paralelo usando Dispatchers.Default
            val downloadTasks = conversations.map { conversation ->
                async(Dispatchers.IO) {
                    try {
                        // Obtener mensajes del thread con el otro usuario
                        val otherUserId = if (conversation.userLowId == userId) {
                            conversation.userHighId
                        } else {
                            conversation.userLowId
                        }
                        
                        val messagesResponse = ApiClient.messagesApi.getThreadWithUser(
                            otherUserId = otherUserId,
                            skip = 0,
                            limit = 50, // Últimos 50 mensajes
                            markAsRead = false,
                            onlyUnread = false
                        )
                        
                        if (messagesResponse.isSuccessful && messagesResponse.body() != null) {
                            val messages = messagesResponse.body()!!.items
                            // Guardar mensajes en base de datos (operación de BD en hilo IO)
                            localRepository.saveMessages(messages)
                            
                            // Actualizar último mensaje de la conversación
                            messages.lastOrNull()?.let { lastMessage ->
                                val conversationId = lastMessage.conversationId
                                if (conversationId != null) {
                                    val timestamp = parseDateTime(lastMessage.createdAt)
                                    localRepository.updateConversationLastMessage(
                                        conversationId,
                                        timestamp
                                    )
                                }
                            }
                            
                            messages.size
                        } else {
                            0
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error descargando mensajes de conversación: ${e.message}")
                        0
                    }
                }
            }
            
            // Esperar todas las descargas en paralelo
            totalMessagesDownloaded = downloadTasks.awaitAll().sum()
            
            Log.d(TAG, "Descargados $totalMessagesDownloaded mensajes nuevos")
            totalMessagesDownloaded
        } catch (e: Exception) {
            Log.e(TAG, "Error en syncMessagesFromServer: ${e.message}", e)
            0
        }
    }
    
    /**
     * Envía mensajes pendientes (creados offline) al servidor.
     * Usa Dispatchers.IO para operaciones de red y base de datos.
     */
    private suspend fun syncPendingMessagesToServer(): Int = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "Sincronizando mensajes pendientes...")
            
            // Obtener mensajes que necesitan sincronización (operación de BD)
            val messagesToSync = localRepository.getMessagesNeedingSync()
            
            if (messagesToSync.isEmpty()) {
                Log.d(TAG, "No hay mensajes pendientes de sincronizar")
                return@withContext 0
            }
            
            Log.d(TAG, "Encontrados ${messagesToSync.size} mensajes pendientes")
            
            // Enviar mensajes en paralelo usando Dispatchers.Default para procesamiento
            val sendTasks = messagesToSync.map { messageEntity ->
                async(Dispatchers.IO) {
                try {
                        // Enviar mensaje al servidor (operación de red)
                    val response = ApiClient.messagesApi.sendMessage(
                        MessageCreate(
                            receiverId = messageEntity.receiverId,
                            content = messageEntity.content,
                            conversationId = messageEntity.conversationId,
                            meta = null
                        )
                    )
                    
                    if (response.isSuccessful && response.body() != null) {
                        val serverMessage = response.body()!!
                        
                            // Actualizar mensaje local con datos del servidor (operación de BD)
                        localRepository.saveMessage(serverMessage)
                        
                            // Eliminar mensaje temporal offline
                        localRepository.messageDao.deleteMessage(messageEntity.messageId)
                        
                            Log.d(TAG, "Mensaje sincronizado: ${serverMessage.messageId}")
                            1
                    } else {
                            Log.w(TAG, "Error enviando mensaje: ${response.code()}")
                            0
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error sincronizando mensaje ${messageEntity.messageId}: ${e.message}")
                        0
                    }
                }
            }
            
            // Esperar todos los envíos en paralelo
            val successCount = sendTasks.awaitAll().sum()
            
            Log.d(TAG, "Sincronizados $successCount de ${messagesToSync.size} mensajes")
            successCount
        } catch (e: Exception) {
            Log.e(TAG, "Error en syncPendingMessagesToServer: ${e.message}", e)
            0
        }
    }
    
    /**
     * Parsea fecha ISO 8601 a timestamp
     */
    private fun parseDateTime(dateTimeString: String): Long {
        return try {
            val cleanDate = dateTimeString.replace("Z$".toRegex(), "")
            val parts = cleanDate.split("T")
            if (parts.size == 2) {
                val dateParts = parts[0].split("-")
                val timeParts = parts[1].split(":")
                val year = dateParts[0].toInt()
                val month = dateParts[1].toInt() - 1
                val day = dateParts[2].toInt()
                val hour = timeParts[0].toInt()
                val minute = timeParts[1].toInt()
                val second = if (timeParts.size > 2) timeParts[2].split(".")[0].toInt() else 0
                
                java.util.Calendar.getInstance().apply {
                    set(year, month, day, hour, minute, second)
                    set(java.util.Calendar.MILLISECOND, 0)
                }.timeInMillis
            } else {
                System.currentTimeMillis()
            }
        } catch (e: Exception) {
            System.currentTimeMillis()
        }
    }
    
    companion object {
        private const val TAG = "MessagesSyncWorker"
        const val WORK_NAME = "messages_sync_worker"
        
        /**
         * Programa sincronización periódica (cada 15 minutos cuando hay conexión)
         */
        fun schedulePeriodic(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()
            
            val workRequest = PeriodicWorkRequestBuilder<MessagesSyncWorker>(
                15, TimeUnit.MINUTES,
                5, TimeUnit.MINUTES // Flex interval
            )
                .setConstraints(constraints)
                .addTag(WORK_NAME)
                .build()
            
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
            
            Log.d(TAG, "Sincronización periódica programada")
        }
        
        /**
         * Programa sincronización inmediata (cuando se detecta internet)
         */
        fun scheduleOnce(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
            
            val workRequest = OneTimeWorkRequestBuilder<MessagesSyncWorker>()
                .setConstraints(constraints)
                .addTag(WORK_NAME)
                .build()
            
            WorkManager.getInstance(context).enqueueUniqueWork(
                "${WORK_NAME}_once",
                ExistingWorkPolicy.REPLACE,
                workRequest
            )
            
            Log.d(TAG, "Sincronización única programada")
        }
        
        /**
         * Cancela todas las sincronizaciones
         */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
            WorkManager.getInstance(context).cancelUniqueWork("${WORK_NAME}_once")
            Log.d(TAG, "Sincronizaciones canceladas")
        }
    }
}

