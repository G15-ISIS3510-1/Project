package com.example.kotlinapp.ui.addCar

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import com.example.kotlinapp.data.remote.Session
import com.example.kotlinapp.data.remote.api.RetrofitClient
import com.example.kotlinapp.data.remote.dto.LoginRequest

class AddCarFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setContent {
                LaunchedEffect(Unit) {
                    // Solo para pruebas. Reemplaza por tus credenciales reales de un usuario existente
                    try {
                        val tok = RetrofitClient.api.login(
                            LoginRequest(
                                email = "user@example.com",
                                password = "123456"   // la que tengas en tu backend
                            )
                        )
                        Session.token = tok.access_token
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
                MaterialTheme { AddCar() }
            }
        }
    }
}