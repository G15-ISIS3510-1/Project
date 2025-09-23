package com.example.kotlinapp

import android.os.Bundle

import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.example.kotlinapp.ui.trips.TripScreen
import androidx.activity.compose.setContent
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.navigation.fragment.NavHostFragment

import com.example.kotlinapp.ui.host.HostScreen
import androidx.activity.compose.setContent

class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        
        setContentView(R.layout.activity_main_nav)
        
        // Configuración de insets para pantalla completa
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.nav_host_fragment)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        
        setupNavigation()
    }
    
    private fun setupNavigation() {
        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        val navController = navHostFragment.navController

    }
    
    override fun onSupportNavigateUp(): Boolean {
        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        val navController = navHostFragment.navController
        return navController.navigateUp() || super.onSupportNavigateUp()
    }
}