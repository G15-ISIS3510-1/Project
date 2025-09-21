package com.example.kotlinapp

import android.os.Bundle


import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent

import com.example.kotlinapp.ui.home.HomeScreen
import com.example.kotlinapp.ui.host.HostScreen

import com.example.kotlinapp.ui.trips.TripScreen
import com.example.kotlinapp.ui.navigation.Screen



import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.NavGraph.Companion.findStartDestination
import com.example.kotlinapp.ui.home.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AppNav()
        }
    }


    @Composable
    private fun AppNav() {
        val nav = rememberNavController()

        NavHost(
            navController = nav,
            startDestination = Screen.Home.route
        ) {
            composable(Screen.Home.route) {
                HomeScreen(
                    onCardClick = { },
                    onBottomClick = { tab -> navigateToTab(nav, tab) }
                )
            }
            composable(Screen.Trip.route) {
                TripScreen(
                    onBottomClick = { tab -> navigateToTab(nav, tab) }
                )
            }
            composable(Screen.Host.route) {
                HostScreen(
                    onSubmitPin = { }
                )
            }
        }
    }


    private fun navigateToTab(nav: NavController, tab: BottomTab) {
        val route = when (tab) {
            BottomTab.Home     -> Screen.Home.route
            BottomTab.Trip     -> Screen.Trip.route
            BottomTab.Host     -> Screen.Host.route
            BottomTab.Messages -> null
            BottomTab.Account  -> null
        } ?: return

        nav.navigate(route) {
            popUpTo(nav.graph.findStartDestination().id) { saveState = true }
            launchSingleTop = true
            restoreState = true
        }
    }
}