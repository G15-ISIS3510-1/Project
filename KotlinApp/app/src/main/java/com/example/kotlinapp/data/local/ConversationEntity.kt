package com.example.kotlinapp.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Index

@Entity(
    tableName = "conversations",
    indices = [
        Index(value = ["userLowId", "userHighId"], unique = true),
        Index(value = ["lastMessageAt"])
    ]
)
data class ConversationEntity(
    @PrimaryKey
    val conversationId: String,
    val userLowId: String,
    val userHighId: String,
    val title: String? = null,
    val createdAt: Long,
    val lastMessageAt: Long? = null,
    val syncedAt: Long = System.currentTimeMillis(),
    val isDeleted: Boolean = false
)

