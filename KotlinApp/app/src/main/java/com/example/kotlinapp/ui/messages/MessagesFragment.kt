package com.example.kotlinapp.ui.messages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.compose.ui.platform.ComposeView
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentMessagesBinding
import com.example.kotlinapp.ui.theme.AppTheme

class MessagesFragment : Fragment() {

    private var _binding: FragmentMessagesBinding? = null
    private val binding get() = _binding!!

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
        setupMessages()
        setupSearch()
        setupBottomBar()
    }

    private fun setupMessages() {
        val messagesContainer = binding.messagesContainer
        
        // Mensajes de ejemplo
        val sampleMessages = listOf(
            "Juan Diaz - Hey! How was your trip yesterday?",
            "Jairo Fierro - Thanks for the great experience!",
        )

        sampleMessages.forEach { messageText ->
            val messageView = createMessageView(messageText)
            messagesContainer.addView(messageView)
        }
    }

    private fun createMessageView(messageText: String): View {
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
            text = messageText.split(" - ")[0]
            textSize = 16f
            setTypeface(null, android.graphics.Typeface.BOLD)
            setTextColor(resources.getColor(android.R.color.black, null))
            setPadding(0, 0, 0, 4)
        }

        val messageTextView = TextView(requireContext()).apply {
            text = messageText.split(" - ")[1]
            textSize = 14f
            setTextColor(resources.getColor(android.R.color.darker_gray, null))
        }

        messageView.addView(nameText)
        messageView.addView(messageTextView)

        messageView.setOnClickListener {
            Toast.makeText(context, "Opening chat with ${nameText.text}", Toast.LENGTH_SHORT).show()
        }

        return messageView
    }

    private fun setupSearch() {
        binding.searchEditText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == android.view.inputmethod.EditorInfo.IME_ACTION_SEARCH) {
                val query = binding.searchEditText.text.toString()
                if (query.isNotEmpty()) {
                    Toast.makeText(context, "Searching for: $query", Toast.LENGTH_SHORT).show()
                }
                true
            } else {
                false
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
