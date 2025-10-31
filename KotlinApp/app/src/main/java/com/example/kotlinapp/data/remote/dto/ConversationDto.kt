package com.example.kotlinapp.data.remote.dto

import com.google.gson.annotations.SerializedName

data class ConversationResponse(
    @SerializedName("conversation_id")
    val conversationId: String,
    
    @SerializedName("user_low_id")
    val userLowId: String,
    
    @SerializedName("user_high_id")
    val userHighId: String,
    
    @SerializedName("title")
    val title: String?,
    
    @SerializedName("created_at")
    val createdAt: String,
    
    @SerializedName("last_message_at")
    val lastMessageAt: String?
)

data class PaginatedConversationResponse(
    @SerializedName("items")
    val items: List<ConversationResponse>,
    
    @SerializedName("total")
    val total: Int,
    
    @SerializedName("skip")
    val skip: Int,
    
    @SerializedName("limit")
    val limit: Int
)

data class ConversationCreateDirect(
    @SerializedName("other_user_id")
    val otherUserId: String
)

data class ConversationUpdate(
    @SerializedName("title")
    val title: String?
)

