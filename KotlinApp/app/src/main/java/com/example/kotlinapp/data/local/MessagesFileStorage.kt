package com.example.kotlinapp.data.local

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

/**
 * Capa 3: Almacenamiento de archivos temporales (Internal Storage)
 * Gestiona archivos temporales relacionados con mensajes:
 * - Imágenes adjuntas
 * - Archivos de audio
 * - Archivos de documentos
 */
class MessagesFileStorage(private val context: Context) {
    
    private val internalDir: File by lazy {
        File(context.filesDir, "messages_attachments").apply {
            if (!exists()) mkdirs()
        }
    }
    
    private val tempDir: File by lazy {
        File(context.cacheDir, "messages_temp").apply {
            if (!exists()) mkdirs()
        }
    }
    
    // ==================== IMAGE STORAGE ====================
    
    /**
     * Guarda una imagen como archivo temporal para un mensaje
     * @return Ruta del archivo guardado
     */
    suspend fun saveImage(bitmap: Bitmap, messageId: String): String = withContext(Dispatchers.IO) {
        val filename = "image_${messageId}_${System.currentTimeMillis()}.jpg"
        val file = File(tempDir, filename)
        
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
        }
        
        file.absolutePath
    }
    
    /**
     * Carga una imagen guardada
     */
    suspend fun loadImage(filePath: String): Bitmap? = withContext(Dispatchers.IO) {
        try {
            BitmapFactory.decodeFile(filePath)
        } catch (e: Exception) {
            null
        }
    }
    
    /**
     * Guarda bytes de imagen
     */
    suspend fun saveImageBytes(bytes: ByteArray, messageId: String): String = withContext(Dispatchers.IO) {
        val filename = "image_${messageId}_${System.currentTimeMillis()}.jpg"
        val file = File(tempDir, filename)
        
        FileOutputStream(file).use { out ->
            out.write(bytes)
        }
        
        file.absolutePath
    }
    
    // ==================== FILE STORAGE ====================
    
    /**
     * Guarda un archivo temporal
     * @return Ruta del archivo guardado
     */
    suspend fun saveFile(bytes: ByteArray, messageId: String, extension: String): String = withContext(Dispatchers.IO) {
        val filename = "file_${messageId}_${System.currentTimeMillis()}.$extension"
        val file = File(tempDir, filename)
        
        FileOutputStream(file).use { out ->
            out.write(bytes)
        }
        
        file.absolutePath
    }
    
    /**
     * Lee un archivo guardado
     */
    suspend fun readFile(filePath: String): ByteArray? = withContext(Dispatchers.IO) {
        try {
            File(filePath).readBytes()
        } catch (e: Exception) {
            null
        }
    }
    
    /**
     * Verifica si un archivo existe
     */
    fun fileExists(filePath: String): Boolean {
        return File(filePath).exists()
    }
    
    /**
     * Obtiene el tamaño de un archivo
     */
    fun getFileSize(filePath: String): Long {
        return File(filePath).length()
    }
    
    // ==================== CLEANUP ====================
    
    /**
     * Limpia archivos temporales antiguos (más de X días)
     */
    suspend fun cleanupOldFiles(maxAgeDays: Int = 7) = withContext(Dispatchers.IO) {
        val cutoffTime = System.currentTimeMillis() - (maxAgeDays * 24 * 60 * 60 * 1000L)
        
        // Limpiar archivos temporales
        tempDir.listFiles()?.forEach { file ->
            if (file.lastModified() < cutoffTime) {
                try {
                    file.delete()
                } catch (e: Exception) {
                    // Ignorar errores de eliminación
                }
            }
        }
        
        // Limpiar directorio de attachments antiguos
        internalDir.listFiles()?.forEach { file ->
            if (file.lastModified() < cutoffTime) {
                try {
                    file.delete()
                } catch (e: Exception) {
                    // Ignorar errores de eliminación
                }
            }
        }
    }
    
    /**
     * Limpia archivos relacionados con mensajes eliminados
     */
    suspend fun cleanupFilesForDeletedMessages(deletedMessageIds: List<String>) = withContext(Dispatchers.IO) {
        deletedMessageIds.forEach { messageId ->
            // Buscar y eliminar archivos relacionados
            tempDir.listFiles()?.forEach { file ->
                if (file.name.contains(messageId)) {
                    try {
                        file.delete()
                    } catch (e: Exception) {
                        // Ignorar errores
                    }
                }
            }
            
            internalDir.listFiles()?.forEach { file ->
                if (file.name.contains(messageId)) {
                    try {
                        file.delete()
                    } catch (e: Exception) {
                        // Ignorar errores
                    }
                }
            }
        }
    }
    
    /**
     * Limpia todos los archivos temporales
     */
    suspend fun cleanupAllTempFiles() = withContext(Dispatchers.IO) {
        try {
            tempDir.deleteRecursively()
            tempDir.mkdirs()
        } catch (e: Exception) {
            // Ignorar errores
        }
    }
    
    /**
     * Obtiene el tamaño total de archivos temporales
     */
    suspend fun getTotalTempFilesSize(): Long = withContext(Dispatchers.IO) {
        var totalSize = 0L
        
        tempDir.listFiles()?.forEach { file ->
            if (file.isFile) {
                totalSize += file.length()
            }
        }
        
        internalDir.listFiles()?.forEach { file ->
            if (file.isFile) {
                totalSize += file.length()
            }
        }
        
        totalSize
    }
}

