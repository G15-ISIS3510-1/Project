package com.example.kotlinapp.ui.messages

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
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
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentMessagesBinding
import com.example.kotlinapp.ui.theme.AppTheme
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MessagesFragment : Fragment() {

    private var _binding: FragmentMessagesBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: MessagesViewModel by viewModels()
    
    // OPTIMIZACIÓN 3: Job para debounce de búsqueda
    private var searchJob: Job? = null
    
    // OPTIMIZACIÓN 1 y 2: Adapter con ViewHolder y DiffUtil
    private lateinit var conversationsAdapter: ConversationsAdapter

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
        setupRecyclerView()
        setupObservers()
        setupSearch()
        setupBottomBar()
    }
    
    /**
     * OPTIMIZACIÓN 1 y 2: Configurar RecyclerView con ViewHolder pattern y DiffUtil
     */
    private fun setupRecyclerView() {
        conversationsAdapter = ConversationsAdapter { conversation ->
            Toast.makeText(context, "Opening chat with ${conversation.otherUserName}", Toast.LENGTH_SHORT).show()
            // TODO: Navegar a la pantalla de chat individual cuando se implemente
        }
        
        binding.messagesRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = conversationsAdapter
            // OPTIMIZACIÓN: Mejorar scroll performance
            setHasFixedSize(true)
            setItemViewCacheSize(20) // Cache de 20 items para mejor scroll
        }
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
    
    /**
     * OPTIMIZACIÓN 1 y 2: Actualizar UI usando RecyclerView con DiffUtil
     * DiffUtil solo actualiza items que cambiaron, no toda la lista
     */
    private fun updateUI(state: MessagesUiState) {
        val messagesContainer = binding.messagesContainer
        val recyclerView = binding.messagesRecyclerView
        
        println("DEBUG Fragment: updateUI called - conversations: ${state.conversations.size}, loading: ${state.loading}, error: ${state.error}")
        
        when {
            state.loading && state.conversations.isEmpty() -> {
                // Mostrar indicador de carga solo si no hay datos locales
                recyclerView.visibility = View.GONE
                messagesContainer.visibility = View.VISIBLE
                messagesContainer.removeAllViews()
                
                val loadingText = TextView(requireContext()).apply {
                    text = "Loading conversations..."
                    textSize = 14f
                    setPadding(16, 16, 16, 16)
                }
                messagesContainer.addView(loadingText)
            }
            state.error != null && state.conversations.isEmpty() && !state.isOffline -> {
                // Solo mostrar error si no hay datos locales Y no está en modo offline explícito
                recyclerView.visibility = View.GONE
                messagesContainer.visibility = View.VISIBLE
                messagesContainer.removeAllViews()
                
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
                recyclerView.visibility = View.GONE
                messagesContainer.visibility = View.VISIBLE
                messagesContainer.removeAllViews()
                
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
                // OPTIMIZACIÓN 2: Mostrar RecyclerView y actualizar con DiffUtil
                messagesContainer.visibility = View.GONE
                recyclerView.visibility = View.VISIBLE
                
                // OPTIMIZACIÓN 2: DiffUtil actualiza solo items que cambiaron
                conversationsAdapter.submitList(state.conversations) {
                    // Callback opcional después de que se complete la actualización
                    println("DEBUG: List updated via DiffUtil")
                }
            }
        }
    }

    /**
     * OPTIMIZACIÓN 3: Debounce en búsqueda para evitar múltiples llamadas mientras el usuario escribe
     */
    private fun setupSearch() {
        // Búsqueda al presionar Enter
        binding.searchEditText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == android.view.inputmethod.EditorInfo.IME_ACTION_SEARCH) {
                searchJob?.cancel()
                val query = binding.searchEditText.text.toString()
                viewModel.onSearchQueryChange(query)
                true
            } else {
                false
            }
        }
        
        // OPTIMIZACIÓN 3: Debounce en cambios de texto (400ms)
        binding.searchEditText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                // Cancelar búsqueda anterior
                searchJob?.cancel()
                
                // OPTIMIZACIÓN 3: Esperar 400ms antes de buscar (debounce)
                searchJob = viewLifecycleOwner.lifecycleScope.launch {
                    delay(400)
                    val query = s?.toString() ?: ""
                    viewModel.onSearchQueryChange(query)
                }
            }
            
            override fun afterTextChanged(s: Editable?) {}
        })
        
        // También actualizar cuando pierde el foco (sin debounce, inmediato)
        binding.searchEditText.setOnFocusChangeListener { _, hasFocus ->
            if (!hasFocus) {
                searchJob?.cancel()
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
        // OPTIMIZACIÓN 3: Cancelar job de búsqueda al destruir la vista
        searchJob?.cancel()
        _binding = null
    }
}
