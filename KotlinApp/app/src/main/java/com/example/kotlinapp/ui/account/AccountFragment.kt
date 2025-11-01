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

        binding.btnViewCar.setOnClickListener {
            Toast.makeText(requireContext(), "View active cars on map", Toast.LENGTH_SHORT).show()
            findNavController().navigate(R.id.vehicleMapFragment)
        }

        binding.btnCommunications.setOnClickListener {
            Toast.makeText(requireContext(), "Communications clicked", Toast.LENGTH_SHORT).show()
            // TODO: Implement communications
        }

        binding.btnPayment.setOnClickListener {
            findNavController().navigate(R.id.action_account_to_payment)
        }

        binding.btnPriceAnalytics.setOnClickListener {
            Toast.makeText(requireContext(), "Price Analytics clicked", Toast.LENGTH_SHORT).show()
            findNavController().navigate(R.id.priceAnalyticsFragment)
        }
        binding.btnMetrics.setOnClickListener {
                findNavController().navigate(R.id.action_account_to_metrics)
        }

            binding.btnSwitchAccount.setOnClickListener {
                Toast.makeText(requireContext(), "Switch Account clicked", Toast.LENGTH_SHORT)
                    .show()
                // TODO: Implement account switch
            }

        binding.btnSignOut.setOnClickListener {
            // Detener sincronización automática de mensajes
            com.example.kotlinapp.App.getMessagesSyncScheduler().stop()
            
            // Hacer logout
            com.example.kotlinapp.data.repository.AuthRepository().logout()
            
            Toast.makeText(requireContext(), "Sesión cerrada", Toast.LENGTH_SHORT).show()
            
            // Navegar al login
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

                BottomTab.Account -> {}
            }
        }

        override fun onDestroyView() {
            super.onDestroyView()
            _binding = null
        }
    }