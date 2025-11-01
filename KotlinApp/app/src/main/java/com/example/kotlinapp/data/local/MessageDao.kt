package com.example.kotlinapp.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface MessageDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessage(message: MessageEntity)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessages(messages: List<MessageEntity>)
    
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId AND isDeleted = 0 ORDER BY createdAt ASC")
    fun getMessagesByConversation(conversationId: String): Flow<List<MessageEntity>>
    
    @Query("SELECT * FROM messages WHERE senderId = :userId OR receiverId = :userId AND isDeleted = 0 ORDER BY createdAt DESC LIMIT :limit")
    suspend fun getRecentMessages(userId: String, limit: Int = 50): List<MessageEntity>
    
    @Query("SELECT * FROM messages WHERE (senderId = :userId1 AND receiverId = :userId2) OR (senderId = :userId2 AND receiverId = :userId1) AND isDeleted = 0 ORDER BY createdAt ASC")
    fun getThreadMessages(userId1: String, userId2: String): Flow<List<MessageEntity>>
    
    @Query("SELECT * FROM messages WHERE messageId = :messageId AND isDeleted = 0")
    suspend fun getMessageById(messageId: String): MessageEntity?
    
    @Query("SELECT * FROM messages WHERE receiverId = :userId AND isRead = 0 AND isDeleted = 0")
    suspend fun getUnreadMessages(userId: String): List<MessageEntity>
    
    @Query("SELECT COUNT(*) FROM messages WHERE receiverId = :userId AND isRead = 0 AND isDeleted = 0")
    suspend fun getUnreadCount(userId: String): Int
    
    @Query("SELECT * FROM messages WHERE receiverId = :userId AND isRead = 0 AND isDeleted = 0 ORDER BY createdAt DESC")
    fun getUnreadMessagesFlow(userId: String): Flow<List<MessageEntity>>
    
    @Update
    suspend fun updateMessage(message: MessageEntity)
    
    @Query("UPDATE messages SET isRead = 1, readAt = :readAt WHERE messageId = :messageId")
    suspend fun markAsRead(messageId: String, readAt: Long)
    
    @Query("UPDATE messages SET isRead = 1, readAt = :readAt WHERE receiverId = :receiverId AND senderId = :senderId AND isRead = 0")
    suspend fun markThreadAsRead(receiverId: String, senderId: String, readAt: Long)
    
    @Query("DELETE FROM messages WHERE messageId = :messageId")
    suspend fun deleteMessage(messageId: String)
    
    @Query("UPDATE messages SET isDeleted = 1 WHERE messageId = :messageId")
    suspend fun markAsDeleted(messageId: String)
    
    // Obtener el último mensaje de una conversación
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId AND isDeleted = 0 ORDER BY createdAt DESC LIMIT 1")
    suspend fun getLastMessage(conversationId: String): MessageEntity?
    
    // Obtener mensajes que necesitan sincronización
    @Query("SELECT * FROM messages WHERE needsSync = 1 AND isDeleted = 0")
    suspend fun getMessagesNeedingSync(): List<MessageEntity>
    
    @Query("SELECT * FROM messages WHERE needsSync = 1 AND isDeleted = 0")
    fun getMessagesNeedingSyncFlow(): Flow<List<MessageEntity>>
    
    // Limpieza automática: eliminar mensajes antiguos (más de X días)
    @Query("DELETE FROM messages WHERE createdAt < :cutoffTimestamp AND isDeleted = 1")
    suspend fun cleanOldDeletedMessages(cutoffTimestamp: Long)
    
    // Limpieza automática: eliminar mensajes muy antiguos (conservar solo últimos N días)
    @Query("DELETE FROM messages WHERE createdAt < :cutoffTimestamp AND isDeleted = 0")
    suspend fun cleanOldMessages(cutoffTimestamp: Long)
}

