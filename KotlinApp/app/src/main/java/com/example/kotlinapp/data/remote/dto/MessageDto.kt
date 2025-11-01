package com.example.kotlinapp.data.remote.dto

import com.google.gson.annotations.SerializedName

data class MessageResponse(
    @SerializedName("message_id")
    val messageId: String,
    
    @SerializedName("sender_id")
    val senderId: String,
    
    @SerializedName("receiver_id")
    val receiverId: String,
    
    @SerializedName("content")
    val content: String,
    
    @SerializedName("conversation_id")
    val conversationId: String?,
    
    @SerializedName("created_at")
    val createdAt: String,
    
    @SerializedName("read_at")
    val readAt: String?,
    
    @SerializedName("meta")
    val meta: Map<String, Any>?
)

data class PaginatedMessageResponse(
    @SerializedName("items")
    val items: List<MessageResponse>,
    
    @SerializedName("total")
    val total: Int,
    
    @SerializedName("skip")
    val skip: Int,
    
    @SerializedName("limit")
    val limit: Int
)

data class MessageCreate(
    @SerializedName("receiver_id")
    val receiverId: String,
    
    @SerializedName("content")
    val content: String,
    
    @SerializedName("conversation_id")
    val conversationId: String? = null,
    
    @SerializedName("meta")
    val meta: Map<String, Any>? = null
)

data class MessageUpdate(
    @SerializedName("content")
    val content: String
)

data class UnreadCountResponse(
    @SerializedName("unread")
    val unread: Int
)

