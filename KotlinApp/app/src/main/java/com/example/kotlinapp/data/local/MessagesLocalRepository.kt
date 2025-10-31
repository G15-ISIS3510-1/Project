package com.example.kotlinapp.data.local

import android.content.Context
import com.example.kotlinapp.core.MessagesDatabaseModule
import com.example.kotlinapp.data.remote.dto.ConversationResponse
import com.example.kotlinapp.data.remote.dto.MessageResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/**
 * Repositorio local para gestionar el almacenamiento offline de mensajes y conversaciones.
 * Implementa las 3 capas de almacenamiento:
 * - DataStore: Configuración
 * - Room: Datos persistentes
 * - Internal Storage: Archivos temporales (manejo de attachments)
 */
class MessagesLocalRepository(private val context: Context) {
    
    private val database = MessagesDatabaseModule.getDatabase(context)
    val conversationDao = database.conversationDao()
    val messageDao = database.messageDao()
    private val dataStore = MessagesDataStore(context)
    
    // ==================== CONVERSATIONS ====================
    
    suspend fun saveConversations(conversations: List<ConversationResponse>) {
        val entities = conversations.map { it.toEntity() }
        conversationDao.insertConversations(entities)
    }
    
    suspend fun saveConversation(conversation: ConversationResponse) {
        conversationDao.insertConversation(conversation.toEntity())
    }
    
    fun getAllConversationsFlow(userId: String): Flow<List<ConversationEntity>> {
        println("DEBUG LocalRepository: Getting conversations flow for userId: $userId")
        return conversationDao.getConversationsByUserId(userId)
    }
    
    suspend fun getConversationById(conversationId: String): ConversationEntity? {
        return conversationDao.getConversationById(conversationId)
    }
    
    fun searchConversations(userId: String, query: String): Flow<List<ConversationEntity>> {
        return conversationDao.searchConversations(userId, query)
    }
    
    suspend fun updateConversationLastMessage(conversationId: String, lastMessageAt: Long) {
        conversationDao.updateLastMessageAt(conversationId, lastMessageAt)
    }
    
    suspend fun deleteConversation(conversationId: String) {
        conversationDao.markAsDeleted(conversationId)
    }
    
    // ==================== MESSAGES ====================
    
    suspend fun saveMessages(messages: List<MessageResponse>) {
        val entities = messages.map { it.toEntity() }
        messageDao.insertMessages(entities)
    }
    
    suspend fun saveMessage(message: MessageResponse) {
        messageDao.insertMessage(message.toEntity())
    }
    
    suspend fun saveMessageOffline(
        conversationId: String?,
        senderId: String,
        receiverId: String,
        content: String
    ): String {
        val messageId = "offline_${System.currentTimeMillis()}_${senderId}"
        val entity = MessageEntity(
            messageId = messageId,
            conversationId = conversationId,
            senderId = senderId,
            receiverId = receiverId,
            content = content,
            createdAt = System.currentTimeMillis(),
            needsSync = true,
            isDeleted = false,
            isRead = false,
            readAt = null,
            syncedAt = 0
        )
        messageDao.insertMessage(entity)
        return messageId
    }
    
    fun getMessagesByConversation(conversationId: String): Flow<List<MessageEntity>> {
        return messageDao.getMessagesByConversation(conversationId)
    }
    
    fun getThreadMessages(userId1: String, userId2: String): Flow<List<MessageEntity>> {
        return messageDao.getThreadMessages(userId1, userId2)
    }
    
    suspend fun getLastMessage(conversationId: String): MessageEntity? {
        return messageDao.getLastMessage(conversationId)
    }
    
    suspend fun getUnreadCount(userId: String): Int {
        return messageDao.getUnreadCount(userId)
    }
    
    fun getUnreadMessagesFlow(userId: String): Flow<List<MessageEntity>> {
        return messageDao.getUnreadMessagesFlow(userId)
    }
    
    suspend fun markMessageAsRead(messageId: String) {
        messageDao.markAsRead(messageId, System.currentTimeMillis())
    }
    
    suspend fun markThreadAsRead(receiverId: String, senderId: String) {
        messageDao.markThreadAsRead(receiverId, senderId, System.currentTimeMillis())
    }
    
    suspend fun deleteMessage(messageId: String) {
        messageDao.markAsDeleted(messageId)
    }
    
    // ==================== SYNC ====================
    
    suspend fun getMessagesNeedingSync(): List<MessageEntity> {
        return messageDao.getMessagesNeedingSync()
    }
    
    fun getMessagesNeedingSyncFlow(): Flow<List<MessageEntity>> {
        return messageDao.getMessagesNeedingSyncFlow()
    }
    
    suspend fun markMessageAsSynced(messageId: String) {
        val message = messageDao.getMessageById(messageId)
        message?.let {
            messageDao.updateMessage(it.copy(needsSync = false, syncedAt = System.currentTimeMillis()))
        }
    }
    
    suspend fun getConversationsNeedingSync(): List<ConversationEntity> {
        val cutoff = System.currentTimeMillis() - (24 * 60 * 60 * 1000L) // 24 horas
        return conversationDao.getConversationsNeedingSync(cutoff)
    }
    
    // ==================== CLEANUP ====================
    
    suspend fun performAutoCleanup() {
        if (!dataStore.shouldPerformCleanup()) return
        
        val retentionCutoff = dataStore.getRetentionCutoffTimestamp()
        
        // Limpiar mensajes eliminados antiguos
        messageDao.cleanOldDeletedMessages(retentionCutoff)
        
        // Limpiar mensajes muy antiguos (más de retención)
        messageDao.cleanOldMessages(retentionCutoff)
        
        // Limpiar conversaciones vacías antiguas
        conversationDao.cleanOldEmptyConversations(retentionCutoff)
        
        // Actualizar timestamp de limpieza
        dataStore.updateLastCleanupTimestamp()
    }
    
    // ==================== DATASTORE ACCESS ====================
    
    val cacheEnabled: Flow<Boolean> = dataStore.cacheEnabled
    val autoCleanupEnabled: Flow<Boolean> = dataStore.autoCleanupEnabled
    val offlineModeEnabled: Flow<Boolean> = dataStore.offlineModeEnabled
    
    suspend fun updateLastSyncTimestamp() {
        dataStore.updateLastSyncTimestamp()
    }
    
    // ==================== EXTENSION FUNCTIONS ====================
    
    private fun ConversationResponse.toEntity(): ConversationEntity {
        return ConversationEntity(
            conversationId = conversationId,
            userLowId = userLowId,
            userHighId = userHighId,
            title = title,
            createdAt = parseDateTime(createdAt),
            lastMessageAt = lastMessageAt?.let { parseDateTime(it) },
            syncedAt = System.currentTimeMillis(),
            isDeleted = false
        )
    }
    
    private fun MessageResponse.toEntity(): MessageEntity {
        return MessageEntity(
            messageId = messageId,
            conversationId = conversationId,
            senderId = senderId,
            receiverId = receiverId,
            content = content,
            createdAt = parseDateTime(createdAt),
            readAt = readAt?.let { parseDateTime(it) },
            isRead = readAt != null,
            syncedAt = System.currentTimeMillis(),
            isDeleted = false,
            needsSync = false
        )
    }
    
    private fun parseDateTime(dateTimeString: String): Long {
        return try {
            // Formato ISO 8601: "2024-01-01T00:00:00" o "2024-01-01T00:00:00Z"
            val cleanDate = dateTimeString.replace("Z$".toRegex(), "")
            val parts = cleanDate.split("T")
            if (parts.size == 2) {
                val dateParts = parts[0].split("-")
                val timeParts = parts[1].split(":")
                val year = dateParts[0].toInt()
                val month = dateParts[1].toInt() - 1 // Calendar month is 0-based
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

