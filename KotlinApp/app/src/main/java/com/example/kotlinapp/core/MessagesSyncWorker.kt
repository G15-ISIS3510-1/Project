package com.example.kotlinapp.core

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.kotlinapp.App
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.local.MessagesLocalRepository
import com.example.kotlinapp.data.remote.dto.MessageCreate

/**
 * Worker para sincronización de mensajes offline con el servidor.
 * Sincroniza mensajes creados offline cuando vuelve la conexión.
 */
class MessagesSyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    private val localRepository = MessagesLocalRepository(context)
    
    override suspend fun doWork(): Result {
        return try {
            // Obtener mensajes que necesitan sincronización
            val messagesToSync = localRepository.getMessagesNeedingSync()
            
            if (messagesToSync.isEmpty()) {
                return Result.success()
            }
            
            var successCount = 0
            var failureCount = 0
            
            for (messageEntity in messagesToSync) {
                try {
                    // Intentar enviar el mensaje al servidor
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
                        
                        // Actualizar el mensaje local con el ID del servidor y marcarlo como sincronizado
                        localRepository.saveMessage(serverMessage)
                        
                        // Eliminar el mensaje temporal offline
                        localRepository.messageDao.deleteMessage(messageEntity.messageId)
                        
                        successCount++
                    } else {
                        failureCount++
                    }
                } catch (e: Exception) {
                    // Si hay error de red, el mensaje se quedará marcado para sincronizar
                    failureCount++
                }
            }
            
            // Actualizar timestamp de última sincronización
            localRepository.updateLastSyncTimestamp()
            
            // Si hubo algunos éxitos, retornar éxito parcial
            if (successCount > 0) {
                Result.success()
            } else if (failureCount == messagesToSync.size) {
                // Si todos fallaron, reintentar
                Result.retry()
            } else {
                Result.success()
            }
        } catch (e: Exception) {
            Result.retry()
        }
    }
    
    companion object {
        const val WORK_NAME = "MessagesSyncWorker"
    }
}

