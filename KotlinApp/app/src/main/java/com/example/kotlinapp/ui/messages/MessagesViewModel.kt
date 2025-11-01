package com.example.kotlinapp.ui.messages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.App
import com.example.kotlinapp.data.local.ConversationEntity
import com.example.kotlinapp.data.local.MessageEntity
import com.example.kotlinapp.data.repository.MessagesRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

data class ConversationItem(
    val conversationId: String,
    val otherUserId: String,
    val otherUserName: String,
    val lastMessage: String,
    val lastMessageAt: Long?
)

data class MessagesUiState(
    val conversations: List<ConversationItem> = emptyList(),
    val loading: Boolean = false,
    val error: String? = null,
    val searchQuery: String = "",
    val isOffline: Boolean = false,
    val syncInProgress: Boolean = false
)

class MessagesViewModel(
    private val repository: MessagesRepository = MessagesRepository(App.getInstance().applicationContext)
) : ViewModel() {
    private val _uiState = MutableStateFlow(MessagesUiState())
    val uiState: StateFlow<MessagesUiState> = _uiState
    
    private val preferencesManager = App.getPreferencesManager()
    private val currentUserId: String?
        get() = preferencesManager.getUserInfo()?.userId

    init {
        observeConversations() // Observar datos locales primero
        loadConversations() // Intentar sincronizar en background
    }
    
    private fun observeConversations() {
        viewModelScope.launch {
            val userId = currentUserId
            if (userId == null) {
                _uiState.value = _uiState.value.copy(
                    conversations = emptyList(),
                    loading = false,
                    error = "Usuario no autenticado"
                )
                return@launch
            }
            
            repository.getConversations()
                .catch { e ->
                    // Si hay error leyendo local, no es crítico - solo mostrar offline
                    println("Error reading local conversations: ${e.message}")
                    e.printStackTrace()
                    _uiState.value = _uiState.value.copy(
                        loading = false,
                        isOffline = true,
                        error = null
                    )
                }
                .collect { conversationEntities ->
                    println("DEBUG: Received ${conversationEntities.size} conversations from local DB")
                    
                    // Convertir entidades a items de UI
                    val conversationItems = conversationEntities.mapNotNull { conv ->
                        val otherUserId = when {
                            conv.userLowId == userId -> conv.userHighId
                            conv.userHighId == userId -> conv.userLowId
                            else -> conv.userLowId
                        }
                        
                        ConversationItem(
                            conversationId = conv.conversationId,
                            otherUserId = otherUserId,
                            otherUserName = "User $otherUserId",
                            lastMessage = "Loading...",
                            lastMessageAt = conv.lastMessageAt
                        )
                    }
                    
                    println("DEBUG: Mapped ${conversationItems.size} conversation items")
                    
                    // Cargar último mensaje de cada conversación
                    val updatedItems = buildList {
                        for (item in conversationItems) {
                            val lastMessage = try {
                                repository.localRepository.getLastMessage(item.conversationId)
                            } catch (e: Exception) {
                                println("Error loading last message for ${item.conversationId}: ${e.message}")
                                null
                            }

                            if (lastMessage == null && _uiState.value.isOffline.not()) {
                                // Sin último mensaje local: intentar sincronizar el hilo en background
                                viewModelScope.launch {
                                    try {
                                        repository.syncThreadMessages(item.otherUserId)
                                    } catch (e: Exception) {
                                        // Ignorar: puede no haber red
                                    }
                                }
                            }

                            add(item.copy(
                                lastMessage = lastMessage?.content ?: "No messages yet",
                                lastMessageAt = lastMessage?.createdAt ?: item.lastMessageAt
                            ))
                        }
                    }
                    
                    println("DEBUG: Updated items with messages: ${updatedItems.size}")
                    
                    val filtered = if (_uiState.value.searchQuery.isNotEmpty()) {
                        updatedItems.filter {
                            it.otherUserName.contains(_uiState.value.searchQuery, ignoreCase = true) ||
                            it.lastMessage.contains(_uiState.value.searchQuery, ignoreCase = true)
                        }
                    } else {
                        updatedItems
                    }
                    
                    // Actualizar estado con los datos locales
                    // Siempre limpiar error cuando hay datos locales (incluso si está vacío)
                    _uiState.value = _uiState.value.copy(
                        conversations = filtered,
                        loading = false,
                        error = null // Siempre limpiar error cuando hay respuesta de datos locales
                    )
                }
        }
    }

    fun loadConversations() {
        viewModelScope.launch {
            // No cambiar loading a true aquí - los datos locales ya se están mostrando
            // Solo intentar sincronizar en background sin bloquear la UI
            try {
                repository.syncConversations()
                // Si la sincronización fue exitosa, los datos locales se actualizarán automáticamente
                _uiState.value = _uiState.value.copy(isOffline = false, error = null)
            } catch (e: Exception) {
                println("Error syncing conversations (offline mode): ${e.message}")
                // Siempre limpiar el error cuando está offline - los datos locales se mostrarán
                val currentState = _uiState.value
                _uiState.value = currentState.copy(
                    isOffline = true,
                    error = null // No mostrar error - los datos locales se mostrarán automáticamente
                )
            }
        }
    }
    
    fun syncConversations() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(syncInProgress = true)
            try {
                repository.syncConversations()
                _uiState.value = _uiState.value.copy(
                    syncInProgress = false,
                    isOffline = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    syncInProgress = false,
                    isOffline = true,
                    error = "Sync failed: ${e.message}"
                )
            }
        }
    }

    fun onSearchQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        // Filtrar conversaciones localmente basado en el query
        filterConversations(query)
    }

    private fun filterConversations(query: String) {
        // El filtrado se hace automáticamente en observeConversations
        // Solo actualizamos el query en el estado
    }

    fun retry() {
        loadConversations()
    }

    fun refresh() {
        syncConversations()
    }
    
    fun sendMessage(receiverId: String, content: String, conversationId: String?) {
        viewModelScope.launch {
            try {
                val result = repository.sendMessage(receiverId, content, conversationId)
                result.onSuccess { messageId ->
                    // Mensaje guardado (offline o online)
                    // El Flow automáticamente actualizará la UI con los datos locales
                    println("Message saved with ID: $messageId")
                    
                    // Si está offline, marcar en el estado
                    if (_uiState.value.isOffline || messageId.startsWith("offline_")) {
                        _uiState.value = _uiState.value.copy(
                            isOffline = true
                        )
                    }
                }.onFailure { e ->
                    _uiState.value = _uiState.value.copy(
                        error = "Error sending message: ${e.message}"
                    )
                }
            } catch (e: Exception) {
                // Si hay error de red, el mensaje ya está guardado offline
                _uiState.value = _uiState.value.copy(
                    isOffline = true,
                    error = "Sin conexión. Mensaje guardado localmente."
                )
            }
        }
    }
    
    fun performCleanup() {
        viewModelScope.launch {
            repository.performCleanup()
        }
    }
}

