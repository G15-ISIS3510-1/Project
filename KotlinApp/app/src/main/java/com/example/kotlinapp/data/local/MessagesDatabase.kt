package com.example.kotlinapp.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase

@Database(
    entities = [ConversationEntity::class, MessageEntity::class],
    version = 2,
    exportSchema = true
)
abstract class MessagesDatabase : RoomDatabase() {
    abstract fun conversationDao(): ConversationDao
    abstract fun messageDao(): MessageDao
    
    companion object {
        // Migración de versión 1 a 2: Agregar índice y campos adicionales si es necesario
        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Agregar índices adicionales si es necesario
                database.execSQL("CREATE INDEX IF NOT EXISTS index_messages_synced_at ON messages(syncedAt)")
                database.execSQL("CREATE INDEX IF NOT EXISTS index_conversations_synced_at ON conversations(syncedAt)")
            }
        }
        
        // Si en el futuro necesitas más migraciones, agrega MIGRATION_2_3, etc.
    }
}

