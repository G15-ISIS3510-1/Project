package com.example.kotlinapp.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface ConversationDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertConversation(conversation: ConversationEntity)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertConversations(conversations: List<ConversationEntity>)
    
    @Query("SELECT * FROM conversations WHERE isDeleted = 0 ORDER BY COALESCE(lastMessageAt, createdAt) DESC")
    fun getAllConversations(): Flow<List<ConversationEntity>>
    
    @Query("SELECT * FROM conversations WHERE conversationId = :conversationId AND isDeleted = 0")
    suspend fun getConversationById(conversationId: String): ConversationEntity?
    
    @Query("SELECT * FROM conversations WHERE (userLowId = :userId OR userHighId = :userId) AND isDeleted = 0 ORDER BY COALESCE(lastMessageAt, createdAt) DESC")
    fun getConversationsByUserId(userId: String): Flow<List<ConversationEntity>>
    
    @Query("SELECT * FROM conversations WHERE (userLowId = :userId OR userHighId = :userId) AND isDeleted = 0 AND (title LIKE :query OR :query = '') ORDER BY COALESCE(lastMessageAt, createdAt) DESC")
    fun searchConversations(userId: String, query: String): Flow<List<ConversationEntity>>
    
    @Update
    suspend fun updateConversation(conversation: ConversationEntity)
    
    @Query("UPDATE conversations SET lastMessageAt = :lastMessageAt WHERE conversationId = :conversationId")
    suspend fun updateLastMessageAt(conversationId: String, lastMessageAt: Long)
    
    @Query("DELETE FROM conversations WHERE conversationId = :conversationId")
    suspend fun deleteConversation(conversationId: String)
    
    @Query("UPDATE conversations SET isDeleted = 1 WHERE conversationId = :conversationId")
    suspend fun markAsDeleted(conversationId: String)
    
    // Limpieza automática: eliminar conversaciones antiguas sin mensajes
    @Query("""
        DELETE FROM conversations 
        WHERE lastMessageAt IS NULL 
        AND createdAt < :cutoffTimestamp 
        AND conversationId NOT IN (SELECT DISTINCT conversationId FROM messages WHERE conversationId IS NOT NULL)
    """)
    suspend fun cleanOldEmptyConversations(cutoffTimestamp: Long)
    
    // Obtener conversaciones que necesitan sincronización
    @Query("SELECT * FROM conversations WHERE syncedAt < :cutoffTimestamp AND isDeleted = 0")
    suspend fun getConversationsNeedingSync(cutoffTimestamp: Long): List<ConversationEntity>
}

