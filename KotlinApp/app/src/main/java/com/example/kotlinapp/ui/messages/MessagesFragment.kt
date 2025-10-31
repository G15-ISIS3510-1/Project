package com.example.kotlinapp.ui.messages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.lifecycle.Lifecycle
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentMessagesBinding
import com.example.kotlinapp.ui.theme.AppTheme
import kotlinx.coroutines.launch

class MessagesFragment : Fragment() {

    private var _binding: FragmentMessagesBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: MessagesViewModel by viewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMessagesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupObservers()
        setupSearch()
        setupBottomBar()
    }

    private fun setupObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    println("DEBUG Fragment: UI State updated - conversations: ${state.conversations.size}, loading: ${state.loading}, error: ${state.error}, isOffline: ${state.isOffline}")
                    updateUI(state)
                }
            }
        }
    }
    
    private fun updateUI(state: MessagesUiState) {
        val messagesContainer = binding.messagesContainer
        
        println("DEBUG Fragment: updateUI called - conversations: ${state.conversations.size}, loading: ${state.loading}, error: ${state.error}")
        
        // Limpiar mensajes anteriores
        messagesContainer.removeAllViews()
        
        when {
            state.loading && state.conversations.isEmpty() -> {
                // Mostrar indicador de carga solo si no hay datos locales
                val loadingText = TextView(requireContext()).apply {
                    text = "Loading conversations..."
                    textSize = 14f
                    setPadding(16, 16, 16, 16)
                }
                messagesContainer.addView(loadingText)
            }
            state.error != null && state.conversations.isEmpty() && !state.isOffline -> {
                // Solo mostrar error si no hay datos locales Y no está en modo offline explícito
                val errorText = TextView(requireContext()).apply {
                    text = "Error: ${state.error}\nTap to retry"
                    textSize = 14f
                    setTextColor(resources.getColor(android.R.color.holo_red_dark, null))
                    setPadding(16, 16, 16, 16)
                    setOnClickListener {
                        viewModel.retry()
                    }
                }
                messagesContainer.addView(errorText)
            }
            state.conversations.isEmpty() -> {
                // Mostrar mensaje vacío
                val emptyText = TextView(requireContext()).apply {
                    text = if (state.isOffline) {
                        "Sin conexión\nLos mensajes se guardarán localmente"
                    } else {
                        "No conversations yet"
                    }
                    textSize = 14f
                    setPadding(16, 16, 16, 16)
                }
                messagesContainer.addView(emptyText)
            }
            else -> {
                // Mostrar indicador offline si está en modo offline
                if (state.isOffline && !state.syncInProgress) {
                    val offlineIndicator = TextView(requireContext()).apply {
                        text = "⚠ Modo offline - Los mensajes se guardarán localmente"
                        textSize = 12f
                        setTextColor(resources.getColor(android.R.color.holo_orange_dark, null))
                        setPadding(16, 8, 16, 8)
                        setBackgroundColor(0x30FFA500.toInt()) // Naranja semi-transparente
                    }
                    messagesContainer.addView(offlineIndicator)
                }
                
                // Mostrar conversaciones
                state.conversations.forEach { conversation ->
                    val messageView = createConversationView(conversation)
                    messagesContainer.addView(messageView)
                }
            }
        }
    }

    private fun createConversationView(conversation: ConversationItem): View {
        val messageView = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 16, 16, 16)
            setBackgroundResource(R.drawable.message_item_background)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 4, 0, 4)
            }
        }

        val nameText = TextView(requireContext()).apply {
            text = conversation.otherUserName
            textSize = 16f
            setTypeface(null, android.graphics.Typeface.BOLD)
            setTextColor(resources.getColor(android.R.color.black, null))
            setPadding(0, 0, 0, 4)
        }

        val messageTextView = TextView(requireContext()).apply {
            text = conversation.lastMessage
            textSize = 14f
            setTextColor(resources.getColor(android.R.color.darker_gray, null))
        }

        messageView.addView(nameText)
        messageView.addView(messageTextView)

        messageView.setOnClickListener {
            Toast.makeText(context, "Opening chat with ${conversation.otherUserName}", Toast.LENGTH_SHORT).show()
            // TODO: Navegar a la pantalla de chat individual cuando se implemente
        }

        return messageView
    }

    private fun setupSearch() {
        binding.searchEditText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == android.view.inputmethod.EditorInfo.IME_ACTION_SEARCH) {
                val query = binding.searchEditText.text.toString()
                viewModel.onSearchQueryChange(query)
                true
            } else {
                false
            }
        }
        
        // También actualizar cuando cambia el texto (opcional)
        binding.searchEditText.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                val query = binding.searchEditText.text.toString()
                viewModel.onSearchQueryChange(query)
            }
        }
    }

    private fun setupBottomBar() {
        val composeView: ComposeView = binding.bottomBarCompose
        composeView.setContent {
            AppTheme {
                PillBottomNavBar(selectedTab = BottomTab.Messages) { tab ->
                    navigateToTab(tab)
                }
            }
        }
    }

    private fun navigateToTab(tab: BottomTab) {
        val navController = findNavController()
        val currentDestination = navController.currentDestination?.id

        when (tab) {
            BottomTab.Home -> {
                if (currentDestination != R.id.homeFragment) {
                    navController.navigate(R.id.homeFragment)
                }
            }
            BottomTab.Trip -> {
                if (currentDestination != R.id.tripFragment) {
                    navController.navigate(R.id.tripFragment)
                }
            }
            BottomTab.Messages -> { }
            BottomTab.Host -> {
                if (currentDestination != R.id.hostFragment) {
                    navController.navigate(R.id.hostFragment)
                }
            }
            BottomTab.Account -> {
                if (currentDestination != R.id.accountFragment) {
                    navController.navigate(R.id.accountFragment)
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
