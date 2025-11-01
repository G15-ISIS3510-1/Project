package com.example.kotlinapp.data.api

import com.example.kotlinapp.data.remote.dto.MessageCreate
import com.example.kotlinapp.data.remote.dto.MessageResponse
import com.example.kotlinapp.data.remote.dto.MessageUpdate
import com.example.kotlinapp.data.remote.dto.PaginatedMessageResponse
import com.example.kotlinapp.data.remote.dto.UnreadCountResponse
import retrofit2.Response
import retrofit2.http.*

interface MessagesApiService {
    
    @GET("api/messages/")
    suspend fun listMyMessages(
        @Query("skip") skip: Int = 0,
        @Query("limit") limit: Int = 100,
        @Query("other_user_id") otherUserId: String? = null,
        @Query("only_unread") onlyUnread: Boolean = false
    ): Response<PaginatedMessageResponse>
    
    @GET("api/messages/thread/{other_user_id}")
    suspend fun getThreadWithUser(
        @Path("other_user_id") otherUserId: String,
        @Query("skip") skip: Int = 0,
        @Query("limit") limit: Int = 100,
        @Query("mark_as_read") markAsRead: Boolean = false,
        @Query("only_unread") onlyUnread: Boolean = false
    ): Response<PaginatedMessageResponse>
    
    @GET("api/messages/unread/count")
    suspend fun getUnreadCount(): Response<UnreadCountResponse>
    
    @GET("api/messages/{message_id}")
    suspend fun getMessage(
        @Path("message_id") messageId: String
    ): Response<MessageResponse>
    
    @POST("api/messages/")
    suspend fun sendMessage(
        @Body payload: MessageCreate
    ): Response<MessageResponse>
    
    @PUT("api/messages/{message_id}")
    suspend fun updateMessage(
        @Path("message_id") messageId: String,
        @Body payload: MessageUpdate
    ): Response<MessageResponse>
    
    @DELETE("api/messages/{message_id}")
    suspend fun deleteMessage(
        @Path("message_id") messageId: String
    ): Response<Map<String, String>>
    
    @POST("api/messages/{message_id}/read")
    suspend fun markMessageAsRead(
        @Path("message_id") messageId: String
    ): Response<Map<String, String>>
    
    @POST("api/messages/thread/{other_user_id}/read")
    suspend fun markThreadAsRead(
        @Path("other_user_id") otherUserId: String
    ): Response<Map<String, Int>>
}

