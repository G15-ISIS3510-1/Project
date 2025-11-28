package com.example.kotlinapp.ui.messages

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.kotlinapp.R

/**
 * OPTIMIZACIÓN: Adapter con ViewHolder pattern y DiffUtil para actualizaciones incrementales
 * 
 * Beneficios:
 * - ViewHolder pattern: Reutiliza Views, mejor rendimiento
 * - DiffUtil: Solo actualiza items que cambiaron, no toda la lista
 * - Menos allocaciones de memoria
 */
class ConversationsAdapter(
    private val onConversationClick: (ConversationItem) -> Unit
) : ListAdapter<ConversationItem, ConversationsAdapter.ConversationViewHolder>(ConversationDiffCallback()) {

    /**
     * OPTIMIZACIÓN: ViewHolder pattern - Reutiliza Views en lugar de crear nuevos
     */
    class ConversationViewHolder(
        itemView: View,
        private val onConversationClick: (ConversationItem) -> Unit
    ) : RecyclerView.ViewHolder(itemView) {
        
        private val nameText: TextView = itemView.findViewById(R.id.conversationNameText)
        private val messageText: TextView = itemView.findViewById(R.id.conversationMessageText)
        
        private var currentConversation: ConversationItem? = null
        
        init {
            itemView.setOnClickListener {
                currentConversation?.let { conversation ->
                    onConversationClick(conversation)
                }
            }
        }
        
        /**
         * OPTIMIZACIÓN: Bind solo actualiza los TextViews, no recrea Views
         */
        fun bind(conversation: ConversationItem) {
            currentConversation = conversation
            nameText.text = conversation.otherUserName
            messageText.text = conversation.lastMessage
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ConversationViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_conversation, parent, false)
        return ConversationViewHolder(view, onConversationClick)
    }

    override fun onBindViewHolder(holder: ConversationViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    /**
     * OPTIMIZACIÓN: DiffUtil callback para actualizaciones incrementales
     * Solo actualiza items que realmente cambiaron
     */
    private class ConversationDiffCallback : DiffUtil.ItemCallback<ConversationItem>() {
        override fun areItemsTheSame(oldItem: ConversationItem, newItem: ConversationItem): Boolean {
            // Comparar por ID - si el ID es el mismo, es el mismo item
            return oldItem.conversationId == newItem.conversationId
        }

        override fun areContentsTheSame(oldItem: ConversationItem, newItem: ConversationItem): Boolean {
            // Comparar contenido - si todo es igual, no necesita actualización
            return oldItem.otherUserName == newItem.otherUserName &&
                   oldItem.lastMessage == newItem.lastMessage &&
                   oldItem.lastMessageAt == newItem.lastMessageAt
        }

        /**
         * OPTIMIZACIÓN: Payload para actualizaciones parciales
         * Si solo cambió el mensaje, solo actualizar el TextView del mensaje
         */
        override fun getChangePayload(oldItem: ConversationItem, newItem: ConversationItem): Any? {
            val payload = mutableListOf<String>()
            
            if (oldItem.otherUserName != newItem.otherUserName) {
                payload.add("name")
            }
            if (oldItem.lastMessage != newItem.lastMessage) {
                payload.add("message")
            }
            if (oldItem.lastMessageAt != newItem.lastMessageAt) {
                payload.add("timestamp")
            }
            
            return if (payload.isEmpty()) null else payload
        }
    }

    /**
     * OPTIMIZACIÓN: Actualización parcial usando payloads
     */
    override fun onBindViewHolder(
        holder: ConversationViewHolder,
        position: Int,
        payloads: MutableList<Any>
    ) {
        if (payloads.isEmpty()) {
            super.onBindViewHolder(holder, position, payloads)
        } else {
            val conversation = getItem(position)
            val payload = payloads[0] as? List<*>
            
            if (payload != null) {
                // Actualizar solo los campos que cambiaron
                if (payload.contains("name") || payload.contains("message")) {
                    holder.bind(conversation)
                }
            } else {
                super.onBindViewHolder(holder, position, payloads)
            }
        }
    }
}


