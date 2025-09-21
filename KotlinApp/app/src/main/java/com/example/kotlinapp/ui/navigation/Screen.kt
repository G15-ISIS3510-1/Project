package com.example.kotlinapp.ui.navigation

sealed class Screen(val route: String) {
    object Home : Screen("home")
    object Trip : Screen("trip")
    object Host : Screen("host")

}