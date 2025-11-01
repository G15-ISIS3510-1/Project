package com.example.kotlinapp.data.repository

import android.content.Context
import com.example.kotlinapp.App
import com.example.kotlinapp.data.api.ApiClient
import com.example.kotlinapp.data.local.ConversationEntity
import com.example.kotlinapp.data.local.MessageEntity
import com.example.kotlinapp.data.local.MessagesLocalRepository
import com.example.kotlinapp.data.local.MessagesFileStorage
import com.example.kotlinapp.data.remote.dto.MessageCreate
import com.example.kotlinapp.data.remote.dto.MessageResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

/**
 * Repositorio híbrido que combina almacenamiento local (offline) y remoto (API).
 * Prioriza datos locales para soporte offline y sincroniza con el servidor.
 */
class MessagesRepository(
    private val context: Context,
    val localRepository: MessagesLocalRepository = MessagesLocalRepository(context),
    private val fileStorage: MessagesFileStorage = MessagesFileStorage(context)
) {
    
    private val preferencesManager = App.getPreferencesManager()
    private val currentUserId: String?
        get() = preferencesManager.getUserInfo()?.userId
    
    // ==================== CONVERSATIONS ====================
    
    /**
     * Obtiene conversaciones con sincronización automática.
     * Primero muestra datos locales (offline), luego sincroniza con API.
     */
    fun getConversations(): Flow<List<ConversationEntity>> {
        val userId = currentUserId
        if (userId == null) {
            println("DEBUG Repository: No userId found, returning empty flow")
            return flow { emit(emptyList()) }
        }
        
        println("DEBUG Repository: Getting conversations for userId: $userId")
        
        // Siempre retornar el Flow de datos locales (incluso si está vacío)
        // Esto asegura que se muestren datos offline si están disponibles
        return localRepository.getAllConversationsFlow(userId)
            .map { conversations ->
                println("DEBUG Repository: Flow emitted ${conversations.size} conversations")
                conversations
            }
            .catch { e ->
                // Si hay error leyendo local, emitir lista vacía (pero no fallar)
                println("ERROR Repository: Error reading local conversations: ${e.message}")
                e.printStackTrace()
                emit(emptyList())
            }
    }
    
    /**
     * Sincroniza conversaciones desde la API y guarda localmente.
     */
    suspend fun syncConversations() {
        try {
            val response = ApiClient.conversationsApi.listMyConversations(skip = 0, limit = 100)
            if (response.isSuccessful) {
                val conversations = response.body()?.items ?: emptyList()
                localRepository.saveConversations(conversations)
                localRepository.updateLastSyncTimestamp()
            }
        } catch (e: Exception) {
            // Si falla la sincronización, los datos locales se mantienen
            e.printStackTrace()
        }
    }
    
    /**
     * Busca conversaciones (local primero, luego remoto si es necesario)
     */
    fun searchConversations(query: String): Flow<List<ConversationEntity>> {
        val userId = currentUserId ?: return flow { emit(emptyList()) }
        return localRepository.searchConversations(userId, query)
    }
    
    // ==================== MESSAGES ====================
    
    /**
     * Obtiene mensajes de una conversación (local primero, luego sincroniza)
     */
    fun getMessagesByConversation(conversationId: String): Flow<List<MessageEntity>> {
        return localRepository.getMessagesByConversation(conversationId)
    }
    
    /**
     * Obtiene mensajes de un thread entre dos usuarios
     */
    fun getThreadMessages(otherUserId: String): Flow<List<MessageEntity>> {
        val userId = currentUserId ?: return flow { emit(emptyList()) }
        return localRepository.getThreadMessages(userId, otherUserId)
    }
    
    /**
     * Sincroniza mensajes de un thread desde la API
     */
    suspend fun syncThreadMessages(otherUserId: String) {
        try {
            val response = ApiClient.messagesApi.getThreadWithUser(
                otherUserId = otherUserId,
                skip = 0,
                limit = 100,
                markAsRead = false,
                onlyUnread = false
            )
            
            if (response.isSuccessful) {
                val messages = response.body()?.items ?: emptyList()
                localRepository.saveMessages(messages)
                
                // Actualizar último mensaje de la conversación
                val lastMessage = messages.lastOrNull()
                lastMessage?.let {
                    val conversationId = it.conversationId
                    if (conversationId != null) {
                        val lastMessageEntity = localRepository.messageDao.getLastMessage(conversationId)
                        val lastMessageTimestamp = lastMessageEntity?.createdAt ?: parseDateTime(it.createdAt)
                        localRepository.updateConversationLastMessage(
                            conversationId,
                            lastMessageTimestamp
                        )
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    /**
     * Envía un mensaje (offline-first: guarda localmente, luego sincroniza)
     */
    suspend fun sendMessage(
        receiverId: String,
        content: String,
        conversationId: String?
    ): Result<String> {
        val userId = currentUserId
        if (userId == null) {
            return Result.failure(Exception("Usuario no autenticado"))
        }
        
        // Guardar mensaje offline primero (siempre se guarda localmente)
        val offlineMessageId = localRepository.saveMessageOffline(
            conversationId = conversationId,
            senderId = userId,
            receiverId = receiverId,
            content = content
        )
        
        // Si hay conversationId, actualizar el último mensaje de la conversación inmediatamente
        conversationId?.let {
            localRepository.updateConversationLastMessage(
                it,
                System.currentTimeMillis()
            )
        }
        
        // Intentar enviar al servidor (si falla, el mensaje queda offline)
        return try {
            val response = ApiClient.messagesApi.sendMessage(
                MessageCreate(
                    receiverId = receiverId,
                    content = content,
                    conversationId = conversationId,
                    meta = null
                )
            )
            
            if (response.isSuccessful && response.body() != null) {
                val serverMessage = response.body()!!
                
                // Reemplazar mensaje offline con el del servidor
                localRepository.saveMessage(serverMessage)
                localRepository.messageDao.deleteMessage(offlineMessageId)
                
                // Actualizar conversación
                conversationId?.let {
                    localRepository.updateConversationLastMessage(
                        it,
                        parseDateTime(serverMessage.createdAt)
                    )
                }
                
                Result.success(serverMessage.messageId)
            } else {
                // El mensaje queda marcado para sincronizar
                Result.success(offlineMessageId)
            }
        } catch (e: Exception) {
            // Si hay error de red, el mensaje queda offline para sincronizar después
            Result.success(offlineMessageId)
        }
    }
    
    /**
     * Marca un mensaje como leído (local y remoto)
     */
    suspend fun markMessageAsRead(messageId: String) {
        // Actualizar local primero
        localRepository.markMessageAsRead(messageId)
        
        // Intentar actualizar en servidor
        try {
            ApiClient.messagesApi.markMessageAsRead(messageId)
        } catch (e: Exception) {
            // Si falla, el mensaje local ya está marcado como leído
        }
    }
    
    /**
     * Obtiene conteo de mensajes no leídos
     */
    suspend fun getUnreadCount(): Int {
        val userId = currentUserId ?: return 0
        return localRepository.getUnreadCount(userId)
    }
    
    // ==================== SYNC & CLEANUP ====================
    
    /**
     * Sincroniza todos los mensajes pendientes offline
     */
    suspend fun syncPendingMessages() {
        val messagesToSync = localRepository.getMessagesNeedingSync()
        
        for (message in messagesToSync) {
            try {
                val response = ApiClient.messagesApi.sendMessage(
                    MessageCreate(
                        receiverId = message.receiverId,
                        content = message.content,
                        conversationId = message.conversationId,
                        meta = null
                    )
                )
                
                if (response.isSuccessful && response.body() != null) {
                    val serverMessage = response.body()!!
                    localRepository.saveMessage(serverMessage)
                    localRepository.markMessageAsSynced(serverMessage.messageId)
                }
            } catch (e: Exception) {
                // Continuar con el siguiente mensaje
            }
        }
    }
    
    /**
     * Ejecuta limpieza automática
     */
    suspend fun performCleanup() {
        localRepository.performAutoCleanup()
        fileStorage.cleanupOldFiles(maxAgeDays = 7)
    }
    
    // ==================== FILE STORAGE ====================
    
    fun getFileStorage(): MessagesFileStorage = fileStorage
    
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
}

