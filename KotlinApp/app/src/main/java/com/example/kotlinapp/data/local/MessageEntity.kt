package com.example.kotlinapp.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Index
import androidx.room.ForeignKey
import androidx.room.ColumnInfo

@Entity(
    tableName = "messages",
    foreignKeys = [
        ForeignKey(
            entity = ConversationEntity::class,
            parentColumns = ["conversationId"],
            childColumns = ["conversationId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index(value = ["conversationId"]),
        Index(value = ["senderId", "receiverId"]),
        Index(value = ["createdAt"]),
        Index(value = ["isRead"]),
        Index(value = ["syncedAt"])
    ]
)
data class MessageEntity(
    @PrimaryKey
    val messageId: String,
    @ColumnInfo(name = "conversationId")
    val conversationId: String? = null,
    val senderId: String,
    val receiverId: String,
    val content: String,
    val createdAt: Long,
    val readAt: Long? = null,
    val isRead: Boolean = false,
    val syncedAt: Long = System.currentTimeMillis(),
    val isDeleted: Boolean = false,
    val needsSync: Boolean = false // Para mensajes creados offline
)

