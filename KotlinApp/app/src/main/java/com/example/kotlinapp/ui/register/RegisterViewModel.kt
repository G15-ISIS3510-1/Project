package com.example.kotlinapp.ui.register

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class RegisterViewModel : ViewModel() {
    
    private val _registerState = MutableLiveData<RegisterState>()
    val registerState: LiveData<RegisterState> = _registerState
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    fun register(name: String, email: String, password: String, confirmPassword: String) {
        // Validaciones básicas
        when {
            name.isEmpty() -> {
                _registerState.value = RegisterState.Error("Name is required")
                return
            }
            email.isEmpty() -> {
                _registerState.value = RegisterState.Error("Email is required")
                return
            }
            password.isEmpty() -> {
                _registerState.value = RegisterState.Error("Password is required")
                return
            }
            confirmPassword.isEmpty() -> {
                _registerState.value = RegisterState.Error("Please confirm your password")
                return
            }
            password != confirmPassword -> {
                _registerState.value = RegisterState.Error("Passwords do not match")
                return
            }
            password.length < 6 -> {
                _registerState.value = RegisterState.Error("Password must be at least 6 characters")
                return
            }
        }
        
        _isLoading.value = true
        
        viewModelScope.launch {
            try {
                // Simular llamada a API de registro
                delay(2000)
                
                // Simulación de registro exitoso
                _registerState.value = RegisterState.Success("Account created successfully! Welcome $name")
            } catch (e: Exception) {
                _registerState.value = RegisterState.Error("Registration failed: ${e.message}")
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun clearState() {
        _registerState.value = null
    }
}

sealed class RegisterState {
    data class Success(val message: String) : RegisterState()
    data class Error(val message: String) : RegisterState()
}
