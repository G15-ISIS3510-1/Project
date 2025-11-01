package com.example.kotlinapp.core

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.kotlinapp.App
import com.example.kotlinapp.data.local.MessagesLocalRepository

/**
 * Worker para limpieza automática de mensajes antiguos.
 * Se ejecuta periódicamente para mantener la base de datos limpia.
 */
class MessagesCleanupWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            val localRepository = MessagesLocalRepository(applicationContext)
            localRepository.performAutoCleanup()
            
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
    
    companion object {
        const val WORK_NAME = "MessagesCleanupWorker"
    }
}

