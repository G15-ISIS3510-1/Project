package com.example.kotlinapp.ui.account

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.compose.ui.platform.ComposeView
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentAccountBinding
import com.example.kotlinapp.ui.navigation.BottomTab
import com.example.kotlinapp.ui.navigation.PillBottomNavBar
import com.example.kotlinapp.ui.theme.AppTheme
import com.example.kotlinapp.ui.addCar.AddCar

class AccountFragment : Fragment() {

    private var _binding: FragmentAccountBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAccountBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupClicks()
        setupBottomBar()
    }

    private fun setupClicks() {
        binding.btnAddCar.setOnClickListener {
            Toast.makeText(requireContext(), "Add Car clicked", Toast.LENGTH_SHORT).show()
            // TODO: Implement add car functionality
            findNavController().navigate(R.id.addCarFragment)

        }

        binding.btnVisitedPlaces.setOnClickListener {
            findNavController().navigate(R.id.action_account_to_visitedPlaces)
        }

        binding.btnCommunications.setOnClickListener {
            Toast.makeText(requireContext(), "Communications clicked", Toast.LENGTH_SHORT).show()
            // TODO: Implement communications
        }

        binding.btnPayment.setOnClickListener {
            findNavController().navigate(R.id.action_account_to_payment)
        }

        binding.btnSwitchAccount.setOnClickListener {
            Toast.makeText(requireContext(), "Switch Account clicked", Toast.LENGTH_SHORT).show()
            // TODO: Implement account switch
        }

        binding.btnSignOut.setOnClickListener {
            Toast.makeText(requireContext(), "Sign Out clicked", Toast.LENGTH_SHORT).show()
            // TODO: Navigate to login and clear session
            findNavController().navigate(R.id.loginFragment)
        }

        binding.btnGoBack.setOnClickListener {
            findNavController().popBackStack()
        }
    }

    private fun setupBottomBar() {
        val composeView: ComposeView = binding.bottomBarCompose
        composeView.setContent {
            AppTheme {
                PillBottomNavBar(selectedTab = BottomTab.Account) { tab ->
                when (tab) {
                    BottomTab.Home -> {
                        val navController = findNavController()
                        if (navController.currentDestination?.id != R.id.homeFragment) {
                            navController.navigate(R.id.homeFragment)
                        }
                    }
                    BottomTab.Trip -> {
                        Toast.makeText(requireContext(), "Trip", Toast.LENGTH_SHORT).show()
                        // TODO: Navigate to TripFragment if created
                    }
                    BottomTab.Messages -> {
                        val navController = findNavController()
                        if (navController.currentDestination?.id != R.id.messagesFragment) {
                            navController.navigate(R.id.messagesFragment)
                        }
                    }
                    BottomTab.Host -> {
                        val navController = findNavController()
                        if (navController.currentDestination?.id != R.id.hostFragment) {
                            navController.navigate(R.id.hostFragment)
                        }
                    }
                    BottomTab.Account -> {
                        val navController = findNavController()
                        if (navController.currentDestination?.id != R.id.accountFragment) {
                            navController.navigate(R.id.accountFragment)
                        }
                    }
                }
            }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}