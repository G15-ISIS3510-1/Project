package com.example.kotlinapp.ui.home

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.compose.ui.platform.ComposeView
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentHomeBinding
import com.example.kotlinapp.ui.theme.AppTheme
import com.example.kotlinapp.ui.toprated.TopRatedVehiclesActivity
import com.example.kotlinapp.ui.navigation.BottomTab

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupCompose()
    }

    private fun setupCompose() {
        val composeView: ComposeView = view?.findViewById(R.id.homeCompose) ?: return
        composeView.setContent {
            AppTheme {
                HomeScreen(
                    onCardClick = { /* TODO: navigate to detail */ },
                    onTopRatedClick = {
                        val intent = Intent(requireContext(), TopRatedVehiclesActivity::class.java)
                        startActivity(intent)
                    },
                    onBottomClick = { tab -> navigateToTab(tab) }
                )
            }
        }
    }

    private fun navigateToTab(tab: BottomTab) {
        val navController = findNavController()
        val currentDestination = navController.currentDestination?.id

        when (tab) {
            BottomTab.Home -> {  }
            BottomTab.Trip -> {
                if (currentDestination != R.id.tripFragment) {
                    navController.navigate(R.id.tripFragment)
                }
            }
            BottomTab.Messages -> {
                if (currentDestination != R.id.messagesFragment) {
                    navController.navigate(R.id.messagesFragment)
                }
            }
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
