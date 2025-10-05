package com.example.kotlinapp.ui.trips


import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.theme.AppTheme

class TripFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                AppTheme(darkTheme = true) {
                    TripScreen(
                        onBottomClick = { tab -> navigateToTab(tab) }
                    )
                }
            }
        }
    }

    private fun navigateToTab(tab: BottomTab) {
        val navController = findNavController()
        when (tab) {
            BottomTab.Home -> navController.navigate(R.id.homeFragment)
            BottomTab.Trip -> { }
            BottomTab.Messages -> navController.navigate(R.id.messagesFragment)
            BottomTab.Host -> navController.navigate(R.id.hostFragment)
            BottomTab.Account -> navController.navigate(R.id.accountFragment)
        }
    }
}