package com.example.kotlinapp

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.lifecycleScope
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import com.example.kotlinapp.analytics.ChatTimeTracker
import com.example.kotlinapp.analytics.TimeTrackingNavListener
import com.example.kotlinapp.core.ThemeController
import com.example.kotlinapp.data.repository.FeatureUsageRepository
import com.tencent.mmkv.MMKV

class MainActivity : AppCompatActivity() {
    private lateinit var navController: NavController
    private var timeTrackingListener: TimeTrackingNavListener? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MMKV.initialize(this)
        
        setupTheme()
        
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
    
    private fun setupTheme() {
        try {
            val themeController = ThemeController(this)
            themeController.initializeTheme()
        } catch (e: Exception) {
            //SI HAY ERROR 
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
    }


    private fun setupNavigation() {
        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        val chatTimeTracker = ChatTimeTracker(
            repository = FeatureUsageRepository(),
            scope = lifecycleScope
        )

        val messagesFragmentId = R.id.messagesFragment
        android.util.Log.d("MainActivity", "Setting up navigation tracking for messagesFragment ID: $messagesFragmentId")
        
        val listener = TimeTrackingNavListener(
            tracker = chatTimeTracker,
            trackedDestinationIds = setOf(messagesFragmentId)
        )
        timeTrackingListener = listener
        navController.addOnDestinationChangedListener(listener)
        android.util.Log.d("MainActivity", "✅ Navigation listener added successfully")
    }
    
    override fun onSupportNavigateUp(): Boolean {
        if (!::navController.isInitialized) {
            val navHostFragment = supportFragmentManager
                .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
            navController = navHostFragment.navController
        }
        return navController.navigateUp() || super.onSupportNavigateUp()
    }

    override fun onDestroy() {
        if (::navController.isInitialized) {
            timeTrackingListener?.let { listener ->
                navController.removeOnDestinationChangedListener(listener)
            }
        }
        super.onDestroy()
    }
}