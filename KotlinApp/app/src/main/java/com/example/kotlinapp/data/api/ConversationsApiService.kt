package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.ConversationCreateDirect
import com.example.kotlinapp.data.remote.dto.ConversationResponse
import com.example.kotlinapp.data.remote.dto.ConversationUpdate
import com.example.kotlinapp.data.remote.dto.PaginatedConversationResponse
import retrofit2.Response
import retrofit2.http.*

interface ConversationsApiService {
    
    @GET("api/conversations/")
    suspend fun listMyConversations(
        @Query("skip") skip: Int = 0,
        @Query("limit") limit: Int = 100
    ): Response<PaginatedConversationResponse>
    
    @GET("api/conversations/{conversation_id}")
    suspend fun getConversation(
        @Path("conversation_id") conversationId: String
    ): Response<ConversationResponse>
    
    @POST("api/conversations/direct")
    suspend fun ensureDirectConversation(
        @Body payload: ConversationCreateDirect
    ): Response<ConversationResponse>
    
    @PUT("api/conversations/{conversation_id}")
    suspend fun updateConversation(
        @Path("conversation_id") conversationId: String,
        @Body payload: ConversationUpdate
    ): Response<ConversationResponse>
    
    @DELETE("api/conversations/{conversation_id}")
    suspend fun deleteConversation(
        @Path("conversation_id") conversationId: String
    ): Response<Map<String, String>>
}

